package com.lime.login.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.lime.login.dto.NaverResponseDto;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Map;

@Controller
public class NaverOAuth2Controller {

  @Value("${naver.client.id}")
  private String clientId;

  @Value("${naver.client.secret}")
  private String clientSecret;

  @Value("${naver.redirect.uri}")
  private String redirectUri;

  private final String tokenUri = "https://nid.naver.com/oauth2.0/token";
  private final String userInfoUri = "https://openapi.naver.com/v1/nid/me";

  @RequestMapping("/naver")
  public void naverCallback(@RequestParam("code") String code, @RequestParam("state") String state, HttpServletResponse response, HttpSession session) throws IOException {

    System.out.println("🟡 네이버 콜백 진입 - code: " + code + ", state: " + state);
    String accessToken = getAccessToken(code, state);

    Map<String, Object> userInfo = getUserInfo(accessToken);
    Map<String, Object> responseMap = (Map<String, Object>) userInfo.get("response");

    String nickname = (String) responseMap.get("nickname");
    String email = (String) responseMap.get("email");

    System.out.println("✅ 네이버 로그인 성공 - " + nickname + " / " + email);

    session.setAttribute("loginUser", new NaverResponseDto(nickname));
    response.sendRedirect("/account/accountList.do");
  }

  private String getAccessToken(String code, String state) throws IOException {
    URL url = new URL(tokenUri + "?grant_type=authorization_code"
            + "&client_id=" + clientId
            + "&client_secret=" + clientSecret
            + "&redirect_uri=" + redirectUri
            + "&code=" + code
            + "&state=" + state);

    HttpURLConnection connection = (HttpURLConnection) url.openConnection();
    connection.setRequestMethod("GET");

    try(BufferedReader br = new BufferedReader(new InputStreamReader(connection.getInputStream()))) {
      StringBuilder sb = new StringBuilder();
      String line;

      while((line = br.readLine()) != null) {
        sb.append(line);
      }

      Map<String, Object> result = new ObjectMapper().readValue(sb.toString(), Map.class);

      return (String) result.get("access_token");
    }
  }

  private Map<String, Object> getUserInfo(String accessToken) throws IOException {
    URL url = new URL(userInfoUri);
    HttpURLConnection connection = (HttpURLConnection) url.openConnection();

    connection.setRequestProperty("Authorization", "Bearer " + accessToken);

    try (BufferedReader br = new BufferedReader(new InputStreamReader(connection.getInputStream()))) {
      StringBuilder sb = new StringBuilder();
      String line;
      while ((line = br.readLine()) != null) sb.append(line);
      return new ObjectMapper().readValue(sb.toString(), Map.class);
    }
  }
}
