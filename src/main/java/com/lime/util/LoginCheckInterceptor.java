package com.lime.util;

import lombok.extern.slf4j.Slf4j;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@Slf4j
public class LoginCheckInterceptor extends HandlerInterceptorAdapter {

  @Override
  public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {

    String requestURI = request.getRequestURI();
    log.info("로그인 체크 인터셉터 실행: {}", requestURI);

    // 로그인 여부 확인
    if(!SessionUtil.isLoggedIn(request)) {
      log.info("미인증 사용자 요청: {}", requestURI);

      // Ajax 요청인 경우 JSON 응답
      if(isAjaxRequest(request)) {
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json;charset=utf-8");
        response.getWriter().write("{\"success\":false,\"message\":\"로그인이 필요합니다.\",\"redirect\":\"/login/login.do\"}");
        return false;
      }

      // 일반 요청인 경우 로그인 페이지로 리다이렉트
      response.sendRedirect("/login/login.do");
      return false;
    }

    return true;
  }

  /**
   * Ajax 요청인지 확인
   * @param request HttpServletRequest
   * @return Ajax 요청 여부
   * */
  private boolean isAjaxRequest(HttpServletRequest request) {
    String requestedWith = request.getHeader("X-Requested-With");
    String contentType = request.getContentType();

    return "XMLHttpRequest".equals(requestedWith) ||
            (contentType != null && contentType.contains("application/json")) ||
            request.getRequestURI().contains("Ajax") || // URL에 Ajax가 포함된 경우
            request.getParameter("ajax") != null; // ajax 파라미터가 있는 경우
  }
}
