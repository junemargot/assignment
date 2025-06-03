package com.lime.user.controller;

import java.util.HashMap;
import java.util.Map;

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
	
	public UserController(UserService userService) {
		this.userService = userService;
	}
	
	// [GET] 회원가입 페이지 요청 처리
	@GetMapping("/user/userInsert.do")
	public String userInsert() {
		
		return "/user/userInsert";
	}
	
	// [POST] 회원가입 폼 제출 처리
	@PostMapping("/user/userInsert.do")
	public String userInsert(@ModelAttribute UserVO user, Model model) {

		// 서버사이드 검증
		if(user.getUserId() == null || user.getUserId().length() < 6) {
			model.addAttribute("errorMsg", "아이디는 6글자 이상이어야 합니다");
			return "user/userInsert";
		}

		if(userService.checkUserId(user.getUserId())) {
			model.addAttribute("errorMsg", "이미 사용 중인 아이디입니다");
			return "user/userInsert";
		}

		boolean success = userService.insertUser(user);

		if(success) {
			// 회원가입 성공 시, JSP에서 alert 처리 위한 플래그 전달
			model.addAttribute("insertSuccess", true);
		} else {
			// 실패 시 오류 메시지를 model에 담아 JSP에서 출력
			model.addAttribute("errorMsg", "회원가입에 실패했습니다.");
		}

		return "user/userInsert";
	}
    
	// [POST] ID 중복 체크 AJAX 요청 처리
	@PostMapping("/user/checkUserId.do")
	@ResponseBody // JSON 형식으로 결과를 응답
	public Map<String, Object> checkUserId(@RequestParam String userId) {

		boolean isDuplicate = userService.checkUserId(userId);

			Map<String, Object> result = new HashMap<>();
			result.put("duplicate", isDuplicate); // JS에서 duplicate를 기준으로 판단

			return result;
	}
}
