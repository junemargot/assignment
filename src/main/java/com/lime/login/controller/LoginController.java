package com.lime.login.controller;

import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.view.json.MappingJackson2JsonView;

import com.lime.common.service.CommonService;
import com.lime.user.service.UserService;
import com.lime.user.vo.UserVO;
import com.lime.util.CommUtils;


@Controller
public class LoginController {


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
		
		// 아이디로 사용자 정보 조회
		UserVO user = userService.findUserById(userId);
		if(user == null) {
			model.addAttribute("errorMsg", "존재하지 않는 아이디입니다.");
			return "/login/login";
		}
		
		if(!userService.matchesPassword(userPassword, user.getPwd())) {
			model.addAttribute("errorMsg", "비밀번호가 일치하지 않습니다.");
			return "/login/login";
		}
		
		HttpSession session = request.getSession();
		session.setAttribute("loginUser", user);
		
		return "redirect:/account/accountList.do";
				
	}

	@RequestMapping(value="/login/idCkedAjax.do")
	public ModelAndView idCkedAjax(HttpServletRequest request ) throws Exception {
		Map<String, Object> inOutMap  = CommUtils.getFormParam(request);



		return new ModelAndView(jsonView, inOutMap);
	}



}// end of class
