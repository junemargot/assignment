package com.lime.user.vo;

public class UserVO {

	private String userSeq   ;
	private String userId  ;
	private String pwd  ;
	private String userName  ;
	private String regDt  ;

	public String getUserSeq() {
		return userSeq;
	}
	public void setUserSeq(String usrrSeq) {
		this.userSeq = usrrSeq;
	}
	public String getUserId() {
		return userId;
	}
	public void setUserId(String userId) {
		this.userId = userId;
	}
	public String getPwd() {
		return pwd;
	}
	public void setPwd(String pwd) {
		this.pwd = pwd;
	}
	public String getUserName() {
		return userName;
	}
	public void setUserName(String userName) {
		this.userName = userName;
	}
	public String getRegDt() {
		return regDt;
	}
	public void setRegDt(String regDt) {
		this.regDt = regDt;
	}
	@Override
	public String toString() {
		return "UserVO [userSeq=" + userSeq + ", userId=" + userId + ", pwd=" + pwd + ", userName=" + userName
				+ ", regDt=" + regDt + "]";
	}

}
