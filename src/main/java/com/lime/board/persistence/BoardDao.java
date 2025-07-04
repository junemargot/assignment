package com.lime.board.persistence;

import com.lime.board.model.BoardVo;
import egovframework.rte.psl.dataaccess.EgovAbstractMapper;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository("boardDao")
public class BoardDao extends EgovAbstractMapper {

  // 게시글 목록 조회
  public List<BoardVo> selectBoardList() throws Exception {
    return selectList("boardDao.selectBoardList");
  }

  // 게시글 목록 조회(페이징)
  public List<BoardVo> selectBoardList(BoardVo boardVo) throws Exception {
    return selectList("boardDao.selectBoardList", boardVo);
  }

  // 게시글 총 개수 조회
  public int selectBoardListCount(BoardVo boardVo) throws Exception {
    return selectOne("boardDao.selectBoardListCount", boardVo);
  }

  // 게시글 상세 조회
  public BoardVo selectBoardDetail(int boardSeq) throws Exception {
    return selectOne("boardDao.selectBoardDetail", boardSeq);
  }

  // 게시글 등록
  public int insertBoard(BoardVo boardVo) throws Exception {
    return insert("boardDao.insertBoard", boardVo);
  }

  // 게시글 수정
  public int updateBoard(BoardVo boardVo) throws Exception {
    return update("boardDao.updateBoard", boardVo);
  }

  // 조회수 증가
  public int updateViewCount(int boardSeq) throws Exception {
    return update("boardDao.updateViewCount", boardSeq);
  }

  // 게시글 삭제
  public int deleteBoard(int boardSeq) throws Exception {
    return delete("boardDao.deleteBoard", boardSeq);
  }

  // 게시글 다중 삭제
  public int deleteBoardList(List<Integer> boardSeqs) throws Exception {
    return delete("boardDao.deleteBoardList", boardSeqs);
  }

  // 삭제된 게시물 목록 조회
  public List<BoardVo> selectDeletedBoardList(BoardVo boardVo) throws Exception {
    return selectList("boardDao.selectDeletedBoardList", boardVo);
  }

  // 삭제된 게시물 총 개수 조회
  public int selectDeletedBoardListCount(BoardVo boardVo) throws Exception {
    return selectOne("boardDao.selectDeletedBoardListCount", boardVo);
  }
}
