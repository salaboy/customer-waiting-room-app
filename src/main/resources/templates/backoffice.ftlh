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
        <h1>Tickets Portal v${version}</h1>
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

    </div>
</div>
<div class="button-layer">
    <a class="main-button inverted" onclick="generateBatch()">
        Generate
    </a>

    <a class="secondary-button" onclick="reset()">
        Reset
    </a>

</div>


<script src="js/vendor/modernizr-3.7.1.min.js"></script>
<script src="https://code.jquery.com/jquery-3.4.1.min.js"
        integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous"></script>
<script>window.jQuery || document.write('<script src="js/vendor/jquery-3.4.1.min.js"><\/script>')</script>
<script src="js/plugins.js"></script>

<script type="text/javascript">

    fetchActiveSessions();
    setInterval(fetchActiveSessions, 1000);

    function fetchActiveSessions() {

        var xhr = new XMLHttpRequest();
        xhr.open("GET", "/queue/", true);


        xhr.onreadystatechange = function () {
            if (this.readyState == 4 && this.status == 200) {
                var data = JSON.parse(this.responseText);
                var sessionsDiv = document.getElementById("sessions");
                sessionsDiv.innerHTML = "";
                for (i = 0; i < data.length; i++) {
                    const sessionId = data[i].sessionId;
                    var sessionDiv = document.createElement("div");

                    if(sessionId.includes("mock")){
                        sessionDiv.className = "session";
                    }else{
                        sessionDiv.className = "session my-session";
                    }

                    var sessionIdDiv = document.createElement("div");
                    sessionIdDiv.className = "session__id"
                    var sessionIdSpan = document.createElement("span");
                    sessionIdSpan.append(i + ". ");
                    sessionIdDiv.appendChild(sessionIdSpan);
                    sessionIdDiv.append(sessionId);

                    sessionDiv.appendChild(sessionIdDiv);

                    var sessionActionsDiv = document.createElement("div");
                    sessionActionsDiv.className = "session__actions"


                    sessionDiv.appendChild(sessionActionsDiv);

                    var removeSessionButton = document.createElement("div");

                    removeSessionButton.onclick = function () {
                        abandonQueue(removeSessionButton, sessionId);
                    };
                    removeSessionButton.innerHTML = "Remove";
                    removeSessionButton.className = "button button-remove";
                    sessionActionsDiv.appendChild(removeSessionButton);
                    sessionsDiv.appendChild(sessionDiv);
                }
            }
        };
        xhr.send();
    }

    function abandonQueue(button, sessionId) {
        var sessionBlock = button.parentNode.parentNode;
        sessionBlock.parentNode.removeChild(sessionBlock);
        console.log("Abandoning queue for session: " + sessionId);
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "/broker", true);
        var data = JSON.stringify(
            {
                sessionId: sessionId,
            }
        );
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.setRequestHeader('Ce-Id', 'CE-' + sessionId);
        xhr.setRequestHeader('Ce-Type', 'Queue.CustomerAbandoned');
        xhr.setRequestHeader('Ce-Source', 'website');
        xhr.setRequestHeader('Ce-Specversion', '1.0');
        xhr.setRequestHeader('Ce-CorrelationKey', sessionId);


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

        var amount = 10;
        for (var i = 0; i < amount; i++) {
            var xhr = new XMLHttpRequest();
            xhr.open("POST", "/broker", true);
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
            xhr.setRequestHeader('Ce-CorrelationKey', sessionId);
            xhr.setRequestHeader('Ce-Specversion', '1.0');


            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4) {
                    callback(xhr.response);
                }
            }

            console.log("Sending Cloud Event to Broker: " + JSON.stringify(data));
            xhr.send(JSON.stringify(data));

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