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
		
		// userId가 존재하면 true, 아니면 false 반환
		return userDAO.countByUserId(userId) > 0;
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
