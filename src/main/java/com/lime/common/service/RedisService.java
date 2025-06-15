package com.lime.common.service;

import java.util.concurrent.TimeUnit;

public interface RedisService {

  void saveData(String key, String value, long timeout, TimeUnit unit);

  String getData(String key);

  void deleteDate(String key);

  boolean exists(String key);
}
