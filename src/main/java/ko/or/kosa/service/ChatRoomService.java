package ko.or.kosa.service;

import java.util.List;

import org.springframework.stereotype.Service;

import ko.or.kosa.dao.ChatRoomDAO;
import ko.or.kosa.entity.ChatRoom;
import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ChatRoomService {

	private final ChatRoomDAO chatRoomDAO;
	
	public List<ChatRoom> findAllRoom() {
		return chatRoomDAO.findAllRoom();
	}

	public ChatRoom createChatRoom(String name) {
		return chatRoomDAO.createChatRoom(name);
	}

	public ChatRoom findRoomById(String roomId) {
		return chatRoomDAO.findRoomById(roomId);
	}

}
