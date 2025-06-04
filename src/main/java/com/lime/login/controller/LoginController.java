package com.lime.login.controller;

import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.view.json.MappingJackson2JsonView;

import com.lime.common.service.CommonService;
import com.lime.login.exception.LoginFailException;
import com.lime.login.service.LoginService;
import com.lime.user.vo.UserVO;
import com.lime.util.CommUtils;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
public class LoginController {

	@Resource(name = "jsonView")
	private MappingJackson2JsonView jsonView;

	@Resource(name="commonService")
	private CommonService commonService;
	
	private final LoginService loginService;
	
	public LoginController(LoginService loginService) {
		this.loginService = loginService;
	}

	// [GET] 로그인 페이지 요청
	@GetMapping("/login/login.do")
	public String loginview(HttpServletRequest request ) {

		return "/login/login";
	}

	// [POST] 로그인 처리
	@PostMapping("/login/loginProc.do")
	public String loginProc(HttpServletRequest request, Model model) {
		String userId = request.getParameter("userId");
		String userPassword = request.getParameter("userPassword");
		
		try {
			UserVO user = loginService.login(userId, userPassword);

			// 세션 생성 및 사용자 정보 세션에 저장
			HttpSession session = request.getSession();
			session.setAttribute("loginUser", user);
			
			log.info("로그인 성공 - {} 세션 생성 완료", user);
			
			return "redirect:/account/accountList.do";
		
		} catch(LoginFailException e) {
			log.warn("로그인 실패: {}", e.getMessage());
			model.addAttribute("errorMsg", e.getMessage());
			
			return "/login/login";
		}		
	}
	
	// [GET, POST] 로그아웃 처리
	@RequestMapping(value="/login/logout.do", method={RequestMethod.GET, RequestMethod.POST})
	public String logout(HttpServletRequest request) {
	    
		HttpSession session = request.getSession(false);
		
		if(session != null) {
			session.invalidate(); // 세션 무효화
		}
		
		return "redirect:/login/login.do";
	}

	
	@RequestMapping(value="/login/idCkedAjax.do")
	public ModelAndView idCkedAjax(HttpServletRequest request ) throws Exception {
		Map<String, Object> inOutMap  = CommUtils.getFormParam(request);

		return new ModelAndView(jsonView, inOutMap);
	}
}