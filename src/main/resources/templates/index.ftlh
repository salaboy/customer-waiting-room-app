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


    <meta name="theme-color" content="#E7E7EA">
</head>

<body data-gr-c-s-loaded="true" onload="joinQueue();">
<!--[if IE]>
<p class="browserupgrade">You are using an <strong>outdated</strong> browser. Please <a href="https://browsehappy.com/">upgrade
    your browser</a> to improve your experience and security.</p>
<![endif]-->

<!-- Add your site or application content here -->
<div class="block header">
    <div class="header__image">
        <img src="img/kubecon-logo.png" width="35">
    </div>
    <div class="header__title">
        <h1>Waiting Room Demo v0.0.0 </h1>
    </div>
    <div class="header__options">

    </div>

</div>
<div class="bottom-blocks">
    <div class="main-title">
        <h3>Welcome to your Tickets Portal</h3>

    </div>
    <div class="queue">
        <div class="queue-header">
            <h2>You are number <span class="position" id="queuePosition">X</span> of <span  id="queueSize">X</span> people waiting.</h2>
            <p>Your approximate waiting time is <span  id="queueWaitingTime">X</span> minutes.</p>

        </div>
        <div id="queue-list" class="queue-list">
<#--            <div class="door"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person you"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->
<#--            <div class="person"></div>-->

        </div>
    </div>
</div>
<div class="button-layer">
    <a id="proceed" class="main-button disabled" >
        Buy Tickets: 5 people left
    </a>
</div>




<script src="js/vendor/modernizr-3.7.1.min.js"></script>
<script src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous"></script>
<script>window.jQuery || document.write('<script src="js/vendor/jquery-3.4.1.min.js"><\/script>')</script>
<script src="js/plugins.js"></script>
<script type="text/javascript">

        function joinQueue() {

            document.getElementById('proceed').disabled = true;

            var xhr = new XMLHttpRequest();
            xhr.open("POST", "/router/message", true);
            var data = JSON.stringify(
                {
                    sessionId: "${sessionId}",
                }
            );
            xhr.setRequestHeader('Content-Type', 'application/json');
            xhr.setRequestHeader('Ce-Id', 'CE-'+ "${sessionId}");
            xhr.setRequestHeader('Ce-Type', 'NewCustomer');
            xhr.setRequestHeader('Ce-Source', 'website');
            xhr.setRequestHeader('correlationKey',  "${sessionId}");

            /// curl -X POST http://customer-waiting-room-app.default.34.78.5.94.xip.io/router/message -H "Ce-Id: 123" -H "Ce-Type: NewCustomer"  -H "Ce-Source: curl" -H "Ce-Subject: hello"  -H "Content-Type: application/json" -H "correlationKey: 1" -d '"{\"sessionId\":\"1\"}"' -v

            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    callback(xhr.response);
                }
            }

            console.log(JSON.stringify(data));
            xhr.send(JSON.stringify(data)); // Double stringify escape double quotes that are needed

            connect();
        }

    function callback(response){
        console.log(response);
    }

    setInterval(pollService, 3000);

    function pollService() {
        $.getJSON("/queue/${sessionId}", function (response) {
            console.log(">> My position is: " + JSON.stringify(response));

            var position = document.getElementById('queuePosition');
            position.innerHTML = response.position;
            var queueSize = document.getElementById('queueSize');
            queueSize.innerHTML = response.size;
            var queueWaitingTime = document.getElementById('queueWaitingTime');
            queueWaitingTime.innerHTML = response.waitTime;
            var queueList = document.getElementById('queue-list');
            queueList.innerHTML = "";
            var door = document.createElement("div");
            door.className = "door";
            queueList.appendChild(door);
            for(var i = 1; i < response.size + 1; i++) {
                var newDiv = document.createElement("div");
                if(i == response.position) {
                    newDiv.className = "person you";
                }else{
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

    function connect()
    {

        sock = new WebSocket(wsURL);
        sock.onopen = function() {
            console.log('Info: Connection Established.');
        };

        sock.onmessage = function(event) {
            console.log(event.data)
            let ce = JSON.parse(event.data);
            console.log(ce);
            if(ce["type"] === "Queue.CustomerExited"){

                var data = JSON.parse(ce["data"]);
                sessionId = data.sessionId;

                document.getElementById('proceed').className = "main-button";

            }
        };

        sock.onerror = function(event){
            console.log("EFFOR: " + event);
        }
        sock.onclose = function(event) {

            console.log('Info: Closing Connection. -> ' + event);
        };
    }

    function proceed(){
        window.location.href = "/tickets?sessionId="+sessionId;
    }

    function log(message)
    {
        var console = document.getElementById('logging');
        var p = document.createElement('p');
        p.appendChild(document.createTextNode(message));
        console.appendChild(p);
    }

</script>


</body>

</html>