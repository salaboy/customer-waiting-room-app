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
        <img src="kubecon-logo.png" height="50px">
    </div>
    <div class="header__title">
        <h1><span><a
                        href="https://github.com/salaboy/customer-waiting-room-app/releases/tag/v${version}">Waiting Room Demo v${version}</a></span>
        </h1>
    </div>
    <div class="header__options">
<#--        <a href="/backoffice">-->
<#--            Go to Back Office <span><img src="arrow_white.svg" alt=""></span>-->
<#--        </a>-->
    </div>

</div>
<div class="bottom-blocks">
    <div class="main-title">
        <h2>Welcome to your Tickets Portal</h2>

            <div class="modal__content__title">
                QUEUE SIZE
                <h5>${queueSize}</h5>
                QUEUE POSITION
                <h5>${queuePosition}</h5>
                SESSION ID
                <h5>${sessionId}</h5>
            </div>
        <div id="connect-container" class="ui centered grid">
            <div class="row">
                <button id="connect" onclick="connect();" class="ui green button ">Connect</button>
                <button id="disconnect" disabled="disabled" onclick="disconnect();"
                        class="ui red button">Disconnect</button>
            </div>
            <div class="row">
                <textarea id="message" style="width: 350px" class="ui input"
                          placeholder="Message to Echo"></textarea>
            </div>
            <div class="row">
                <button id="echo" onclick="echo();" disabled="disabled"
                        class="ui button">Echo message</button>
            </div>
        </div>
        <div id="console-container">
            <h3>Logging</h3>
            <div id="logging"></div>
        </div>

        </div>
    </div>

</div>

<script src="js/vendor/modernizr-3.7.1.min.js"></script>
<script src="https://code.jquery.com/jquery-3.4.1.min.js"
        integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous"></script>
<script>window.jQuery || document.write('<script src="js/vendor/jquery-3.4.1reconnecting-websocket.min.js"><\/script>')</script>
<script src="js/plugins.js"></script>
<#--<script src="js/reconnecting-websocket.min.js"></script>-->
<#--<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>-->
<script type="text/javascript">

    function joinQueue() {
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

        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                callback(xhr.response);
            }
        }

        console.log(data);
        xhr.send(JSON.stringify(data)); // Double stringify escape double quotes that are needed

        connect();
    }

    function callback(response){
        console.log(response);
    }



    console.log("Protocol: " + location.protocol);
    let wsURL = "ws://" + document.location.host + "/ws?sessionId=${sessionId}";
    if (location.protocol === 'https:') {
        wsURL = "wss://" + document.location.host + "/ws?sessionId=${sessionId}";
    }
    console.log("WS URL: " + wsURL);

    var sock;

    function setConnected(connected)
    {
        document.getElementById('connect').disabled = connected;
        document.getElementById('disconnect').disabled = !connected;
        document.getElementById('echo').disabled = !connected;
    }

    function connect()
    {

        sock = new WebSocket(wsURL);
        sock.onopen = function() {
            setConnected(true);
            console.log('Info: Connection Established.');
        };

        sock.onmessage = function(event) {
            console.log(event.data)
            let ce = JSON.parse(event.data);
            console.log(ce);
            if(ce["type"] === "Queue.CustomerExited"){
                //window.location.href = "/tickets?sessionId";
            }
        };

        sock.onerror = function(event){
            console.log("EFFOR: " + event);
        }
        sock.onclose = function(event) {

            setConnected(false);
            console.log('Info: Closing Connection. -> ' + event);
        };
    }

    function disconnect()
    {
        if (sock != null) {
            sock.close();
            sock = null;
        }
        setConnected(false);
    }

    function echo()
    {
        if (sock != null)
        {
            var message = document.getElementById('message').value;
            log('Sent to server :: ' + message);
            sock.send(message);
        } else {
            alert('connection not established, please connect.');
        }
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