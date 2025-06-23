package com.lime.account.service.Impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import egovframework.example.sample.service.SampleDefaultVO;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import com.lime.account.service.AccountService;

import egovframework.rte.psl.dataaccess.util.EgovMap;

@Service("accountService")
public class AccountServiceImpl implements AccountService {

	@Resource(name="accountDAO")
	private AccountDAO accountDAO;

	@Override
	public void insertAccount(Map<String, Object> paramMap) throws Exception {
		accountDAO.insertAccount(paramMap);
	}

	@Override
	public EgovMap selectAccount(Map<String, Object> paramMap) throws Exception {
		return accountDAO.selectAccount(paramMap);
	}

	@Override
	public List<EgovMap> selectAccountList(SampleDefaultVO searchVO) throws Exception {
		return accountDAO.selectAccountList(searchVO);
	}

	@Override
	public void updateAccount(Map<String, Object> paramMap) throws Exception {
		accountDAO.updateAccount(paramMap);
	}

	@Override
	public void deleteAccount(Map<String, Object> paramMap) throws Exception {
		accountDAO.deleteAccount(paramMap);
	}

	@Override
	public Workbook createAccountListExcel(SampleDefaultVO searchVO) throws Exception {

		// 모든 데이터 조회
		List<EgovMap> accountList = accountDAO.selectAccountList(searchVO);

		// Excel 워크북 생성 (XSSFWorkbook: .xlsx 형식)
		Workbook workbook = new XSSFWorkbook();
		Sheet sheet = workbook.createSheet("회계비용 리스트");

		// 헤더 행 생성 및 데이터 설정
		Row header = sheet.createRow(0); // 첫 번째 행을 헤더 행으로 생성
		header.createCell(0).setCellValue("수익/비용"); // 각 셀에 헤더 텍스트 설정
		header.createCell(1).setCellValue("관");
		header.createCell(2).setCellValue("항");
		header.createCell(3).setCellValue("목");
		header.createCell(4).setCellValue("과");
		header.createCell(5).setCellValue("비용상세");
		header.createCell(6).setCellValue("금액");
		header.createCell(7).setCellValue("등록일");
		header.createCell(8).setCellValue("작성자");

		// 데이터 행 생성 및 설정
		int rowNum = 1;
		for(EgovMap account : accountList) {
			Row row = sheet.createRow(rowNum++);
			row.createCell(0).setCellValue((String) account.get("profitCostNm"));
			row.createCell(1).setCellValue((String) account.get("bigGroupNm"));
			row.createCell(2).setCellValue((String) account.get("middleGroupNm"));
			row.createCell(3).setCellValue((String) account.get("smallGroupNm"));
			row.createCell(4).setCellValue((String) account.get("detailGroupNm"));
			row.createCell(5).setCellValue((String) account.get("comments"));
			row.createCell(6).setCellValue(account.get("transactionMoney").toString());
			row.createCell(7).setCellValue(account.get("regDate").toString());
			row.createCell(8).setCellValue((String) account.get("writer"));
		}

		return workbook;
	}

	@Override
	public int selectAccountTotalCount(SampleDefaultVO searchVO) throws Exception {
		return accountDAO.selectAccountTotalCount(searchVO);
	}


}