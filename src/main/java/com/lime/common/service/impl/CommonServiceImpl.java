package com.lime.common.service.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import com.lime.common.service.CommonService;

import egovframework.rte.psl.dataaccess.util.EgovMap;

@Service("commonService")
public class CommonServiceImpl implements CommonService {


	@Resource(name="commonDAO")
	private CommonDAO commonDAO;

	@Override
	public List<EgovMap> selectCombo(Map<String, Object> inOutMap) throws Exception {
		return commonDAO.selectCombo(inOutMap);
	}
}
