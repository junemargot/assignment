package com.lime.user.controller;

import java.util.HashMap;
import java.util.Map;

import com.lime.common.service.EmailService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.lime.user.service.UserService;
import com.lime.user.vo.UserVO;

@Controller
public class UserController {

	private final UserService userService;
	private final EmailService emailService;
	
	public UserController(UserService userService, EmailService emailService) {
		this.userService = userService;
		this.emailService = emailService;
	}
	
	// [GET] 회원가입 페이지 요청 처리
	@GetMapping("/user/userInsert.do")
	public String userInsert() {
		
		return "/user/userInsert";
	}
	
	// [POST] 회원가입 폼 제출 처리
	@PostMapping("/user/userInsert.do")
	public String userInsert(@ModelAttribute UserVO user, Model model) {

		// 1. 서버사이드 입력값 검증
		if(user.getUserId() == null || user.getUserId().length() < 6) {
			model.addAttribute("errorMsg", "아이디는 6글자 이상이어야 합니다");
			return "user/userInsert";
		}

		// 2. ID 중복 체크
		if(userService.checkUserId(user.getUserId())) {
			model.addAttribute("errorMsg", "이미 사용 중인 아이디입니다");
			return "user/userInsert";
		}

		// 3. 회원 정보 DB 저장 시도
		boolean success = userService.insertUser(user);

		if(success) {
			// 성공 시 플래그 전달 (JSP에서 alert 처리)
			model.addAttribute("insertSuccess", true);
		} else {
			// 실패 시 오류 메시지 전달
			model.addAttribute("errorMsg", "회원가입에 실패했습니다.");
		}

		return "user/userInsert";
	}
    
	// [POST] ID 중복 체크 AJAX 요청 처리
	@PostMapping("/user/checkUserId.do")
	@ResponseBody // JSON 형식으로 결과를 응답
	public Map<String, Object> checkUserId(@RequestParam String userId) {

		boolean isDuplicate = userService.checkUserId(userId); // 서비스로직을 호출해 응답받은 결과값을 할당

		Map<String, Object> result = new HashMap<>();
		result.put("duplicate", isDuplicate); // JS에서 duplicate key값으로 판단,

		return result;
	}

	// [GET] 이메일 인증
	@GetMapping("/user/mailCheck")
	@ResponseBody
	public String mailCheck(@RequestParam String email) {

		String code = String.format("%06d", (int)(Math.random() * 1000000));

		emailService.sendMail(email, "[LIME] 회원가입 이메일 인증번호", "인증번호: " + code);

		return code;
	}

}
