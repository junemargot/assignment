package com.lime.login.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.lime.login.dto.KakaoResponseDto;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Map;

@Slf4j
@Controller
public class KakaoOAuth2Controller {

  @Value("${kakao.client.id}")
  private String clientId;

  @Value("${kakao.client.secret}")
  private String clientSecret;

  @Value("${kakao.redirect.uri}")
  private String redirectUri;

  private final String tokenUri = "https://kauth.kakao.com/oauth/token";
  private final String userInfoUri = "https://kapi.kakao.com/v2/user/me";

  @RequestMapping("/kakao")
  public void kakaoCallback(@RequestParam("code") String code, HttpServletResponse response, HttpSession session) throws IOException {

    log.info("🟡 카카오 콜백 진입 - code {}", code);

    // 1. AccessToken 요청
    String accessToken = getAccessToken(code);

    // 2. 사용자 정보 요청
    Map<String, Object> userInfo = getUserInfo(accessToken);

    // 3. 이메일 추출 및 세션 저장
    Map<String, Object> kakaoAccount = (Map<String, Object>) userInfo.get("kakao_account");
    Map<String, Object> profile = (Map<String, Object>) kakaoAccount.get("profile");

    String nickname = (String) profile.get("nickname");
    String email = (String) kakaoAccount.get("email");
    log.info("로그인 성공 - {}, {}", email, nickname);

    // 4. 사용자 정보 세션 저장
    session.setAttribute("loginUser", new KakaoResponseDto(nickname));

    // 5. 로그인 후 리다이렉트
    response.sendRedirect("/account/accountList.do");
  }

  /*
  * AccessToken 요청
  */
  private String getAccessToken(String code) throws IOException {
    URL url = new URL(tokenUri); // POST 요청할 Kakao URL
    HttpURLConnection connection = (HttpURLConnection) url.openConnection();
    connection.setRequestMethod("POST");
    connection.setDoOutput(true);
    connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
    connection.setRequestProperty("Accept", "application/json");

    connection.setRequestProperty("User-Agent", "Mozilla/5.0");

    String params = "grant_type=authorization_code"
            + "&client_id=" + clientId
            + "&redirect_uri=" + redirectUri
            + "&code=" + code
            + "&client_secret=" + clientSecret;

    try (OutputStream os = connection.getOutputStream()) {
      os.write(params.getBytes(StandardCharsets.UTF_8));
      os.flush();
    } catch (IOException e) {
      log.error("Token 요청 실패: {}", e.getMessage());

      if (connection.getErrorStream() != null) {
        BufferedReader errorReader = new BufferedReader(new InputStreamReader(connection.getErrorStream()));
        StringBuilder errorBuilder = new StringBuilder();
        String errorLine;
        while ((errorLine = errorReader.readLine()) != null) {
          errorBuilder.append(errorLine);
        }
        log.error("카카오 에러 응답: {}", errorBuilder.toString());
      }
      throw e;
    }

    try (BufferedReader br = new BufferedReader(new InputStreamReader(connection.getInputStream()))) {
      StringBuilder sb = new StringBuilder();
      String line;
      while ((line = br.readLine()) != null) sb.append(line);
      Map<String, Object> result = new ObjectMapper().readValue(sb.toString(), Map.class);
      log.debug("Token 응답: {}", result);

      return (String) result.get("access_token");
    }
  }

  private Map<String, Object> getUserInfo(String accessToken) throws IOException {
    URL url = new URL(userInfoUri);
    HttpURLConnection conn = (HttpURLConnection) url.openConnection();

    conn.setRequestProperty("Authorization", "Bearer " + accessToken);

    try (BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()))) {
      StringBuilder sb = new StringBuilder();
      String line;
      while ((line = br.readLine()) != null) sb.append(line);
      return new ObjectMapper().readValue(sb.toString(), Map.class);
    }
  }
}