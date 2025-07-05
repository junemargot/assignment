package com.lime.board.service;

import com.lime.board.model.BoardVo;

import java.util.List;

public interface BoardService {

  // 게시글 목록 조회
  List<BoardVo> selectBoardList() throws Exception;

  // 게시글 목록 조회(페이징)
  List<BoardVo> selectBoardList(BoardVo boardVo) throws Exception;

  // 게시글 총 개수 조회
  int selectBoardListCount(BoardVo boardVo) throws Exception;

  // 게시글 상세 조회
  BoardVo selectBoardDetail(int boardSeq) throws Exception;

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

  // 삭제된 게시물 목록 조회
  List<BoardVo> selectDeletedBoardList(BoardVo boardVo) throws Exception;

  // 삭제된 게시물 총 개수 조회
  int selectDeletedBoardListCount(BoardVo boardVo) throws Exception;

  // 게시물 복원 (단일)
  boolean restoreBoard(int boardSeq) throws Exception;

  // 게시물 복원 (다중)
  boolean restoreBoardList(List<Integer> boardSeqs) throws Exception;

  // 게시물 영구 삭제 (단일)
  boolean permanentDeleteBoard(int boardSeq) throws Exception;

  // 게시물 영구 삭제 (다중)
  boolean permanetDeleteBoardList(List<Integer> boardSeqs) throws Exception;
}
