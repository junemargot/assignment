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
	
	public LoginController(UserService userService) {
		this.userService = userService;
	}

	@RequestMapping(value="/login/login.do")
	public String loginview(HttpServletRequest request ) {

		return "/login/login";
	}
	
	@PostMapping("/login/loginProc.do")
	public String loginProc(HttpServletRequest request, Model model) {
		String userId = request.getParameter("userId");
		String userPassword = request.getParameter("userPassword");
		
		// 1. 아이디로 사용자 정보 조회
		UserVO user = userService.findUserById(userId);
		if(user == null) {
			log.warn("존재하지 않는 아이디 - {}", userId);
			model.addAttribute("errorMsg", "존재하지 않는 아이디입니다.");
			return "/login/login";
		}
		
		log.info("조회된 사용자: {}", user.toString());
		
		// 2. 비밀번호 검증
		if(!userService.matchesPassword(userPassword, user.getPwd())) {
			model.addAttribute("errorMsg", "비밀번호가 일치하지 않습니다.");
			return "/login/login";
		}
		
		// 3. 세션 처리
		HttpSession session = request.getSession();
		session.setAttribute("loginUser", user);
		log.info("로그인 성공 - {} 세션 생성 완료", user.getUserName());
		
		return "redirect:/account/accountList.do";
				
	}
	
	// GET, POST 모두 처리
	@RequestMapping(value="/login/logout.do", method={RequestMethod.GET, RequestMethod.POST})
	public String logout(HttpServletRequest request) {
	    
		HttpSession session = request.getSession(false);
	    
		if(session != null) {
	        session.invalidate();
	    }
	    
	    return "redirect:/login/login.do";
	}
	
//	@PostMapping("/login/logout.do")
//	public String logoutProc(HttpServletRequest request) {
//		HttpSession session = request.getSession(false);
//		if(session != null) {
//			session.invalidate();
//		}
//		
//		return "redirect:/login/login.do";
//	}
//	
//	@GetMapping("/login/logout.do")
//	public String logout(HttpServletRequest request) {
//	    HttpSession session = request.getSession(false);
//	    if(session != null) {
//	        session.invalidate();
//	    }
//	    
//	    return "redirect:/login/login.do";
//	}
	
	
	@RequestMapping(value="/login/idCkedAjax.do")
	public ModelAndView idCkedAjax(HttpServletRequest request ) throws Exception {
		Map<String, Object> inOutMap  = CommUtils.getFormParam(request);



		return new ModelAndView(jsonView, inOutMap);
	}



}// end of class
