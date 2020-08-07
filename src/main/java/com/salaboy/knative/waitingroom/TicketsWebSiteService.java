package com.salaboy.knative.waitingroom;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.salaboy.cloudevents.helper.CloudEventsHelper;
import com.salaboy.knative.waitingroom.models.ServiceInfo;
import io.cloudevents.CloudEvent;
import io.cloudevents.v03.AttributesImpl;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.reactive.HandlerMapping;
import org.springframework.web.reactive.handler.SimpleUrlHandlerMapping;
import org.springframework.web.reactive.socket.WebSocketHandler;
import org.springframework.web.reactive.socket.WebSocketMessage;
import org.springframework.web.reactive.socket.WebSocketSession;
import org.springframework.web.reactive.socket.server.WebSocketService;
import org.springframework.web.reactive.socket.server.support.HandshakeWebSocketService;
import org.springframework.web.reactive.socket.server.support.WebSocketHandlerAdapter;
import org.springframework.web.reactive.socket.server.upgrade.ReactorNettyRequestUpgradeStrategy;
import org.springframework.web.server.WebSession;
import reactor.core.CoreSubscriber;
import reactor.core.publisher.EmitterProcessor;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.net.URI;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

@SpringBootApplication
@Slf4j
public class TicketsWebSiteService {

    public static void main(String[] args) {
        SpringApplication.run(TicketsWebSiteService.class, args);
    }

    @Autowired
    private WebSocketHandler webSocketHandler;

    private List<String> users = new CopyOnWriteArrayList<String>();

    @Bean
    public HandlerMapping webSocketHandlerMapping() {
        log.info(">>> Handler mapping here.. ");
        Map<String, WebSocketHandler> map = new HashMap<>();
        map.put("/ws", webSocketHandler);

        SimpleUrlHandlerMapping handlerMapping = new SimpleUrlHandlerMapping();

        handlerMapping.setOrder(1);
        handlerMapping.setUrlMap(map);

        return handlerMapping;
    }

    @Bean
    public WebSocketHandlerAdapter handlerAdapter() {
        return new WebSocketHandlerAdapter(webSocketService());
    }


    public WebSocketService webSocketService() {
        return new HandshakeWebSocketService(new ReactorNettyRequestUpgradeStrategy());
    }


}

@Component
@Slf4j
class ReactiveWebSocketHandler implements WebSocketHandler {


    private Map<String, WebSocketSession> sessions = new ConcurrentHashMap<>();
    private EmitterProcessor<String> emitterProcessor = EmitterProcessor.create();
    private Flux<String> cloudEventsFlux = emitterProcessor.map(x -> "consume: " + x);

    public EmitterProcessor<String> getEmitterProcessor() {
        return emitterProcessor;
    }

    public Set<String> getSessionsId() {
        return sessions.keySet();
    }


    @Override
    public Mono<Void> handle(WebSocketSession webSocketSession) {
        String id = webSocketSession.getId();
        log.info(">>> WebSocketSession Id: " + id);
        String sessionId = webSocketSession.getHandshakeInfo().getUri().getQuery().split("=")[1];
        log.info(">>>  Session Id from connection: " + sessionId);
        if(sessions.get(sessionId) == null) {
            sessions.put(sessionId, webSocketSession);

            log.info("Starting WebSocket Session [{}]", sessionId);
            // Send the session id back to the client
            WebSocketMessage msg = webSocketSession.textMessage(String.format("{\"session\":\"%s\"}", sessionId));
            // Register the outbound flux as the source of outbound messages
            final Flux<WebSocketMessage> outFlux = Flux.concat(Flux.just(msg), cloudEventsFlux
                    .filter(cloudEvent -> cloudEvent.contains(sessionId)).map(cloudEvent -> {
                log.info("Sending message to client [{}]: {}", sessionId, cloudEvent);

                return webSocketSession.textMessage(cloudEvent);
            }));

            webSocketSession.receive()
                    .doFinally(sig -> {
                log.info("Terminating WebSocket Session (client side) sig: [{}], [{}]", sig.name(), sessionId);
                webSocketSession.close();
                sessions.remove(sessionId);  // remove the stored session id
            })
                    .subscribe(inMsg -> {
                log.info("Received inbound message from client [{}]: {}", sessionId, inMsg.getPayloadAsText());
            });

            return webSocketSession.send(outFlux);
        }

        return Mono.empty();
    }
}


