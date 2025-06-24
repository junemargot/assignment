package com.lime.user.controller;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import com.lime.common.service.EmailService;
import com.lime.util.SessionUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import com.lime.user.service.UserService;
import com.lime.user.vo.UserVO;

import javax.servlet.http.HttpServletRequest;

@Slf4j
@Controller
@RequestMapping("/user")
public class UserController {

	private final UserService userService;
	private final EmailService emailService;
	
	public UserController(UserService userService, EmailService emailService) {
		this.userService = userService;
		this.emailService = emailService;
	}
	
	/**
	* 회원가입 페이지 요청
  *
  * @method GET
  * @url /user/userInsert.do
	* @return 회원가입 JSP 경로 반환
	*/
	@GetMapping("/userInsert.do")
	public String userInsert() {
		return "/user/userInsert";
	}

	/**
	 * 회원가입 요청 처리
	 *
	 * @method POST
	 * @url /user/userInsert.do
	 * @param user 사용자 정보
	 * @param address1 기본 주소
	 * @param address2 상세 주소
	 * @param files 첨부파일 배열
	 * @param model 뷰에 전달할 모델 객체
	 * @return 회원가입 페이지 또는 결과에 따라 재요청
	 */
	@PostMapping("/userInsert.do")
	public String userInsert(@ModelAttribute UserVO user,
													 @RequestParam(required = false) String address1,
													 @RequestParam(required = false) String address2,
													 @RequestParam(required = false) String[] files,
													 Model model) {
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

		return "/user/userInsert";
	}
    
	/**
	 * ID 중복 여부 확인
	 *
	 * @method POST
	 * @url /user/checkUserId.do
	 * @param userId 확인할 사용자 ID
	 * @return 중복 여부 결과 JSON 반환
	 */
	@PostMapping("/checkUserId.do")
	@ResponseBody
	public Map<String, Object> checkUserId(@RequestParam String userId) {
		boolean isDuplicate = userService.checkUserId(userId); // 서비스로직을 호출해 응답받은 결과값을 할당
		Map<String, Object> result = new HashMap<>();
		result.put("duplicate", isDuplicate); // JS에서 duplicate key값으로 판단,

		return result;
	}

	/**
	 * 이메일 인증번호 발송 요청
	 *
	 * @method GET
	 * @url /user/mailCheck.do
	 * @param email 인증코드를 받을 이메일 주소
	 * @return "SEND OK" - 인증 코드가 정상적으로 발송되었음을 나타냄
	 */
	@GetMapping("/mailCheck.do")
	@ResponseBody
	public String mailCheck(@RequestParam String email) {
		emailService.sendVerificationCode(email);
		return "SEND OK";
	}

	/**
	 * 이메일 인증번호 검증 요청
	 *
	 * @method POST
	 * @url /user/verifyCode.do
	 * @param email 이메일 주소
	 * @param code 인증 코드
	 * @return 인증 성공 여부
	 * */
	@PostMapping("/verifyCode.do")
	@ResponseBody
	public boolean verifyCode(@RequestParam String email, @RequestParam String code) {
		return emailService.verifyCode(email, code);
	}

	/**
	 * 기존 이메일 인증 코드 삭제 (재발송 전 처리)
	 *
	 * @method POST
	 * @url /user/clearCode.do
	 * @param email 인증번호 삭제 대상 이메일
	 * @return 처리 성공/실패 응답
	 * */
	@PostMapping("/clearCode.do")
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

	/**
	 * 사용자 ID 존재 여부 확인 (비밀번호 변경 시 사용)
	 *
	 * @method POST
	 * @url /user/checkUserIdExists.do
	 * @param userId 입력한 사용자 ID
	 * @return 존재 여부 결과
	 * */
	@PostMapping("/checkUserIdExists.do")
	@ResponseBody
	public Map<String, Object> checkUserIdExists(@RequestParam String userId) {
		boolean exists = userService.checkUserId(userId);

		Map<String, Object> result = new HashMap<>();
		result.put("exists", exists);

		return result;
	}

