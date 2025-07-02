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
  <div class="container" style="max-width: 1400px; margin: 0 auto;">
    <div id="wrap" class="col-md-offset col-sm-15" style="margin-top: 50px;">
      <div align="center"><h2>게시물 리스트</h2></div>
      <!-- 버튼 그룹 -->
      <div class="form_box2" style="margin-bottom: 10px; display: flex; justify-content: space-between; align-items: center; width: 100%;">
        <div class="left">
          <button type="button" class="btn btn-default" id="selectAllBtn" onclick="selectAll(this)" data-selected="false">전체선택</button>
        </div>
        <div class="right">
<%--          <button type="button" class="btn btn-default" onclick="toggleInputRow()">행추가</button>--%>
          <button type="button" class="btn btn-default" onclick="addInputRow()">행추가</button>
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
        <tr id="inputRowTemplate" class="input-row" style="display: none;">
          <td class="row-no">-</td>
          <td>
            <input type="checkbox" class="rowCheck tempCheck" data-temp="true" />
          </td>
<%--        <tr class="input-row" id="inputRow" >--%>
<%--          <td></td>--%>
<%--          <td></td>--%>
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
    <!-- 입력행 개수 히든 필드 -->
    <input type="hidden" id="inputRowCount" value="${inputRowCount}" />
  </div>

