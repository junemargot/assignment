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
            <button type="button" class="btn btn-default btn-sm">등록</button>
          </td>
        </tr>

      <!-- 실제 데이터(서버 렌더링) -->
      <c:forEach var="board" items="${boardList}">
        <tr class="data-row">
          <td>${board.boardSeq}</td>
          <td>
            <input type="checkbox" class="rowCheck" value="${board.boardSeq}" />
          </td>
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
  // 전역 변수 추가
  let inputRowCounter = 0; // 동적으로 추가되는 행들의 고유 ID를 부여하기 위한 카운터
  const maxInputRows= 5; // 한 페이지에 최대로 표시할 수 있는 입력 행의 개수

  // DOM 문서 로드되면 실행됨
  document.addEventListener('DOMContentLoaded', function() {
    var savedInputRowCount = parseInt(document.getElementById('inputRowCount').value) || 0;

    // 새로고침 감지
    var isRefresh = (
      performance.navigation.type === 1 ||  // 새로고침
      (performance.getEntriesByType('navigation')[0] &&
        performance.getEntriesByType('navigation')[0].type === 'reload')
    );

    if(isRefresh) {
      // 새로고침이고 inputRowCount가 있으면 깨끗한 URL로 리다이렉트
      var urlParams = new URLSearchParams(window.location.search);
      if(urlParams.has('inputRowCount')) {
        var currentPage = parseInt(document.getElementById('currentPageIndex').value) || 1;
        var cleanUrl = '/board/boardList.do?pageIndex=' + currentPage;
        window.location.replace(cleanUrl);
        return;
      }
    } else {
      // 새로고침이 아니면 기존 로직 수행
      var urlParams = new URLSearchParams(window.location.search);
      var hasInputRowParam = urlParams.has('inputRowCount');

      if(savedInputRowCount > 0 && hasInputRowParam) {
        for(var i = 0; i < savedInputRowCount; i++) {
          addInputRowToDOM(false);
        }
      }
    }
  });

  // 동적 입력 행을 DOM에 추가하는 핵심 함수
  // saveToServer: true이면 서버에 입력 행 개수 업데이트 요청, false이면 요청 안함 (페이지 로드 시 사용)
  function addInputRowToDOM(saveToServer) {
    const tbody = document.getElementById('boardListBody');
    const currentInputRows = tbody.querySelectorAll('.dynamic-input-row, .edit-input-row').length;

    if(currentInputRows >= maxInputRows) {
      if(saveToServer) alert('한 페이지에 최대 ' + maxInputRows + '개의 행만 표시할 수 있습니다.');
      return null; // 추가 실패
    }

    inputRowCounter++; // 새 행에 부여할 고유 ID 증가
    const template = document.getElementById('inputRowTemplate');
    const newRow = template.cloneNode(true); // 템플릿 복제 (자식 요소 포함)

    // 새 행의 ID와 클래스 설정
    newRow.id = 'inputRow_' + inputRowCounter; // newRow라는 전체 <tr> 요소 자체에 id를 부여하는 것.
    newRow.style.display = 'table-row';        // 보이도록 설정
    newRow.classList.add('dynamic-input-row'); // 동적 입력 행임을 표시

    // 복제된 행 newRow 내부 요소에 접근하여 각 변수에 할당
    const titleInput = newRow.querySelector('input[name="title"]'); // newRow 안에서 name이 "title"인 input 태그를 찾아 titleInput 변수에 연결
    const regDateInput = newRow.querySelector('input[name="regDate"]');
    const writerInput = newRow.querySelector('input[name="writer"]');
    const checkbox = newRow.querySelector('.tempCheck'); // newRow 안에서 class가 "tempCheck"인 요소를 찾아 checkbox 변수에 연결
    const button = newRow.querySelector('button');

    // 각 입력 필드에 고유 ID 부여
    titleInput.id = 'inputTitle_' + inputRowCounter;
    regDateInput.id = 'inputRegDate_' + inputRowCounter;
    writerInput.id = 'inputWriter_' + inputRowCounter;
    checkbox.setAttribute('data-row-id', inputRowCounter); // 체크박스에 연결된 행 ID 저장

    // 기본 값 설정 (등록일은 현재 날짜, 작성자는 로그인 유저)
    const today = new Date().toISOString().split('T')[0];
    regDateInput.value = today;
    writerInput.value = '${loginUser.userName}';

    // 등록 버튼에 클릭 이벤트 연결 (현재 생성된 행의 ID를 넘겨줌)
    button.onclick = function () { addRowFromInput(newRow.id); };

    // DOM에 삽입: 첫 번째 실제 데이터 행 앞에 삽입
    const firstDataRow = tbody.querySelector('.data-row');
    if(firstDataRow) {
      tbody.insertBefore(newRow, firstDataRow);
    } else {
      tbody.appendChild(newRow); // 데이터 행이 없으면 tbody 마지막에 추가
    }

    if(saveToServer) {
      updatePageWithInputRows(); // 서버에 입력 행 개수 업데이트 요청
    }
    return newRow; // 새로 생성된 행 반환
  }



  // 현재 페이지 정보
  var currentPage = parseInt(document.getElementById('currentPageIndex').value) || 1;
  var inputRowVisible = false;

  // ** 추가 - 새로운 행추가 함수
  function addInputRow() {
    addInputRowToDOM(true); // 서버에 개수 업데이트 요청
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
    const rowElement = document.getElementById(rowId);
    const titleInput = rowElement.querySelector('input[name="title"]');

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
          // 등록 성공 시 입력행 초기화해서 페이지 이동
          var currentPage = parseInt(document.getElementById('currentPageIndex').value) || 1;
          window.location.href = '/board/boardList.do?pageIndex=' + currentPage;
        } else {
          alert(response.message);
        }
      }
    };

    xhr.send(serializeForm(formData));
  }

  function goPage(pageNo) {
    var currentInputRows = document.querySelectorAll('.dynamic-input-row').length;
    var url = '/board/boardList.do?pageIndex=' + pageNo;

    // 현재 페이지에만 입력행 개수 전달 (다른 페이지로 이동 시에는 0)
    if(pageNo == getCurrentPageNo()) {
      url += '&inputRowCount=' + currentInputRows;
    }

    window.location.href = url;
  }

  function getCurrentPageNo() {
    return parseInt(document.getElementById('currentPageIndex').value) || 1;
  }

  //==================== OK

  // 폼 유효성 검증
  function validateBoard(titleInput) {
    if(!titleInput.value.trim()) {
      alert('내용을 입력해주세요.');
      titleInput.focus();
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
    if(checkedBoxes.length === 0) {
      alert('삭제할 게시글을 선택해주세요.');
      return;
    }

    // 실제 데이터와 임시 입력행 분리
    var realDataBoxes = []; // 실제 데이터행 체크박스
    var tempInputBoxes = []; // 임시 입력행 체크박스
    var tempInputWithContent = []; // 내용이 입력된 임시 행

    checkedBoxes.forEach(function(checkbox) {
      const row = checkbox.closest('tr');

      if(checkbox.classList.contains('tempCheck')) {
        var titleInput = row.querySelector('input[name="title"]');
        if(titleInput && titleInput.value.trim()) {
          tempInputWithContent.push('입력된 내용이 있는 행');
        } else {
          tempInputBoxes.push(checkbox);
        }
      } else {
        realDataBoxes.push(checkbox);
      }
    });

    // 1. 내용이 입력된 임시 행에 대한 경고
    if(tempInputWithContent.length > 0) {
      alert('내용이 입력된 입력 행은 삭제할 수 없습니다.');
      return;
    }

    // 2. 내용 없는 임시 입력행 DOM에서 삭제
    tempInputBoxes.forEach(function(checkbox) {
      checkbox.closest('tr').remove();
    });

    // 3. 실제 데이터 행 서버 삭제 요청
    if(realDataBoxes.length > 0) {
      if(!confirm(realDataBoxes.length + '개의 게시글을 삭제하시겠습니까?')) {
        return;
      }

      const seqs = [];
      realDataBoxes.forEach(function(checkbox) {
        seqs.push(checkbox.value);
      });

      const xhr = createXHR();
      xhr.open('POST', '/board/delete.do', true);
      xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');

      xhr.onreadystatechange = function() {
        if(xhr.readyState === 4 && xhr.status === 200) {
          const response = JSON.parse(xhr.responseText);
          if(response.success) {
            alert(response.message);

            // 입력행도 함께 삭제되었으면 입력행 개수 업데이트 후 새로고침
            if(tempInputBoxes.length > 0) {
              updatePageWithInputRows();
            } else {
              window.location.reload();
            }
          } else {
            alert(response.message);
          }
        }
      };

      var formData = 'seqs=' + seqs.join('&seqs=');
      xhr.send(formData);
    } else if(tempInputBoxes.length > 0) {
      alert('선택한 입력행이 삭제되었습니다.');
      updatePageWithInputRows(); // 입력행 개수 서버 업데이트
    }
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

    const checkbox  = checkedList[0];
    const tr        = checkbox.closest('tr');

    // 이미 수정 행이 열려있는지 확인 (중복 방지)
    if(tr.nextElementSibling && tr.nextElementSibling.classList.contains('edit-input-row')) {
      alert('이미 수정 중인 게시글입니다.');
      return;
    }

    // 새 입력행을 추가하는 addInputRowToDOM 함수를 재활용
    const editRowElement = addInputRowToDOM(false);
    // if(!editRowElement) {
    //   alert('수정 행을 추가할 수 없습니다. 페이지 내 입력 행 수를 확인해주세요.');
    //   return;
    // }

    // edit-input-row 클래스 추가 및 tempCheck 제거
    editRowElement.classList.remove('dynamic-input-row');
    editRowElement.classList.add('edit-input-row');
    editRowElement.querySelector('.tempCheck').classList.remove('tempCheck');
    editRowElement.querySelector('.row-no').textContent = tr.cells[0].textContent.trim(); // 게시글 번호 표시

    // 원본 데이터 행 바로 아래로 이동
    tr.parentNode.insertBefore(editRowElement, tr.nextSibling);

    // 선택한 게시글의 정보
    const boardSeq  = tr.cells[0].textContent.trim();
    // const titleTxt  = tr.cells[2].textContent.trim();
    const titleTxt = tr.cells[2].querySelector('.title-link') ? tr.cells[2].querySelector('.title-link').textContent.trim() : tr.cells[2].textContent.trim(); // span 태그 고려
    const regDate   = tr.cells[3].textContent.trim();
    const writerTxt = tr.cells[4].textContent.trim();

    // 입력 필드에 기존 게시글 값 바인딩 (동적으로 생성된 input 필드의 ID를 사용)
    const titleInput = editRowElement.querySelector('input[name="title"]');
    const regDateInput = editRowElement.querySelector('input[name="regDate"]');
    const writerInput = editRowElement.querySelector('input[name="writer"]');
    const button = editRowElement.querySelector('button');

    titleInput.value = titleTxt;
    regDateInput.value = regDate;
    writerInput.value = writerTxt;

    // boardSeq를 hidden 필드로 세팅 (수정 행 내부에)
    let seqHidden = document.createElement('input');
    seqHidden.type = 'hidden';
    seqHidden.id = 'inputSeqHidden_' + inputRowCounter; // 고유 ID 부여
    seqHidden.name = 'boardSeq';
    seqHidden.value = boardSeq;
    editRowElement.appendChild(seqHidden);

    // 버튼 텍스트 '수정완료'로 변경 및 onclick 이벤트 연결
    button.textContent = "수정완료";
    button.onclick = function() { updateRowFromInput(editRowElement.id); };

    // 수정 필드에 포커스
    titleInput.focus();
  }

  // 수정 데이터 서버 전송 (updateRow 대체)
  function updateRowFromInput(rowId) {
    const rowElement = document.getElementById(rowId);
    const titleInput = rowElement.querySelector('input[name="title"]');
    const regDateInput = rowElement.querySelector('input[name="regDate"]');
    const writerInput = rowElement.querySelector('input[name="writer"]');
    const boardSeqHidden = rowElement.querySelector('input[name="boardSeq"][type="hidden"]');

    if(!validateBoard(titleInput)) return;

    const formData = {
      boardSeq: boardSeqHidden.value,
      title   : titleInput.value.trim(),
      regDate : regDateInput.value,
      writer  : writerInput.value.trim()
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
