package com.salaboy.knative.waitingroom;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.salaboy.cloudevents.helper.CloudEventsHelper;
import com.salaboy.knative.waitingroom.models.ClientSession;
import com.salaboy.knative.waitingroom.models.ServiceInfo;
import io.cloudevents.CloudEvent;
import io.cloudevents.core.format.EventFormat;
import io.cloudevents.core.provider.EventFormatProvider;
import io.cloudevents.jackson.JsonFormat;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.cloud.gateway.route.Route;
import org.springframework.context.annotation.Bean;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
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
import org.springframework.web.server.ServerWebExchange;
import org.springframework.web.server.WebSession;
import reactor.core.publisher.EmitterProcessor;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.net.URI;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

import static java.util.UUID.randomUUID;
import static org.springframework.cloud.gateway.support.ServerWebExchangeUtils.*;

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
    public GlobalFilter customFilter() {
        return new LoggingFilter();
    }

    @Bean
    public HandlerMapping webSocketHandlerMapping() {

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
    } //

    //
    public WebSocketService webSocketService() {
        return new HandshakeWebSocketService(new ReactorNettyRequestUpgradeStrategy());
    }


}

@Slf4j
class LoggingFilter implements GlobalFilter {


    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        Set<URI> uris = exchange.getAttributeOrDefault(GATEWAY_ORIGINAL_REQUEST_URL_ATTR, Collections.emptySet());
        String originalUri = (uris.isEmpty()) ? "Unknown" : uris.iterator().next().toString();
        Route route = exchange.getAttribute(GATEWAY_ROUTE_ATTR);
        URI routeUri = exchange.getAttribute(GATEWAY_REQUEST_URL_ATTR);
        log.info(">>> Incoming request " + originalUri + " is routed to id: " + route.getId()
                + ", uri:" + routeUri);
        return chain.filter(exchange);
    }
}

@Component
@Slf4j
class ReactiveWebSocketHandler implements WebSocketHandler {

    private List<String> sessions = new CopyOnWriteArrayList<>();
    private Map<String, EmitterProcessor<String>> processors = new ConcurrentHashMap<>();


    public ReactiveWebSocketHandler() { }

    public EmitterProcessor<String> getEmitterProcessor(String id) {
        return processors.get(id);
    }

    public Set<String> getProcessors(){
        return processors.keySet();
    }

    public List<String> getSessionsId() {
        return sessions;
    }


    @Override
    public Mono<Void> handle(WebSocketSession webSocketSession) {
        String id = webSocketSession.getId();

        String sessionId = webSocketSession.getHandshakeInfo().getUri().getQuery().split("=")[1];
        if (sessions.add(sessionId)) {
            log.info("Session Id added: " + sessionId);
            processors.put(sessionId, EmitterProcessor.create());
            Flux<String> cloudEventsFlux = processors.get(sessionId).map(x -> x);

            // Send the session id back to the client
            String msg = String.format("{\"session\":\"%s\"}", sessionId);
            // Register the outbound flux as the source of outbound messages //.filter(cloudEvent -> cloudEvent.contains(sessionId))
            final Flux<WebSocketMessage> outFlux = Flux.concat(Flux.just(msg), cloudEventsFlux)
                    .map(cloudEvent -> {
                        log.info("Sending message to client [{}]: {}", sessionId, cloudEvent);

                        return webSocketSession.textMessage(cloudEvent);
                    });


            return webSocketSession.send(outFlux).and(webSocketSession.receive().doFinally(sig -> {
                log.info("Terminating WebSocket Session (client side) sig: [{}], [{}]", sig.name(), sessionId);
                webSocketSession.close();
                sessions.remove(sessionId);  // remove the stored session id
                processors.remove(sessionId);
                log.info("remove session and processor for id: " + sessionId);
            }).map(WebSocketMessage::getPayloadAsText).log());

        }
        return Mono.empty();

    }
}


@RestController
@RequestMapping("/api/")
@Slf4j
class SiteRestController {

    @Value("${version:0.0.0}")
    private String version;
    private ObjectMapper objectMapper = new ObjectMapper();


    @Autowired
    private ReactiveWebSocketHandler handler;

    @GetMapping("/info")
    public String infoWithVersion() {
        return "{ \"name\" : \"User Interface\", \"version\" : \"" + version + "\", \"source\": \"https://github.com/salaboy/customer-waiting-room-app/releases/tag/v" + version + "\" }";
    }

    private void logCloudEvent(CloudEvent cloudEvent) {
        EventFormat format = EventFormatProvider
                .getInstance()
                .resolveFormat(JsonFormat.CONTENT_TYPE);

        log.info("Cloud Event: " + new String(format.serialize(cloudEvent)));

    }

