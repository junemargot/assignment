<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<script>
$(document).ready(function(){
	// 거래일자 datepicker 설정 (common.js 함수 활용)
	$('input[name="transactionDate"]').addClass('datepicker');

	// 금액 필드 - 숫자만 입력 허용, 콤마 포맷
	$('input[name="transactionMoney"]').on('input', function(){
		this.value = this.value.replace(/[^0-9]/g, '');
		// 3자리마다 콤마 추가
		if(this.value) {
			this.value = Number(this.value).toLocaleString();
		}
	});

	// <select> 태그의 값이 변경을 감지
	// 1차 select (수익/비용) 변경 이벤트
	$('#profitCost').change(function(){
		var selectedCode = $(this).val(); // 현재 선택된 드롭다운의 값(value)을 가져옴

		if(selectedCode) {
			loadSubCategory(selectedCode, '#bigGroup'); // 선택된 코드로 바로 다음 하위 카테고리 로드
			// 그 다음 하위 select을 해당 없음으로 초기화, 비활성화
			resetLowerSelects(['select[name="middleGroup"]', 'select[name="smallGroup"]', 'select[name="comment1"]']);
		} else { // '선택' 옵션이 다시 선택된 경우(값이 비어있는 경우)
			resetAllLowerSelects(); // 모든 하위 select을 초기 상태로 되돌림
		}
	});

	// 2차 select (관) 변경 이벤트
	$('#bigGroup').change(function(){
		var selectedCode = $(this).val();

		if(selectedCode) {
			loadSubCategory(selectedCode, 'select[name="middleGroup"]');
			resetLowerSelects(['select[name="smallGroup"]', 'select[name="comment1"]']);

		} else {
			resetLowerSelects(['select[name="middleGroup"]', 'select[name="smallGroup"]', 'select[name="comment1"]']);
		}
	});

	// 3차 select (항) 변경 이벤트
	$('select[name="middleGroup"]').change(function(){
		var selectedCode = $(this).val();

		if(selectedCode && selectedCode !== '0') {
			loadSubCategory(selectedCode, 'select[name="smallGroup"]');
			resetLowerSelects(['select[name="comment1"]']);

		} else {
			resetLowerSelects(['select[name="smallGroup"]', 'select[name="comment1"]']);
		}
	});

	// 4차 select (목) 변경 이벤트
	$('select[name="smallGroup"]').change(function(){
		var selectedCode = $(this).val();

		if(selectedCode && selectedCode !== '0') {
			loadSubCategory(selectedCode, 'select[name="comment1"]');

		} else {
			resetLowerSelects(['select[name="comment1"]']);
		}
	});
});

// AJAX로 하위 카테고리 로드
function loadSubCategory(parentCode, targetSelect) {
	$.ajax({
		url: '/account/getSubCategory.do', // 데이터를 요청할 서버 URL
		type: 'POST',                      // HTTP 요청 방식
		data: { category: parentCode },    // 서버로 보낼 데이터(부모 카테고리)
		dataType: 'json',                  // 서버로부터 받을 데이터 타입
		success: function(data) {          // 서버 요청이 성공했을 때 실행될 콜백 함수
			var options = '';                // <option> 태그들을 담을 변수
			var disable = false;             // targetSelect의 disabled 속성을 제어할 변수

			if(data && data.length > 0) {    // 서버에서 받은 데이터가 있고, 데이터가 비어있지 않다면
				options = '<option value="">선택</option>'; // 첫번째 옵션으로 "선택" 추가
				// 받은 데이터(배열)를 반복하면서 각 아이템(카테고리)으로 <option> 태그 생성
				$.each(data, function(index, item) {
					options += '<option value="' + item.code + '">' + item.comKor + '</option>';
				});
			} else { // 데이터가 없거나 비어있는 경우 (더 이상 하위 카테고리가 없음)
				options = '<option value="0">해당없음</option>'; // "해당없음" 옵션 추가
				disable = true; // 해당 드롭다운을 비활성화
			}
			$(targetSelect).html(options); // 생성된 옵션들을 targetSelect에 삽입
			$(targetSelect).prop('disabled', disable); // targetSelect의 disabled 속성 설정
		},
		error: function() { // 서버 요청이 실패했을 때 실행될 콜백 함수
			alert('목록 조회 중 오류가 발생했습니다.');
			$(targetSelect).html('<option value="0">해당없음</option>'); // 오류 시 "해당없음"으로 초기화
			$(targetSelect).prop('disabled', true); // 오류 시 드롭다운 비활성화
		}
	});
}

// 하위 select들 초기화 함수
function resetLowerSelects(selectArray) {
	// selectArray 배열을 순회하며 각 select 요소를 처리
	$.each(selectArray, function(index, selector) {
		// 1. 해당 셀렉터로 jQuery 객체를 생성하고, 내부 html을 새로운 <option> 태그로 교체
		$(selector).html('<option value="0">해당없음</option>');
		// 2. 해당 셀렉터로 jQuery 객체를 생성하고, 'disabled' 속성을 true로 설정하여 비활성화
		$(selector).prop('disabled', true);
	});
}

// 전체 하위 select 초기화 (최상위 select이 초기화될 때 사용)
function resetAllLowerSelects() {
	$('#bigGroup').html('<option value="">선택</option>').prop('disabled', true);
	$('select[name="middleGroup"]').html('<option value="0">해당없음</option>').prop('disabled', true);
	$('select[name="smallGroup"]').html('<option value="0">해당없음</option>').prop('disabled', true);
	$('select[name="comment1"]').html('<option value="0">해당없음</option>').prop('disabled', true);
	// 해당 select 박스의 disabled 속성을 true로 설정하여 비활성화 처리
}

