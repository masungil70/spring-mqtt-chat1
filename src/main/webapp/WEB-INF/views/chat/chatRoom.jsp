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
    <script type="text/javascript" src="/resources/mqtt/mqtt.min.js"></script>
    
  <body>
     <div class="container" id="app">
        <div>
            <h2 id="room-name"></h2>
        </div>
        <div class="input-group">
            <div class="input-group-prepend">
                <label class="input-group-text">내용</label>
            </div>
            <input type="text" class="form-control" name="message" id="message">
            <div class="input-group-append">
                <button class="btn btn-primary" type="button" id="send_message_button">보내기</button>
                <button class="btn btn-primary" type="button" id="leave_button">잠시나가기</button>
                <button class="btn btn-primary disabled" type="button" id="reenter_button">다시입장</button>
            </div>
        </div>
        <div>잠시 나가기는 채팅방에서 수신되는 메시지를 받지 않고 채팅방에 참여한 모든 사람에 메시지는 보낼수 있다</div>
        <ul class="list-group" id="message_list"></ul>
    </div>
    <script type="text/javascript">
    
    //MQTT 수신 받을 상태로 초기화를 한다
    //MQTT client
    const roomId = localStorage.getItem('chat.roomId');
    const sender = localStorage.getItem('chat.sender');

    //MQTT info host, port, topic 을 설정.
    //const mqtt_host = "www.masugil.shop";
    //const mqtt_port = 9090; //websocket port : mosquitt.conf 파일에 설정됨 :   
    //const mqtt_topic = "/team1/sub/" + roomId;
    const mqtt_host = "www.dondog.site";
    const mqtt_port = 8883; //websocket ssl port : mosquitt.conf 파일에 설정됨  
    const mqtt_topic = "/test/sub/" + roomId;
    //*websocket에 ssl 적용시
    //아래 내용 mosquitt.conf 파일에 추가함 
		//listener 8883
		//protocol websockets
		//cafile /etc/ssl/ca_bundle.crt
		//certfile /etc/ssl/certificate.crt
		//keyfile /etc/ssl/private.key
		//require_certificate false
		//tls_version tlsv1.2
    

    const options = {
    		  protocol : 'wss',
    		  hostname : mqtt_host,
          port: mqtt_port,
          username : 'kong',
          password : '1234',
          clean: true,
    }
    console.log('Connecting mqtt client ');
    console.log('mqtt_topic -> ', mqtt_topic);
      
    const mqttClient = mqtt.connect(options);
    console.log('mqttClient -> ', mqttClient);

    const disconnect = () => {
         console.log('mqtt 연결 끊음');
         mqttClient.end();
    }  
      
    mqttClient.on('error', (err) => {
        console.log('Connection error: ', err)
        mqttClient.end()
    });
      
    mqttClient.on('reconnect', () => {
        console.log('Reconnecting...')
    });
      
    mqttClient.on('connect', () => {
    	  console.log('Connected')
        //구독 메시지 등록 
        //메시지 수신 이벤트 핸들러 등록
        subscribe();
          
        //채팅방에 입장 메시지를 서버에 전송한다
        enterSendMessage();
    });
      
    // 구독 메시지 수신 
    mqttClient.on('message', function (topic, message) {
        // message is Buffer
        console.log("mqtt message receive :", message.toString())
        recvMessage(JSON.parse(message.toString()))
    })
      
    $("#message").on("keydown", e => {
    	  if (e.keyCode == 13) {
    		  sendMessage();
        }
    });
        
    $("#send_message_button").on("click", e => {
        sendMessage();
    });
        
    $("#leave_button").on("click", e => {
    	  $("#leave_button,#send_message_button").addClass("disabled");
        $("#reenter_button").removeClass("disabled");
        
        //잠시 나간다 . 메시지 수신을 하는 않는다
        unsubscribe();
               
        //채팅방에 퇴장메시지를 서버에 전송한다
        leaveSendMessage();

    });
        
    $("#reenter_button").on("click", e => {
    	  $("#reenter_button").addClass("disabled");
        $("#leave_button,#send_message_button").removeClass("disabled");
        
        //채팅방에 입장한다
        //구독을 신청한다 
        subscribe();
            
        //채팅방에 입장 메시지를 서버에 전송한다
        enterSendMessage();
    });

        
    $(document).ready(()=>{
    	  //채팅방의 정보를 얻는다
        console.log("before getRoomInfo");            
        getRoomInfo();
            
        $(window).on("beforeunload", e => {
        	  //구독을 해제 한다
            unsubscribe();
            mqttClient.disconnect();
        })
    });

    //메시지 수신 이벤트 핸들러 등록
    //구독을 등록한다
    const subscribe = () => {
    	  mqttClient.subscribe(mqtt_topic, err => {
    		  console.log("Subscribe to a topic 생성");
    		  if (!err) {
    			  console.log("error", err);
          } else {
          }
        })
    }
        
    //메시지 수신를 해제 한다 
    //구독을 해제한다
    const unsubscribe = () => {
    	  mqttClient.unsubscribe(mqtt_topic);
    }
        
    //roomId를 이용하여 채팅방 정보를 출력한다 
    //현재는 이름만 출력함  
    const getRoomInfo = () => {
        $.ajax({ 
            type: "GET",
            url: "<c:url value='/chat/room/'/>" + roomId,
            dataType: "json" // 요청을 서버로 해서 응답이 왔을 때 기본적으로 모든 것이 문자열 (생긴게 json이라면) => javascript오브젝트로 변경
        }).done(resp => {
            //채팅방의 이름을 출력한다 
            console.log("getRoomInfo resp", resp);            
            $("#room-name").text(resp.name + " - " + sender);
        }).fail(err => {
            console.log("getRoomInfo error", err);            
        }); 
    }
        
    //입장메시지를 전송한다
    const enterSendMessage = () => {
    	  console.log("enterSendMessage ")
        
    	  //채팅방에 입장을 서버에 전송한다
    	  mqttClient.publish(mqtt_topic, JSON.stringify({type:'ENTER', roomId : roomId, sender : '[알림]', message : sender + "님 입장하셨습니다"}));
    }
        
    //퇴장메시지를 전송한다
    const leaveSendMessage = () => {
    	  //채팅방에 입장을 서버에 전송한다
        mqttClient.publish(mqtt_topic, JSON.stringify({type:'LEAVE', roomId : roomId, sender : '[알림]', message : sender + "님 퇴장하셨습니다"}));
    }
        

    //서버에 메시지를 전송한다
    const sendMessage = () => {
    	  const message = $("#message").val();
        mqttClient.publish(mqtt_topic, JSON.stringify({type:'TALK', roomId : roomId, sender : sender, message:message}));
        $("#message").val("");
    };
         
    const recvMessage = recv =>  {
    	  console.log(recv);
        $("#message_list").prepend('<li class="list-group-item" >[' + recv.sender + '] - ' + recv.message + '</li>'); 
    }
      
    </script>
    </body>
</html>