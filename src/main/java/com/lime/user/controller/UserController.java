package com.lime.user.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.lime.user.service.UserService;
import com.lime.user.vo.UserVO;

@Controller
public class UserController {

	@Autowired
	private UserService userService;
	
	// 회원가입 GET
	@RequestMapping(value="/user/userInsert.do", method=RequestMethod.GET)
	public String userInsert() {
		
		return "/user/userInsert";
	}
	
    // 회원가입 처리 POST
    @RequestMapping(value="/user/userInsert.do", method=RequestMethod.POST)
    public String userInsertProc(UserVO userVO, Model model) {
        
    	userService.insertUser(userVO);
        
        return "redirect:/user/login.do";
    }
    
    @RequestMapping(value="/user/checkUserId.do", method=RequestMethod.POST)
    @ResponseBody
    public Map<String, Object> checkUserId(@RequestParam String userId) {
        boolean isDuplicate = userService.checkUserId(userId);
        Map<String, Object> result = new HashMap<>();
        result.put("duplicate", isDuplicate);
        return result;
    }
}
