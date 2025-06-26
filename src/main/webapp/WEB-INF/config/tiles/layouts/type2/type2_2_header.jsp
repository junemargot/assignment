<%@page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<nav class="navbar navbar-inverse">
  <div class="container-fluid">
    <div class="navbar-header">
      <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#myNavbar">
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
        <span class="icon-bar"></span>
      </button>
      <a class="navbar-brand" href="/account/accountList.do">
		<img width="35px;" src='<c:url value="/images/egovframework/common/lime.jpg" />'>
      </a>
    </div>
    <div class="collapse navbar-collapse navbar-right" id="myNavbar">
			<ul class="nav navbar-nav">
				<li class="active">
					<a class="dropdown-toggle" data-toggle="dropdown" href="/board/boardList.do">게시판관리</a>
					<ul class="dropdown-menu">
						<li>
							<a href="/board/boardList.do">게시판</a>
						</li>
					</ul>
				</li>
			</ul>
      <ul class="nav navbar-nav">
        <li class="active">
					<a class="dropdown-toggle" data-toggle="dropdown" href="#">회계관리</a>
					<ul class="dropdown-menu">
						<li>
							<a href="/account/accountList.do">회계정보</a>
						</li>
					</ul>
        </li>
      </ul>
      <ul class="nav navbar-nav">
		<c:choose>
			<c:when test="${not empty sessionScope.loginUser}">
				<li class="active">
					<a href="/user/mypage.do">
						<span class="glyphicon glyphicon-user"></span>MyPage
					</a>
				</li>
				<li class="active">
					<a href="/user/mypage.do">
						<span class="glyphicon"></span>${sessionScope.loginUser.userName}님
					</a>
				</li>
				<li class="active">
					<a href="/login/logout.do">
						<span class="glyphicon glyphicon-log-in"></span>LogOut
					</a>
				</li>
			</c:when>
			<c:otherwise>
				<li class="dropdown active">
				  <span style="font-size: 12px; color: white; display: block; margin-top: 15px;">
					로그인해주세요
				  </span>
				</li>
				<li class="active">
				  <a href="/login/login.do">
					<span class="glyphicon glyphicon-log-in"></span>LogIn
				  </a>
				</li>
				<li class="active">
				  <a href="/user/userInsert.do">
					<span class="glyphicon glyphicon-user"></span>회원가입
				  </a>
				</li>
			</c:otherwise>
		</c:choose>
      </ul>
    </div>
  </div>
</nav>