// 공통 유효성 검증 함수(saveAccountData, updateAccountData에서 사용)
function validateAccountForm() {
	// 1. 필수 입력값 검증
	if(!$('#profitCost').val()) { // profitCost id를 가진 요소의 값이 비어있는지 확인
		alert('[수익/비용]을 선택해주세요.');
		$('#profitCost').focus(); // 해당 입력 필드에 포커스 이동
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

	return true;
}

// 비용 등록 함수
function saveAccountData() {
	if(!validateAccountForm()) return false; // 유효성 검증

	// 서버로 보낼 데이터를 담을 객체 생성
	var formData = {
		profitCost: $('#profitCost').val(),
		bigGroup: $('#bigGroup').val(),
		middleGroup: $('select[name="middleGroup"]').val() || '0',
		smallGroup: $('select[name="smallGroup"]').val() || '0',
		detailGroup: $('select[name="comment1"]').val() || '0',
		comments: $('input[name="comment"]').val() || '',
		transactionMoney: $('input[name="transactionMoney"]').val().replace(/,/g, ''),
		transactionDate: $('input[name="transactionDate"]').val()
	};

	$.ajax({
		url: '/account/save.do',
		type: 'POST',
		data: formData,
		dataType: 'json',
		success: function(result) {
			if(result.success) {
				alert('저장되었습니다.');
				location.href = '/account/edit.do?seq=' + result.seq;

			} else {
				alert('저장 중 오류가 발생했습니다: ' + (result.message || ''));
			}
		},
		error: function() {
			alert('저장 중 오류가 발생했습니다.');
		}
	});
}

$(document).ready(function() {
	// 모든 select 박스 중, "해당없음"만 있으면 비활성화
	$('select').each(function() {
		var $select = $(this); // 현재 반복중인 <select> 태그를 jQuery 객체로 래핑
		var $options = $select.find('option'); // 현재 <select> 안의 모든 <option> 태그들을 찾아서 객체로 저장
		if ($options.length === 1 && $options.val() === '0') { // <option>의 개수가 1개이고, 유일한 옵션의 value '0'이면
			$select.prop('disabled', true); // 해당 select 박스를 비활성화
		}
	});

	// 페이지 진입 시 select 상태 - 첫번째 select를 제외한 모든 하위 select 비활성화
	$('#bigGroup').prop('disabled', true);
	$('select[name="middleGroup"]').prop('disabled', true);
	$('select[name="smallGroup"]').prop('disabled', true);
	$('select[name="comment1"]').prop('disabled', true);
});

</script>

<!-- 비용 START -->
<div class="container" style="margin-top: 50px">
	<div class="col-sm-12"><label for="disabledInput" class="col-sm-12 control-label"></label></div>
	<div class="col-sm-12"><label for="disabledInput" class="col-sm-12 control-label"></label></div>
	<div class="col-sm-12"><label for="disabledInput" class="col-sm-12 control-label"></label></div>
	<div class="col-sm-12"><label for="disabledInput" class="col-sm-12 control-label"></label></div>

	<div class="col-sm-11" id="costDiv">
		<div>
			<div class="col-sm-11">
				<div class="col-sm-12">
					<div class="col-sm-3">
						<select class="form-control" id="profitCost" name="profitCost" title="비용">
							<option value="">대분류선택</option>
							<c:forEach var="list" items="${resultMap}" varStatus="cnt">
								<option value="${list.code}">${list.comKor}</option>
							</c:forEach>
						</select>
				  </div>

				  <div class="col-sm-3">
						<select class="form-control" id="bigGroup"  name="bigGroup" title="관">
							<option value="">선택</option>
						</select>
				  </div>

				  <div class="col-sm-3">
						<select class="form-control "  name="middleGroup"  title="항">
							<option value="0">해당없음</option>
						</select>
				  </div>

				  <div class="col-sm-3">
						<select class="form-control " name="smallGroup" title="목">
							<option value="0">해당없음</option>
						</select>
				  </div>
				</div>

				<div class="col-sm-12">
					<label for="disabledInput" class="col-sm-12 control-label"></label>
				</div>
				<div class="col-sm-12">
				  <div class="col-sm-3">
						<select class="form-control " name="comment1" title="과">
							<option value="0">해당없음</option>
						</select>
				  </div>
				  <div class="col-sm-9">
						<input class="form-control " name="comment" type="text" value="" placeholder="비용 상세 입력" title="비용 상세">
				  </div>
				</div>

				<div class="col-sm-12">
					<label for="disabledInput" class="col-sm-12 control-label"></label>
				</div>
				<div class="col-sm-12">
					<label for="disabledInput" class="col-sm-1 control-label"><font size="1px">금액</font></label>
					<div class="col-sm-3">
						<input class="form-control"  name="transactionMoney" type="text" value="" title="금액">
					</div>
					<label for="disabledInput" class="col-sm-1 control-label"><font size="1px">거래일자</font></label>
					<div class="col-sm-3 datepicker-wrapper">
						<input class="form-control datepicker" name="transactionDate" type="text" value="" style="width: 80%" title="거래일자" readonly />
					</div>
				</div>

				<div class="col-sm-12"><label for="disabledInput" class="col-sm-12 control-label"></label></div>
				<div class="col-sm-12"><label for="disabledInput" class="col-sm-12 control-label"></label></div>
			</div>
		</div>
	</div>
	<!-- 저장 버튼 추가 -->
	<div class="col-sm-12" style="text-align: center; margin-top: 20px;">
		<button type="button" class="btn btn-primary" onclick="saveAccountData()">저장</button>
		<button type="button" class="btn btn-default" onclick="location.href='/account/accountList.do'">목록</button>
	</div>
</div>

<!-- 비용 END -->