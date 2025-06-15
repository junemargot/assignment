<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<link href="jquery.editable-select.min.css" rel="stylesheet">
<script src="jquery.editable-select.js"></script>
<style>
	.form-group > div[class^="col-sm-"] {
		padding-right: 5px;
		padding-left: 5px;
	}
</style>

<script type="text/javascript">
function initValidationEvents() {
	$('#pwd').on('keyup', function() { // pwd의 영역을 선택하는 선택자. keyup 입력이 끝났을때
		validatePassword();
		validatePasswordConfirm();
	});
	
	// $('#pwdck').on('keyup', function() {
	// 	validatePasswordConfirm();
	// });
}

// ID 유효성 검증
function validateUserId() {
	var userId = $('#userId').val();
	var userIdRegex = /^[A-Za-z]{6,}$/;

	if(!userIdRegex.test(userId)) {
		$('#userIdError').text('아이디는 영문 6글자 이상이어야 합니다.').css('color', 'red');
		return false;
	}

	$('#userIdError').text('사용 가능한 ID입니다.').css('color', 'blue');
	return true;
}

// 비밀번호 유효성 검증
function validatePassword() {
	var password = $('#pwd').val();
	var passwordRegex = /^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*])[a-zA-Z0-9!@#$%^&*]{6,12}$/;
	
	if(!passwordRegex.test(password)) {
		$('#pwdError').text('비밀번호는 6-12자리 영문, 숫자, 특수문자를 포함해야 합니다.').css('color', 'red');
		return false;
	}

	$('#pwdError').text('사용 가능한 비밀번호입니다.').css('color', 'blue');
	return true;
}

// 비밀번호 확인 검증
function validatePasswordConfirm() {
	var password = $('#pwd').val();
	var passwordConfirm = $('#pwdck').val();
	
	if(passwordConfirm === '') {
		$('#passwordConfirmError').text('비밀번호를 한번 더 입력해주세요').css('color', 'red');
		return false;
	}
	
	if(password !== passwordConfirm) {
		$('#passwordConfirmError').text('비밀번호가 일치하지 않습니다').css('color', 'red');
		return false;
	}
	
	$('#passwordConfirmError').text('비밀번호가 일치합니다').css('color', 'blue');
	return true;
}

// 이름 검증
function validateUserName() {
	var userName = $('#userName').val();
	var userNameRegex = /^[A-Za-z]+$/;

	if(!userNameRegex.test(userName)) {
		$('userNameError').text('이름은 영문만 사용 가능합니다.').css('color', 'red');
		return false;
	}

	$('#userNameError').text('');
	return true;
}

// 주민번호 검증
function validateRRN() {
	var rrn = $('userRRN').val();
	var sum = 0;
	if(rrn.length !== 13 || isNaN(rrn)) {
		$('#RRNError').text('13자리 주민등록번호를 입력해주세요.').css('color', 'red');
		return false;
	}

	var weights = [2, 3, 4, 5, 6, 7, 8, 9, 2, 3, 4, 5];
	for(var i = 0; i < 12; i++) {
		sum += parseInt(rrn.charAt(i)) * weights[i];
	}
	var check = (11 - (sum % 11)) % 10;
	if(check !== parseInt(rrn.charAt(12))) {
		$('#RRNError').text('유효하지 않은 주민등록번호입니다.').css('color', 'red');
		return false;
	}
	$('#RRNError').text('유효한 주민등록번호입니다').css('color', 'blue');
	return true;
}

// ID 중복체크
function checkUserId() {
	if(!validateUserId()) return;
	
	var userId = $('#userId').val();
	
	$.ajax({
		url: '/user/checkUserId.do',
		type: 'POST',
		data: { userId: userId },
		dataType: 'json',
		success: function(response) {
			if(response.duplicate) { // object
				// $('#userIdChecked').val('false'); // 중복
				$('#userIdError').text('이미 사용 중인 아이디입니다.').css('color', 'red');
			} else {
				$('#userIdChecked').val('true');
				$('#userIdError').text('사용 가능한 ID입니다.').css('color', 'blue');
			}
		},
		error: function(xhr, status, error) {
			alert('중복체크 중 오류가 발생했습니다.');
		}
	});
}

