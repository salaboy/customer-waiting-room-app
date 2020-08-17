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

<body data-gr-c-s-loaded="true" class="backoffice">
<!--[if IE]>
<p class="browserupgrade">You are using an <strong>outdated</strong> browser. Please <a href="https://browsehappy.com/">upgrade
    your browser</a> to improve your experience and security.</p>
<![endif]-->

<!-- Add your site or application content here -->
<div class="block header">
    <div class="header__image">

    </div>
    <div class="header__title">
        <h1>Waiting Room Demo v0.0.0 </h1>
    </div>
    <div class="header__options">
        <a href="/">
            Go to Main Site <span><img src="img/house.svg" alt=""></span>
        </a>
    </div>

</div>
<div class="bottom-blocks">
    <div class="main-title">
        <h2>Active sessions</h2>
    </div>

    <div class="sessions" id="sessions">
        <#--        <div class="session">-->
        <#--            <a href="#">81390238210931238901238201938242342342310 24 234 38091238812903812039</a>-->
        <#--        </div>-->
        <#--        <div class="session">-->
        <#--            <a href="#">8139023821093812903812039</a>-->
        <#--        </div>-->


    </div>
</div>
<div class="button-layer">
    <a class="main-button inverted" onclick="generateBatch()">
        Generate
    </a>

    <a class="secondary-button" onclick="reset()">
        Reset
    </a>

    <#--    <a class="main-button">-->

    <#--        Remove all Sessions-->

    <#--    </a>-->
</div>


<script src="js/vendor/modernizr-3.7.1.min.js"></script>
<script src="https://code.jquery.com/jquery-3.4.1.min.js"
        integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous"></script>
<script>window.jQuery || document.write('<script src="js/vendor/jquery-3.4.1.min.js"><\/script>')</script>
<script src="js/plugins.js"></script>

<script type="text/javascript">

    fetchActiveSessions();
    setInterval(fetchActiveSessions, 3000);

    function fetchActiveSessions() {

        var xhr = new XMLHttpRequest();
        xhr.open("GET", "/queue/", true);


        xhr.onreadystatechange = function () {
            if (this.readyState == 4 && this.status == 200) {
                var data = JSON.parse(this.responseText);
                var sessionsDiv = document.getElementById("sessions");
                sessionsDiv.innerHTML = "";
                for (i = 0; i < data.length; i++) {
                    var sessionId = data[i].sessionId;
                    var sessionDiv = document.createElement("div");
                    sessionDiv.className = "session";
                    var a = document.createElement("a");
                    a.href = "#";
                    a.onclick = function () {
                        abandonQueue(sessionId);
                    };
                    a.innerHTML = sessionId;
                    sessionDiv.appendChild(a)
                    sessionsDiv.appendChild(sessionDiv);
                }
            }
        };
        xhr.send();
    }

    function abandonQueue(sessionId) {
        console.log("Abandoning queue for session: " + sessionId);
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "/router/message", true);
        var data = JSON.stringify(
            {
                sessionId: sessionId,
            }
        );
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.setRequestHeader('Ce-Id', 'CE-' + sessionId);
        xhr.setRequestHeader('Ce-Type', 'Queue.CustomerAbandoned');
        xhr.setRequestHeader('Ce-Source', 'website');
        xhr.setRequestHeader('correlationKey', sessionId);


        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                callback(xhr.response);
            }
        }

        console.log("Sending Cloud Event to Router: " + JSON.stringify(data));
        xhr.send(JSON.stringify(data));

        xhr = new XMLHttpRequest();
        xhr.open("POST", "/queue/abandon", true);

        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.setRequestHeader('Ce-Id', 'CE-' + sessionId);
        xhr.setRequestHeader('Ce-Type', 'Queue.CustomerAbandoned');
        xhr.setRequestHeader('Ce-Source', 'website');
        xhr.setRequestHeader('correlationKey', sessionId);


        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                callback(xhr.response);
            }
        }

        console.log("Sending Cloud Event to Router: " + JSON.stringify(data));
        xhr.send(JSON.stringify(data));
    }

    function createMyGuid() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            var r = Math.random() * 16 | 0, v = c === 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }

    function generateBatch() {
        /// curl -X POST http://customer-waiting-room-app.default.34.78.5.94.xip.io/router/message -H "Ce-Id: 123" -H "Ce-Type: NewCustomer"  -H "Ce-Source: curl" -H "Ce-Subject: hello"  -H "Content-Type: application/json" -H "correlationKey: 1" -d '"{\"sessionId\":\"1\"}"' -v
        var amount = 10;
        for (var i = 0; i < amount; i++) {
            var xhr = new XMLHttpRequest();
            xhr.open("POST", "/router/message", true);
            var sessionId = "mock-" + i + createMyGuid();
            var data = JSON.stringify(
                {
                    sessionId: sessionId,
                    ticketsType: "",
                    ticketsQuantity: "0",
                    reservationId: ""
                }
            );
            xhr.setRequestHeader('Content-Type', 'application/json');
            xhr.setRequestHeader('Ce-Id', 'CE-' + sessionId);
            xhr.setRequestHeader('Ce-Type', 'Queue.CustomerJoined');
            xhr.setRequestHeader('Ce-Source', 'website');
            xhr.setRequestHeader('correlationKey', sessionId);


            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4) {
                    callback(xhr.response);
                }
            }

            console.log("Sending Cloud Event to Router: " + JSON.stringify(data));
            xhr.send(JSON.stringify(data));


            xhr = new XMLHttpRequest();
            xhr.open("POST", "/queue/join", true);

            xhr.setRequestHeader('Content-Type', 'application/json');
            xhr.setRequestHeader('Ce-Id', 'CE-' + sessionId);
            xhr.setRequestHeader('Ce-Type', 'Queue.CustomerJoined');
            xhr.setRequestHeader('Ce-Source', 'website');
            xhr.setRequestHeader('correlationKey', sessionId);

            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4) {
                    callback(xhr.response);
                }
            }

            console.log("Sending Cloud Event to Queue: " + JSON.stringify(data));
            xhr.send(JSON.stringify(data)); // Double stringify escape double quotes that are needed
        }
    }

    function callback(response) {
        console.log(response);
    }

    function cleanup() {


    }

    function reset() {
        window.location.href = "/backoffice?reset=true";

    }

</script>

</body>

</html>