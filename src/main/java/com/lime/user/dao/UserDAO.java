package com.lime.user.dao;

import org.apache.ibatis.annotations.Mapper;

import com.lime.user.vo.UserVO;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface UserDAO {

	// ID 중복 체크
	int countByUserId(String userId);
	
	// 회원가입 처리
	void insertUser(UserVO userVO);

	// 회원정보 조회
	UserVO selectByUserId(String userId);

	// 비밀번호 변경
	int updateUserPwd(@Param("userId") String userId, @Param("newPwd") String newPwd);

	int updateUser(UserVO userVO);
}
