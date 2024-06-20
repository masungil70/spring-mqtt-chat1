<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
  <head>
  	<title>Spring stomp chat</title>
  </head>
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css">
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js"></script>
  <body>
 	<div class="container" id="app">
        <div class="row">
            <div class="col-md-12">
                <h3>채팅방 리스트</h3>
            </div>
        </div>
        <div class="input-group">
            <div class="input-group-prepend">
                <label class="input-group-text">방제목</label>
            </div>
            <input type="text" class="form-control" name="room_name" id="room_name">
            <div class="input-group-append">
                <button class="btn btn-primary" type="button" id="create_room_button">채팅방 개설</button>
            </div>
        </div>
        <!-- 방 목록은 비동기로 서버에서 얻어 출력한다 -->
        <ul class="list-group" id="roomList"></ul>
    </div>
    <script type="text/javascript">
    	$("#room_name").on("keydown", e => {
    		if (e.keyCode == 13) {
    			createRoom();
    		}
    	});
    	
    	$("#create_room_button").on("click", e => {
   			createRoom();
    	});
    	
    	
    	$(document).ready(()=>{
    		//시작시 방목록을 얻어 출력한다
    		roomListOutput();
    	});

    	//전체 방목록을 얻어 출력한다  
    	const roomListOutput = () => {
        	$.ajax({ 
        		type: "GET",
        		url: '<c:url value="/chat/rooms"/>',
        		dataType: "json" // 요청을 서버로 해서 응답이 왔을 때 기본적으로 모든 것이 문자열 (생긴게 json이라면) => javascript오브젝트로 변경
        	}).done(resp => {
           	let htmls = "";
           	//전달받은 배열을 이용하여 방목록을 출력하기 위한 HTML 문자열을 구성한다
           	resp.forEach(room => {
           		htmls += '<li class="list-group-item list-group-item-action" data-room-id="' + room.roomId + '">' + room.name + '</li>'; 
           	});
           	console.log("htmls", htmls);
           	$("ul#roomList li").remove();
           	$("#roomList").append(htmls);
           	
           	//방을 클릭하면 입장할 수 있는 이벤트를 설정한다
           	$("ul#roomList li").on("click", e => {
           		const roomId = $(e.target).attr("data-room-id");
           		console.log("111 oomId =>", roomId);
           		enterRoom(roomId);
           	});
        	}).fail(err => {
        		alert(err);
        	}); 
    	}
    	
    	//방을 개설한다 
    	const createRoom = () => {
    		const room_name = $("#room_name").val();
    		
    		if("" === room_name) {
					alert("방 제목을 입력해 주십시요.");
					$("#room_name").focus();
					return false;
        }
    		
        const param = {
		      	name : room_name
        };
       	$.ajax({ 
       		type: "POST",
       		url: '<c:url value="/chat/room"/>',
       		data: param, 
       		dataType: "json" // 요청을 서버로 해서 응답이 왔을 때 기본적으로 모든 것이 문자열 (생긴게 json이라면) => javascript오브젝트로 변경
       	}).done(resp => {
           alert(resp.name + "방 개설에 성공하였습니다.")
           $("#room_name").val("");
           //다른 사람이 개설한 방목록과 내가 개설한 목록을 전체를 얻어 출력한다
           roomListOutput();
       	}).fail(err => {
       		alert("채팅방 개설에 실패하였습니다.");
       	}); 
    	};
    	
    	//채팅방에 입장 처리하는 함수 
    	const enterRoom = roomId => {
        const sender = prompt('대화명을 입력해 주세요.');
        if (sender == '') {
        	alert("대화명은 필수 입력입니다");
        	return false;
        }
        //입장하는 사람의 이름과 채팅방이름을 지역저장소에 저장한다
        //이렇게 저장하면 다른 페이지에서 해당 키를 이용하여 값을 읽을 수 있다
        localStorage.setItem('chat.sender', sender);
        localStorage.setItem('chat.roomId', roomId);
        location.href = '<c:url value="/chat/room/enter/"/>' + roomId;
    	}	    
    </script>
	</body>
</html>