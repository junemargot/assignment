package com.lime.board.service;

import com.lime.board.model.BoardVo;
import egovframework.rte.psl.dataaccess.util.EgovMap;

import java.util.List;

public interface BoardService {

  // 게시글 목록 조회
  List<EgovMap> selectBoardList() throws Exception;

  // 게시글 목록 조회(페이징)
  List<EgovMap> selectBoardList(BoardVo boardVo) throws Exception;

  // 게시글 총 개수 조회
  int selectBoardListCount(BoardVo boardVo) throws Exception;

  // 게시글 상세 조회
  EgovMap selectBoardDetail(int boardSeq) throws Exception;

  // 게시글 등록
  boolean insertBoard(BoardVo boardVo) throws Exception;

  // 게시글 수정
  boolean updateBoard(BoardVo boardVo) throws Exception;

  // 조회수 증가
  boolean updateViewCount(int boardSeq) throws Exception;

  // 게시글 삭제
  boolean deleteBoard(int boardSeq) throws Exception;

  // 게시글 다중 삭제
  boolean deleteBoardList(List<Integer> boardSeqs) throws Exception;

}
