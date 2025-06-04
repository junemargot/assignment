package com.lime.user.dao;

import org.apache.ibatis.annotations.Mapper;

import com.lime.user.vo.UserVO;

@Mapper
public interface UserDAO {

	// ID 중복 체크
	public int countByUserId(String userId); 
	
	// 회원가입 처리
	public void insertUser(UserVO userVO);

	// 회원정보 조회
	public UserVO selectByUserId(String userId);
}
