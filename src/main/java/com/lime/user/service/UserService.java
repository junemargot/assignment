package com.lime.user.service;

import com.lime.user.vo.UserVO;

public interface UserService {

	// ID 중복 체크
	public boolean checkUserId(String userId);
	
	// 회원가입 처리
	public boolean insertUser(UserVO user);
	
	// 회원 정보 조회
	public UserVO findUserById(String userId);

	// 아이디 존재 체크
	boolean existUserId(String userId);

	// 기존 비밀번호 일치 여부 체크
	boolean checkUserPwd(String userId, String pwd);

	// 비밀번호 변경
	boolean changeUserPwd(String userId, String newPwd);
	
}
