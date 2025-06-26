package com.lime.board.model;

import egovframework.example.sample.service.SampleDefaultVO;

import java.time.LocalDate;

public class BoardVo extends SampleDefaultVO {
  private int boardSeq;
  private String title;
  private String writer;
  private int viewCount;
  private String regDate;

  public BoardVo() {}

  public BoardVo(String title, String writer) {
    this.title = title;
    this.writer = writer;
    this.viewCount = 0;
  }

  public int getBoardSeq() {
    return boardSeq;
  }

  public void setBoardSeq(int boardSeq) {
    this.boardSeq = boardSeq;
  }

  public String getTitle() {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public String getWriter() {
    return writer;
  }

  public void setWriter(String writer) {
    this.writer = writer;
  }

  public int getViewCount() {
    return viewCount;
  }

  public void setViewCount(int viewCount) {
    this.viewCount = viewCount;
  }

  public String getRegDate() {
    return regDate;
  }

  public void setRegDate(String regDate) {
    this.regDate = regDate;
  }

  @Override
  public String toString() {
    return "BoardVo{" +
            "boardSeq=" + boardSeq +
            ", title='" + title + '\'' +
            ", writer='" + writer + '\'' +
            ", viewCount=" + viewCount +
            ", regDate=" + regDate +
            '}';
  }
}
