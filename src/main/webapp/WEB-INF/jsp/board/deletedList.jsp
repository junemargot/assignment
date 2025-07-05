<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<html>
<head>
  <title>게시물 관리</title>
  <style>
    th, td {
      text-align: center;
      vertical-align: middle !important;
    }

    .pagination {
      display: flex;
      justify-content: center;
      margin-top: 70px;
      font-size: 14px;
      border: 1px solid #ddd;
      padding: 10px;
    }

    .form_box2 {
      margin-bottom: 10px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      width: 100%;
    }

  </style>
</head>
<body>
  <div class="container" style="max-width: 1400px; margin: 0 auto;">
    <div id="wrap" class="col-md-offset col-sm-15" style="margin-top: 50px;">
      <h2 align="center">게시물 관리</h2>
      <!-- 버튼 그룹 (행추가 관련 기능 제거) -->
      <div class="form_box2" style="margin-bottom: 10px;">
        <div class="left">
        </div>
        <div class="right">
          <button type="button" class="btn btn-secondary" onclick="location.href='/board/boardList.do'">일반 게시판</button>
        </div>
      </div>
    </div>

    <!-- 테이블에서 입력행 템플릿 제거 -->
    <table class="table table-bordered table-hover">
      <thead>
        <tr>
          <th width="5%">번호</th>
          <th width="30%">제목</th>
          <th width="15%">등록일</th>
          <th width="15%">작성자</th>
          <th width="10%">조회수</th>
          <th width="10%">상태</th>
          <th width="15%">관리</th>
        </tr>
      </thead>
      <tbody>
      <!-- 입력행 템플릿 없음 -->
      <c:forEach var="board" items="${boardList}">
        <tr style="background-color: #ffe6e6;">
          <td>${board.boardSeq}</td>
          <td>${board.title}</td>
          <td>${board.regDate}</td>
          <td>${board.writer}</td>
          <td>${board.viewCount}</td>
          <td>
            <span style="color: red;">삭제됨</span>
          </td>
          <td>
            <button type="button" class="btn btn-success btn-sm" onclick="restoreBoard(${board.boardSeq})">복원</button>
            <button type="button" class="btn btn-danger btn-sm" onclick="permanentDeleteBoard(${board.boardSeq})">영구삭제</button>
          </td>
        </tr>
      </c:forEach>
      </tbody>
    </table>

    <!-- 페이지네이션 -->
    <div class="pagination" style="text-align: center;">
      <ui:pagination paginationInfo="${paginationInfo}" type="text" jsFunction="goPage" />
    </div>
    <!-- 페이징용 히든 필드 -->
    <input type="hidden" id="currentPageIndex" value="${boardVo.pageIndex}" />
  </div>

<script>
  function restoreBoard(boardSeq) {
    if(!confirm('해당 게시물을 복원하시겠습니까?')) {
      return;
    }

    const xhr = createXHR();
    xhr.open('POST', '/board/restore.do', true);
    xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');

    xhr.onreadystatechange = function() {
      if(xhr.readyState === 4 && xhr.status === 200) {
        const response = JSON.parse(xhr.responseText);
        alert(response.message);

        if(response.success) {
          window.location.reload();
        }
      }
    };

    xhr.send('boardSeq=' + boardSeq);
  }

  function permanentDeleteBoard(boardSeq) {
    if(!confirm("해당 게시물을 영구삭제하시겠습니까?\n영구삭제된 게시물은 복구할 수 없습니다.")) {
      return;
    }

    if(!confirm("정말로 영구삭제하시겠습니까? 이 작업을 되돌릴 수 없습니다.")) {
      return;
    }

    const xhr = createXHR();
    xhr.open('POST', '/board/permanentDelete.do', true);
    xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');

    xhr.onreadystatechange = function() {
      if(xhr.readyState === 4) {
        if(xhr.status === 200) {
          try {
            const response = JSON.parse(xhr.responseText);
            alert(response.message);

            if(response.success) {
              window.location.reload();
            }
          } catch(e) {
            alert('서버 응답 처리 중 오류가 발생했습니다.');
          }
        } else {
          alert('서버 오류가 발생했습니다. (상태 코드: ' + xhr.status + ')');
        }
      }
    };

    xhr.send('boardSeq=' + boardSeq);
  }



  // 서버와 비동기적으로 통신하기 위한 XMLHttpRequest를 생성하는 함수
  function createXHR() {
    // 1. 최신/표준 브라우저 확인
    if(window.XMLHttpRequest) {
      return new XMLHttpRequest();

    // 2. 구형 Internet Explorer 브라우저 확인 (ActiveXObject 사용)
    } else if(window.ActiveXObject) {
      return new ActiveXObject("Microsoft.XMLHTTP");
    }

    // 3. 지원하지 않는 브라우저인 경우
    return null;
  }

  // 폼 데이터를 URL 인코딩 형식으로 변환
  function serializeForm(formData) {
    var params = []; // 쿼리스트링을 담을 빈 배열 선언
    for(var key in formData) {
      if(formData.hasOwnProperty(key)) {
        params.push(encodeURIComponent(key) + "=" + encodeURIComponent(formData[key]))
      }
    }

    return params.join('&');
  }

// 페이지 이동 함수
function goPage(pageNo) {
  window.location.href = '/board/deletedList.do?pageIndex=' + pageNo;
}

</script>
</body>
</html>

