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
      vertical-align: middle;
    }

    .pagination {
      display: flex;
      justify-content: center;
      margin-top: 70px;
      font-size: 14px;
      border: 1px solid #ddd;
      padding: 10px;
    }

    .input-row {
      background-color: #f8f9fa;
      display: none;
    }

    .input-row input {
      font-size: 12px;
      padding: 4px;
      height: 30px;
    }
  </style>
</head>
<body>
  <div class="container">
    <div id="wrap" class="col-md-offset col-sm-15" style="margin-top: 50px;">
      <div align="center"><h2>게시물 리스트</h2></div>
      <!-- 버튼 그룹 -->
      <div class="form_box2 col-md-offset-7" align="right" style="margin-bottom: 10px;">
        <div class="right">
          <button type="button" class="btn btn-default" onclick="toggleInputRow()">행추가</button>
          <button type="button" class="btn btn-default" onclick="editRow()">행수정</button>
          <button type="button" class="btn btn-default" onclick="deleteRows()">행삭제</button>
        </div>
      </div>
    </div>

    <!-- 게시판 테이블 -->
    <table class="table table-bordered table-hover">
      <thead>
        <tr>
          <th width="5%">번호</th>
          <th width="5%">선택</th>
          <th width="40%">제목</th>
          <th width="15%">등록일</th>
          <th width="15%">작성자</th>
          <th width="10%">조회수</th>
        </tr>
      </thead>
      <tbody id="boardListBody">
        <!-- 입력행(기본 숨김) -->
        <tr class="input-row" id="inputRow" >
          <td></td>
          <td></td>
          <td>
            <input type="text" id="inputTitle" name="title" class="form-control" placeholder="내용을 입력해주세요" style="width: 100%;" />
          </td>
          <td>
            <input type="date" id="inputRegDate" name="regDate" class="form-control" placeholder="등록일" style="width: 100%; background-color: #f8f9fa;" disabled />
          </td>
          <td>
            <input type="text" id="inputWriter" name="writer" class="form-control" value="${loginUser.userName}" style="width: 100%; background-color: #f8f9fa;" disabled />
          </td>
          <td>
            <button type="button" class="btn btn-default btn-sm" onclick="addRow()">등록</button>
          </td>
        </tr>

      <!-- 실제 데이터(서버 렌더링) -->
      <c:forEach var="board" items="${boardList}">
        <tr class="data-row">
          <td>${board.boardSeq}</td>
          <td><input type="checkbox" class="rowCheck" value="${board.boardSeq}" /></td>
          <td>
            <span class="title-link"
                  onclick="titleClickHandler(event, ${board.boardSeq}, this)"
                  ondblclick="cancelSingleClick()"
                  style="cursor: pointer;">
                ${board.title}
            </span>
          </td>
          <td>${board.regDate}</td>
          <td>${board.writer}</td>
          <td class="view-count">${board.viewCount}</td>
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

