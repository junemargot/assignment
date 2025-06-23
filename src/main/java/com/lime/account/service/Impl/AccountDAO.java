package com.lime.account.service.Impl;

import java.util.List;
import java.util.Map;

import egovframework.example.sample.service.SampleDefaultVO;
import org.springframework.stereotype.Repository;

import egovframework.rte.fdl.cmmn.exception.EgovBizException;
import egovframework.rte.psl.dataaccess.EgovAbstractMapper;
import egovframework.rte.psl.dataaccess.util.EgovMap;

@Repository("accountDAO")
public class AccountDAO extends EgovAbstractMapper{

  public void insertAccount(Map<String, Object> paramMap) {
    // MyBatis 매퍼의 namespace + 쿼리 ID 지정
    insert("Account.insertAccount", paramMap);
  }

  public EgovMap selectAccount(Map<String, Object> paramMap) throws Exception{
    return selectOne("Account.selectAccount", paramMap);
  }

  public List<EgovMap> selectAccountList() throws Exception{
    return selectList("Account.selectAccountList");
  }

  public List<EgovMap> selectAccountList(SampleDefaultVO searchVO) throws Exception{
    return selectList("Account.selectAccountListPaging", searchVO);
  }

  public void updateAccount(Map<String, Object> paramMap) throws Exception{
    update("Account.updateAccount", paramMap);
  }

  public void deleteAccount(Map<String, Object> paramMap) throws Exception{
    delete("Account.deleteAccount", paramMap);
  }

  public int selectAccountTotalCount(SampleDefaultVO searchVO) throws Exception{
    return selectOne("Account.selectAccountTotalCount", searchVO);
  }
}