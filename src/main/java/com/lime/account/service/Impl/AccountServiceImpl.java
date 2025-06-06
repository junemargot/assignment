package com.lime.account.service.Impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

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
	public List<EgovMap> selectAccountList() throws Exception {
		return accountDAO.selectAccountList();
	}

	@Override
	public void updateAccount(Map<String, Object> paramMap) throws Exception {
		accountDAO.updateAccount(paramMap);
	}
}