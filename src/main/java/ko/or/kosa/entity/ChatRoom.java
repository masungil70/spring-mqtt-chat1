package ko.or.kosa.entity;

import java.util.UUID;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ChatRoom implements Comparable<ChatRoom>{
  private String roomId;
  private String name;

  public static ChatRoom create(String name) {
      return new ChatRoom(UUID.randomUUID().toString(), name);
  }

	@Override
	public int compareTo(ChatRoom o) {
		if (o == null) return 1;
		return name.compareToIgnoreCase(o.name);
	}
	
  
  
}

