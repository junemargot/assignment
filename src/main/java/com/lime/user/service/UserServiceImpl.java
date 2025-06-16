package com.lime.user.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import com.lime.user.dao.UserDAO;
import com.lime.user.vo.UserVO;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class UserServiceImpl implements UserService {
	
	private static final Logger log = LoggerFactory.getLogger(UserServiceImpl.class);
	
	private final BCryptPasswordEncoder pwEncoder;
	private final UserDAO userDAO;
	
	public UserServiceImpl(BCryptPasswordEncoder pwEncoder, UserDAO userDAO) {
		this.pwEncoder = pwEncoder;
		this.userDAO = userDAO;
	}

	@Override
	public boolean checkUserId(String userId) {
		
		int count = userDAO.countByUserId(userId);
		log.info("중복 체크 결과 {}", count);

		// userId가 존재하면 true, 아니면 false 반환
		return count > 0;
	}

	@Override
	public boolean insertUser(UserVO user) {
		
		try {
			// 서버사이드 필수값 검증
			if(user == null || user.getUserId() == null || user.getPwd() == null) {
				log.warn("회원가입 실패: 필수값 누락");
				return false;
			}

			// 비밀번호 암호화
			String hashedPw = pwEncoder.encode(user.getPwd());
			user.setPwd(hashedPw);

			// DB 저장
			userDAO.insertUser(user);
			log.info("회원가입 성공: {}", user.getUserId());

			return true;
		
		} catch(Exception e) {
			log.error("회원가입 처리 중 오류 발생:", e);
			return false;
		}
	}

	@Override
	public UserVO findUserById(String userId) {
		
		return userDAO.selectByUserId(userId);
	}

	@Override
	public boolean existUserId(String userId) {

		return userDAO.countByUserId(userId) > 0;
	}

	@Override
	public boolean checkUserPwd(String userId, String pwd) {

		UserVO user = userDAO.selectByUserId(userId);
		if(user == null) return false;

		return pwEncoder.matches(pwd, user.getPwd());
	}

	@Override
	public boolean changeUserPwd(String userId, String newPwd) {

		String hashedPw = pwEncoder.encode(newPwd);
		int updated = userDAO.updateUserPwd(userId, hashedPw);

		return updated > 0;
	}
}
