<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script>
    $(document).ready(function(){
        // 거래일자 datepicker 설정
        $('input[name="transactionDate"]').addClass('datepicker');

        // 금액 필드 - 숫자만 입력 허용
        $('input[name="transactionMoney"]').on('input', function(){
            this.value = this.value.replace(/[^0-9]/g, '');
            if(this.value) {
                this.value = Number(this.value).toLocaleString();
            }
        });

        // 기존 데이터로 select 박스들 설정
        loadExistingData();

        // select 박스 change 이벤트들 (기존과 동일)
        $('#profitCost').change(function(){
            var selectedCode = $(this).val();
            if(selectedCode) {
                loadSubCategory(selectedCode, '#bigGroup');
                resetLowerSelects(['select[name="middleGroup"]', 'select[name="smallGroup"]', 'select[name="comment1"]']);
            }
        });

        // 나머지 change 이벤트들도 동일하게 구현
    });

    // 기존 데이터로 select 박스들 설정
    function loadExistingData() {
        var profitCost = '${accountData.PROFIT_COST}';
        var bigGroup = '${accountData.BIG_GROUP}';
        var middleGroup = '${accountData.MIDDLE_GROUP}';
        var smallGroup = '${accountData.SMALL_GROUP}';
        var detailGroup = '${accountData.DETAIL_GROUP}';

        // 1차 select 설정
        $('#profitCost').val(profitCost);

        // 2차 select 로딩 및 설정
        if(profitCost) {
            loadSubCategoryWithCallback(profitCost, '#bigGroup', function() {
                $('#bigGroup').val(bigGroup);

                // 3차 select 로딩 및 설정
                if(bigGroup) {
                    loadSubCategoryWithCallback(bigGroup, 'select[name="middleGroup"]', function() {
                        $('select[name="middleGroup"]').val(middleGroup);

                        // 4차 select 로딩 및 설정
                        if(middleGroup && middleGroup !== '0') {
                            loadSubCategoryWithCallback(middleGroup, 'select[name="smallGroup"]', function() {
                                $('select[name="smallGroup"]').val(smallGroup);

                                // 5차 select 로딩 및 설정
                                if(smallGroup && smallGroup !== '0') {
                                    loadSubCategoryWithCallback(smallGroup, 'select[name="comment1"]', function() {
                                        $('select[name="comment1"]').val(detailGroup);
                                    });
                                }
                            });
                        }
                    });
                }
            });
        }
    }

    // 콜백 함수를 지원하는 loadSubCategory
    function loadSubCategoryWithCallback(parentCode, targetSelect, callback) {
        $.ajax({
            url: '/account/getSubCategory.do',
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

                // 콜백 함수 실행
                if(callback) callback();
            }
        });
    }

    // 수정 저장 함수
    function updateCostData() {
        // 유효성 검사 (기존과 동일)

        var formData = {
            seq: '${accountData.ACCOUNT_SEQ}',
            profitCost: $('#profitCost').val(),
            bigGroup: $('#bigGroup').val(),
            middleGroup: $('select[name="middleGroup"]').val() || '0',
            smallGroup: $('select[name="smallGroup"]').val() || '0',
            detailGroup: $('select[name="comment1"]').val() || '0',
            comments: $('input[name="comment"]').val() || '',
            transactionMoney: $('input[name="transactionMoney"]').val().replace(/,/g, ''),
            transactionDate: $('input[name="transactionDate"]').val()
        };

        $.ajax({
            url: '/account/update.do',
            type: 'POST',
            data: formData,
            dataType: 'json',
            success: function(result) {
                if(result.success) {
                    alert('수정되었습니다.');
                    location.href = '/account/accountList.do';
                }
            }
        });
    }
</script>

<div class="container" style="margin-top: 50px">
  <div class="col-sm-11" id="costDiv">
    <div class="col-sm-12">
      <div class="col-sm-3">
        <select class="form-control" id="profitCost" name="profitCost" title="수익/비용">
          <option value="">대분류 선택</option>
          <c:forEach var="list" items="${resultMap}" varStatus="cnt">
            <option value="${list.code}">${list.comKor}</option>
          </c:forEach>
        </select>
      </div>

      <div class="col-sm-3">
        <select class="form-control" id="bigGroup" name="bigGroup" title="관">
          <option value="">선택</option>
        </select>
      </div>

      <div class="col-sm-3">
        <select class="form-control" name="middleGroup" title="항">
          <option value="0">해당없음</option>
        </select>
      </div>

      <div class="col-sm-3">
        <select class="form-control" name="smallGroup" title="목">
          <option value="0">해당없음</option>
        </select>
      </div>
    </div>

    <div class="col-sm-12">
      <div class="col-sm-3">
        <select class="form-control" name="comment1" title="과">
          <option value="0">해당없음</option>
        </select>
      </div>
      <div class="col-sm-9">
        <input class="form-control" name="comment" type="text"
               value="${accountData.COMMENTS}" placeholder="비용 상세 입력" title="비용 상세">
      </div>
    </div>

    <div class="col-sm-12">
      <div class="col-sm-3">
        <input class="form-control" name="transactionMoney" type="text"
               value="${accountData.TRANSACTION_MONEY}" title="금액">
      </div>
      <div class="col-sm-3">
        <input class="form-control datepicker" name="transactionDate" type="text"
               value="${accountData.TRANSACTION_DATE}" title="거래일자" readonly>
      </div>
    </div>
  </div>

  <!-- 수정 버튼 -->
  <div class="col-sm-12" style="text-align: center; margin-top: 20px;">
    <button type="button" class="btn btn-primary" onclick="updateCostData()">수정</button>
    <button type="button" class="btn btn-default" onclick="location.href='/account/accountList.do'">목록</button>
  </div>
</div>
