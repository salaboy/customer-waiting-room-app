
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

    </div>
    <div class="header__title">
        <h1>Tickets Portal v${version}</h1>
    </div>
    <div class="header__options">

    </div>

</div>
<div class="bottom-blocks">
    <div class="main-title">


    </div>
    <div class="queue">
        <div class="queue-header">
            <h2>Purchase your tickets.</h2>
            <div class="codesIds">Session ID:  <span>${sessionId}</span></div>
            <div class="codesIds">Reservation ID:  <span>${reservationId}</span></div>

        </div>
        <div class="queue-form">
            <form class="form" action="">

                <div class="form-field half">
                    <label>Type</label>
                    <select  name="ticketsType" id="ticketsType">
                        <option value="standing">Standing</option>
                        <option value="balcony 1">Balcony Left</option>
                        <option value="balcony 2">Balcony Right</option>
                        <option value="far away">Far Away</option>
                    </select>
                </div>
                <div class="form-field small">
                    <label>Quantity</label>
                    <input type="number" id="ticketsQuantity">
                </div>
            </form>

        </div>
    </div>
</div>
<div class="button-layer">
    <a class="main-button" onclick="reserveTickets()">
        Reserve Tickets
    </a>
</div>



<script src="js/vendor/modernizr-3.7.1.min.js"></script>
<script src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous"></script>
<script>window.jQuery || document.write('<script src="js/vendor/jquery-3.4.1.min.js"><\/script>')</script>
<script src="js/plugins.js"></script>

<script type="text/javascript">
 function reserveTickets(){

     var ticketsType = document.getElementById("ticketsType").value;
     var ticketsQuantity = document.getElementById("ticketsQuantity").value;
     var xhr = new XMLHttpRequest();
     xhr.open("POST", "/broker", true);
     var data = JSON.stringify(
         {
             reservationId: "${reservationId}",
             sessionId: "${sessionId}",
             ticketsType: ticketsType,
             ticketsQuantity: ticketsQuantity
         }
     );
     xhr.setRequestHeader('Content-Type', 'application/json');
     xhr.setRequestHeader('Ce-Id', 'CE-' + "${sessionId}");
     xhr.setRequestHeader('Ce-Type', 'Tickets.Reserved');
     xhr.setRequestHeader('Ce-Source', 'website');
     xhr.setRequestHeader('Ce-CorrelationKey', "${sessionId}");
     xhr.setRequestHeader('Ce-Specversion', '1.0');

     /// curl -X POST http://customer-waiting-room-app.default.34.78.5.94.xip.io/router/message -H "Ce-Id: 123" -H "Ce-Type: NewCustomer"  -H "Ce-Source: curl" -H "Ce-Subject: hello"  -H "Content-Type: application/json" -H "correlationKey: 1" -d '"{\"sessionId\":\"1\"}"' -v

     xhr.onreadystatechange = function () {
         if (xhr.readyState === 4) {
             callback(xhr.response);
         }
     }

     xhr.send(JSON.stringify(data));
 }
 function callback(response) {
    window.location.href = "/pay?sessionId=${sessionId}&reservationId=${reservationId}";
 }

</script>




</body>

</html>
