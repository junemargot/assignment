<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<style>
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

	.input-row select,
	.input-row input {
		font-size: 12px;
		padding: 4px;
		height: 30px;
	}
</style>

<script type="text/javascript">
	function goPage(pageNo) {
		document.getElementById("pageIndex").value = pageNo;
		document.getElementById("sendForm").submit();
	}

	// 추가 - accountInsert.jsp 함수 재사용
	// 계층형 SELECT 바인딩 함수
	function bindCascadingSelect(selector, nextSelector, lowerSelectors = []) {
		$(selector).change(function() {
			const selectedCode = $(this).val();

			if(selectedCode && selectedCode !== '0') {
				loadSubCategory(selectedCode, nextSelector);
				if(lowerSelectors.length > 0) {
					resetLowerSelects(lowerSelectors);
				}
			} else {
				resetLowerSelects([nextSelector, ...lowerSelectors]);
			}
		});
	}

	// 하위 SELECT 초기화
	function resetLowerSelects(selectArray) {
		$.each(selectArray, function(index, selector) {
			$(selector).html('<option value="0">해당없음</option>').prop('disabled', true);
		});
	}

	// 카테고리 로드
	function loadSubCategory(parentCode, targetSelect) {
		$.ajax({
			url: '/account/getSubCategory.do',
			type: 'POST',
			data: { category: parentCode },
			dataType: 'json',
			success: function(data) {
				var options = '';
				var disable = false;

				if(data && data.length > 0) {
					options = '<option value="">선택</option>';
					$.each(data, function(index, item) {
						options += '<option value="' + item.code + '">' + item.comKor + '</option>';
					});
				} else {
					options = '<option value="0">해당없음</option>';
					disable = true;
				}
				$(targetSelect).html(options).prop("disabled", disable);
			},
			error: function() {
				alert('목록 조회 중 오류가 발생했습니다.');
				$(targetSelect).html('<option value="0">해당없음</option>').prop('disabled', true);
			}
		});
	}

	// function resetLowSelects(selectArray) {
	// 	$.each(selectArray, function(index, selector) {
	// 		$(selector).html('<option value="0">해당없음</option>').prop('disabled', true);
	// 	});
	// }

	// 전체 선택/해제 기능
	function toggleAll() {
		var checkAll = document.getElementById('checkAll');
		var checkboxes = document.querySelectorAll('.rowCheck');

		for(var i = 0; i < checkboxes.length; i++) {
			checkboxes[i].checked = checkAll.checked;
		}
	}

	// 입력 행 표시
	function showInputRow() {
		$('.input-row').show();
		$('#profitCost').focus();
	}

	// 행 추가 기능
	function addRow() {
		// 유효성 검증
		if(!$('#profitCost').val()) {
			alert('[수익/비용]을 선택해주세요.');
			$('#profitCost').focus(); // 해당 입력 필드에 포커스 이동
			return false;
		}

		if(!$('#bigGroup').val()) {
			alert('[앞서 선택한 분류]에 해당하는 대분류를 선택해주세요.');
			$('#bigGroup').focus();
			return false;
		}

		if(!$('#inputMoney').val()) {
			alert('[금액]을 입력해주세요.');
			$('input[name="transactionMoney"]').focus();
			return false;
		}

		if(!$('#inputRegDate').val()) {
			alert('[거래일자]를 선택해주세요.');
			$('input[name="transactionDate"]').focus();
			return false;
		}

		var formData = {
			profitCost: $('#profitCost').val(),
			bigGroup: $('#bigGroup').val(),
			middleGroup: $('#middleGroup').val() || '0',
			smallGroup: $('#smallGroup').val() || '0',
			detailGroup: $('#detailGroup').val() || '0',
			transactionMoney: $('#inputMoney').val(),
			transactionDate: $('#inputRegDate').val()
		};

		$.ajax({
			url: '/account/save.do',  // 기존 저장 API 사용
			type: 'POST',
			data: formData,
			dataType: 'json',
			success: function(response) {
				if(response.success) {
					// 성공 시 페이지 새로고침하여 실제 저장된 데이터 표시
					alert("입력사항이 저장되었습니다.");
					location.reload();  // 또는 window.location.href = '/account/accountList.do';
				} else {
					alert('저장 중 오류가 발생했습니다: ' + response.message);
				}
			},
			error: function(xhr, status, error) {
				alert('저장 중 오류가 발생했습니다.');
				console.error(error);
			}
		});
	}

	// 입력 행 초기화
	function resetInputRow() {
		$('#profitCost').val('');
		$('#bigGroup').html('<option value="">선택</option>').prop('disabled', true);
		$('#middleGroup').html('<option value="0">해당없음</option>').prop('disabled', true);
		$('#smallGroup').html('<option value="0">해당없음</option>').prop('disabled', true);
		$('#detailGroup').html('<option value="0">해당없음</option>').prop('disabled', true);
		$('#inputMoney').val('');
		$('#inputRegDate').val('');
	}

	// 선택된 행 삭제
	function deleteRows() {
		var checkedBoxes = document.querySelectorAll('.rowCheck:checked');

		if(checkedBoxes.length === 0) {
			alert("삭제할 행을 선택해주세요.");
			return false;
		}

		if(confirm('선택된 ' + checkedBoxes.length + '개의 행을 삭제하시겠습니까?')) {
			// 선택된 항목의 sequence 추출
			var seqs = [];
			checkedBoxes.forEach(function(checkbox) {
				seqs.push(checkbox.value); // value에 accountSeq가 들어있음
			});

			$.ajax({
				url: '/account/delete.do',
				type: 'POST',
				data: { seqs: seqs },
				traditional: true, // 배열 직렬화
				dataType: 'json',
				success: function(response) {
					if(response.success) {
						alert(response.message);
						location.reload(); // 페이지 새로고침
					} else {
						alert('삭제 중 오류가 발생했습니다: ' + response.message);
					}
				},
				error: function(xhr, status, error) {
					alert('삭제 중 오류가 발생했습니다.');
					console.error(error);
				}
			});
		}
	}

	// === 이벤트 핸들러 ===
	$(document).ready(function() {
		$('select').each(function() { // 페이지 내의 <select>을 전부 순회하고
			var $select = $(this); // 현재 반복중인 <select> 태그를 jQuery 객체로 래핑
			var $options = $select.find('option'); // 현재 <select> 안의 모든 <option> 태그들을 찾아서 객체로 저장
			if ($options.length === 1 && $options.val() === '0') { // <option>의 개수가 1개이고, 유일한 옵션의 value '0'이면
				$select.prop('disabled', true); // 해당 select 박스를 비활성화
			}
		});
		// 계층형 select 연동
		bindCascadingSelect('#profitCost', '#bigGroup', ['select[name="middleGroup"]', 'select[name="smallGroup"]', 'select[name="comment1"]']);
		bindCascadingSelect('#bigGroup', 'select[name="middleGroup"]', ['select[name="smallGroup"]', 'select[name="comment1"]']);
		bindCascadingSelect('select[name="middleGroup"]', 'select[name="smallGroup"]', ['select[name="comment1"]']);
		bindCascadingSelect('select[name="smallGroup"]', 'select[name="comment1"]', []);

		// 초기 상태 설정
		$('#bigGroup').prop('disabled', true);

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
	});

