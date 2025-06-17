package com.lime.login.dto;

public class NaverResponseDto {
  private String userName;

  public NaverResponseDto(String nickname) {
    this.userName = nickname;
  }

  public String getUserName() {
    return userName;
  }
}
