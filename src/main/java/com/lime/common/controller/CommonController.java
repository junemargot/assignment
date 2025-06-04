package com.lime.common.controller;

import com.lime.common.service.CommonService;
import egovframework.rte.psl.dataaccess.util.EgovMap;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
public class CommonController {

  @Resource(name="commonService")
  private CommonService commonService;

  @PostMapping("/common/getSubCategory.do")
  @ResponseBody
  public List<EgovMap> getSubCategory(@RequestParam String category) throws Exception {

    Map<String, Object> paramMap = new HashMap<>();
    paramMap.put("category", category);

    return commonService.selectCombo(paramMap);
  }
}
