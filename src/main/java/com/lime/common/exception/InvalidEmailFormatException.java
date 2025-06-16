package com.lime.common.exception;

public class InvalidEmailFormatException extends RuntimeException {

  public InvalidEmailFormatException(String message) {
    super(message);
  }
}
