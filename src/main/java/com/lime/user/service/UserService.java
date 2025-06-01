package com.lime.user.service;

import com.lime.user.vo.UserVO;

public interface UserService {

	// ID 중복 체크
	public boolean checkUserId(String userId);
	
	// 회원가입 처리
	public boolean insertUser(UserVO user);
	
	// 회원 정보 조회
	public UserVO findUserById(String userId);
	
}
