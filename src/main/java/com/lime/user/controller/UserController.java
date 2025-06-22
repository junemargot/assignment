package com.lime.user.controller;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import com.lime.common.service.EmailService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.lime.user.service.UserService;
import com.lime.user.vo.UserVO;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

@Slf4j
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
	public String userInsert(@ModelAttribute UserVO user, @RequestParam(required = false) String address1, @RequestParam(required = false) String address2,
													 @RequestParam(required = false) String[] files, Model model) {

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

		// 3. 주소 + 상세주소 통합
		String fullAddress = (address1 != null ? address1: "") +
													(address2 != null && !address2.isEmpty() ? ", " + address2 : "");
		user.setAddress(fullAddress);

		// 4. 파일명 처리
		if(files != null && files.length > 0) {
			user.setFileNames(String.join(",", files));
		}

		// 5. 회원 정보 DB 저장 시도
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

	// [GET] 이메일 인증번호 발송
	@GetMapping("/user/mailCheck.do")
	@ResponseBody
	public String mailCheck(@RequestParam String email) {

		emailService.sendVerificationCode(email);

		return "SEND OK";
	}

	// [POST] 이메일 인증번호 검증
	@PostMapping("/user/verifyCode.do")
	@ResponseBody
	public boolean verifyCode(@RequestParam String email, @RequestParam String code) {

		return emailService.verifyCode(email, code);
	}

	// [GET] 비밀번호 변경 페이지 요청 처리
	@GetMapping("/user/changePwd.do")
	public String ChangeUserPwd() {

		return "/user/changePwd";
	}

	// [POST] 인증번호 재발송을 위한 기존 코드 삭제 API
	@PostMapping("/user/clearCode.do")
	@ResponseBody
	public ResponseEntity<String> clearCode(@RequestParam String email) {
		try {
			emailService.clearVerificationCode(email);
			return ResponseEntity.ok("CLEARED");
		} catch(Exception e) {
			log.error("인증번호 삭제 실패: {}", e.getMessage());
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("인증번호 삭제 실패");
		}
	}

	// [POST] 아이디 존재 체크 (비밀번호 변경용)
	@PostMapping("/user/checkUserIdExists.do")
	@ResponseBody
	public Map<String, Object> checkUserIdExists(@RequestParam String userId) {
		boolean exists = userService.checkUserId(userId);

		Map<String, Object> result = new HashMap<>();
		result.put("exists", exists);

		return result;
	}

	// [POST] 기존 비밀번호 확인 (비밀번호 변경용)
	@PostMapping("/user/checkUserPwd.do")
	@ResponseBody
	public Map<String, Object> checkUserPwd(@RequestParam String userId, @RequestParam String pwd) {
		boolean valid = userService.checkUserPwd(userId, pwd);

		Map<String, Object> result = new HashMap<>();
		result.put("valid", valid);

		return result;
	}

	// [POST] 비밀번호 변경
	@PostMapping("/user/changePwd.do")
	public String changeUserPwd(@RequestParam String userId, @RequestParam String pwd, Model model) {
		boolean result = userService.changeUserPwd(userId, pwd);

		if(result) {
			model.addAttribute("changeSuccess", true);
		} else {
			model.addAttribute("errorMsg", "비밀번호 변경에 실패했습니다.");
		}

		return "/user/changePwd";
	}

	// [GET] 마이페이지에서 비밀번호 변경 페이지 이동
	@GetMapping("/user/changePwdFromMypage.do")
	public String changePwdFromMyPage(HttpServletRequest request, Model model) {
		HttpSession session = request.getSession();
		UserVO loginUser = (UserVO) session.getAttribute("loginUser");

		if(loginUser == null) {
			return "redirect:/login/login.do";
		}

		model.addAttribute("fromMypage", true);
		model.addAttribute("loginUser", loginUser);
		return "/user/changePwd";
	}

	// [GET] 마이페이지
	@GetMapping("/user/mypage.do")
	public String myPage(HttpServletRequest request, Model model) {
		HttpSession session = request.getSession();
		log.info("SESSION ID: {}", session.getId());
		log.info("SESSION ATTRIBUTE: {}", Collections.list(session.getAttributeNames()));

		UserVO loginUser = (UserVO) session.getAttribute("loginUser");
		log.info("loginUser from session: {}", loginUser);

		if(loginUser == null) {
			log.warn("Session exists but loginUser is null!");
			return "redirect:/login/login.do";
		}

		// 현재 로그인한 사용자 정보 조회
		UserVO userInfo = userService.findUserById(loginUser.getUserId());
		model.addAttribute("userInfo", userInfo);

		return "/user/mypage";
	}

	// [POST] 마이페이지 - 회원정보 수정
	@PostMapping("/user/mypage.do")
	public String updateUser(HttpServletRequest request, @ModelAttribute UserVO user, 
							@RequestParam(required = false) String address1, 
							@RequestParam(required = false) String address2, 
							@RequestParam(required = false) String[] files,
							@RequestParam(required = false) String oldPwd,
							Model model) {

		try {
			HttpSession session = request.getSession();
			UserVO loginUser = (UserVO) session.getAttribute("loginUser");

			if(loginUser == null) {
				return "redirect:/login/login.do";
			}

			// 현재 로그인한 사용자의 ID 설정
			user.setUserId(loginUser.getUserId());

			// * 로깅용 - 전달 파라미터
			Map<String, String[]> paramMap = request.getParameterMap();
			log.info("전달된 파라미터: {}", paramMap);
			log.info("받은 user 객체: {}", user);
			log.info("files 파라미터: {}", Arrays.toString(files));

			// 1. 기존 비밀번호 확인 (새 비밀번호가 입력된 경우에만)
			if(user.getPwd() != null && !user.getPwd().trim().isEmpty()) {
				if(oldPwd == null || oldPwd.trim().isEmpty()) {
					model.addAttribute("errorMsg", "현재 비밀번호를 입력해주세요.");
					UserVO userInfo = userService.findUserById(loginUser.getUserId());
					model.addAttribute("userInfo", userInfo);
					return "/user/mypage";
				}

				// 기존 비밀번호 확인
				if(!userService.checkUserPwd(loginUser.getUserId(), oldPwd)) {
					model.addAttribute("errorMsg", "현재 비밀번호가 일치하지 않습니다.");
					UserVO userInfo = userService.findUserById(loginUser.getUserId());
					model.addAttribute("userInfo", userInfo);
					return "/user/mypage";
				}
			} else {
				// 비밀번호 변경하지 않는 경우 null로 설정
				user.setPwd(null);
			}

			// 2. 주소 합치기(백엔드 처리)
			String fullAddress = (address1 != null ? address1 : "") +
							(address2 != null && !address2.isEmpty() ? ", " + address2 : "");
			user.setAddress(fullAddress);

			// 3. 파일명 처리
			if(files != null && files.length > 0) {
				// 새로운 파일이 업로드된 경우
				user.setFileNames(String.join(",", files));
			} else {
				// 파일을 변경하지 않는 경우 기존 파일명 유지
				UserVO currentUser = userService.findUserById(loginUser.getUserId());
				user.setFileNames(currentUser.getFileNames());
			}

			// 4. 회원정보 수정
			userService.updateUser(user);

			// 5. 세션 정보 갱신
			UserVO updatedUser = userService.findUserById(loginUser.getUserId());
			session.setAttribute("loginUser", updatedUser);
			log.info("updateUser: {}", updatedUser);

			// 6. 성공 플래그 전달
			model.addAttribute("updateSuccess", true);
			model.addAttribute("userInfo", updatedUser);

			return "/user/mypage";

		} catch(Exception e) {
			log.error("회원정보 수정 중 오류 발생: {}", e.getMessage());
			e.printStackTrace();

			model.addAttribute("errorMsg", "회원정보 수정 중 오류가 발생했습니다.");
			UserVO userInfo = userService.findUserById(user.getUserId());
			model.addAttribute("userInfo", userInfo);
			return "/user/mypage";
		}
	}
}
