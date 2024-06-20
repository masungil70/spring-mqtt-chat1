<%@ page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="utf-8"
	isELIgnored="false"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="contextPath"  value="${pageContext.request.contextPath}"  />
<!DOCTYPE html >
<html>
<head>
<meta charset="utf-8">
</head>
<body>
	<div>
		기능 구현된 것 
		<ul>
			<li>채팅방 목록 출력</li>
			<li>채팅방 생성</li>
			<li>방입장 </li>
			<li>메시지 전송 </li>
			<li>메시지 수신 </li>
			<li>채팅방 나가기 - 나가기 버튼 클릭, 창 닫기 버튼 클릭시  </li>
		</ul>
	</div>
	<h1><a href="<c:url value='/chat/roomList'/>">채팅방목록</a></h1>

</body>
</html>