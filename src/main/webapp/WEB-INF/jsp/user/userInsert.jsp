<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>


<script type="text/javascript">
function validateUserId() {
	var userId = $('#userId').val();
	if(userId.length < 6) {
		$('#userIdError').text('아이디는 6글자 이상이어야 합니다.').css('color', 'red');
		return false;
	}
	$('#userIdError').text('');
	return true;
}

	$(document).ready(function(){
		// ID 중복 체크 버튼 클릭 이벤트
		$("#idcked").click(function(){
			var userId = $("#userId").val();
			
			// 아이디 입력 확인
			if(userId == '' || userId.length == 0) {/
				alert("아이디를 입력해주세요.");
				$("#userId").focus();
				return false;
			}
			
			// AJAX로 중복체크 요청
			$.ajax({
			    url: '/boardAjax/user/checkUserId.do',
			    type: 'POST',
			    data: { userId: userId },
			    dataType: 'json',
			    success: function(result) {
			        if(result.duplicate == true) {
			            $("#checkResult").css("color", "red").text("사용 불가능한 ID입니다.");
			        } else {
			            $("#checkResult").css("color", "green").text("사용 가능한 ID입니다.");
			        }
			    },
			    error: function() {
			        alert("중복체크 중 오류가 발생했습니다.");
			    }
			});
		});
	});
</script>


<div class="container" style="margin-top: 50px">
	<form action="/boardAjax/user/userInsert.do" method="post" class="form-horizontal" id="sendForm">
	    <div class="form-group">
	      <label class="col-sm-2 control-label">ID</label>
	      <div class="col-sm-4">
	        <input class="form-control" id="userId" name="userId" type="text" value="" title="ID">
	      </div>

	      <div class="container">
	      	<button type="button" id="idcked" class="btn btn-default" style="display: block;">ID 중복 체크</button>
   	        <div id="userIdError"></div>
	      	<span id="checkResult"></span>
	      </div>

	    </div>

	    <div class="form-group">
	      <label for="disabledInput " class="col-sm-2 control-label">패스워드</label>
	      <div class="col-sm-4">
	        <input class="form-control" id="pwd" name="pwd" type="password" title="패스워드" >
	      </div>
	      <label for="disabledInput " class="col-sm-2 control-label">패스워드 확인</label>
	      <div class="col-sm-4">
	        <input class="form-control" id="pwdck" name="" type="password" title="패스워드 확인">
	      </div>
	    </div>

	    <div class="form-group">
	      <label for="disabledInput" class="col-sm-2 control-label">이름</label>
	      <div class="col-sm-4">
	        <input class="form-control" id="userName" name="userName" type="text" value="" title="이름" >
	      </div>
	    </div>


	    <div class="col-md-offset-4">
			<button type="submit" id="saveBtn"class="btn btn-primary">저장</button>
			<button type="button" id="#"class="btn btn-danger">취소</button>
	    </div>
	</form>
</div>


