package com.lime.account.service;

import java.util.List;
import java.util.Map;

import egovframework.example.sample.service.SampleDefaultVO;
import egovframework.rte.psl.dataaccess.util.EgovMap;
import org.apache.poi.ss.usermodel.Workbook;

public interface AccountService {

  void insertAccount(Map<String, Object> paramMap) throws Exception;

  EgovMap selectAccount(Map<String, Object> paramMap) throws Exception;

  List<EgovMap> selectAccountList(SampleDefaultVO searchVO) throws Exception;

  int selectAccountTotalCount(SampleDefaultVO searchVO) throws Exception;

  void updateAccount(Map<String, Object> paramMap) throws Exception;

  void deleteAccount(Map<String, Object> paramMap) throws Exception;

  Workbook createAccountListExcel(SampleDefaultVO searchVO) throws Exception;
}
