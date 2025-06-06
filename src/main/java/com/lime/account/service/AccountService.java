package com.lime.account.service;

import java.util.List;
import java.util.Map;

import egovframework.rte.psl.dataaccess.util.EgovMap;

public interface AccountService {

  void insertAccount(Map<String, Object> paramMap) throws Exception;

  EgovMap selectAccount(Map<String, Object> paramMap) throws Exception;

  List<EgovMap> selectAccountList() throws Exception;

  void updateAccount(Map<String, Object> paramMap) throws Exception;
}