// 회원가입 폼 제출 시 전체 유효성 검증
function validateForm() { // ajax로 바꾸기
	var isValid = true;
	
	if(!validateUserId()) isValid = false;
	if($('#userIdChecked').val() !== 'true') {
		alert('아이디 중복체크를 해주세요.');
		isValid = false;
	}
	
	if(!validatePassword()) isValid = false;
	if(!validatePasswordConfirm()) isValid = false;
	
	if($('#userName').val().trim() === '') {
		$('#userNameError').text('이름을 입력해주세요.').css('color', 'red');
		isValid = false;
	} else {
		$('#userNameError').text();
	}
	
	return isValid;
}

// 데이터가 많아지게 되면 ajax가 효율적이다.

$(document).ready(function() {
	$('#userId').on('blur', validateUserId);
	$('#pwd').on('keyup', function() {
			validatePassword();
			validatePasswordConfirm(); // 실시간 일치 여부도 함께
	});
	$('#pwdck').on('keyup', validatePasswordConfirm);
	$('#idcked').on('click', checkUserId); // ID 중복 체크 버튼 연결

	// 유효성 검증 강화 - 아이디 변경 시 중복체크 상태 초기화
	$('#userId').on('input', function() {
		$('#userIdChecked').val('false');
		$('#userIdError').text('');
	});
});

</script>


