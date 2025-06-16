package com.lime.common.service;

import com.lime.common.exception.EmailSendException;
import com.lime.common.exception.InvalidEmailFormatException;
import com.lime.common.exception.VerificationCodeAlreadyExistsException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import javax.mail.internet.MimeMessage;
import java.security.SecureRandom;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
public class EmailService {

  private final JavaMailSender mailSender;
  private final RedisService redisService;

  public EmailService(JavaMailSender mailSender, RedisService redisService) {
    this.mailSender = mailSender;
    this.redisService = redisService;
  }

  private static final String VERIFICATION_PREFIX = "email:verification";
  private static final long CODE_EXPIRY_MINUTES = 5L;
  private static final String FROM_EMAIL = "dearsophiehwang@gmail.com";

  /*
  * 인증번호 생성 및 이메일 발송
  */
  public void sendVerificationCode(String email) {

    // 이메일 유효성 검증
    validateEmail(email);

    String key = VERIFICATION_PREFIX + email;

    if(redisService.exists(key)) {
      throw new VerificationCodeAlreadyExistsException(
              "이미 발송된 인증번호가 있습니다." + CODE_EXPIRY_MINUTES + "분 후 다시 시도해주세요."
      );
    }

    String code = generateCode();

    try {
      // Redis에 이메일-코드 저장 (5분 유효)
      redisService.saveData(key, code, CODE_EXPIRY_MINUTES, TimeUnit.MINUTES);

      // 이메일 발송
      sendEmail(email, code);
      log.info("인증번호 발송 완료 - 이메일: {}", email);

    } catch(EmailSendException e) {
      redisService.deleteData(key);
      throw e;

    } catch(Exception e) {
      redisService.deleteData(key);
      log.error("인증번호 발송 중 예외 발생 - 이메일: {}, 에러: {}", email, e.getMessage(), e);
      throw new EmailSendException("인증번호 발송 중 오류가 발생했습니다.", e);
    }
  }

  /*
  * 6자리 인증번호 생성
  */
  private String generateCode() {
    SecureRandom random = new SecureRandom();
    int code = 100000 + random.nextInt(900000);

    return String.valueOf(code);
  }

  /*
  * 이메일 발송
  */
  private void sendEmail(String to, String code) {
    try {
      MimeMessage message = mailSender.createMimeMessage();
      MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

      helper.setFrom(FROM_EMAIL);
      helper.setTo(to);
      helper.setSubject("[LIME] 회원가입 인증 메일 안내");
      String content = String.format(
              "<div style='margin: 20px; font-family: Arial, sans-serif;'>" +
                "<h2 style='color: #333;'>LIME 이메일 인증</h2>" +
                "<p>안녕하세요! 회원가입을 위한 인증번호를 안내드립니다.</p>" +
                "<div style='background-color: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0; text-align: center;'>" +
                "<h3 style='color: #007bff; margin: 0; font-size: 24px;'>인증번호: %s</h3>" +
                "</div>" +
                "<p><strong>인증번호는 %d분간 유효합니다.</strong></p>" +
                "<p style='color: #666; font-size: 14px;'>본인이 요청하지 않은 경우 이 메일을 무시하셔도 됩니다.</p>" +
              "</div>",
              code, CODE_EXPIRY_MINUTES
      );

      helper.setText(content, true);
      mailSender.send(message);

    } catch(Exception e) {
      log.error("이메일 발송 실패 - 수신자: {}, 에러: {}", to, e.getMessage(), e);
      throw new EmailSendException("이메일 발송에 실패했습니다.", e);
    }
  }

  /*
  * 인증번호 검증
  */
  public boolean verifyCode(String email, String inputCode) {
    // 입력값 검증
    if(email == null || email.trim().isEmpty()) {
      log.warn("인증번호 검증 실패 - 이메일이 비어있음");
      return false;
    }

    if(inputCode == null || inputCode.trim().isEmpty()) {
      log.warn("인증번호 검증 실패 - 인증번호가 비어있음");
      return false;
    }

    String key = VERIFICATION_PREFIX + email;
    String savedCode = redisService.getData(key);

    if(savedCode == null) {
      log.warn("인증번호 검증 실패 - 코드 없음 또는 만료: {}", email);
      return false;
    }

    boolean success = savedCode.equals(inputCode.trim());

    if(success) {
      redisService.deleteData(key); // 인증 성공 시 redis에서 삭제
      log.info("이메일 인증 성공 - 이메일: {}", email);
    } else {
      log.warn("인증번호 검증 실패 - 코드 불일치: {}", email);
    }

    return success;
  }

  /*
  * 이메일 유효성 서버사이드 검증
  */
  private void validateEmail(String email) {
    if(email == null || email.trim().isEmpty()) {
      throw new InvalidEmailFormatException("이메일이 입력되지 않았습니다.");
    }

    if(!email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")) {
      throw new InvalidEmailFormatException("올바른 이메일 형식이 아닙니다.");
    }
  }

  /*
  * 인증번호 재발송을 위한 기존 코드 삭제
  */
  public void clearVerificationCode(String email) {
    if(email != null && !email.trim().isEmpty()) {
      String key = VERIFICATION_PREFIX + email;
      redisService.deleteData(key);
      log.info("인증번호 삭제 완료 - 이메일: {}", email);
    }
  }

  /**
   * 인증번호 존재 여부 확인
   */
  public boolean hasVerificationCode(String email) {
    if(email == null || email.trim().isEmpty()) {
      return false;
    }

    String key = VERIFICATION_PREFIX + email;
    return redisService.exists(key);
  }
}
