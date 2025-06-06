package com.lime.account.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import com.lime.user.vo.UserVO;
import lombok.extern.slf4j.Slf4j;
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

@Slf4j
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

	// [POST] 저장
	@PostMapping("save.do")
	@ResponseBody
	public Map<String, Object> saveAccount(@RequestParam Map<String, Object> params, HttpSession session) {

		Map<String, Object> result = new HashMap<>();

		try {
			// 1. 세션에서 UserVO 객체 추출
			UserVO loginUser = (UserVO) session.getAttribute("loginUser");
			if (loginUser == null) {
				throw new Exception("로그인이 필요합니다.");
			}

			// 2. 작성자 정보 설정(UserVO에서 userId 추출)
			String writer = loginUser.getUserId();
			params.put("writer", writer);

			// 2. 금액 처리(콤마 제거 및 숫자 변환)
			String moneyStr = (String) params.get("transactionMoney");
			if (moneyStr == null || moneyStr.isEmpty()) {
				throw new IllegalArgumentException("금액을 입력해주세요.");
			}
			int transactionMoney = Integer.parseInt(moneyStr.replaceAll(",", ""));
			params.put("transactionMoney", transactionMoney);

			// 3. 저장 실행
			accountService.insertAccount(params);

			// 4. 생성된 시퀀스 반환 (MyBatis selectKey 활용)
			result.put("success", true);
			result.put("seq", params.get("ACCOUNT_SEQ"));

		} catch (NumberFormatException e) {
			result.put("success", false);
			result.put("message", "금액 형식이 올바르지 않습니다.");

		} catch (Exception e) {
      result.put("success", false);
			result.put("message", e.getMessage());
    }

		return result;
  }

	// [GET] 수정 페이지
	@GetMapping("edit.do")
	public String editAccount(@RequestParam int seq, ModelMap modelMap) throws Exception {

		// 1. 기존 저장된 데이터 조회
		Map<String, Object> paramMap = new HashMap<>();
		paramMap.put("seq", seq);
		EgovMap accountData = accountService.selectAccount(paramMap); // 단건 조회
		log.info("accountData = {}", accountData); // 값 확인

		// 2. 첫 번째 select 박스용 데이터(수익/비용)
		Map<String, Object> categoryMap = new HashMap<>();
		categoryMap.put("category", "A000000");
		List<EgovMap> resultMap = commonService.selectCombo(categoryMap);

		modelMap.addAttribute("accountData", accountData);
		modelMap.addAttribute("resultMap", resultMap);

		return "/account/accountEdit"; // 수정 폼 JSP
	}

	// [POST] 수정 저장 처리
	@PostMapping("update.do")
	@ResponseBody
	public Map<String, Object> updateAccount(
					@RequestParam Map<String, Object> params,
					HttpSession session) {

		Map<String, Object> result = new HashMap<>();
		try {
			// 수정 처리
			accountService.updateAccount(params);
			result.put("success", true);
		} catch(Exception e) {
			result.put("success", false);
			result.put("message", e.getMessage());
		}
		return result;
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
