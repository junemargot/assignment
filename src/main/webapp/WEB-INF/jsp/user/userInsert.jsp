<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
<style>
	.form-group > div[class^="col-sm-"] {
		padding-right: 5px;
		padding-left: 5px;
	}

	.required-star {
		color: red;
		vertical-align: middle;
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
	const userName = $('#userName').val();
	const userNameRegex = /^[가-힣a-zA-Z]{2,}$/;

	if(!userNameRegex.test(userName)) {
		$('#userNameError').text('한글 또는 영문 2글자 이상 입력해주세요.').css('color', 'red');
		return false;
	}

	$('#userNameError').text('');
	return true;
}

// 주민번호 검증
function validateRRN() {
	let rrn = $('#userRRN').val().replace(/-/g, '');

	// 길이 및 숫자 체크
	if(rrn.length !== 13 || isNaN(rrn)) {
		$('#RRNError').text('13자리 주민등록번호를 입력해주세요.').css('color', 'red');
		return false;
	}

	// 주민번호 유효성 검증
	const weights = [2, 3, 4, 5, 6, 7, 8, 9, 2, 3, 4, 5];
	let sum = 0;

	for(let i = 0; i < 12; i++) {
		sum += parseInt(rrn[i]) * weights[i];
	}

	const checkDigit = (11 - (sum % 11)) % 10;
	if(checkDigit !== parseInt(rrn[12])) {
		$('#RRNError').text('유효하지 않은 주민등록번호입니다.').css('color', 'red');
		return false;
	}

	$('#RRNError').text('유효한 주민등록번호입니다.').css('color', 'blue');
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

// 이메일 검증
function validateEmail() {
	const email = ($('#userEmail').val() || '').trim();
	const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;

	if(email === '') {
		$('#emailError').text('이메일을 입력해주세요.').css('color', 'red');
		return false;
	}

	if(!emailRegex.test(email)) {
		$('#emailError').text('유효한 이메일 주소를 입력해주세요.').css('color', 'red');
		return false;
	}

	$('#emailError').text('');
	return true;
}

// 인증번호 형식 검증
function validateEmailCode() {
	const code = $('#emailAuthCode').val().trim();

	if(code === '') {
		$('#emailCodeError').text('인증번호를 입력해주세요.').css('color', 'red');
		return false;
	}

	if(code.length !== 6 || isNaN(code)) {
		$('#emailCodeError').text('6자리 숫자를 입력해주세요.').css('color', 'red');
		return false;
	}

	$('#emailCodeError').text('');
	return true;
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

	// 이메일
	if(!validateEmail()) {
		isValid = false;
	} else if($('#emailVerified').val() !== 'true') {
		$('#emailCodeError').text('이메일 인증을 완료해주세요.').css('color', 'red');
		isValid = false;
	}
	
	return isValid;
}







// 데이터가 많아지게 되면 ajax가 효율적이다.

$(document).ready(function() {
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

	$('#userName').on('blur keyup', validateUserName);

	// 눈 아이콘 클릭 시 보이기/숨기기
	$('#viewRRN').on('click', function() {
		const input = $('#userRRN');
		const icon = $(this).find('i');
		if (input.attr('type') === 'password') {
			input.attr('type', 'text');
			icon.removeClass('fa-eye-slash').addClass('fa-eye');
		} else {
			input.attr('type', 'password');
			icon.removeClass('fa-eye').addClass('fa-eye-slash');
		}
	});

	// 이메일 변경 감지 및 상태 초기화
	let initialEmail = '';

	$('#userEmail').on('input', function() {
		const currentEmail = $(this).val().trim();

		if(initialEmail && currentEmail !== initialEmail) {
			// 상태 초기화 UI 표시
			$('#emailError').text('이메일이 변경되었습니다. 재인증이 필요합니다.').css('color', 'red');
			$('#emailCodeError').text('');
			// 서버에 기존 인증번호 삭제 요청
			$.post('/user/clearCode.do', { email: initialEmail }).fail(() => console.error('기존 인증번호 삭제 실패'));

			// 로컬 상태 초기화
			resetVerificationState();

			// 현재 입력값을 새로운 기준값으로 설정
			initialEmail = currentEmail;
		}
	});

	// 이메일 인증번호 버튼 이벤트
	$('#emailAuthBtn').on('click', function() {
		if(!validateEmail()) return;

		const email = $('#userEmail').val().trim();
		initialEmail = email;

		$.ajax({
			type: 'GET',
			url: '/user/mailCheck.do?email=' + encodeURIComponent(email),
			success: function() {
				// 1. 이메일 입력칸, 인증번호 발송 버튼 비활성화
				// $('#userEmail').prop('readonly', false); // 이메일 입력칸 활성화 유지
				// $('#emailAuthBtn').prop('disabled', false); // 인증번호 버튼 비활성화
				// alert("인증번호가 발송되었습니다.");
				$('#emailError').text('인증번호가 발송되었습니다. 5분 내로 입력해주세요.').css('color', 'blue');

				// 2. 인증번호 입력칸 + 확인버튼
				$('#emailAuthArea').css('display', 'flex').find('input', 'button').prop('disabled', false); // 인증번호 입력 영역 표시
				$('#emailAuthCode').prop('disabled', false).val('').focus(); // 인증번호 입력칸 활성화하고 포커스
				$('#emailVerifyBtn').prop('disabled', false);
			},
			error: function(xhr) {
				alert("인증번호 발송에 실패했습니다." + xhr.responseText);
			}
		});
	});

	// 인증번호 확인 버튼 이벤트
	$('#emailVerifyBtn').on('click', function() {
		if(!validateEmailCode()) return;

		$.ajax({
			url: '/user/verifyCode.do',
			method: 'POST',
			data: {
				email: $('#userEmail').val().trim(),
				code: $('#emailAuthCode').val().trim()
			},
			success: function(result) {
				if(result) {
					$('#emailVerified').val('true');
					$('#emailCodeError').text('이메일 인증이 완료되었습니다.').css('color', 'blue');
					$('#emailError').text('');
					// 인증번호 입력칸, 확인버튼 비활성화
					$('#emailAuthCode').prop('disabled', true);
					$('#emailVerifyBtn').prop('disabled', true);
				} else {
					$('#emailCodeError').text('인증번호가 일치하지 않습니다.').css('color', 'red');
				}
			},
			error: function() {
				alert('인증 처리 중 오류가 발생했습니다.');
			}
		});
	});
});

function resetVerificationState() {
	$('#emailVerified').val('false');
	$('#emailAuthCode').val('').prop('disabled', false);
	$('#emailVerifyBtn').val.prop('disabled', false);
	$('#emailCodeError').text('');

	$.post('/user/clearCode.do', { email: initialEmail });
}

</script>

<div class="container" style="margin-top: 50px">
	<form action="/user/userInsert.do" method="post" onSubmit="return validateForm()" class="form-horizontal" id="sendForm">
		<input type="hidden" id="userIdChecked" value="false" />
		<!-- 아이디 -->
		<div class="form-group">
			<label class="col-sm-2 control-label">
				ID <span class="required-star">*</span>
			</label>
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
			<label class="col-sm-2 control-label">
				비밀번호 <span class="required-star">*</span>
			</label>
			<div class="col-sm-4">
				<input class="form-control" id="pwd" name="pwd" type="password" title="비밀번호" placeholder="비밀번호를 입력해주세요" />
				<div id="pwdError" style="margin-top: 5px;"></div>
			</div>
			<label class="col-sm-2 control-label">
				비밀번호 확인 <span class="required-star">*</span>
			</label>
			<div class="col-sm-4">
				<input class="form-control" id="pwdck" name="" type="password" title="비밀번호 확인" placeholder="비밀번호를 한번 더 입력해주세요" />
				<div id="passwordConfirmError" style="margin-top: 5px;"></div>
			</div>
		</div>

		<!-- 이름 -->
		<div class="form-group">
			<label class="col-sm-2 control-label">
				이름 <span class="required-star">*</span>
			</label>
			<div class="col-sm-4">
				<input class="form-control" id="userName" name="userName" type="text" value="" title="이름" placeholder="이름을 입력해주세요" />
				<div id="userNameError" style="margin-top: 5px;"></div>
			</div>
		</div>

		<!-- 이메일 -->
		<div class="form-group">
			<label class="col-sm-2 control-label">
				이메일 <span class="required-star">*</span>
			</label>
			<div class="col-sm-4">
				<div style="display: flex; gap: 8px; width: 100%;">
					<input class="form-control" id="userEmail" name="email" type="email" placeholder="예: example@example.com" autocomplete="off" style="flex: 2;" />
					<button type="button" id="emailAuthBtn" class="btn btn-default" style="flex: 1;">인증번호 발송</button>
				</div>
				<!-- 인증번호 입력 + 인증 확인 버튼 (아래 줄) -->
				<div id="emailAuthArea" style="gap: 8px; margin-top: 8px; display: none; width: 100%;">
					<input class="form-control" id="emailAuthCode" type="text" placeholder="인증번호 6자리" style="flex: 2;" />
					<button type="button" id="emailVerifyBtn" class="btn btn-success" style="flex: 1;">인증 확인</button>
				</div>
				<input type="hidden" id="emailVerified" value="false" />
				<div id="emailError" style="margin-top: 5px;"></div>
				<div id="emailCodeError" style="margin-top: 5px;"></div>
			</div>
		</div>

		<!-- 주민등록번호 -->
		<div class="form-group">
			<label class="col-sm-2 control-label">주민등록번호( - 제외)</label>
			<div class="col-sm-4" style="position: relative;">
				<input class="form-control" id="userRRN" name="rrn" type="password" title="주민등록번호" placeholder="예: 1234561234567" maxlength="13" autocomplete="off" />
				<span id="viewRRN" style="position: absolute; right: 14px; top: 7px; cursor: pointer; font-size: 14px; color: #888;">
					<i class="fa fa-eye-slash" aria-hidden="true"></i>
				</span>
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
				<input class="form-control" id="zipCode" name="zipcode" type="text" title="우편번호" readonly />
				<div id="zipCodeError" style="margin-top: 5px;"></div>
			</div>
			<div class="container">
				<button type="button" onclick="searchAddress('address')" class="btn btn-default" style="display: block;">우편번호 찾기</button>
			</div>
		</div>

		<!-- 주소 -->
		<div class="form-group">
			<label class="col-sm-2 control-label">주소</label>
			<div class="col-sm-4">
				<input class="form-control" id="address1" name="address1" type="text" title="주소" readonly />
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
				<input class="form-control" id="companyAddress" name="companyAddress" type="text" title="회사주소" readonly />
			</div>
			<div class="container">
				<button onclick="openJusoPopup()" type="button" class="btn btn-default" style="display: block;">주소 검색</button>
			</div>
		</div>

		<!-- 첨부파일 -->
		<div class="form-group">
			<label class="col-sm-2 control-label">첨부 파일</label>
			<div class="col-sm-4">
				<input type="file" id="fileInput" name="files" multiple accept="*/*" onchange="handleFiles(this.files)" class="form-control" style="display: none;">
				<button type="button" class="btn btn-default" onclick="document.getElementById('fileInput').click()">파일 선택</button>
				<div id="fileList" style="margin-top: 10px;"></div>
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

<!-- script 추가 -->
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script>
	function searchAddress() {
		new daum.Postcode({
			oncomplete: function(data) {
				$('#zipCode').val(data.zonecode);
				$('#address1').val(data.address);
				$('#address2').focus();
			}
		}).open();
	}

	// 회사 주소 팝업 열기 함수
	function openJusoPopup() {
		// jusoPopup.jsp는 행정안전부에서 제공하는 샘플 파일을 서버에 올린 경로로 수정하세요
		window.open('/popup/jusoPopup.jsp', 'jusoPopup', 'width=570,height=420,scrollbars=yes,resizable=yes');
	}

	// 팝업에서 주소를 선택하면 이 함수가 실행됨
	function jusoCallBack(roadFullAddr, roadAddrPart1, addrDetail, roadAddrPart2, engAddr, jibunAddr, zipNo, admCd, rnMgtSn, bdMgtSn,
												detBdNmList, bdNm, bdKdcd, siNm, sggNm, emdNm, liNm, rn, udrtYn, buldMnnm, buldSlno, mtYn, lnbrMnnm, lnbrSlno, emdNo) {
		// roadFullAddr(전체 도로명주소) 또는 roadAddrPart1(도로명주소) 중 원하는 값 사용
		document.getElementById('companyAddress').value = roadFullAddr;
	}
</script>

<script>
	let uploadedFiles = [];

	function handleFiles(files) {
		// 파일 개수 제한
		if(files.length > 3) {
			alert('파일첨부는 최대 3개까지만 가능합니다.');

			document.getElementById('fileInput').value = '';
			uploadedFiles = [];

			return;
		}

		// 파일 배열 초기화 후 새로 담기
		for(let i = 0; i < files.length; i++) {
			uploadedFiles.push(files[i]);
		}
		console.log(uploadedFiles);
		updateFileList();
}

	function updateFileList() {
		uploadedFiles.forEach((file, index) => {
			console.log(`파일 ${index}:`, file);
			console.log(`파일명: `, file.name);
			console.log(`파일명 타입: `, typeof file.name);
		});

		var list = uploadedFiles.map((file, index) => {
			return `
				<div style="display:flex; align-items:center; margin-bottom:4px; color:black;">
					<span>\${file.name}</span>
					<button type="button" onclick="removeFile(\${index})" class="btn btn-xs btn-danger" style="margin-left:8px;">삭제</button>
				</div>
  `}).join('');
		$('#fileList').html(list);
	}

	function removeFile(index) {
		var test = uploadedFiles.splice(index, 1);
		console.log("삭제: ", test);
		document.getElementById('fileInput').value = '';
		updateFileList();
	}
</script>
