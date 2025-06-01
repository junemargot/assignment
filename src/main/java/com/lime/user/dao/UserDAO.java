package com.lime.user.dao;

import org.apache.ibatis.annotations.Mapper;

import com.lime.user.vo.UserVO;

@Mapper
public interface UserDAO {

	// userId 중복 체크
	public int countByUserId(String userId); 
	
	// 회원가입 처리
	public void insertUser(UserVO userVO);
	
	public UserVO selectByUserId(String userId);
}