    @PostMapping("/")
    public String pushDataViaWebSocket(@RequestHeader HttpHeaders headers, @RequestBody String body) throws JsonProcessingException {
        CloudEvent cloudEvent = CloudEventsHelper.parseFromRequest(headers, body);

        logCloudEvent(cloudEvent);

        log.info("Getting processor for session Id: " + headers.get("Sessionid"));
        log.info("> All HEADERS: " );
        for(String key : headers.keySet()){
            log.info(">> HEADER: " + key + " -> VALUE: " + headers.get(key));
        }

        String data = new String(cloudEvent.getData());
        log.info("RAW Cloud Event Data" + data);
        String stringVersion = objectMapper.readValue(data, String.class);
        ClientSession clientSession = objectMapper.readValue(stringVersion, ClientSession.class);

        log.info("Client Session from Cloud Event Data" + clientSession.getSessionId());
        log.info("Getting processor for session Id: " + clientSession.getSessionId());
        if(!clientSession.getSessionId().contains("mock")) {
            byte[] serialized = EventFormatProvider
                    .getInstance()
                    .resolveFormat(JsonFormat.CONTENT_TYPE)
                    .serialize(cloudEvent);

            handler.getEmitterProcessor(clientSession.getSessionId()).onNext(new String(serialized));
        }else{
            log.info("session id contained mock, not sending to websocket: " + clientSession.getSessionId());
        }
        return "OK!";
    }

    @GetMapping("/sessions")
    public List<String> getSessions() {
        return handler.getSessionsId();
    }

    @GetMapping("/processors")
    public Set<String> getProcessors() {
        return handler.getProcessors();
    }


}



@Controller
@Slf4j
class TicketsSiteController {


    @Value("${version:0.0.0}")
    private String version;

    @Value("${TICKETS_SERVICE:http://tickets-service}")
    private String TICKETS_SERVICE;

    @Value("${PAYMENTS_SERVICE_EXTERNAL:http://payments-service.default.34.121.118.94.xip.io}") //it needs to be the public IP here..
    private String PAYMENTS_SERVICE_EXTERNAL;

    @Value("${K_SINK:http://broker-ingress.knative-eventing.svc.cluster.local/default/default}") //it needs to be the public IP here..
    private String K_SINK;

    private RestTemplate restTemplate = new RestTemplate();


    @GetMapping("/")
    public String index(Model model, WebSession session) {
        session.getAttributes().putIfAbsent("sessionId", randomUUID().toString());
        String sessionId = session.getAttribute("sessionId");
        ServiceInfo ticketsInfo = null;
        ServiceInfo paymentsInfo = null;


//        try {
//            ResponseEntity<ServiceInfo> tickets = restTemplate.getForEntity(TICKETS_SERVICE + "/info", ServiceInfo.class);
//            ticketsInfo = tickets.getBody();
//
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//        try {
//            ResponseEntity<ServiceInfo> payments = restTemplate.getForEntity(PAYMENTS_SERVICE_EXTERNAL + "/info", ServiceInfo.class);
//            paymentsInfo = payments.getBody();
//        } catch (Exception e) {
//            e.printStackTrace();
//        }



        model.addAttribute("version", version);
        model.addAttribute("sessionId", sessionId);
//        model.addAttribute("tickets", ticketsInfo);
//        model.addAttribute("payments", paymentsInfo);



        return "index";
    }

    @GetMapping("/pay")
    public String pay(@RequestParam(value = "sessionId", required = true) String sessionId,
                      @RequestParam(value = "reservationId", required = true) String reservationId,
                      Model model) {

        model.addAttribute("version", version);
        model.addAttribute("sessionId", sessionId);
        model.addAttribute("reservationId", reservationId);
        model.addAttribute("paymentsServiceExternal", PAYMENTS_SERVICE_EXTERNAL);

        return "pay";
    }

    @GetMapping("/yourtickets")
    public String yourTickets(@RequestParam(value = "sessionId", required = true) String sessionId,
                      @RequestParam(value = "reservationId", required = true) String reservationId,
                      Model model) {

        model.addAttribute("version", version);
        model.addAttribute("sessionId", sessionId);
        model.addAttribute("reservationId", reservationId);
        model.addAttribute("ticketsCode", UUID.randomUUID().toString());

        return "yourtickets";
    }

    @GetMapping("/tickets")
    public String tickets(@RequestParam(value = "sessionId", required = true) String sessionId, WebSession session, Model model) {

        session.getAttributes().putIfAbsent("reservationId", randomUUID().toString());
        String reservationId = session.getAttribute("reservationId");

        model.addAttribute("version", version);
        model.addAttribute("reservationId", reservationId);
        model.addAttribute("sessionId", sessionId);

        return "tickets";
    }

    @GetMapping("/backoffice")
    public String backoffice( WebSession session, @RequestParam(value="reset", required = false, defaultValue = "false") boolean reset, Model model) {

        if(reset){
            session.getAttributes().remove("sessionId");
            session.getAttributes().remove("reservationId");
        }
        model.addAttribute("version", version);

        return "backoffice";
    }


}

