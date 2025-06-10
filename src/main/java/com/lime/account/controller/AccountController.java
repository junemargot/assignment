package com.lime.account.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.lime.user.vo.UserVO;
import egovframework.example.sample.service.SampleDefaultVO;
import egovframework.rte.ptl.mvc.tags.ui.pagination.PaginationInfo;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
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

	// [POST] 계층형 select 박스 데이터 조회 (대분류 -> 중분류 등 Ajax)
	@PostMapping("getSubCategory.do")
	@ResponseBody
	public List<EgovMap> getSubCategory(@RequestParam String category) throws Exception {
		// category 파라미터로 하위 카테고리 조회
		Map<String, Object> paramMap = new HashMap<>();
		paramMap.put("category", category);

		return commonService.selectCombo(paramMap); // DB에서 목록 조회 후 반환
	}

	// [GET] 회계 입력 폼
	@RequestMapping("accountInsert.do")
	public String accountInsert(HttpServletRequest request, ModelMap model) throws Exception{

		Map<String, Object> inOutMap = new HashMap<>();
		inOutMap.put("category", "A000000"); // 최상위 카테고리값 설정

		List<EgovMap> resultMap = commonService.selectCombo(inOutMap);
		System.out.println(resultMap);
		model.put("resultMap", resultMap);

		return "/account/accountInsert";
	}

	// [POST] 회계비용 등록
	@PostMapping("save.do")
	@ResponseBody
	public Map<String, Object> saveAccount(@RequestParam Map<String, Object> params, HttpSession session) {

		Map<String, Object> result = new HashMap<>();

		try {
			// 1. 로그인 사용자 확인
			UserVO loginUser = (UserVO) session.getAttribute("loginUser");
			if (loginUser == null) {
				throw new Exception("로그인이 필요합니다.");
			}

			// 2. 작성자 정보 설정(UserVO에서 userId 추출)
			String writer = loginUser.getUserId();
			params.put("writer", writer);

			// 3. 금액 처리(콤마 제거 및 숫자 변환)
			String moneyStr = (String) params.get("transactionMoney");
			if (moneyStr == null || moneyStr.isEmpty()) {
				throw new IllegalArgumentException("금액을 입력해주세요.");
			}
			int transactionMoney = Integer.parseInt(moneyStr.replaceAll(",", ""));
			params.put("transactionMoney", transactionMoney);

			// 4. 저장 실행 (insertAccount 내부에서 MyBatis selectKey로 시퀀스 채움)
			accountService.insertAccount(params);

			// 5. 응답에 성공 및 생성된 시퀀스 반환
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
		paramMap.put("seq", seq); // paramMap에 "seq" 키로 요청 파라미터에서 받은 seq 값 추가
		EgovMap accountData = accountService.selectAccount(paramMap); // 단건 조회
		log.info("accountData = {}", accountData);

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
	public Map<String, Object> updateAccount(@RequestParam Map<String, Object> params, HttpSession session) {

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

	// [GET] 회계 목록 조회
	@GetMapping("accountList.do")
	public String selectAccountList(@ModelAttribute("searchVO") SampleDefaultVO searchVO, ModelMap modelMap) throws Exception {

		// 페이징 설정
		PaginationInfo paginationInfo = new PaginationInfo(); // EgovFramework의 페이징 정보를 담는 객체 생성
		paginationInfo.setCurrentPageNo(searchVO.getPageIndex()); // 현재 페이지 번호를 searchVO에서 가져와 설정
		paginationInfo.setRecordCountPerPage(searchVO.getRecordCountPerPage()); // 페이지당 보여줄 레코드(게시물) 수를 searchVO에서 가져와 설정
		paginationInfo.setPageSize(searchVO.getPageSize()); // 페이징 블록(하단에 표시되는 페이지 번호 묶음) 크기를 searchVO에서 가져와 설정

		searchVO.setFirstIndex(paginationInfo.getFirstRecordIndex()); // 현재 페이지의 첫 번째 레코드 인덱스(OFFSET)
		searchVO.setLastIndex(paginationInfo.getLastRecordIndex());
		searchVO.setRecordCountPerPage(paginationInfo.getRecordCountPerPage()); // 페이지당 레코드 수(LIMIT)

		// 데이터 조회
		List<EgovMap> accountList = accountService.selectAccountList(searchVO);
		int totalCount = accountService.selectAccountTotalCount(searchVO); // 페이징 계산을 위한 전체 레코드 수 조회

		paginationInfo.setTotalRecordCount(totalCount); // 전체 레코드 수를 페이징 정보 객체에 설정(총 페이지 수 계산)

		modelMap.addAttribute("accountList", accountList);
		modelMap.addAttribute("paginationInfo", paginationInfo);

		return "/account/accountList";
	}

	// [POST] 콤보박스 데이터 조회
	@PostMapping("selectCombo.do")
	public ModelAndView ajaxtest(HttpServletRequest request) throws Exception{

		Map<String, Object> inOutMap  = CommUtils.getFormParam(request);
		commonService.selectCombo(inOutMap);

		return new ModelAndView(jsonView, inOutMap);
	}

	// [GET] 비용 리스트 엑셀 다운로드
	@GetMapping("listToExcel.do")
	public void downloadExcel(HttpServletResponse response) throws Exception {
		SampleDefaultVO searchVO = new SampleDefaultVO();
		searchVO.setPageIndex(1);
		searchVO.setRecordCountPerPage(Integer.MAX_VALUE); // 모든 레코드를 한 번에 가져옴(페이징 무시)
		searchVO.setPageSize(1);

		// 서비스 호출
		Workbook workbook = accountService.createAccountListExcel(searchVO);

		// HTTP 응답 헤더 설정
		response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"); // MIME 타입 설정
		response.setHeader("Content-Disposition", "attachment; filename=account_list.xlsx"); // 파일 다운로드 설정 및 파일명 지정

		// 워크북을 응답 스트림에 쓰기 및 종료
		workbook.write(response.getOutputStream()); // 생성된 워크북 데이터를 HTTP 응답 스트림으로 전송
		workbook.close(); // 워크북 리소스 해제
	}

	/**
	 *
	 * @param searchVO - 조회할 정보가 담긴 SampleDefaultVO
	 * @param model
	 * @return "egovSampleList"
	 * @exception Exception
	 */
//	@GetMapping("accountList.do")
//	public String selectSampleList(HttpServletRequest request, ModelMap model) throws Exception {
//
//		Map<String, Object> inOutMap  = CommUtils.getFormParam(request);
//		model.put("inOutMap", inOutMap);
//
//		return "/account/accountList";
//	}

}// end of calss
