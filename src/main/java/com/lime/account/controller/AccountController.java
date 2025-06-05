package com.lime.account.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.view.json.MappingJackson2JsonView;

import com.lime.account.service.AccountService;
import com.lime.common.service.CommonService;
import com.lime.util.CommUtils;

import egovframework.rte.psl.dataaccess.util.EgovMap;


@Controller
@RequestMapping("/account")
public class AccountController {

	@Resource(name = "jsonView")
	private MappingJackson2JsonView jsonView;

	@Resource(name="accountService")
	private AccountService accountService;

	@Resource(name="commonService")
	private CommonService commonService;

	// [POST] 계층형 select 박스 데이터 조회
	@PostMapping("getSubCategory.do")
	@ResponseBody
	public List<EgovMap> getSubCategory(@RequestParam String category) throws Exception {

		Map<String, Object> paramMap = new HashMap<>();
		paramMap.put("category", category);

		return commonService.selectCombo(paramMap);
	}

	/**
	 *
	 * @param searchVO - 조회할 정보가 담긴 SampleDefaultVO
	 * @param model
	 * @return "egovSampleList"
	 * @exception Exception
	 */
	// [GET] 회계 목록 조회
	@GetMapping("accountList.do")
	public String selectSampleList(HttpServletRequest request, ModelMap model) throws Exception {

		Map<String, Object> inOutMap  = CommUtils.getFormParam(request);
		model.put("inOutMap", inOutMap);

		return "/account/accountList";
	}

	/**
	 *
	 * @param request
	 * @return
	 * @throws Exception
	 */
	// [GET] 회계 입력 폼
	@RequestMapping("accountInsert.do")
	public String accountInsert(HttpServletRequest request, ModelMap model) throws Exception{

		Map<String, Object> inOutMap = new HashMap<>();
		inOutMap.put("category", "A000000");

		List<EgovMap> resultMap= commonService.selectCombo(inOutMap);
		System.out.println(resultMap);
		model.put("resultMap", resultMap);

		return "/account/accountInsert";
	}


	/**
	 *
	 * @param request
	 * @return
	 * @throws Exception
	 */
	// [POST] 콤보박스 데이터 조회
	@PostMapping("selectCombo.do")
	public ModelAndView ajaxtest(HttpServletRequest request) throws Exception{

		Map<String, Object> inOutMap  = CommUtils.getFormParam(request);
		commonService.selectCombo(inOutMap);

		return new ModelAndView(jsonView, inOutMap);
	}







}// end of calss
