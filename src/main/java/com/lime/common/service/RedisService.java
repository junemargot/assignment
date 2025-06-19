package com.lime.common.service;

import java.util.concurrent.TimeUnit;

public interface RedisService {

  // 데이터 저장 (TTL 설정)
  void saveData(String key, String value, long timeout, TimeUnit unit);

  // 데이터 조회
  String getData(String key);

  // 데이터 삭제
  void deleteData(String key);

  // 키 존재 여부
  boolean exists(String key);
}
