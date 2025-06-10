<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script>
$(document).ready(function() {
  // 거래일자 datepicker 설정
  $('input[name="transactionDate"]').addClass('datepicker');

  // 금액 필드 - 숫자만 입력 허용
  $('input[name="transactionMoney"]').on('input', function(){
    this.value = this.value.replace(/[^0-9]/g, ''); // 숫자가 아닌 모든 문자를 제거하고 다시 값으로 설정
    if(this.value) {
      this.value = Number(this.value).toLocaleString();
    }
  });

  // 기존 데이터로 select 박스들 설정
  loadExistingData();

  // 새로 추가된 select 변경 이벤트
  // 1차 select (수익/비용) 변경 이벤트
  $('#profitCost').change(function() {
      var selectedCode = $(this).val();
      if(selectedCode) {
        loadSubCategoryWithCallback(selectedCode, '#bigGroup', function() {
          $('#bigGroup').prop('disabled', false);
        });
      } else {
        resetAllLowerSelects();
      }
  });

  // 2차 select (관) 변경 이벤트
  $('#bigGroup').change(function() {
      var selectedCode = $(this).val();
      if(selectedCode) {
        loadSubCategoryWithCallback(selectedCode, 'select[name="middleGroup"]');
      } else {
        resetLowerSelects(['select[name="middleGroup"]', 'select[name="smallGroup"]', 'select[name="comment1"]']);
      }
  });

  // 3차 select (항) 변경 이벤트
  $('select[name="middleGroup"]').change(function() {
      var selectedCode = $(this).val();
      if(selectedCode && selectedCode !== '0') {
        loadSubCategoryWithCallback(selectedCode, 'select[name="smallGroup"]');
      } else {
        resetLowerSelects(['select[name="smallGroup"]', 'select[name="comment1"]']);
      }
  });

  // 4차 select (목) 변경 이벤트
  $('select[name="smallGroup"]').change(function() {
    var selectedCode = $(this).val();
    if(selectedCode && selectedCode !== '0') {
      loadSubCategoryWithCallback(selectedCode, 'select[name="comment1"]');
    } else {
      resetLowerSelects(['select[name="comment1"]']);
    }
  });
});

// 기존 데이터로 select 박스들 설정 -> 각 select 박스의 값을 설정할 때마다 달라지는 하위 select 박스의 옵션 목록을 기반으로 하위 select 박스의 기존 값을 설정하는 과정
function loadExistingData() {
  // 서버로부터 전달받은 accountData 객체의 값을 표시하기 위함
  // EL(Expression Language)을 사용해 '${accountData.속성명}'으로 값에 접근
  var profitCost = '${accountData.profitCost}';
  var bigGroup = '${accountData.bigGroup}';
  var middleGroup = '${accountData.middleGroup}';
  var smallGroup = '${accountData.smallGroup}';
  var detailGroup = '${accountData.detailGroup}';

  // 1차 select 설정
  $('#profitCost').val(profitCost); // id가 profitCost인 select에 기존 accountData의 profitCost 값 설정

  // 2차 select 로딩 및 설정
  if(profitCost) {
    // loadCategoryWithCallback을 호출해 profitCost에 해당하는 bigGroup 옵션들 로드
    loadSubCategoryWithCallback(profitCost, '#bigGroup', function() {
      $('#bigGroup').val(bigGroup); // bigGroup select에 기존 accountData의 bigGroup 값 설정 - "선택된 상태로 만드는" 작업

      // 3차 select 로딩 및 설정
      if(bigGroup) {
        loadSubCategoryWithCallback(bigGroup, 'select[name="middleGroup"]', function() {
          $('select[name="middleGroup"]').val(middleGroup);

          // 4차 select 로딩 및 설정
          if(middleGroup && middleGroup !== '0') {
            loadSubCategoryWithCallback(middleGroup, 'select[name="smallGroup"]', function() {
              $('select[name="smallGroup"]').val(smallGroup);

              // 5차 select 로딩 및 설정
              if(smallGroup && smallGroup !== '0') {
                loadSubCategoryWithCallback(smallGroup, 'select[name="comment1"]', function() {
                  $('select[name="comment1"]').val(detailGroup);
                });
              }
            });
          }
        });
      }
    });
  }
}

// 콜백 함수를 지원하는 loadSubCategory
function loadSubCategoryWithCallback(parentCode, targetSelect, callback) {
  $.ajax({
    url: '/account/getSubCategory.do',
    type: 'POST',
    data: { category: parentCode },
    dataType: 'json',
    success: function(data) { // 서버로부터 하위 카테고리 데이터를 받았을 때
      var options = '';
      var disable = false;

      // 1. 서버에서 받은 '옵션 데이터'로 options 문자열 생성
      if(data && data.length > 0) {
        options = '<option value="">선택</option>';
        $.each(data, function(index, item) { // 받은 데이터 배열 순회하여 세팅
          options += '<option value="' + item.code + '">' + item.comKor + '</option>';
        });

      } else {
        options = '<option value="0">해당없음</option>';
        disable = true;
      }

      // 2. targetSelect에 생성된 '옵션 데이터'를 채워넣음 - select 박스 내부에 <option> 태그들(선택지 목록)을 채워 넣는 작업
      $(targetSelect).html(options);
      $(targetSelect).prop('disabled', disable);

      // 콜백 함수 실행
      if(callback) callback();
    }
  });
}

// 하위 select들 초기화 함수 (상위 select가 비어있을 때만 사용)
function resetLowerSelects(selectArray) {
  $.each(selectArray, function(index, selector) {
    $(selector).html('<option value="0">해당없음</option>');
    $(selector).prop('disabled', true);
  });
}

