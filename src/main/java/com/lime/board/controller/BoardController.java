package com.lime.board.controller;

import com.lime.board.model.BoardVo;
import com.lime.board.service.BoardService;
import com.lime.util.SessionUtil;
import com.lime.user.vo.UserVO;
import egovframework.rte.ptl.mvc.tags.ui.pagination.PaginationInfo;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/board")
public class BoardController {

  private final BoardService boardService;

  public BoardController(BoardService boardService) {
    this.boardService = boardService;
  }

  /*
  * 게시판 목록 페이지
  * */
  @GetMapping("/boardList.do")
  public String boardList(@ModelAttribute("boardVo") BoardVo boardVo, HttpServletRequest request, Model model) throws Exception {
    // 페이징 설정
    PaginationInfo paginationInfo = new PaginationInfo();
    paginationInfo.setCurrentPageNo(boardVo.getPageIndex());
    paginationInfo.setRecordCountPerPage(10);  // 페이지당 게시글 수: 10개
    paginationInfo.setPageSize(10);            // 페이징 블록 크기: 10개

    // SQL 쿼리를 위한 시작/종료 인덱스 계산
    boardVo.setFirstIndex(paginationInfo.getFirstRecordIndex());
    boardVo.setLastIndex(paginationInfo.getLastRecordIndex());
    boardVo.setRecordCountPerPage(paginationInfo.getRecordCountPerPage());

    // 게시글 목록 조회
    List<BoardVo> boardList = boardService.selectBoardList(boardVo);
    model.addAttribute("boardList", boardList);

    // 전체 게시글 수 조회
    int totalCount = boardService.selectBoardListCount(boardVo);
    paginationInfo.setTotalRecordCount(totalCount); // 전체 레코드 수 설정
    model.addAttribute("paginationInfo", paginationInfo);

    // 로그인 사용자 정보 전달
    UserVO loginUser = SessionUtil.getLoginUser(request);
    model.addAttribute("loginUser", loginUser);

    return "/board/boardList";
  }

  /*
   * 게시글 등록
   * */
  @PostMapping("/save.do")
  @ResponseBody
  public Map<String, Object> saveBoard(@ModelAttribute BoardVo boardVo, HttpServletRequest request) throws Exception {
    Map<String, Object> result = new HashMap<>();

    try {
      // 로그인 사용자 정보로 작성자 설정
      UserVO loginUser = SessionUtil.getLoginUser(request);
      boardVo.setWriter(loginUser.getUserName());

      // 게시글 저장 서비스 호출
      boolean success = boardService.insertBoard(boardVo);
      result.put("success", success);
      result.put("message", success ? "게시글이 등록되었습니다." : "게시글 등록에 실패했습니다.");

    } catch(Exception e) {
      result.put("success", false);
      result.put("message", "오류가 발생했습니다: " + e.getMessage());
    }

    return result;
  }

  /*
  * 게시글 수정
  * */
  @PostMapping("/update.do")
  @ResponseBody
  public Map<String, Object> updateBoard(@ModelAttribute BoardVo boardVo) throws Exception {
    Map<String, Object> result = new HashMap<>();

    try {
      boolean success = boardService.updateBoard(boardVo);
      result.put("success", success);
      result.put("message", success ? "게시글이 수정되었습니다." : "게시글 수정에 실패했습니다.");

    } catch(Exception e) {
      result.put("success", false);
      result.put("message", "오류가 발생했습니다: " + e.getMessage());
    }

    return result;
  }

  @PostMapping("/increaseViewCount.do")
  @ResponseBody
  public Map<String, Object> increaseViewCount(@RequestParam("boardSeq") int boardSeq) throws Exception {
    Map<String, Object> result = new HashMap<>();

    try {
      boolean success = boardService.updateViewCount(boardSeq);
      result.put("success", success);

      if(success) {
        BoardVo board = boardService.selectBoardDetail(boardSeq);
        result.put("viewCount", board.getViewCount()); // 갱신된 조회수 반환
      }
    } catch(Exception e) {
      result.put("success", false);
      result.put("message", "오류가 발생했습니다: " + e.getMessage());
    }

    return result;
  }

  /*
  * 게시글 삭제
  * */
  @PostMapping("/delete.do")
  @ResponseBody
  public Map<String, Object> deleteBoard(@RequestParam("seqs") List<Integer> boardseqs) throws Exception {
    Map<String, Object> result = new HashMap<>();

    try {
      boolean success = boardService.deleteBoardList(boardseqs);
      result.put("success", success);

      if(success) {
        result.put("message", boardseqs.size() + "개의 게시글이 삭제되었습니다.");
      } else {
        result.put("message", "게시글 삭제에 실패했습니다.");
      }
    } catch(Exception e) {
      result.put("success", false);
      result.put("message", "오류가 발생했습니다: " + e.getMessage());
    }

    return result;
  }
}
