package com.lime.user.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import com.lime.user.dao.UserDAO;
import com.lime.user.vo.UserVO;

@Service
public class UserServiceImpl implements UserService {

	
	@Autowired
	private BCryptPasswordEncoder pwEncoder;
	
	@Autowired
	private UserDAO userDAO;

	@Override
	public boolean checkUserId(String userId) {
		
		int count = userDAO.countByUserId(userId);
	    System.out.println("중복 체크 결과 (count): " + count); // 로그 확인

	    // userId가 존재하면 true, 아니면 false 반환
		return count > 0;
	}

	@Override
	public boolean insertUser(UserVO user) {
		
		try {
			String hashedPw = pwEncoder.encode(user.getPwd());
			user.setPwd(hashedPw);
			
			userDAO.insertUser(user);
			return true;
		
		} catch(Exception e) {
			e.printStackTrace();
			return false;
		}
	}
}
