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
import com.lime.user.service.UserService;
import com.lime.user.service.UserServiceImpl;
import com.lime.user.vo.UserVO;
import com.lime.util.CommUtils;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
public class LoginController {
	
    private static final Logger log = LoggerFactory.getLogger(LoginController.class);

	@Resource(name = "jsonView")
	private MappingJackson2JsonView jsonView;

	@Resource(name="commonService")
	private CommonService commonService;
	
	private UserService userService;
	private LoginService loginService;
	
	public LoginController(UserService userService, LoginService loginService) {
		this.userService = userService;
		this.loginService = loginService;
	}

	@RequestMapping(value="/login/login.do")
	public String loginview(HttpServletRequest request ) {

		return "/login/login";
	}
	
	@PostMapping("/login/loginProc.do")
	public String loginProc(HttpServletRequest request, Model model) {
		String userId = request.getParameter("userId");
		String userPassword = request.getParameter("userPassword");
		
		try {
			UserVO user = loginService.login(userId, userPassword);
			
			HttpSession session = request.getSession();
			session.setAttribute("loginUser", user);
			
			log.info("로그인 성공 - {} 세션 생성 완료", user.getUserName());
			
			return "redirect:/account/accountList.do";
		
		} catch(LoginFailException e) {
			log.warn("로그인 실패: {}", e.getMessage());
			model.addAttribute("errorMsg", e.getMessage());
			
			return "/login/login";
		}		
	}
	
	// GET, POST 모두 처리
	@RequestMapping(value="/login/logout.do", method={RequestMethod.GET, RequestMethod.POST})
	public String logout(HttpServletRequest request) {
	    
		loginService.logout(request.getSession(false));
		
		return "redirect:/login/login.do";
	}
	
	@RequestMapping(value="/login/idCkedAjax.do")
	public ModelAndView idCkedAjax(HttpServletRequest request ) throws Exception {
		Map<String, Object> inOutMap  = CommUtils.getFormParam(request);



		return new ModelAndView(jsonView, inOutMap);
	}



}// end of class
