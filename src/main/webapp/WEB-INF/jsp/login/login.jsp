<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script type="text/javascript">

</script>


<form id="sendForm" action="/login/loginProc.do" method="post" autocomplete="off">
	<input type="hidden" id="platform" name="platform" value="">
	<div class="container col-md-offset-2 col-sm-6" style="margin-top: 100px;">
		<div class="input-group">
			<span class="input-group-addon"><i class="glyphicon glyphicon-user"></i></span>
			<input id="userId" type="text" class="form-control valiChk" name="userId" title="ID" placeholder="아이디를 입력해주세요" />
		</div>
		<div id="userIdError" style="color: red; margin-bottom: 5px;"></div>
		<div class="input-group">
			<span class="input-group-addon"><i class="glyphicon glyphicon-lock"></i></span>
			<input id="userPassword" type="password" class="form-control valiChk" name="userPassword" title="Password" placeholder="비밀번호를 입력해주세요" />
		</div>
        <div id="userPasswordError" style="color:red; margin-bottom:5px;"></div>
		<br />
		<div style="text-align: center;">
			<button type="submit" id="#" class="btn btn-primary">로그인</button>
			<button type="button" id="#" class="btn btn-warning" onclick="location.href='/login/login.do'">취소</button>
			<button type="button" id="#" class="btn btn-info" onclick="location.href='/user/userInsert.do'">회원가입</button>
			<button type="button" id="#" class="btn btn-success" onclick="location.href='/user/changePwd.do'">비밀번호 변경</button>
		</div>
		<!-- 로그인 실패 시 메시지 표시 -->
		<c:if test="${not empty errorMsg}">
			<div style="color: red; margin-top: 10px;">${errorMsg}</div>
		</c:if>

		<!-- 소셜 로그인 -->
		<div style="text-align: center; margin-top: 20px;">
			<a href="https://kauth.kakao.com/oauth/authorize?client_id=af43511c568316df64c319f5389140b8&redirect_uri=http://localhost:8080/login/oauth2/code/kakao&response_type=code">
				<img src="/resources/images/kakao/kakao_login_large_narrow.png" alt="카카오 로그인" style="width: 130px;" />
			</a>
			<a href="https://nid.naver.com/oauth2.0/authorize?response_type=code&client_id=V2xJK7UApgrINC3kyaYB&redirect_uri=http://localhost:8080/login/oauth2/code/naver&state=RANDOM_STRING">
				<img src="/resources/images/naver/btnG_완성형.png" alt="네이버 로그인" style="width: 119px;" />
			</a>
		</div>
	</div>
</form>

<script type="text/javascript">
document.addEventListener('DOMContentLoaded', function() {
	document.getElementById('sendForm').addEventListener('submit', function(e) {
		var userId = document.getElementById('userId').value.trim();
		var userPassword = document.getElementById('userPassword').value.trim();
		var valid = true;

		document.getElementById('userIdError').textContent = '';
		document.getElementById('userPasswordError').textContent = '';

		if(userId === '') {
			document.getElementById('userIdError').textContent = '아이디를 입력해주세요';
			valid = false;
		}

		if(userPassword === '') {
			document.getElementById('userPasswordError').textContent = '비밀번호를 입력해주세요';
			valid = false;
		}

		if(!valid) {
			e.preventDefault(); // 검증 실패 시 제출 방지
		}
	});
});
</script>