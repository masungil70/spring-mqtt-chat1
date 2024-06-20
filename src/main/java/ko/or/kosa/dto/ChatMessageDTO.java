package ko.or.kosa.dto;

import lombok.Data;

@Data
public class ChatMessageDTO {
  // 메시지 타입 : 입장, 채팅, 나가기
  public enum MessageType {
      ENTER, TALK, LEAVE
  }

  private MessageType type; // 메시지 타입
  private String roomId; // 방번호
  private String sender; // 메시지 보낸사람
  private String message; // 메시지
  
  public void typeProcess() {
  	switch(type) {
  	case ENTER:
  		message = sender + "님이 입장하셨습니다.";
  		sender = "[알림]";
  		break;
  	case LEAVE:
  		message = sender + "님이 퇴장하셨습니다.";
  		sender = "[알림]";
  		break;
  	default:
  	}
  	
  }
}
