package com.lime.user.vo;

public class UserVO {

	private String userSeq;
	private String userId;
	private String pwd;
	private String userName;
	private String rrn;
	private String zipcode;
	private String address;
	private String companyAddress;
	private String email;
	private String fileNames;
	private String regDt;
	private String roleType;

	@Override
	public String toString() {
		return "UserVO{" +
						"userSeq='" + userSeq + '\'' +
						", userId='" + userId + '\'' +
						", pwd='" + pwd + '\'' +
						", userName='" + userName + '\'' +
						", rrn='" + rrn + '\'' +
						", zipcode='" + zipcode + '\'' +
						", address='" + address + '\'' +
						", companyAddress='" + companyAddress + '\'' +
						", email='" + email + '\'' +
						", fileNames='" + fileNames + '\'' +
						", regDt='" + regDt + '\'' +
						", roleType='" + roleType + '\'' +
						'}';
	}

	public String getUserSeq() {
		return userSeq;
	}

	public void setUserSeq(String userSeq) {
		this.userSeq = userSeq;
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

	public String getRrn() {
		return rrn;
	}

	public void setRrn(String rrn) {
		this.rrn = rrn;
	}

	public String getZipcode() {
		return zipcode;
	}

	public void setZipcode(String zipcode) {
		this.zipcode = zipcode;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public String getCompanyAddress() {
		return companyAddress;
	}

	public void setCompanyAddress(String companyAddress) {
		this.companyAddress = companyAddress;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getFileNames() {
		return fileNames;
	}

	public void setFileNames(String fileNames) {
		this.fileNames = fileNames;
	}

	public String getRegDt() {
		return regDt;
	}

	public void setRegDt(String regDt) {
		this.regDt = regDt;
	}

	public String getRoleType() {
		return roleType;
	}

	public void setRoleType(String roleType) {
		this.roleType = roleType;
	}
}
