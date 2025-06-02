package com.lime.login.service;

import javax.servlet.http.HttpSession;

import com.lime.login.exception.LoginFailException;
import com.lime.user.vo.UserVO;

public interface LoginService {

	public boolean matchesPassword(String rawPwd, String encodedPwd);

	public UserVO login(String userId, String userPassword) throws LoginFailException;
	
}
