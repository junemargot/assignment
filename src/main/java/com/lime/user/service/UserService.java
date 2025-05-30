package com.lime.user.service;

import com.lime.user.vo.UserVO;

public interface UserService {

	// ID 중복 체크
	public boolean checkUserId(String userId);
	
	// 회원가입 처리
	public boolean insertUser(UserVO user);
}
