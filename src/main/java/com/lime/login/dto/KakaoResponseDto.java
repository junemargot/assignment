package com.lime.login.dto;

public class KakaoResponseDto {

  private final String userName;

  public KakaoResponseDto(String userName) {
    this.userName = userName;
  }

  public String getUserName() {
    return userName;
  }
}