	/**
	 * 기존 비밀번호 일치 여부 확인
	 *
	 * @method POST
	 * @url /user/checkUserPwd.do
	 * @param userId 사용자 ID
	 * @param pwd 입력한 현재 비밀번호
	 * @return 일치 여부 결과
	 * */
	@PostMapping("/checkUserPwd.do")
	@ResponseBody
	public Map<String, Object> checkUserPwd(@RequestParam String userId, @RequestParam String pwd) {
		boolean valid = userService.checkUserPwd(userId, pwd);

		Map<String, Object> result = new HashMap<>();
		result.put("valid", valid);

		return result;
	}

	/**
	 * 비밀번호 변경 페이지 요청 (단독 접근)
	 *
	 * @method GET
	 * @url /user/changePwd.do
	 * @return 비밀번호 변경 페이지 경로 반환
	 */
	@GetMapping("/changePwd.do")
	public String ChangeUserPwd() {
		return "/user/changePwd";
	}

	/**
	 * 비밀번호 변경 처리
	 *
	 * @method POST
	 * @url /user/changePwd.do
	 * @param userId 사용자 ID
	 * @param pwd 새 비밀번호
	 * @param model 응답 모델
	 * @return 변경 결과 페이지 경로
	 * */
	@PostMapping("/changePwd.do")
	public String changeUserPwd(@RequestParam String userId, @RequestParam String pwd, Model model) {
		boolean result = userService.changeUserPwd(userId, pwd);

		if(result) {
			model.addAttribute("changeSuccess", true);
		} else {
			model.addAttribute("errorMsg", "비밀번호 변경에 실패했습니다.");
		}

		return "/user/changePwd";
	}

	/**
	 * 마이페이지에서 비밀번호 변경 페이지 이동
	 *
	 * @method GET
	 * @url /user/changePwdFromMypage.do
	 * @return 비밀번호 변경 페이지 경로
	 * */
	@GetMapping("/changePwdFromMypage.do")
	public String changePwdFromMyPage(HttpServletRequest request, Model model) {
		UserVO loginUser = SessionUtil.getLoginUser(request);

		model.addAttribute("fromMypage", true);
		model.addAttribute("loginUser", loginUser);

		return "/user/changePwd";
	}

	/**
	 * 마이페이지 조회 - 회원정보 수정
	 *
	 * @method GET
	 * @url /user/mypage.do
	 * @return 마이페이지 뷰
	 * */
	@GetMapping("/mypage.do")
	public String myPage(HttpServletRequest request, Model model) {
		UserVO loginUser = SessionUtil.getLoginUser(request);

		// 현재 로그인한 사용자 정보 조회
		UserVO userInfo = userService.findUserById(loginUser.getUserId());
		model.addAttribute("userInfo", userInfo);

		return "/user/mypage";
	}

	/**
	 * 마이페이지 - 회원정보 수정 요청 처리
	 *
	 * @method POST
	 * @url /user/mypage.do
	 * @return 수정 결과 페이지
	 * */
	@PostMapping("/mypage.do")
	public String updateUser(HttpServletRequest request, @ModelAttribute UserVO user, 
													 @RequestParam(required = false) String address1,
													 @RequestParam(required = false) String address2,
													 @RequestParam(required = false) String[] files,
													 @RequestParam(required = false) String oldPwd,
													 Model model) {
		try {
			UserVO loginUser = SessionUtil.getLoginUser(request);

			// 현재 로그인한 사용자의 ID 설정
			user.setUserId(loginUser.getUserId());

			// 비밀번호 변경 요청인 경우 현재 비밀번호 검증
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
			SessionUtil.updateLoginUser(request, updatedUser);
			log.info("updateUser: {}", updatedUser);

			// 6. 성공 플래그 전달
			model.addAttribute("updateSuccess", true);
			model.addAttribute("userInfo", updatedUser);

			return "/user/mypage";

		} catch(Exception e) {
			log.error("회원정보 수정 중 오류 발생: {}", e.getMessage());
			model.addAttribute("errorMsg", "회원정보 수정 중 오류가 발생했습니다.");
			UserVO userInfo = userService.findUserById(user.getUserId());
			model.addAttribute("userInfo", userInfo);
			return "/user/mypage";
		}
	}
}