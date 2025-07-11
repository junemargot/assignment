package com.lime.board.controller;

import com.lime.board.model.BoardVo;
import com.lime.board.service.BoardService;
import com.lime.util.SessionUtil;
import com.lime.user.vo.UserVO;
import egovframework.rte.ptl.mvc.tags.ui.pagination.PaginationInfo;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
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
  public String boardList(@ModelAttribute("boardVo") BoardVo boardVo,
                          @RequestParam(value = "inputRowCount", defaultValue = "0") int inputRowCount,
                          HttpServletRequest request,
                          Model model) throws Exception {

    UserVO loginUser = SessionUtil.getLoginUser(request);

    // 권한 정보 설정
    boardVo.setRoleType(loginUser.getRoleType());
    boardVo.setCurrentUserName(loginUser.getUserName());
    System.out.println("roleType: " + loginUser.getRoleType());

    // 입력행 개수를 고려한 실제 조회할 데이터 개수 계산
    int defaultPageSize = 10; // 기본 페이지 사이즈
    int actualPageSize = defaultPageSize - inputRowCount; // 실제 데이터 조회 개수

    // 실제 페이지 사이즈 확인
    log.info("actualPageSize: {}", actualPageSize);

    // 페이지네이션 정보 설정
    PaginationInfo paginationInfo = new PaginationInfo();
    paginationInfo.setCurrentPageNo(boardVo.getPageIndex());
    paginationInfo.setRecordCountPerPage(actualPageSize);  // 페이지당 게시글 수: 10개
    paginationInfo.setPageSize(10);                        // 페이징 블록 크기: 10개

    // SQL 쿼리를 위한 시작/종료 인덱스 계산
    boardVo.setFirstIndex(paginationInfo.getFirstRecordIndex());
    boardVo.setLastIndex(paginationInfo.getLastRecordIndex());
    boardVo.setRecordCountPerPage(paginationInfo.getRecordCountPerPage());

    // 게시글 목록 조회
    List<BoardVo> boardList = boardService.selectBoardList(boardVo);
    model.addAttribute("boardList", boardList);

    int totalCount = boardService.selectBoardListCount(boardVo); // 전체 게시글 수 카운트
    paginationInfo.setTotalRecordCount(totalCount); // 총 페이지 수 계산 및 이전, 다음 버튼 활성화에 필요
    model.addAttribute("paginationInfo", paginationInfo);
    model.addAttribute("inputRowCount", inputRowCount);

    // 로그인 사용자 정보 전달
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

  /**
   * 삭제된 게시물 관리 페이지 (관리자 전용)
   * */
  @GetMapping("/deletedList.do")
  public String deletedBoardList(@ModelAttribute("boardVo") BoardVo boardVo,
                                  HttpServletRequest request,
                                  Model model) throws Exception {

    UserVO loginUser = SessionUtil.getLoginUser(request);

    if(!"ADMIN".equals(loginUser.getRoleType())) {
      return "redirect:/board/boardList.do";
    }

    boardVo.setRoleType(loginUser.getRoleType());

    // 페이징 처리 (고정 페이지 사이즈)
    int pageSize = 10;  // 고정값

    PaginationInfo paginationInfo = new PaginationInfo();
    paginationInfo.setCurrentPageNo(boardVo.getPageIndex());
    paginationInfo.setRecordCountPerPage(pageSize);  // 고정값 사용
    paginationInfo.setPageSize(10);

    boardVo.setFirstIndex(paginationInfo.getFirstRecordIndex());
    boardVo.setLastIndex(paginationInfo.getLastRecordIndex());
    boardVo.setRecordCountPerPage(paginationInfo.getRecordCountPerPage());

    // 삭제된 게시물 목록 조회
    List<BoardVo> deletedBoardList = boardService.selectDeletedBoardList(boardVo);
    model.addAttribute("boardList", deletedBoardList);

    int totalCount = boardService.selectDeletedBoardListCount(boardVo);
    paginationInfo.setTotalRecordCount(totalCount);
    model.addAttribute("paginationInfo", paginationInfo);

    model.addAttribute("loginUser", loginUser);

    return "/board/deletedList";
  }

  /**
   * 게시물 복원 (단일)
   * */
  @PostMapping("/restore.do")
  @ResponseBody
  public Map<String, Object> restoreBoard(@RequestParam("boardSeq") int boardSeq,
                                          HttpServletRequest request) throws Exception {

    Map<String, Object> result = new HashMap<>();

    try {
      UserVO loginUser = SessionUtil.getLoginUser(request);
      if(!"ADMIN".equals(loginUser.getRoleType())) {
        result.put("success", false);
        result.put("message", "관리자만 복원할 수 있습니다.");
        return result;
      }

      boolean success = boardService.restoreBoard(boardSeq);
      result.put("success", success);
      result.put("message", success ? "게시물이 복원이 처리되었습니다." : "게시물 복원에 실패했습니다.");

    } catch(Exception e) {
      result.put("success", false);
      result.put("message", "오류가 발생했습니다: " + e.getMessage());
    }

    return result;
  }

  /**
   * 게시물 다중 복원
   * */
  @PostMapping("restoreList.do")
  @ResponseBody
  public Map<String, Object> restoreBoardList(@RequestParam("seqs") List<Integer> boardSeqs,
                                              HttpServletRequest request) throws Exception {

    Map<String, Object> result = new HashMap<>();

    try {
      UserVO loginUser = SessionUtil.getLoginUser(request);
      if(!"ADMIN".equals(loginUser.getRoleType())) {
        result.put("success", false);
        result.put("message", "관리자만 복원할 수 있습니다.");
        return result;
      }

      boolean success = boardService.restoreBoardList(boardSeqs);
      result.put("success", success);

      if(success) {
        result.put("message", boardSeqs.size() + "개의 게시물이 복원되었습니다.");
      } else {
        result.put("message", "게시물 복원에 실패했습니다.");
      }
    } catch(Exception e) {
      result.put("success", false);
      result.put("message", "오류가 발생했습니다: " + e.getMessage());
    }

    return result;
  }

  /**
   * 영구삭제 (단일) - 복구 불가능한 완전 삭제
   * */
  @PostMapping("/permanentDelete.do")
  @ResponseBody
  public Map<String, Object> pemanentDeleteBoard(@RequestParam("boardSeq") int boardSeq,
                                                  HttpServletRequest request) throws Exception {

    Map<String, Object> result = new HashMap<>();

    try {
      UserVO loginUser = SessionUtil.getLoginUser(request);
      if(!"ADMIN".equals(loginUser.getRoleType())) {
        result.put("success", false);
        result.put("message", "관리자만 영구삭제할 수 있습니다.");
        return result;
      }

      boolean success = boardService.permanentDeleteBoard(boardSeq);
      result.put("success", success);
      result.put("message", success ? "게시물이 영구삭제 처리되었습니다." : "게시물 영구삭제에 실패했습니다.");

    } catch(Exception e) {
      result.put("success", false);
      result.put("message", "오류가 발생했습니다: " + e.getMessage());
    }

    return result;
  }

  /**
   * 영구삭제 (다중)
   * */
  @PostMapping("/permanentDeleteList.do")
  @ResponseBody
  public Map<String, Object> permanentDeleteBoardList(@RequestParam("seqs") List<Integer> boardSeqs,
                                                      HttpServletRequest request) throws Exception {

    Map<String, Object> result = new HashMap<>();

    try {
      UserVO loginUser = SessionUtil.getLoginUser(request);
      if(!"ADMIN".equals(loginUser.getRoleType())) {
        result.put("success", false);
        result.put("message", "관리자만 영구삭제할 수 있습니다.");
        return result;
      }

      boolean success = boardService.permanetDeleteBoardList(boardSeqs);
      result.put("success", success);

      if(success) {
        result.put("message", boardSeqs.size() + "개의 게시물이 영구삭제되었습니다.");
      } else {
        result.put("message", "영구삭제에 실패했습니다.");
      }
    } catch (Exception e) {
      result.put("success", false);
      result.put("message", "오류가 발생했습니다: " + e.getMessage());
    }

    return result;
  }
}
