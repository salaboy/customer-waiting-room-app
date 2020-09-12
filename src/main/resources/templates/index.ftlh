<!doctype html>
<html class="no-js" lang="">

<head>
    <meta charset="utf-8">
    <title></title>
    <meta name="description" content="">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link rel="manifest" href="site.webmanifest">
    <link rel="apple-touch-icon" href="icon.png">
    <!-- Place favicon.ico in the root directory -->
    <link rel="stylesheet" href="css/normalize.css">
    <link rel="stylesheet" href="css/main.css">
    <link href="https://fonts.googleapis.com/css?family=Rubik:300,400&display=swap" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/toastify-js/src/toastify.min.css">

    <meta name="theme-color" content="#E7E7EA">
</head>

<body data-gr-c-s-loaded="true">
<!--[if IE]>
<p class="browserupgrade">You are using an <strong>outdated</strong> browser. Please <a href="https://browsehappy.com/">upgrade
    your browser</a> to improve your experience and security.</p>
<![endif]-->

<!-- Add your site or application content here -->
<div class="block header">
    <div class="header__image">

    </div>
    <div class="header__title">
        <h1>Tickets Portal v${version}</h1>
    </div>
    <div class="header__options">
        <a href="/backoffice">
            Back Office<span><img src="arrow.svg" alt=""></span>
        </a>
    </div>

</div>
<div class="bottom-blocks">

    <div class="queue">

        <div class="queue-header">
            <h2 id="queueTitle">Join the queue.</h2>
            <p id="waitingLabel">There are currently <span id="queueSize">X</span> people waiting. Your approximate
                waiting time will be <span id="queueWaitingTime">X</span> minutes.</p>
            <div id="sessionIdLabel" class="codesIds"></div>
        </div>


        <div id="queue-list" class="queue-list">


        </div>
    </div>
</div>
<div class="button-layer">
    <a id="joinQueueButton" onclick="joinQueue();" class="main-button">
        Join the Queue
    </a>
    <a id="quitQueueButton" onclick="quitQueue();" class="main-button hidden">
        Quit the Queue
    </a>
    <a id="proceed" onclick="proceed();" class="main-button hidden">
        Reserve Tickets
    </a>
</div>


<script src="js/vendor/modernizr-3.7.1.min.js"></script>
<script src="https://code.jquery.com/jquery-3.4.1.min.js"
        integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous"></script>
