package ko.or.kosa.config;

import java.util.UUID;

import org.apache.commons.lang3.StringUtils;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.integration.annotation.MessagingGateway;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.channel.DirectChannel;
import org.springframework.integration.config.EnableIntegration;
import org.springframework.integration.core.MessageProducer;
import org.springframework.integration.mqtt.core.DefaultMqttPahoClientFactory;
import org.springframework.integration.mqtt.core.MqttPahoClientFactory;
import org.springframework.integration.mqtt.inbound.MqttPahoMessageDrivenChannelAdapter;
import org.springframework.integration.mqtt.outbound.MqttPahoMessageHandler;
import org.springframework.integration.mqtt.support.DefaultPahoMessageConverter;
import org.springframework.integration.mqtt.support.MqttHeaders;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.MessageHandler;
import org.springframework.messaging.MessageHeaders;
import org.springframework.messaging.MessagingException;
import org.springframework.messaging.handler.annotation.Header;

import ko.or.kosa.service.MqttService;

@Configuration
@EnableIntegration
public class MqttConfig {
	
	/*
	 * windows 10에서 mosquitto 프로그램 설치 후 
	 * 환경설정 변수에 mosquitt 폴더 프로그램이 설치된 폴더 추가 
	 * 
	 * cmd 창에서 
	 * 메시지 구독 
	 * mosquitto_sub -h www.masungil.shop -p 51883  -t /team1/sub/# -u team1 -P 1004team1
	 * 
	 * 메시지 발행  
	 * mosquitto_pub -h www.masungil.shop -p 51883 -t /team1/sub/bbb -u team1 -P 1004team1 -m "메시지"
	 */
	
//	private final String topic = "/team1/sub/";
//  private static final String USERNAME = "team1";
//  private static final String PASSWORD = "1004team1";
	private final String topic = "/test/sub/";
  private static final String USERNAME = "kong";
  private static final String PASSWORD = "1234";
	
  @Bean
  public MqttConnectOptions getReceiverMqttConnectOptions() {
      MqttConnectOptions mqttConnectOptions = new MqttConnectOptions();
      mqttConnectOptions.setCleanSession(true);
      mqttConnectOptions.setConnectionTimeout(30);
      mqttConnectOptions.setKeepAliveInterval(60);
      mqttConnectOptions.setAutomaticReconnect(true);
      mqttConnectOptions.setUserName(USERNAME);
      mqttConnectOptions.setPassword(PASSWORD.toCharArray());

      String hostUrl = "tcp://www.dondog.site:1883";
      mqttConnectOptions.setServerURIs(new String[] { hostUrl });
      return mqttConnectOptions;
  }

  @Bean
  public MqttPahoClientFactory mqttClientFactory() {
      DefaultMqttPahoClientFactory factory = new DefaultMqttPahoClientFactory();
      factory.setConnectionOptions(getReceiverMqttConnectOptions());
      return factory;
  }

  @Bean
  public MessageProducer inbound() {
      String clientId2 = "uuid-" + UUID.randomUUID().toString();
      // /team1/sub : mqtt 경로
      MqttPahoMessageDrivenChannelAdapter adapter = new MqttPahoMessageDrivenChannelAdapter(clientId2,
              mqttClientFactory(), topic + "#");
      adapter.setCompletionTimeout(20000);
      adapter.setConverter(new DefaultPahoMessageConverter());
      adapter.setQos(1);
      adapter.setOutputChannel(mqttInputChannel());
      return adapter;
  }

  @Autowired
  MqttService mqttService;

  @Bean
  public MessageChannel mqttInputChannel() {
      return new DirectChannel();
  }

  @Bean
  @ServiceActivator(inputChannel = "mqttInputChannel")
  public MessageHandler handler() {
      return new MessageHandler() {

          @Override
          public void handleMessage(Message<?> message) throws MessagingException {
              MessageHeaders messageHeaders = message.getHeaders();
              String mqtt_receivedTopic = (String) messageHeaders.get("mqtt_receivedTopic");

              if (mqttService != null && StringUtils.startsWith(mqtt_receivedTopic, topic)) {
              	mqttService.execute(mqtt_receivedTopic, (String) message.getPayload());
              }
          }
      };
  }

  @Bean
  @ServiceActivator(inputChannel = "mqttOutboundChannel")
  public MessageHandler mqttOutbound() {
      MqttPahoMessageHandler messageHandler = new MqttPahoMessageHandler("testClient", mqttClientFactory());
      messageHandler.setAsync(true);
      messageHandler.setDefaultTopic("testTopic");
      return messageHandler;
  }

  @Bean
  public MessageChannel mqttOutboundChannel() {
      return new DirectChannel();
  }

  @MessagingGateway(defaultRequestChannel = "mqttOutboundChannel")
  public interface OutboundGateway {
      void sendToMqtt(String data, @Header(MqttHeaders.TOPIC) String topic);
  }    

}
