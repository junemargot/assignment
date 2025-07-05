package com.lime.board.service;

import com.lime.board.model.BoardVo;
import com.lime.board.persistence.BoardDao;
import egovframework.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.stereotype.Service;

import java.util.List;

@Service("boardService")
public class BoardServiceImpl extends EgovAbstractServiceImpl implements BoardService {

  private final BoardDao boardDao;

  public BoardServiceImpl(BoardDao boardDao) {
    this.boardDao = boardDao;
  }

  @Override
  public List<BoardVo> selectBoardList() throws Exception {
    return boardDao.selectBoardList();
  }

  @Override
  public List<BoardVo> selectBoardList(BoardVo boardVo) throws Exception {
    return boardDao.selectBoardList(boardVo);
  }

  @Override
  public int selectBoardListCount(BoardVo boardVo) throws Exception {
    return boardDao.selectBoardListCount(boardVo);
  }

  @Override
  public BoardVo selectBoardDetail(int boardSeq) throws Exception {
    return boardDao.selectBoardDetail(boardSeq);
  }

  @Override
  public boolean insertBoard(BoardVo boardVo) throws Exception {
    int result = boardDao.insertBoard(boardVo);
    return result > 0;
  }

  @Override
  public boolean updateBoard(BoardVo boardVo) throws Exception {
    int result = boardDao.updateBoard(boardVo);
    return result > 0;
  }

  @Override
  public boolean updateViewCount(int boardSeq) throws Exception {
    int result = boardDao.updateViewCount(boardSeq);
    return result > 0;
  }

  @Override
  public boolean deleteBoard(int boardSeq) throws Exception {
    int result = boardDao.deleteBoard(boardSeq);
    return result > 0;
  }

  @Override
  public boolean deleteBoardList(List<Integer> boardSeqs) throws Exception {
    int result = boardDao.deleteBoardList(boardSeqs);
    return result > 0;
  }

  @Override
  public List<BoardVo> selectDeletedBoardList(BoardVo boardVo) throws Exception {
    return boardDao.selectDeletedBoardList(boardVo);
  }

  @Override
  public int selectDeletedBoardListCount(BoardVo boardVo) throws Exception {
    return boardDao.selectDeletedBoardListCount(boardVo);
  }

  @Override
  public boolean restoreBoard(int boardSeq) throws Exception {
    int result = boardDao.restoreBoard(boardSeq);
    return result > 0;
  }

  @Override
  public boolean restoreBoardList(List<Integer> boardSeqs) throws Exception {
    int result = boardDao.restoreBoardList(boardSeqs);
    return result > 0;
  }

  @Override
  public boolean permanentDeleteBoard(int boardSeq) throws Exception {
    int result = boardDao.permanentDeleteBoard(boardSeq);
    return result > 0;
  }

  @Override
  public boolean permanetDeleteBoardList(List<Integer> boardSeqs) throws Exception {
    int result = boardDao.permanentDeleteBoardList(boardSeqs);
    return result > 0;
  }
}