// 전체 하위 select 초기화
function resetAllLowerSelects() {
  $('#bigGroup').html('<option value="">선택</option>').prop('disabled', true);
  $('select[name="middleGroup"]').html('<option value="0">해당없음</option>').prop('disabled', true);
  $('select[name="smallGroup"]').html('<option value="0">해당없음</option>').prop('disabled', true);
  $('select[name="comment1"]').html('<option value="0">해당없음</option>').prop('disabled', true);
}

// 공통 유효성 검증 함수
function validateAccountForm() {
  // 1. 필수 입력값 검증
  if(!$('#profitCost').val()) {
    alert('[수익/비용]을 선택해주세요.');
    $('#profitCost').focus();
    return false;
  }

  if(!$('#bigGroup').val()) {
    alert('[앞서 선택한 분류]에 해당하는 대분류를 선택해주세요.');
    $('#bigGroup').focus();
    return false;
}

  // 2. 하위 분류는 "0"(해당없음) 허용, 빈 값만 체크
  var middleGroupVal = $('select[name="middleGroup"]').val();
  var smallGroupVal = $('select[name="smallGroup"]').val();
  var detailGroupVal = $('select[name="comment1"]').val();

  if(middleGroupVal === "" || middleGroupVal === null) {
    alert('[앞서 선택한 분류]의 중간 분류를 선택해주세요.');
    $('#middleGroup').focus();
    return false;
  }

  if(smallGroupVal === "" || smallGroupVal === null) {
    alert('[앞서 선택한 분류]의 세부 항목을 선택해주세요.');
    $('#smallGroup').focus();
    return false;
  }

  if(detailGroupVal === "" || detailGroupVal === null) {
    alert('[앞서 선택한 분류]의 최종 항목을 선택해주세요.');
    $('#detailGroup').focus();
    return false;
  }

  // 3. 금액, 거래일자 체크
  if(!$('input[name="transactionMoney"]').val()) {
    alert('[금액]을 입력해주세요.');
    $('input[name="transactionMoney"]').focus();
    return false;
  }

  if(!$('input[name="transactionDate"]').val()) {
    alert('[거래일자]를 선택해주세요.');
    $('input[name="transactionDate"]').focus();
    return false;
  }

  return true; // 모든 검증 통과
}

// 수정 저장 함수
function updateAccountData() {
  if(!validateAccountForm()) return false;

  var formData = {
    seq: '${accountData.accountSeq}',
    profitCost: $('#profitCost').val(),
    bigGroup: $('#bigGroup').val(),
    middleGroup: $('select[name="middleGroup"]').val() || '0',
    smallGroup: $('select[name="smallGroup"]').val() || '0',
    detailGroup: $('select[name="comment1"]').val() || '0',
    comments: $('input[name="comment"]').val() || '',
    transactionMoney: $('input[name="transactionMoney"]').val().replace(/,/g, ''),
    transactionDate: $('input[name="transactionDate"]').val()
  };
  console.log("수정 formData: ", formData);

  $.ajax({
    url: '/account/update.do',
    type: 'POST',
    data: formData,
    dataType: 'json',
    success: function(result) {
      if(result.success) {
        alert('수정되었습니다.');
        location.href = '/account/accountList.do';
      } else {
        alert('수정 중 오류가 발생했습니다: ' + (result.message || ''));
      }
    },
    error: function() {
        alert('수정 중 오류가 발생했습니다.');
    }
  });
}
</script>

<div class="container" style="margin-top: 50px">
  <div class="col-sm-11" id="costDiv">
    <div class="col-sm-12">
      <div class="col-sm-3">
        <select class="form-control" id="profitCost" name="profitCost" title="수익/비용">
          <option value="">대분류 선택</option>
          <c:forEach var="list" items="${resultMap}" varStatus="cnt">
            <option value="${list.code}">${list.comKor}</option>
          </c:forEach>
        </select>
      </div>

      <div class="col-sm-3">
        <select class="form-control" id="bigGroup" name="bigGroup" title="관">
          <option value="">선택</option>
        </select>
      </div>

      <div class="col-sm-3">
        <select class="form-control" name="middleGroup" title="항">
          <option value="0">해당없음</option>
        </select>
      </div>

      <div class="col-sm-3">
        <select class="form-control" name="smallGroup" title="목">
          <option value="0">해당없음</option>
        </select>
      </div>
    </div>

    <div class="col-sm-12">
      <div class="col-sm-3">
        <select class="form-control" name="comment1" title="과">
          <option value="0">해당없음</option>
        </select>
      </div>
      <div class="col-sm-9">
        <input class="form-control" name="comment" type="text" value="${accountData.comments}" placeholder="비용 상세 입력" title="비용 상세">
      </div>
    </div>

    <div class="col-sm-12">
      <div class="col-sm-3">
        <input class="form-control" name="transactionMoney" type="text"  value="${accountData.transactionMoney}" title="금액">
      </div>
      <div class="col-sm-3">
        <input class="form-control datepicker" name="transactionDate" type="text" value="${accountData.transactionDate}" title="거래일자" readonly>
      </div>
    </div>
  </div>

  <!-- 수정 버튼 -->
  <div class="col-sm-12" style="text-align: center; margin-top: 20px;">
    <button type="button" class="btn btn-primary" onclick="updateAccountData()">수정</button>
    <button type="button" class="btn btn-default" onclick="location.href='/account/accountList.do'">목록</button>
  </div>
</div>