<script>window.jQuery || document.write('<script src="js/vendor/jquery-3.4.1.min.js"><\/script>')</script>
<script src="js/plugins.js"></script>
<script type="text/javascript" src="https://cdn.jsdelivr.net/npm/toastify-js"></script>
<script type="text/javascript">

    document.getElementById('proceed').disabled = true;

    var connected = false;

    function quitQueue() {
        document.getElementById("sessionIdLabel").innerHTML = "";
        var queueList = document.getElementById('queue-list');
        document.getElementById('quitQueueButton').className = "main-button hidden";
        document.getElementById('joinQueueButton').className = "main-button";
        document.getElementById('queueTitle').innerHTML = "Join the queue."
        document.getElementById('waitingLabel').innerHTML = "There are currently <span id=\"queueSize\">X</span> people waiting. Your approximate waiting time will be <span id=\"queueWaitingTime\">X</span> minutes.";
        queueList.className = "queue-list queue-list-hidden";
        console.log("Abandoning queue for session: " + sessionId);
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "/broker", true);
        var data = JSON.stringify(
            {
                sessionId:  "${sessionId}",
            }
        );
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.setRequestHeader('Ce-Id', 'CE-' +  "${sessionId}");
        xhr.setRequestHeader('Ce-Type', 'Queue.CustomerAbandoned');
        xhr.setRequestHeader('Ce-Source', 'website');
        xhr.setRequestHeader('Ce-Specversion', '1.0');
        xhr.setRequestHeader('correlationKey',  "${sessionId}");


        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                callback(xhr.response);
            }
        }

        console.log("Sending Cloud Event to Broker: " + JSON.stringify(data));
        xhr.send(JSON.stringify(data));

    }

    function joinQueue() {

        document.getElementById("sessionIdLabel").innerHTML = "Session ID: <span>${sessionId}</span>";


        var xhr = new XMLHttpRequest();
        xhr.open("POST", "/broker", true);
        var data = JSON.stringify(
            {
                sessionId: "${sessionId}",
                ticketsType: "",
                ticketsQuantity: "0",
                reservationId: ""
            }
        );
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.setRequestHeader('Ce-Id', 'CE-' + "${sessionId}");
        xhr.setRequestHeader('Ce-Type', 'Queue.CustomerJoined');
        xhr.setRequestHeader('Ce-Source', 'website');
        xhr.setRequestHeader('Ce-Specversion', '1.0');
        xhr.setRequestHeader('Ce-CorrelationKey', "${sessionId}");

        /// curl -X POST http://customer-waiting-room-app.default.34.78.5.94.xip.io/router/message -H "Ce-Id: 123" -H "Ce-Type: Queue.CustomerJoined    "  -H "Ce-Source: curl" -H "Ce-Subject: hello"  -H "Content-Type: application/json" -H "correlationKey: 1" -d '"{\"sessionId\":\"1\"}"' -v

        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                callback(xhr.response);
            }
        }

        console.log("Sending Cloud Event to Broker: " + JSON.stringify(data));
        xhr.send(JSON.stringify(data)); // Double stringify escape double quotes that are needed


        connect();

        document.getElementById('joinQueueButton').className = "main-button hidden";
        document.getElementById('quitQueueButton').className = "main-button";
    }

    function callback(response) {
        console.log(response);
    }

    setInterval(pollService, 3000);

    function pollService() {

        $.getJSON("/queue/${sessionId}", function (response) {
            console.log("Response Data: "  + JSON.stringify(response));
            var positionInQueue = JSON.parse(JSON.stringify(response));
            console.log(">> My position is: " + positionInQueue.position);
            console.log(">> My Queue Size is: " + positionInQueue.size);
            console.log(">> My wait time  is: " + positionInQueue.waitTime);
            var queueList = document.getElementById('queue-list');
            var queueTitle = document.getElementById('queueTitle');
            var waitingLabel = document.getElementById('waitingLabel');
            if (positionInQueue.position >= 0) {
                queueTitle.innerHTML = "You are number <span class=\"position\" id=\"queuePosition\">" + (response.position + 1) + "</span> of <span id=\"queueSize\">" + response.size + "</span>";
                waitingLabel.innerHTML = " Your approximate " +
                    "                waiting time is <span id=\"queueWaitingTime\">X</span> minutes.";
                queueList.className = "queue-list";
                var queueSize = document.getElementById('queueSize');
                queueSize.innerHTML = response.size;
                var queueWaitingTime = document.getElementById('queueWaitingTime');
                queueWaitingTime.innerHTML = response.waitTime;
            } else if(!readyToBuy){

                queueList.className = "queue-list queue-list-hidden";
                queueTitle.innerHTML = "Join the queue.";
            }else{
                queueList.className = "queue-list queue-list-hidden";
                queueTitle.innerHTML = "Reserve your tickets now!";
                queueList.parentNode.removeChild(queueList);
            }



            var queueList = document.getElementById('queue-list');
            queueList.innerHTML = "";
            var door = document.createElement("div");
            door.className = "door";
            queueList.appendChild(door);
            for (var i = 0; i < response.size; i++) {
                var newDiv = document.createElement("div");
                if (i == response.position) {
                    newDiv.className = "person you";
                } else {
                    newDiv.className = "person";
                }
                queueList.appendChild(newDiv);
            }

        }).fail(function (jqxhr, textStatus, error) {
            console.log(textStatus + " -> " + error);
        });

    }


    console.log("Protocol: " + location.protocol);
    let wsURL = "ws://" + document.location.host + "/ws?sessionId=${sessionId}";
    if (location.protocol === 'https:') {
        wsURL = "wss://" + document.location.host + "/ws?sessionId=${sessionId}";
    }
    console.log("WS URL: " + wsURL);

    var sock;

    var sessionId;

    var readyToBuy = false;

    function connect() {

        sock = new WebSocket(wsURL);
        sock.onopen = function () {
            console.log('Info: Connection Established.');
        };

        sock.onmessage = function (event) {
            console.log(event.data)
            let ce = JSON.parse(event.data);
            console.log(ce);
            if (ce["type"] === "Queue.CustomerExited") {

                var data = JSON.parse(ce["data"]);
                sessionId = data.sessionId;
                readyToBuy = true;
                var queueList = document.getElementById('queue-list');
                var queueTitle = document.getElementById('queueTitle');
                var waitingLabel = document.getElementById('waitingLabel');
                queueList.className = "queue-list-hidden";
                queueTitle.innerHTML = "Reserve your tickets now!";
                waitingLabel.innerHTML = "";
                document.getElementById('proceed').className = "main-button";

            }
        };

        sock.onerror = function (event) {
            console.log("EFFOR: " + event);
        }
        sock.onclose = function (event) {
            connected = false;
            console.log('Info: Closing Connection. -> ' + event);
        };
        connected = true;


    }


    function proceed() {
        window.location.href = "/tickets?sessionId=" + sessionId;
    }


    function log(message) {
        var console = document.getElementById('logging');
        var p = document.createElement('p');
        p.appendChild(document.createTextNode(message));
        console.appendChild(p);
    }

</script>


</body>

</html>