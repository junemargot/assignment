package com.lime.common.service;

import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import javax.mail.internet.MimeMessage;
import java.util.Random;
import java.util.concurrent.TimeUnit;

@Service
public class EmailService {

  private final JavaMailSender mailSender;
  private final RedisService redisService;

  public EmailService(JavaMailSender mailSender, RedisService redisService) {
    this.mailSender = mailSender;
    this.redisService = redisService;
  }

  // 인증번호 생성 및 이메일 발송
  public void sendVerificationCode(String email) {
    String code = generateCode();

    // Redis에 이메일-코드 저장 (5분 유효)
    redisService.saveData(email, code, 5, TimeUnit.MINUTES);

    // 이메일 발송
    sendEmail(email, code);
  }


  // 인증번호 생성(6자리)
  private String generateCode() {
    Random random = new Random();
    int code = 100000 + random.nextInt(100000);

    return String.valueOf(code);
  }

  // 이메일 발송
  private void sendEmail(String to, String code) {
    try {
      MimeMessage message = mailSender.createMimeMessage();
      MimeMessageHelper helper = new MimeMessageHelper(message, true, "utf-8");

      helper.setFrom("dearsophiehwang@gmail.com");
      helper.setTo(to);
      helper.setSubject("[LIME] 회원가입 인증 메일 안내");
      helper.setText(
              "이메일 인증번호: " + code,
              true
      );

      mailSender.send(message);

    } catch(Exception e) {
      e.printStackTrace();
    }
  }

  // 인증번호 검증
  public boolean verifyCode(String email, String inputCode) {
    String savedCode = redisService.getData(email);
    if(savedCode == null) {
      return false;
    }

    boolean success = savedCode.equals(inputCode);
    if(success) {
      redisService.deleteDate(email); // 인증 성공 시 redis에서 삭제
    }
    return success;
  }
}
