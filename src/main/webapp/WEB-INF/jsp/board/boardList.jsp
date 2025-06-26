<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<html>
<head>
  <title>게시판 관리</title>
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
            <input type="date" id="inputRegDate" class="form-control" placeholder="등록일" style="width: 100%; background-color: #f8f9fa;" disabled />
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
        <tr>
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
<%--                      firstPageLabel="처음" previousPageLabel="이전" nextPageLabel="다음" lastPageLabel="끝" />--%>
    </div>
    <!-- 페이징용 히든 필드 -->
    <input type="hidden" id="currentPageIndex" value="${boardVo.pageIndex}" />
  </div>

<script type="text/javascript">
  // 현재 페이지 정보
  var currentPage = parseInt(document.getElementById('currentPageIndex').value) || 1;

  // 입력행 토글
  var inputRowVisible = false;
  function toggleInputRow() {
    // 로그인 체크
    var loginUser = '${loginUser.userName}';
    if(!loginUser) {
      alert("로그인 후 이용해주세요.");
      return;
    }

    // 수정모드인 경우 초기화
    resetInputRow();

    var inputRow = document.getElementById('inputRow');
    if(inputRowVisible) {
      inputRow.style.display = 'none';
      inputRowVisible = false;
    } else {
      var tbody = document.getElementById('boardListBody');
      var firstDataRow = tbody.querySelector('tr:not(.input-row)');
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

  // 폼 데이터를 URL 인코딩 형식으로 변환
  function serializeForm(formData) {
    var params = [];
    for(var key in formData) {
      if(formData.hasOwnProperty(key)) {
        params.push(encodeURIComponent(key) + "=" + encodeURIComponent(formData[key]))
      }
    }

    return params.join('&');
  }

  // 행 추가
  function addRow() {
    if(!validateBoard()) return false;

    var formData = {
      title: document.getElementById('inputTitle').value.trim()
    };

    // Ajax 요청
    var xhr = createXHR();
    xhr.open('POST', '/board/save.do', true);
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

    xhr.send(serializeForm(formData));
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

    var seqs = [];
    checkedBoxes.forEach(function(checkbox) {
      seqs.push(checkbox.value);
    });

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

    // 이미 입력행이 열려있으면 닫기
    if(inputRowVisible) toggleInputRow();
    resetInputRow();

    // 선택한 tr 정보
    const checkbox  = checkedList[0];
    const tr        = checkbox.closest('tr');
    const boardSeq  = tr.cells[0].textContent.trim();
    const titleTxt  = tr.cells[2].textContent.trim();
    const regDate   = tr.cells[3].textContent.trim();
    const writerTxt = tr.cells[4].textContent.trim();

    // 숨겨둔 입력행을 선택한 tr 바로 아래 삽입
    const inputTr = document.getElementById('inputRow');
    tr.parentNode.insertBefore(inputTr, tr.nextSibling);
    inputTr.style.display = 'table-row';
    inputRowVisible = true;

    // 입력칸 값 바인딩
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
      btn.textContent = '수정완료';
      btn.onclick = function() { updateRow(); };
    }

    function updateRow() {
      if(!validateBoard()) return;

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

    // 단일 클릭만 실행 -> 250ms 안에 dblclick 오면 취소
    let clickTimer = null;
    function titleClickHandler(e, boardSeq, element) {
      if(clickTimer) return;

      clickTimer = setTimeout(function() {
        increaseViewCount(boardSeq, element);
        clickTimer = null;
      }, 250);
    }

    function cancelSingleClick() {
      if(clickTimer) {
        clearTimeout(clickTimer);
        clickTimer = null;
      }
    }


</script>
</body>
</html>
