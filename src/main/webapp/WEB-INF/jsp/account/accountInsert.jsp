<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>


<script>
$(document).ready(function(){
	// 거래일자 datepicker 설정 (common.js 함수 활용)
	$('input[name="transactionDate"]').addClass('datepicker');

	// 금액 필드 - 숫자만 입력 허용
	$('input[name="transactionMoney"]').on('input', function(){
	this.value = this.value.replace(/[^0-9]/g, '');
	// 3자리마다 콤마 추가
	if(this.value) {
	this.value = Number(this.value).toLocaleString();
	}
	});

	// 1차 select (수익/비용) 변경 이벤트
	$('#profitCost').change(function(){
		var selectedCode = $(this).val();

		if(selectedCode) {
			loadSubCategory(selectedCode, '#bigGroup');
			resetLowerSelects(['select[name="middleGroup"]', 'select[name="smallGroup"]', 'select[name="comment1"]']);

		} else {
			resetAllLowerSelects();
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
		url: '/common/getSubCategory.do',
		type: 'POST',
		data: { category: parentCode },
		dataType: 'json',
		success: function(data) {
			var options = '<option value="">선택</option>';
			if(data && data.length > 0) {
				$.each(data, function(index, item) {
					options += '<option value="' + item.code + '">' + item.comKor + '</option>';
				});
			} else {
				options = '<option value="0">해당없음</option>';
			}
			$(targetSelect).html(options);
		},
		error: function() {
			alert('목록 조회 중 오류가 발생했습니다.');
			$(targetSelect).html('<option value="0">해당없음</option>');
		}
	});
}

// 하위 select들 초기화
function resetLowerSelects(selectArray) {
	$.each(selectArray, function(index, selector) {
		$(selector).html('<option value="0">해당없음</option>');
	});
}

// 전체 하위 select 초기화
function resetAllLowerSelects() {
	$('#bigGroup').html('<option value="">선택</option>');
	$('select[name="middleGroup"]').html('<option value="0">해당없음</option>');
	$('select[name="smallGroup"]').html('<option value="0">해당없음</option>');
	$('select[name="comment1"]').html('<option value="0">해당없음</option>');
}

// 저장 함수
function saveCostData() {
	// 필수값 검증
	if(!$('#profitCost').val()) {
		alert('수익/비용을 선택해주세요.');
		$('#profitCost').focus();
		return false;
	}

	if(!$('#bigGroup').val()) {
		alert('관을 선택해주세요.');
		$('#bigGroup').focus();
		return false;
	}

	if(!$('input[name="transactionMoney"]').val()) {
		alert('금액을 입력해주세요.');
		$('input[name="transactionMoney"]').focus();
		return false;
	}

	if(!$('input[name="transactionDate"]').val()) {
		alert('거래일자를 선택해주세요.');
		$('input[name="transactionDate"]').focus();
		return false;
	}

	var formData = {
		profitCostCode: $('#profitCost').val(),
		bigGroupCode: $('#bigGroup').val(),
		middleGroupCode: $('select[name="middleGroup"]').val() || '0',
		smallGroupCode: $('select[name="smallGroup"]').val() || '0',
		comment1Code: $('select[name="comment1"]').val() || '0',
		commentText: $('input[name="comment"]').val() || '',
		transactionMoney: $('input[name="transactionMoney"]').val().replace(/,/g, ''), // 콤마 제거
		transactionDate: $('input[name="transactionDate"]').val()
	};

	$.ajax({
		url: '/cost/save.do',
		type: 'POST',
		data: formData,
		dataType: 'json',
		success: function(result) {
			if(result.success) {
				alert('저장되었습니다.');
				location.href = '/cost/edit.do?seq=' + result.seq;

			} else {
				alert('저장 중 오류가 발생했습니다: ' + (result.message || ''));
			}
		},
		error: function() {
			alert('저장 중 오류가 발생했습니다.');
		}
	});
}

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
							<option value="">대분류 선택</option>
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
					<div class="col-sm-3">
						<input class="form-contro col-sm-2"  name="transactionDate" type="text" value="" style="width: 80%" title="거래일자">
					</div>
				</div>

				<div class="col-sm-12"><label for="disabledInput" class="col-sm-12 control-label"></label></div>
				<div class="col-sm-12"><label for="disabledInput" class="col-sm-12 control-label"></label></div>
			</div>
		</div>
	</div>
	<!-- 저장 버튼 추가 -->
	<div class="col-sm-12" style="text-align: center; margin-top: 20px;">
		<button type="button" class="btn btn-primary" onclick="saveCostData()">저장</button>
		<button type="button" class="btn btn-default" onclick="location.href='/cost/list.do'">목록</button>
	</div>

	<!-- 거래일자 input 수정 -->
	<input class="form-control datepicker" name="transactionDate" type="text" value="" style="width: 80%" title="거래일자" readonly />
</div>

<!-- 비용 END -->