package com.lime.login.service;

import javax.servlet.http.HttpSession;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import com.lime.login.exception.LoginFailException;
import com.lime.user.service.UserService;
import com.lime.user.vo.UserVO;

@Service
public class LoginServiceImpl implements LoginService{
	
	private final UserService userService;
	private final BCryptPasswordEncoder pwEncoder;
	
	public LoginServiceImpl(UserService userService, BCryptPasswordEncoder pwEncoder) {
		this.userService = userService;
		this.pwEncoder = pwEncoder;
	}

	// 비밀번호 일치 여부 확인(BCrypt 사용)
	@Override
	public boolean matchesPassword(String rawPwd, String encodedPwd) {
		
		return pwEncoder.matches(rawPwd, encodedPwd);
	}

	// 실제 로그인 처리
	@Override
	public UserVO login(String userId, String userPassword) throws LoginFailException {

		// 1. DB에서 사용자 조회(ID 기반)
		UserVO user = userService.findUserById(userId);

		// 2. ID 존재하지 않으면 예외 발생
		if(user == null) {
			throw new LoginFailException("존재하지 않는 아이디입니다.");
		}

		// 3. 비밀번호 불일치 시 예외 발생
		if(!matchesPassword(userPassword, user.getPwd())) {
			throw new LoginFailException("비밀번호가 일치하지 않습니다.");
		}

		return user; // 인증 성공 시 사용자 반환
	}
}