<script type="text/javascript">
  // 페이지 로드 시 입력행 복원
  document.addEventListener('DOMContentLoaded', function() {
    var savedInputRowCount = parseInt(document.getElementById('inputRowCount').value) || 0;

    // 저장된 입력행 개수만큼 입력행 추가 (서버 요청 없이)
    for(var i = 0; i < savedInputRowCount; i++) {
      addInputRowSilent(); // 페이지 새로고침하지 않는 버전
    }
  });

  // 페이지 새로고침 없이 입력행만 추가하는 함수
  function addInputRowSilent() {
    // addInputRow()와 동일하지만 updatePageWithInputRows() 호출 제외
    var tbody = document.getElementById('boardListBody');
    var currentInputRows = tbody.querySelectorAll('.dynamic-input-row').length;

    if(currentInputRows >= maxRowsPerPage) {
        return;
    }

    inputRowCounter++;
    var template = document.getElementById('inputRowTemplate');
    var newRow = template.cloneNode(true);

    newRow.id = 'inputRow_' + inputRowCounter;
    newRow.style.display = 'table-row';
    newRow.classList.add('dynamic-input-row');

    var titleInput = newRow.querySelector('input[name="title"]');
    var regDateInput = newRow.querySelector('input[name="regDate"]');
    var writerInput = newRow.querySelector('input[name="writer"]');
    var checkbox = newRow.querySelector('.tempCheck');
    var button = newRow.querySelector('button');

    titleInput.id = 'inputTitle_' + inputRowCounter;
    regDateInput.id = 'inputRegDate_' + inputRowCounter;
    writerInput.id = 'inputWriter_' + inputRowCounter;
    checkbox.setAttribute('data-row-id', inputRowCounter);

    var today = new Date().toISOString().split('T')[0];
    regDateInput.value = today;
    writerInput.value = '${loginUser.userName}';

    button.onclick = function () { addRowFromInput(inputRowCounter); };

    var firstDataRow = tbody.querySelector('.data-row');
    if(firstDataRow) {
        tbody.insertBefore(newRow, firstDataRow);
    } else {
        tbody.appendChild(newRow);
    }
  }

  // 전역 변수 추가
  var inputRowCounter = 0;
  var maxRowsPerPage = 10;

  // 현재 페이지 정보
  var currentPage = parseInt(document.getElementById('currentPageIndex').value) || 1;
  var inputRowVisible = false;

  // 입력행 가시성 토글
  function toggleInputRow() {
    resetInputRow(); // 입력행의 내용 초기화 설정(수정모드 등에서 남아있는 값 초기화)

    var inputRow = document.getElementById('inputRow');
    if(inputRowVisible) {
      inputRow.style.display = 'none';
      inputRowVisible = false;
    } else {
      var tbody = document.getElementById('boardListBody');
      var firstDataRow = tbody.querySelector('.data-row');
      tbody.insertBefore(inputRow, firstDataRow); // insertBefore(삽입할_노드, 기준_노드)

      inputRow.style.display = 'table-row';
      inputRowVisible = true;
      document.getElementById('inputTitle').focus();

      // 현재 날짜 설정
      var today = new Date().toISOString().split('T')[0]; // "2025-06-28T12:34:56.789Z";
      document.getElementById('inputRegDate').value = today;
    }
  }

  // ** 추가 - 새로운 행추가 함수
  function addInputRow() {
    var tbody = document.getElementById('boardListBody');
    // var currentDataRows = tbody.querySelectorAll('.data-row').length;
    var currentInputRows = tbody.querySelectorAll('.dynamic-input-row').length;

    // 페이지당 최대 행 수 체크 (페이지당 최대 10개까지 가능)
    if(currentInputRows >= maxRowsPerPage) {
      alert('한 페이지에 최대 ' + maxRowsPerPage + '개의 행만 표시할 수 있습니다.');
      return;
    }

    inputRowCounter++;
    var template = document.getElementById('inputRowTemplate');
    var newRow = template.cloneNode(true);

    // 새 행의 속성 설정
    newRow.id = 'inputRow_' + inputRowCounter;
    newRow.style.display = 'table-row';
    newRow.classList.add('dynamic-input-row');

    // 입력 필드들의 ID 변경
    var titleInput = newRow.querySelector('input[name="title"]');
    var regDateInput = newRow.querySelector('input[name="regDate"]');
    var writerInput = newRow.querySelector('input[name="writer"]');
    var checkbox = newRow.querySelector('.tempCheck');
    var button = newRow.querySelector('button');

    titleInput.id = 'inputTitle_' + inputRowCounter;
    regDateInput.id = 'inputRegDate_' + inputRowCounter;
    writerInput.id = 'inputWriter_' + inputRowCounter;
    checkbox.setAttribute('data-row-id', inputRowCounter);

    // 현재 날짜 설정
    var today = new Date().toISOString().split('T')[0];
    regDateInput.value = today;
    writerInput.value = '${loginUser.userName}';

    // 등록 버튼 이벤트 수정
    button.onclick = function () { addRowFromInput(inputRowCounter); };

    // 첫번째 데이터 행 앞에 삽입
    var firstDataRow = tbody.querySelector('.data-row');
    if(firstDataRow) {
      tbody.insertBefore(newRow, firstDataRow);
    } else {
      tbody.appendChild(newRow);
    }

    // 서버에 입력행 개수 업데이트 요청
    updatePageWithInputRows();

    // 포커스 설정
    titleInput.focus();
  }

  // 입력행 개수를 고려한 페이지 새로고침
  function updatePageWithInputRows() {
    var currentInputRows = document.querySelectorAll('.dynamic-input-row').length;
    var currentPage = parseInt(document.getElementById('currentPageIndex').value) || 1;

    // 현재 페이지를 입력행 개수와 함께 새로고침
    window.location.href = '/board/boardList.do?pageIndex=' + currentPage + '&inputRowCount=' + currentInputRows;
  }

  // 입력행에서 실제 데이터 등록
  function addRowFromInput(rowId) {
    var titleInput = document.getElementById('inputTitle_' + rowId);

    if (!titleInput.value.trim()) {
      alert('내용을 입력해주세요.');
      titleInput.focus();
      return false;
    }

    var formData = {
      title: titleInput.value.trim()
    };

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


  // 새 글 등록을 위한 input 초기화 설정
  function resetInputRow() {
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
  // function goPage(pageNo) {
  //   window.location.href = '/board/boardList.do?pageIndex=' + pageNo;
  // }

  function goPage(pageNo) {
    var currentInputRows = document.querySelectorAll('.dynamic-input-row').length;
    var url = '/board/boardList.do?pageIndex=' + pageNo;

    if(currentInputRows > 0) {
      url += '&inputRowCount=' + currentInputRows;
    }
    window.location.href = url;
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

  // 새로운 데이터를 서버에 저장하는 역할을 하는 함수
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

  // 전체선택 함수
  function selectAll(button) {
    // 현재 페이지의 게시글 체크박스만 선택 (input[type=checkbox].rowCheck, tempCheck 제외)
    var isSelected = button.getAttribute('data-selected') === 'true'; // 버튼의 data-selected 속성으로 선택/해제 상태 판별
    var checkboxes = document.querySelectorAll('.rowCheck'); // 현재 페이지의 게시글 체크박스만 선택

    // 전체선택 -> 전체해제, 전체해제 -> 전체선택
    checkboxes.forEach(function(checkbox) {
      checkbox.checked = !isSelected;
    });

    // 버튼 상태 및 텍스트 업데이트
    if(isSelected) {
      button.textContent = '전체선택';
      button.setAttribute('data-selected', 'false');
    } else {
      button.textContent = '전체해제';
      button.setAttribute('data-selected', 'true');
    }
  }

  // 행 삭제
  function deleteRows() {
    var checkedBoxes = document.querySelectorAll('.rowCheck:checked');
    // var checkedBoxes = document.querySelectorAll('.rowCheck:checked:not(.tempCheck)');

    // 실제 데이터와 임시 입력행 분리
    var realDataBoxes = [];
    var tempInputBoxes = [];
    var cannotDeleteTemp = [];

    checkedBoxes.forEach(function(checkbox) {
      if(checkbox.classList.contains('tempCheck')) {
        var row = checkbox.closest('tr');
        var titleInput = row.querySelector('input[name="title"]');
        if(titleInput && titleInput.value.trim()) {
          cannotDeleteTemp.push('입력된 내용이 있는 행');
        } else {
          tempInputBoxes.push(checkbox);
        }
      } else {
        realDataBoxes.push(checkbox);
      }
    });

    // 1. 임시 입력행 먼저 삭제 (dom에서 삭제)
    tempInputBoxes.forEach(function(checkbox) {
      var row = checkbox.closest('tr');
      row.remove();
    });

    // 2. 실제 데이터가 있으면 서버 요청
    if(realDataBoxes.length > 0) {
      var seqs = [];
      realDataBoxes.forEach(function(checkbox) {
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
    } else {
      // 임시 입력행만 삭제한 경우
      alert('선택한 입력행이 삭제되었습니다.');
    }
  }



    // before
  //   if(checkedBoxes.length === 0) {
  //     alert('삭제할 게시글을 선택해주세요.');
  //     return;
  //   }
  //
  //   if(!confirm(checkedBoxes.length + '개의 게시글을 삭제하시겠습니까?')) {
  //     return;
  //   }
  //
  //   // 선택된 게시글의 식별자 추출
  //   var seqs = [];
  //   checkedBoxes.forEach(function(checkbox) { // 선택된 각 체크박스를 순회하며 해당 체크박스의 value(게시글 식별자)를 seqs 배열에 추가
  //     seqs.push(checkbox.value);
  //   });
  //
  //   // XMLHttpRequest 객체 생성 및 요청 준비
  //   var xhr = createXHR();
  //   xhr.open('POST', '/board/delete.do', true);
  //   xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
  //
  //   xhr.onreadystatechange = function() {
  //     if(xhr.readyState === 4 && xhr.status === 200) {
  //       var response = JSON.parse(xhr.responseText);
  //       if(response.success) {
  //         alert(response.message);
  //         window.location.reload();
  //       } else {
  //         alert(response.message);
  //       }
  //     }
  //   };
  //
  //   var formData = 'seqs=' + seqs.join('&seqs=');
  //   xhr.send(formData);
  // }

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
    // console.log(checkedList);
    // console.log(checkedList[0]);
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
