<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<html>
<head>
  <title>게시물 관리</title>

</head>
<body>
  <!-- 버튼 그룹 (행추가 관련 기능 제거) -->
  <div class="form_box2" style="margin-bottom: 10px;">
    <div class="left">
      <button type="button" class="btn btn-default" onclick="selectAll(this)" data-selected="false">전체선택</button>
    </div>
    <div class="right">
      <button type="button" class="btn btn-success" onclick="restoreBoards()">복원</button>
      <button type="button" class="btn btn-danger" onclick="permanentDeleteBoards()">영구삭제</button>
      <button type="button" class="btn btn-secondary" onclick="location.href='/board/boardList.do'">일반 게시판</button>
    </div>
  </div>

  <!-- 테이블에서 입력행 템플릿 제거 -->
  <table class="table table-bordered table-hover">
    <thead>
    <tr>
      <th width="5%">번호</th>
      <th width="5%">선택</th>
      <th width="40%">제목</th>
      <th width="15%">등록일</th>
      <th width="15%">작성자</th>
      <th width="10%">조회수</th>
      <th width="10%">상태</th>
    </tr>
    </thead>
    <tbody>
    <!-- 입력행 템플릿 없음 -->
    <c:forEach var="board" items="${boardList}">
      <tr style="background-color: #ffe6e6;">
        <td>${board.boardSeq}</td>
        <td>
          <input type="checkbox" class="rowCheck" value="${board.boardSeq}" />
        </td>
        <td>${board.title}</td>
        <td>${board.regDate}</td>
        <td>${board.writer}</td>
        <td>${board.viewCount}</td>
        <td><span style="color: red;">삭제됨</span></td>
      </tr>
    </c:forEach>
    </tbody>
  </table>
</body>
</html>

