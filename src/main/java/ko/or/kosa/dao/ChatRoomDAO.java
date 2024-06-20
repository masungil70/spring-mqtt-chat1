package ko.or.kosa.dao;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import javax.annotation.PostConstruct;

import org.springframework.stereotype.Repository;

import ko.or.kosa.entity.ChatRoom;

@Repository
public class ChatRoomDAO {
  private Map<String, ChatRoom> chatRoomMap;

  @PostConstruct
  private void init() {
      chatRoomMap = new LinkedHashMap<>();
  }

  public List<ChatRoom> findAllRoom() {
    // 채팅방 이름 순으로 반환
		return chatRoomMap.values().stream().sorted().collect(Collectors.toList());
  }

  public ChatRoom findRoomById(String id) {
      return chatRoomMap.get(id);
  }

  public ChatRoom createChatRoom(String name) {
      ChatRoom chatRoom = ChatRoom.create(name);
      chatRoomMap.put(chatRoom.getRoomId(), chatRoom);
      return chatRoom;
  }

}
