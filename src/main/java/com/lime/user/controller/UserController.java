package com.lime.user.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
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
	@GetMapping(value="/user/userInsert.do")
	public String userInsert() {
		
		return "/user/userInsert";
	}
	
    // 회원가입 처리 POST
    @PostMapping(value="/user/userInsert.do")
    public String userInsert(@ModelAttribute UserVO user, Model model) {
        
    	boolean success = userService.insertUser(user);
    	
    	if(success) {
    		model.addAttribute("insertSuccess", true);
    	} else {
    		model.addAttribute("errorMsg", "회원가입에 실패했습니다.");
    	}
        
//        return "redirect:/login/login.do";
    	return "user/userInsert";
    }
    
    @PostMapping(value="/user/checkUserId.do")
    @ResponseBody
    public Map<String, Object> checkUserId(@RequestParam String userId) {
        boolean isDuplicate = userService.checkUserId(userId);
        Map<String, Object> result = new HashMap<>();
        result.put("duplicate", isDuplicate);
        return result;
    }
}
