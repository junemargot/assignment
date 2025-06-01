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


	@Override
	public boolean matchesPassword(String rawPwd, String encodedPwd) {
		
		return pwEncoder.matches(rawPwd, encodedPwd);
	}


	@Override
	public UserVO login(String userId, String userPassword) throws LoginFailException {
		
		UserVO user = userService.findUserById(userId);
		
		if(user == null) {
			throw new LoginFailException("존재하지 않는 아이디입니다.");
		}
		
		if(!matchesPassword(userPassword, user.getPwd())) {
			throw new LoginFailException("비밀번호가 일치하지 않습니다.");
		}
		
		return user;
	}


	@Override
	public void logout(HttpSession session) {
		
		if(session != null) {
			session.invalidate();
		}
		
	}
	

}