</script>

<%--Spring Form 태그 라이브러리를 사용하여 서버의 searchVO 객체와 이 폼을 연결. 폼 제출 시, 폼 필드들이 searchVO 객체에 자동으로 바인딩된다.--%>
<form:form modelAttribute="searchVO" name="sendForm" id="sendForm" method="get" onsubmit="return false;">
	<form:hidden path="pageIndex" />
	<input type="hidden" id="situSeq" name="situSeq" value="">
	<input type="hidden" id="mode" name="mode" value="Cre">
	<div id="wrap" class="col-md-offset-1 col-sm-10" style="margin-top: 50px;">
		<div align="center"><h2>회계정보리스트</h2></div>
		<div class="form_box2 col-md-offset-7" align="right" style="margin-bottom: 10px;">
			<div class="right">
				<button class="btn btn-primary" onclick="location.href='/account/accountInsert.do'">등록</button>
				<button class="btn btn-primary" onclick="showInputRow()">행추가</button>
				<button class="btn btn-primary" onclick="deleteRows()">행삭제</button>
				<button class="btn btn-primary" onclick="location.href='/account/listToExcel.do'">엑셀 다운</button>
			</div>
		</div>
	    <br/>
		<table class="table table-hover" style="margin-left: auto; margin-right: auto; text-align: center;">
		    <thead>
		      <tr align="center">
						<th><input type="checkbox" id="checkAll" onchange="toggleAll()" /></th>
		        <th style="text-align: center;">수익/비용</th>
		        <th style="text-align: center;">관</th>
		        <th style="text-align: center;">항</th>
		        <th style="text-align: center;">목</th>
		        <th style="text-align: center;">과</th>
		        <th style="text-align: center;">금액</th>
		        <th style="text-align: center;">등록일</th>
		        <th style="text-align: center;">작성자</th>
		      </tr>
				</thead>
				<tbody id="accountListBody">
					<!-- 입력행 -->
					<tr class="input-row">
						<td></td>
						<td>
							<select id="profitCost" name="profitCost" title="비용" class="form-control" style="width: 100%;" title="비용">
								<option value="">대분류선택</option>
								<c:forEach var="list" items="${resultMap}" varStatus="cnt">
									<option value="${list.code}">${list.comKor}</option>
								</c:forEach>
							</select>
						</td>
						<td>
							<select id="bigGroup" name="bigGroup" class="form-control" style="width: 100%;" title="관">
								<option value="">선택</option>
							</select>
						</td>
						<td>
							<select id="middleGroup" name="middleGroup" class="form-control" style="width: 100%;" title="항">
								<option value="0">해당없음</option>
							</select>
						</td>
						<td>
							<select id="smallGroup" name="smallGroup" class="form-control" style="width: 100%;" title="목">
								<option value="0">해당없음</option>
							</select>
						</td>
						<td>
							<select id="detailGroup" name="comment1" class="form-control" style="width: 100%;" title="과">
								<option value="0">해당없음</option>
							</select>
						</td>
						<td>
							<input type="text" id="inputMoney" name="transactionMoney" class="form-control" placeholder="금액 상세 입력" title="비용 상세" style="width: 100%;"  />
						</td>
						<td>
							<input type="text" id="inputRegDate" name="transactionDate" class="form-control datepicker" placeholder="거래일자" title="거래일자" style="width: 100%" readonly />
						</td>
						<td>
							<button type="button" class="btn btn-default btn-sm" onclick="addRow()">추가</button>
						</td>
					</tr>
					<!-- 기존 데이터행 -->
					<c:forEach var="account" items="${accountList}">
						<tr>
							<td><input type="checkbox" class="rowCheck" value="${account.accountSeq}" /></td>
							<td>${account.profitCostNm}</td>
							<td>${account.bigGroupNm}</td>
							<td>${account.middleGroupNm}</td>
							<td>${account.smallGroupNm}</td>
							<td>${account.detailGroupNm}</td>
							<td>
								<fmt:formatNumber value="${account.transactionMoney}" pattern="#,###" />원
							</td>
							<td>
								<fmt:parseDate value="${account.regDate}" pattern="yyyy-MM-dd" var="parsedRegDate" />
								<fmt:formatDate value="${parsedRegDate}" pattern="yyyy년 M월 d일" />
							</td>
							<td>${account.writer}</td>
						</tr>
					</c:forEach>
				</tbody>
		</table>
		<!-- 페이지네이션 -->
		<div class="pagination" style="text-align: center;">
			<ui:pagination paginationInfo="${paginationInfo}" type="text" jsFunction="goPage" />
		</div>
	</div>
</form:form>


