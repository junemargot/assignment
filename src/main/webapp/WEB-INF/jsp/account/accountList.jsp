<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="ui" uri="http://egovframework.gov/ctl/ui"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<script type="text/javascript">


</script>

<form name="sendForm" id="sendForm" method="post" onsubmit="return false;">
	<input type="hidden" id="situSeq" name="situSeq" value="">
	<input type="hidden" id="mode" name="mode" value="Cre">
	<div id="wrap"  class="col-md-offset-1 col-sm-10">
		<div align="center"><h2>회계정보리스트</h2></div>
		<div class="form_box2 col-md-offset-7" align="right">
			<div class="right">
				<button class="btn btn-primary" onclick="location.href='/account/accountInsert.do'">등록</button>
				<button class="btn btn-primary" onclick="location.href='/account/listToExcel.do'">엑셀 다운</button>
			</div>
		</div>
	    <br/>
		<table class="table table-hover" style="margin-left: auto; margin-right: auto; text-align: center;">
		    <thead>
		      <tr align="center">
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
				<tbody>
					<c:forEach var="account" items="${accountList}">
						<tr>
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
	</div>
</form>


