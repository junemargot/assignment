package com.lime.common.service;

import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

@Service
public class RedisServiceImpl implements RedisService {

  private final StringRedisTemplate redisTemplate;

  public RedisServiceImpl(StringRedisTemplate redisTemplate) {
    this.redisTemplate = redisTemplate;
  }

  @Override
  public void saveData(String key, String value, long timeout, TimeUnit unit) {
    redisTemplate.opsForValue().set(key, value, timeout, unit);
  }

  @Override
  public String getData(String key) {
    return redisTemplate.opsForValue().get(key);
  }

  @Override
  public void deleteData(String key) {
    redisTemplate.delete(key);
  }

  @Override
  public boolean exists(String key) {
    return redisTemplate.hasKey(key);
  }
}