<script type="text/javascript">
  // 현재 페이지 정보
  var currentPage = parseInt(document.getElementById('currentPageIndex').value) || 1;

  // 입력행 토글 관리
  var inputRowVisible = false;
  function toggleInputRow() {
    // 입력행의 내용 초기화 설정(수정모드 등에서 남아있는 값 초기화)
    resetInputRow();

    var inputRow = document.getElementById('inputRow');
    if(inputRowVisible) {
      inputRow.style.display = 'none';
      inputRowVisible = false;
    } else {
      var tbody = document.getElementById('boardListBody');
    var firstDataRow = tbody.querySelector('.data-row');
      tbody.insertBefore(inputRow, firstDataRow);

      inputRow.style.display = 'table-row';
      inputRowVisible = true;
      document.getElementById('inputTitle').focus();

      // 현재 날짜 설정
      var today = new Date().toISOString().split('T')[0];
      document.getElementById('inputRegDate').value = today;
    }
  }

  function resetInputRow() {
    // 입력 필드 초기화
    document.getElementById('inputTitle').value = '';
    document.getElementById('inputRegDate').value = '';
    document.getElementById('inputWriter').value = '${loginUser.userName}';

    // hidden 필드 제거
    var seqHidden = document.getElementById('inputSeqHidden');
    if(seqHidden) {
      seqHidden.remove();
    }

    // 버튼 상태 초기화
    var btn = document.querySelector('#inputRow button');
    btn.textContent = '등록';
    btn.onclick = function() { addRow(); };
  }

  // 페이지 이동
  function goPage(pageNo) {
    window.location.href = '/board/boardList.do?pageIndex=' + pageNo;
  }


  // 폼 유효성 검증
  function validateBoard() {
    var title = document.getElementById('inputTitle').value.trim();

    if(!title) {
      alert('내용을 입력해주세요.');
      document.getElementById('inputTitle').focus();
      return false;
    }

    return true;
  }

  // XMLHttpRequest로 Ajax 통신 구현
  function createXHR() {
    if(window.XMLHttpRequest) {
      return new XMLHttpRequest();
    } else if(window.ActiveXObject) {
      return new ActiveXObject("Microsoft.XMLHTTP");
    }

    return null;
  }

  // 데이터 서버에 저장
  function addRow() {
    if(!validateBoard()) return false;

    // 폼 데이터 객체 생성
    var formData = {
      title: document.getElementById('inputTitle').value.trim()
    };

    // XMLHttpRequest 객체 생성
    var xhr = createXHR();
    xhr.open('POST', '/board/save.do', true);
    xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded'); // 요청 헤더에 데이터를 폼 전송 방식(쿼리스트링)으로 설정

    // 응답 처리 함수 등록
    xhr.onreadystatechange = function() {
      if(xhr.readyState === 4 && xhr.status === 200) {
        var response = JSON.parse(xhr.responseText);
        if(response.success) {
            alert(response.message);
            window.location.reload();
        } else {
            alert(response.message);
        }
      }
    };

    xhr.send(serializeForm(formData));
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

  // 행 삭제
  function deleteRows() {
    var checkedBoxes = document.querySelectorAll('.rowCheck:checked');
    if(checkedBoxes.length === 0) {
      alert('삭제할 게시글을 선택해주세요.');
      return;
    }

    if(!confirm(checkedBoxes.length + '개의 게시글을 삭제하시겠습니까?')) {
      return;
    }

    // 선택된 게시글의 식별자 추출
    var seqs = [];
    checkedBoxes.forEach(function(checkbox) { // 선택된 각 체크박스를 순회하며 해당 체크박스의 value(게시글 식별자)를 seqs 배열에 추가
      seqs.push(checkbox.value);
    });

    // XMLHttpRequest 객체 생성 및 요청 준비
    var xhr = createXHR();
    xhr.open('POST', '/board/delete.do', true);
    xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');

    xhr.onreadystatechange = function() {
      if(xhr.readyState === 4 && xhr.status === 200) {
        var response = JSON.parse(xhr.responseText);
        if(response.success) {
          alert(response.message);
          window.location.reload();
        } else {
          alert(response.message);
        }
      }
    };

    var formData = 'seqs=' + seqs.join('&seqs=');
    xhr.send(formData);
  }

  // 행 수정
  function editRow() {
    // 수정할 행 선택 여부
    const checkedList = document.querySelectorAll('.rowCheck:checked');
    if(checkedList.length === 0) {
      alert('수정할 게시글을 선택해주세요.');
      return;
    }

    if(checkedList.length > 1) {
      alert("한 번에 하나의 게시물만 수정할 수 있습니다.");
      return;
    }

    // 이미 입력행이 열려있으면 닫고, 필드 초기화
    if(inputRowVisible) toggleInputRow();
    resetInputRow();

    // 선택한 게시글의 정보
    const checkbox  = checkedList[0];
    const tr        = checkbox.closest('tr');
    const boardSeq  = tr.cells[0].textContent.trim();
    const titleTxt  = tr.cells[2].textContent.trim();
    const regDate   = tr.cells[3].textContent.trim();
    const writerTxt = tr.cells[4].textContent.trim();

    // 숨겨둔 입력행을 선택된 행 바로 아래 삽입 및 표시
    const inputTr = document.getElementById('inputRow');
    tr.parentNode.insertBefore(inputTr, tr.nextSibling);
    inputTr.style.display = 'table-row';
    inputRowVisible = true;

    // 입력 필드에 기존 게시글 값 바인딩
    document.getElementById('inputTitle').value = titleTxt;
    document.getElementById('inputRegDate').value = regDate;
    document.getElementById('inputWriter').value = writerTxt;

    // boardSeq를 hidden 필드로 세팅
    let seqHidden = document.getElementById('inputSeqHidden');
    if(!seqHidden) {
      seqHidden = document.createElement('input');
      seqHidden.type = 'hidden';
      seqHidden.id = 'inputSeqHidden';
      seqHidden.name = 'boardSeq';
      inputTr.appendChild(seqHidden);
    }
    seqHidden.value = boardSeq;

    // 등록버튼의 onclick -> 업데이트
    const btn = inputTr.querySelector('button');
    btn.textContent = "수정완료";
    btn.onclick = function() { updateRow(); };
  }

  // 수정 데이터 서버 전송
  function updateRow() {
    if(!validateBoard()) return;

    // 수정된 게시글 데이터를 담을 객체 생성
    const formData = {
      boardSeq: document.getElementById('inputSeqHidden').value,
      title   : document.getElementById('inputTitle').value.trim(),
      regDate : document.getElementById('inputRegDate').value,
      writer  : document.getElementById('inputWriter').value.trim()
    };

    const xhr = createXHR();
    xhr.open('POST', '/board/update.do', true);
    xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    xhr.onreadystatechange = function () {
      if (xhr.readyState === 4 && xhr.status === 200) {
        const res = JSON.parse(xhr.responseText);
        alert(res.message);
        if (res.success) location.reload();
      }
    };

    xhr.send(serializeForm(formData));
  }

  // 단일 클릭 처리 로직 (더블 클릭 방지)
  let clickTimer = null; // 단일클릭, 더블클릭 구분하는 용도의 변수
  function titleClickHandler(e, boardSeq, element) {
    if(clickTimer) return; // clickTimer가 null이므로 increaseViewCount()

    clickTimer = setTimeout(function() {
      increaseViewCount(boardSeq, element);
      clickTimer = null;
    }, 250);
  }

  // 단일 클릭 취소 (더블클릭 시 호출됨)
  function cancelSingleClick() {
    if(clickTimer) { // 클릭타이머가 설정되어 있다면,
      clearTimeout(clickTimer); // 해당 타이머를 취소해 함수가 실행되지 않도록하고
      clickTimer = null; // 다시 초기화
    }
  }

  // 조회수 증가
  function increaseViewCount(boardSeq, element) {
    var xhr = createXHR();
    xhr.open('POST', '/board/increaseViewCount.do', true);
    xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');

    xhr.onreadystatechange = function() {
      if(xhr.readyState === 4 && xhr.status === 200) {
        var response = JSON.parse(xhr.responseText);
        if(response.success) {
          // 조회수 업데이트
          var viewCountCell = element.closest('tr').querySelector('.view-count');
          viewCountCell.textContent = response.viewCount;
        }
      }
    };

    xhr.send('boardSeq=' + boardSeq);
  }


</script>
</body>
</html>
