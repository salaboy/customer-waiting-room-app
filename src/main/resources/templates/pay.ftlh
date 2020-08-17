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

<body data-gr-c-s-loaded="true">
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
            <h2>Your tickets are reserved. Please pay:</h2>
            <p>Your buying ID is ${sessionId}</p>

        </div>
        <div class="queue-form">
            <form class="form" action="">
                <div class="form-field small">
                    <label>Credit Card Information</label>
                    <input type="number" id="creditCard">
                </div>

            </form>

        </div>
        <iframe id="paymentFrame" src="">

        </iframe>

        <div>
            <span id="paymentStatus"> Please Pay ... </span>
        </div>
    </div>
</div>
<div class="button-layer">
    <a id="payButton" class="main-button" onclick="payTickets()">
        Pay
    </a>
    <a id="nextButton" class="main-button disabled" onclick="next()">
        Next
    </a>
</div>


<script src="js/vendor/modernizr-3.7.1.min.js"></script>
<script src="https://code.jquery.com/jquery-3.4.1.min.js"
        integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous"></script>
<script>window.jQuery || document.write('<script src="js/vendor/jquery-3.4.1.min.js"><\/script>')</script>
<script src="js/plugins.js"></script>

<script type="text/javascript">
    function next() {
        window.location.href = "/yourtickets?sessionId=${sessionId}&reservationId=${reservationId}";
    }

    function payTickets() {
        document.getElementById("paymentStatus").innerHTML = "Payment request sent";
        console.log("pay tickets clicked! ");
        document.getElementById("paymentFrame").src="http://payments-service/?sessionId=${sessionId}&reservationId=${reservationId}"
        //document.getElementById("paymentFrame").src = "http://localhost:8083/?sessionId=${sessionId}&reservationId=${reservationId}"
        var cc = document.getElementById("creditCard").value;

        var xhr = new XMLHttpRequest();
        xhr.open("POST", "/tickets/checkout", true);
        var data = JSON.stringify(
            {
                sessionId: "${sessionId}",
                reservationId: "${reservationId}",
                cc: cc
            }
        );
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.setRequestHeader('Ce-Id', 'CE-' + "${sessionId}");
        xhr.setRequestHeader('Ce-Type', 'Tickets.PaymentRequested');
        xhr.setRequestHeader('Ce-Source', 'website');
        xhr.setRequestHeader('correlationKey', "${reservationId}");

        /// curl -X POST http://customer-waiting-room-app.default.34.78.5.94.xip.io/router/message -H "Ce-Id: 123" -H "Ce-Type: NewCustomer"  -H "Ce-Source: curl" -H "Ce-Subject: hello"  -H "Content-Type: application/json" -H "correlationKey: 1" -d '"{\"sessionId\":\"1\"}"' -v

        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                callback(xhr.response);
            }
        }

        xhr.send(JSON.stringify(data));


        xhr = new XMLHttpRequest();
        xhr.open("POST", "/router/message", true);

        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.setRequestHeader('Ce-Id', 'CE-' + "${sessionId}");
        xhr.setRequestHeader('Ce-Type', 'Tickets.PaymentRequested');
        xhr.setRequestHeader('Ce-Source', 'website');
        xhr.setRequestHeader('correlationKey', "${reservationId}");

        /// curl -X POST http://customer-waiting-room-app.default.34.78.5.94.xip.io/router/message -H "Ce-Id: 123" -H "Ce-Type: NewCustomer"  -H "Ce-Source: curl" -H "Ce-Subject: hello"  -H "Content-Type: application/json" -H "correlationKey: 1" -d '"{\"sessionId\":\"1\"}"' -v

        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                callback(xhr.response);
            }
        }

        xhr.send(JSON.stringify(data));

    }

    function callback(response) {
        console.log(response);
        console.log("payment request received!!!");
        document.getElementById("paymentStatus").innerHTML = "Payment request received";
        connect();
    }

    var sessionId;

    console.log("Protocol: " + location.protocol);
    let wsURL = "ws://" + document.location.host + "/ws?sessionId=${sessionId}";
    if (location.protocol === 'https:') {
        wsURL = "wss://" + document.location.host + "/ws?sessionId=${sessionId}";
    }
    console.log("WS URL: " + wsURL);

    var sock;

    function connect() {

        sock = new WebSocket(wsURL);
        sock.onopen = function () {
            console.log('Info: Connection Established.');
        };

        sock.onmessage = function (event) {
            console.log(event.data)
            let ce = JSON.parse(event.data);
            console.log(ce);
            if (ce["type"] === "Tickets.PaymentsAuthorized") {

                var data = JSON.parse(ce["data"]);
                console.log(data);
                document.getElementById("paymentStatus").innerHTML = "Payment Authorized!";
                document.getElementById("nextButton").className = "main-button";
                document.getElementById("payButton").className = "main-button disabled";

            }
        };

        sock.onerror = function (event) {
            console.log("EFFOR: " + event);
        }
        sock.onclose = function (event) {

            console.log('Info: Closing Connection. -> ' + event);
        };
    }

</script>


</body>

</html>