<div class="container" style="margin-top: 50px">
	<form action="/user/userInsert.do" method="post" onSubmit="return validateForm()" class="form-horizontal" id="sendForm">
		<input type="hidden" id="userIdChecked" value="false" />
	    
	    <!-- 아이디 -->
	    <div class="form-group">
	      <label class="col-sm-2 control-label">ID</label>
	      <div class="col-sm-4">
	        <input class="form-control" id="userId" name="userId" type="text" value="" title="ID" placeholder="아이디를 입력해주세요">
					<!-- ID 유효성 메시지 -->
					<div id="userIdError" style="margin-top: 5px;"></div>
	      </div>
				<!-- 중복확인 버튼 -->
	      <div class="container">
					<button type="button" id="idcked" class="btn btn-default" style="display: block;">ID 중복 체크</button>
	      </div>
	    </div>

			<!-- 비밀번호 -->
	    <div class="form-group">
	      <label class="col-sm-2 control-label">비밀번호</label>
	      <div class="col-sm-4">
	        <input class="form-control" id="pwd" name="pwd" type="password" title="비밀번호" placeholder="비밀번호를 입력해주세요" />
					<div id="pwdError" style="margin-top: 5px;"></div>
	      </div>
	      <label class="col-sm-2 control-label">비밀번호 확인</label>
	      <div class="col-sm-4">
	        <input class="form-control" id="pwdck" name="" type="password" title="비밀번호 확인" placeholder="비밀번호를 한번 더 입력해주세요" />
	        <div id="passwordConfirmError" style="margin-top: 5px;"></div>	      	
	      </div>
	    </div>

			<!-- 이름 -->
	    <div class="form-group">
	      <label class="col-sm-2 control-label">이름</label>
	      <div class="col-sm-4">
	        <input class="form-control" id="userName" name="userName" type="text" value="" title="이름" placeholder="이름을 입력해주세요" />
	        <div id="userNameError" style="margin-top: 5px;"></div>	      	
	      </div>
	    </div>

			<!-- 주민등록번호 -->
			<div class="form-group">
				<label class="col-sm-2 control-label">주민등록번호( - 제외)</label>
				<div class="col-sm-4">
					<input class="form-control" id="userRRN" name="userRRN" type="text" title="주민등록번호"
								 placeholder="예: 1234561234567" maxlength="13"
								 oninput="this.value = this.value.replace(/[^0-9]/g, '')"
					/>
					<div id="RRNError" style="margin-top: 5px;"></div>
				</div>
				<div class="container">
					<button type="button" class="btn btn-default" style="display: block;" onclick="validateRRN()">주민등록번호 확인</button>
				</div>
			</div>

			<!-- 우편번호 -->
			<div class="form-group">
				<label class="col-sm-2 control-label">우편번호</label>
				<div class="col-sm-4">
					<input class="form-control" id="zipCode" name="zipCode" type="text" title="우편번호" />
					<div id="zipCodeError" style="margin-top: 5px;"></div>
				</div>
				<div class="container">
					<button type="button" class="btn btn-default" style="display: block;">우편번호 찾기</button>
				</div>
			</div>

			<!-- 주소 -->
			<div class="form-group">
				<label class="col-sm-2 control-label">주소</label>
				<div class="col-sm-4">
					<input class="form-control" id="address1" name="address1" type="text" title="주소" />
				</div>
			</div>

			<!-- 상세 주소 -->
			<div class="form-group">
				<label class="col-sm-2 control-label">상세 주소</label>
				<div class="col-sm-4">
					<input class="form-control" id="address2" name="address2" type="text" title="상세주소" />
				</div>
			</div>

			<!-- 회사 주소 -->
			<div class="form-group">
				<label class="col-sm-2 control-label">회사 주소</label>
				<div class="col-sm-4">
					<input class="form-control" id="companyAddress" name="companyAddress" type="text" title="회사주소" />
				</div>
				<div class="container">
					<button type="button" class="btn btn-default" style="display: block;">검색</button>
				</div>
			</div>

			<!-- 이메일 -->
			<div class="form-group">
				<label class="col-sm-2 control-label">이메일</label>
				<div class="col-sm-4">
					<input class="form-control" id="userEmail" name="userEmail" type="text" title="이메일" placeholder="예: example@example.com">
					<!-- 이메일 유효성 메시지 -->
					<div id="emailError" style="margin-top: 5px;"></div>
				</div>
				<!-- 이메일 인증 버튼 -->
				<div class="container">
					<button type="button" id="emailAuthBtn" class="btn btn-default" style="display: block;">인증번호 발송</button>
				</div>
			</div>

			<!-- 첨부파일 -->
			<div class="form-group">
				<label class="col-sm-2 control-label">첨부파일</label>
				<div class="col-sm-4">
					<input type="file" id="fileInput" multiple accept="*/*" class="form-control">
					<ul id="fileList" style="margin-top:5px; list-style:none; padding:0;"></ul>
				</div>
			</div>

			<!-- 버튼 -->
	    <div class="col-md-offset-4">
				<button type="submit" id="saveBtn" class="btn btn-primary">저장</button>
				<button type="button" id="#" class="btn btn-warning" onclick="location.href='/login/login.do'">목록</button>
				<button type="button" id="#" class="btn btn-danger" onclick="location.href='/login/login.do'">취소</button>
	    </div>
	</form>
	<c:if test="${insertSuccess}">
	    <script type="text/javascript">
	        alert("회원가입이 완료되었습니다. 로그인 페이지로 이동합니다.");
	        window.location.href = "/login/login.do";
	    </script>
	</c:if>
</div>

<script>
	$('#emailDomain').editableSelect({
		filter: false,
		effects: 'slide',
		duration: 200,
		trigger: 'manual'
	}).on('change', function() {
		if(this.value === 'custom') {
			$(this).editableSelect('hide');
			$('#emailDomainCustom').show().focus();
		}
	});

	$('#emailDomainCustom').on('blur', function() {
		if($(this).val()) {
			$('#emailDomain').editableSelect('add', $(this).val());
			$('#emailDomain').editableSelect('set', $(this).val());
		}
		$(this).hide();
	});

</script>