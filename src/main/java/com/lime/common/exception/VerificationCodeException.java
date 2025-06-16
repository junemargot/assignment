package com.lime.common.exception;

public class VerificationCodeException extends RuntimeException {

  public VerificationCodeException(String message) {
    super(message);
  }

  public VerificationCodeException(String message, Throwable cause) {
    super(message, cause);
  }
}
