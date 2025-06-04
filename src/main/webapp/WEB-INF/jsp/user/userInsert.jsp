<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>


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
	if(userId.length < 6) {
		$('#userIdError').text('아이디는 6글자 이상이어야 합니다.').css('color', 'red');
		return false;
	}
	$('#userIdError').text('');
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
	      <label for="disabledInput " class="col-sm-2 control-label">비밀번호</label>
	      <div class="col-sm-4">
	        <input class="form-control" id="pwd" name="pwd" type="password" title="비밀번호" placeholder="비밀번호를 입력해주세요" />
	      	<div id="pwdError" style="margin-top: 5px;"></div>
	      </div>
	      <label for="disabledInput " class="col-sm-2 control-label">비밀번호 확인</label>
	      <div class="col-sm-4">
	        <input class="form-control" id="pwdck" name="" type="password" title="비밀번호 확인" placeholder="비밀번호를 한번 더 입력해주세요" />
	        <div id="passwordConfirmError" style="margin-top: 5px;"></div>	      	
	      </div>
	    </div>

	    <div class="form-group">
	      <label for="disabledInput" class="col-sm-2 control-label">이름</label>
	      <div class="col-sm-4">
	        <input class="form-control" id="userName" name="userName" type="text" value="" title="이름" placeholder="이름을 입력해주세요" />
	        <div id="userNameError" style="margin-top: 5px;"></div>	      	
	      </div>
	    </div>


	    <div class="col-md-offset-4">
			<button type="submit" id="saveBtn" class="btn btn-primary">회원가입</button>
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
