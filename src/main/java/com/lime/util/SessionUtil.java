package com.lime.util;

import com.lime.user.vo.UserVO;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

public class SessionUtil {

  private static final String LOGIN_USER_KEY = "loginUser";

  /**
   * 로그인 사용자 조회
   * @param request HttpServletRequest
   * @return 로그인 사용자 (미로그인시 null)
   * */
  public static UserVO getLoginUser(HttpServletRequest request) {
    HttpSession session = request.getSession(false);
    if(session == null) {
      return null;
    }
    return (UserVO) session.getAttribute(LOGIN_USER_KEY);
  }

  /**
   * 로그인 여부 확인
   * @param request HttpServletRequest
   * @return 로그인 여부
   * */
  public static boolean isLoggedIn(HttpServletRequest request) {
    return getLoginUser(request) != null;
  }

  /**
   * 로그인 사용자 정보 세션에 저장
   * @param request HttpServletRequest
   * @param user 사용자 정보
   * */
  public static void setLoginUser(HttpServletRequest request, UserVO user) {
    HttpSession session = request.getSession();
    session.setAttribute(LOGIN_USER_KEY, user);
  }

  /**
   * 세션에서 로그인 사용자 정보 업데이트
   * @param request HttpServletRequest
   * @param updatedUser 업데이트된 사용자 정보
   * */
  public static void updateLoginUser(HttpServletRequest request, UserVO updatedUser) {
    HttpSession session = request.getSession(false);
    if(session != null) {
      session.setAttribute(LOGIN_USER_KEY, updatedUser);
    }
  }

  /**
   * 세션 무효화 (로그아웃)
   * @param request HttpServletRequest
   * */
  public static void invalidateSession(HttpServletRequest request) {
    HttpSession session = request.getSession(false);
    if(session != null) {
      session.invalidate();
    }
  }
}