@RestController
@RequestMapping("/api/")
class SiteRestController{

    @Value("${version:0.0.0}")
    private String version;


    @Autowired
    private ReactiveWebSocketHandler handler;

    @GetMapping("/info")
    public String infoWithVersion() {
        return "{ \"name\" : \"User Interface\", \"version\" : \"" + version + "\", \"source\": \"https://github.com/salaboy/customer-waiting-room-app/releases/tag/v" + version + "\" }";
    }


    @PostMapping("/")
    public String pushDataViaWebSocket(@RequestHeader Map<String, String> headers, @RequestBody String body){
        CloudEvent<AttributesImpl, String> cloudEvent = CloudEventsHelper.parseFromRequest(headers, body);
        //handler.getEmitterProcessor().onNext( sessionId + "," + UUID.randomUUID().toString());
        handler.getEmitterProcessor().onNext( cloudEvent.toString() );
        return "OK!";
    }

    @GetMapping("/sessions")
    public Set<String> getSessions() {
        return handler.getSessionsId();
    }


}


@Controller
class TicketsSiteController {


    @Value("${version:0.0.0}")
    private String version;

    @Value("${TICKETS_SERVICE:http://tickets-service}")
    private String TICKETS_SERVICE;

    @Value("${PAYMENTS_SERVICE:http://payments-service}")
    private String PAYMENTS_SERVICE;


    @Value("${QUEUE_SERVICE:http://queue-service}")
    private String QUEUE_SERVICE;

    private RestTemplate restTemplate = new RestTemplate();



    @GetMapping("/")
    public String index(Model model,  WebSession session) {
        session.getAttributes().putIfAbsent("sessionId", UUID.randomUUID().toString());
        String sessionId = session.getAttribute("sessionId");
        ServiceInfo ticketsInfo = null;
        ServiceInfo paymentsInfo = null;
        int queuePosition = -1;
        int queueSize = -1;

        try {
            ResponseEntity<ServiceInfo> tickets = restTemplate.getForEntity(TICKETS_SERVICE + "/info", ServiceInfo.class);
            ticketsInfo = tickets.getBody();

        } catch (Exception e) {
            e.printStackTrace();
        }
        try {
            ResponseEntity<ServiceInfo> payments = restTemplate.getForEntity(PAYMENTS_SERVICE + "/info", ServiceInfo.class);
            paymentsInfo = payments.getBody();
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            ResponseEntity<String> queueSizeRequest = restTemplate.getForEntity(QUEUE_SERVICE + "/", String.class);
            queueSize = Integer.valueOf(queueSizeRequest.getBody().toString());
        } catch (Exception e) {
            e.printStackTrace();
        }

        try {
            ResponseEntity<String> queuePositionRequest = restTemplate.getForEntity(QUEUE_SERVICE + "/" + sessionId, String.class);
            queuePosition = Integer.valueOf(queuePositionRequest.getBody().toString());
        } catch (Exception e) {
            e.printStackTrace();
        }

        model.addAttribute("version", version);
        model.addAttribute("sessionId", sessionId);
        model.addAttribute("tickets", ticketsInfo);
        model.addAttribute("payments", paymentsInfo);
        model.addAttribute("queuePosition", queuePosition);
        model.addAttribute("queueSize", queueSize);


        return "index";
    }

    @GetMapping("/backoffice")
    public String backoffice(@RequestParam(value = "pending", required = false, defaultValue = "false") boolean pending, Model model) {
        ServiceInfo ticketsInfo = null;
        ServiceInfo paymentsInfo = null;

        try {
            ResponseEntity<ServiceInfo> tickets = restTemplate.getForEntity(TICKETS_SERVICE + "/info", ServiceInfo.class);
            ticketsInfo = tickets.getBody();

        } catch (Exception e) {
            e.printStackTrace();
        }
        try {
            ResponseEntity<ServiceInfo> payments = restTemplate.getForEntity(PAYMENTS_SERVICE + "/info", ServiceInfo.class);
            paymentsInfo = payments.getBody();
        } catch (Exception e) {
            e.printStackTrace();
        }

        model.addAttribute("version", version);
        model.addAttribute("tickets", ticketsInfo);
        model.addAttribute("payments", paymentsInfo);

        return "backoffice";
    }


}

