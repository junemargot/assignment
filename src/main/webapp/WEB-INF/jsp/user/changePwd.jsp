<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<html>
<head>
  <title>비밀번호 변경</title>
  <script type="text/javascript">
      // ID 유효성 및 가입회원 여부 체크
      function checkUserIdExist() {
          var userId = $('#userId').val().trim();
          if (userId === '') {
              $('#userIdError').text('아이디를 입력하세요.').css('color', 'red');
              return false;
          }
          // AJAX로 DB에 가입된 회원인지 확인
          $.ajax({
              url: '/user/checkUserIdExists.do',
              type: 'POST',
              data: { userId: userId },
              dataType: 'json',
              success: function(response) {
                  if (response.exists) {
                      $('#userIdChecked').val('true');
                      $('#userIdError').text('가입된 아이디입니다.').css('color', 'blue');
                      $('#pwd').prop('disabled', false);
                      $('#pwdck').prop('disabled', false);
                  } else {
                      $('#userIdChecked').val('false');
                      $('#userIdError').text('가입되어 있지 않은 아이디입니다.').css('color', 'red');
                      $('#pwd').prop('disabled', true).val('');
                      $('#pwdck').prop('disabled', true).val('');
                      $('#pwdError').text('');
                      $('#passwordConfirmError').text('');
                  }
              },
              error: function() {
                  $('#userIdError').text('ID 체크 중 오류가 발생했습니다.').css('color', 'red');
              }
          });
      }

      // 비밀번호 유효성 검사 (회원가입과 동일)
      function validatePassword() {
          var password = $('#pwd').val();
          // 6~12자리, 영문/숫자/특수문자 조합
          var passwordRegex = /^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*])[a-zA-Z0-9!@#$%^&*]{6,12}$/;
          if (!passwordRegex.test(password)) {
              $('#pwdError').text('비밀번호는 6~12자리, 영문/숫자/특수문자를 모두 포함해야 합니다.').css('color', 'red');
              return false;
          }
          $('#pwdError').text('사용 가능한 비밀번호입니다.').css('color', 'blue');
          return true;
      }

      // 비밀번호 확인
      function validatePasswordConfirm() {
          var password = $('#pwd').val();
          var passwordConfirm = $('#pwdck').val();
          if (passwordConfirm === '') {
              $('#passwordConfirmError').text('비밀번호를 한번 더 입력해주세요.').css('color', 'red');
              return false;
          }
          if (password !== passwordConfirm) {
              $('#passwordConfirmError').text('비밀번호가 일치하지 않습니다.').css('color', 'red');
              return false;
          }
          $('#passwordConfirmError').text('비밀번호가 일치합니다.').css('color', 'blue');
          return true;
      }

      // 폼 제출 전 전체 유효성 검사
      function validateChangeForm() {
          var isValid = true;
          if ($('#userIdChecked').val() !== 'true') {
              $('#userIdError').text('ID 체크를 해주세요.').css('color', 'red');
              isValid = false;
          }
          if (!validatePassword()) isValid = false;
          if (!validatePasswordConfirm()) isValid = false;
          return isValid;
      }

      $(document).ready(function() {
          $('#idcked').on('click', checkUserIdExist);
          $('#pwd').on('keyup', function() {
              validatePassword();
              validatePasswordConfirm();
          });
          $('#pwdck').on('keyup', validatePasswordConfirm);
          $('#userId').on('input', function() {
              $('#userIdChecked').val('false');
              $('#userIdError').text('');
              $('#pwd').prop('disabled', true).val('');
              $('#pwdck').prop('disabled', true).val('');
              $('#pwdError').text('');
              $('#passwordConfirmError').text('');
          });
          $('#changeForm').on('submit', function() {
              return validateChangeForm();
          });
      });
  </script>
</head>
<body>
  <div class="container" style="margin-top: 50px">
    <form action="/user/changePwd.do" method="post" class="form-horizontal" id="changeForm">
      <input type="hidden" id="userIdChecked" value="false" />
      <!-- 아이디 -->
      <div class="form-group">
        <label class="col-sm-2 control-label">ID</label>
        <div class="col-sm-4">
          <input class="form-control" id="userId" name="userId" type="text" value="" title="ID" placeholder="아이디를 입력해주세요" />
          <!-- ID 유효성 메시지 -->
          <div id="userIdError" style="margin-top: 5px;"></div>
        </div>
        <!-- 중복확인 버튼 -->
        <div class="container">
          <button type="button" id="idcked" class="btn btn-default" style="display: block;">ID 체크</button>
        </div>
      </div>

      <!-- 비밀번호 -->
      <div class="form-group">
        <label class="col-sm-2 control-label">변경 패스워드</label>
        <div class="col-sm-4">
          <input class="form-control" id="pwd" name="pwd" type="password" title="비밀번호" placeholder="비밀번호를 입력해주세요" />
          <div id="pwdError" style="margin-top: 5px;"></div>
        </div>
        <label class="col-sm-2 control-label">변경 패스워드 확인</label>
        <div class="col-sm-4">
          <input class="form-control" id="pwdck" name="" type="password" title="비밀번호 확인" placeholder="비밀번호를 한번 더 입력해주세요" />
          <div id="passwordConfirmError" style="margin-top: 5px;"></div>
        </div>
      </div>

      <!-- 버튼 -->
      <div class="col-md-offset-4">
        <button type="submit" id="changeBtn" class="btn btn-primary">변경</button>
        <button type="button" id="#" class="btn btn-danger" onclick="location.href='/login/login.do'">취소</button>
      </div>

    </form>
    <c:if test="${changeSuccess}">
      <script type="text/javascript">
          alert("비밀번호가 성공적으로 변경되었습니다. 로그인 페이지로 이동합니다.");
          window.location.href = "/login/login.do";
      </script>
    </c:if>
  </div>
</body>
</html>
