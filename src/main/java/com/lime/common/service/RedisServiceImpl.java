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
    redisTemplate.opsForValue().set(key, value, timeout, unit); // TTL과 함꼐 데이터 저장
  }

  @Override
  public String getData(String key) {
    return redisTemplate.opsForValue().get(key); // 키로 데이터 조회
  }

  @Override
  public void deleteData(String key) {
    redisTemplate.delete(key); // 키 삭제
  }

  @Override
  public boolean exists(String key) {
    return redisTemplate.hasKey(key); // 키 존재 여부 확인
  }
}
