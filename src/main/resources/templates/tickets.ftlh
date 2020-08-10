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
        <div id="modalContent" class="modal__content">
            <div class="modal__content__title">
                Select Tickets
                <h5>
                    <#if c4p??>
                        <a href="https://github.com/salaboy/tickets-service/releases/tag/v${tickets.version}">${tickets.name}
                            v${tickets.version}</a>
                    <#else>
                        <a href="https://github.com/salaboy/tickets-service/">
                            N/A</a>
                    </#if>
                </h5>

            </div>
            <div id="modalBody" class="modal__content__body">
                <div class="form">
                    <div class="form-field">
                        <label>Type</label>
                        <input id="type" type="text">
                    </div>
                    <div class="form-field">
                        <label>Quantity</label>
                        <input id="quantity" type="text">
                    </div>


                </div>
            </div>
            <div id="modalActions" class="modal__content__action">
                <div id="modalErrorMessage" class="modal__content__action__message">

                </div>
                <a onclick="buyTicket()" class="button">Buy Tickets</a>
            </div>

        </div>
    </div>

</div>

<script src="js/vendor/modernizr-3.7.1.min.js"></script>
<script src="https://code.jquery.com/jquery-3.4.1.min.js"
        integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous"></script>
<script>window.jQuery || document.write('<script src="js/vendor/jquery-3.4.1reconnecting-websocket.min.js"><\/script>')</script>
<script src="js/plugins.js"></script>
<script type="text/javascript">




    function buyTicket() {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "/tickets/");
        var errorMsg = "Please complete required fields: ";
        // if (document.getElementById("author").value == "") {
        //     errorMsg += "author,"
        // }
        // if (document.getElementById("email").value == "") {
        //     errorMsg += "email,"
        // }
        // if (document.getElementById("title").value == "") {
        //     errorMsg += "title,"
        // }
        // if (document.getElementById("description").value == "") {
        //     errorMsg += "description,"
        // }

        if (errorMsg == "Please complete required fields: ") {
            var data = JSON.stringify({
                quantity: document.getElementById("quantity").value,
                type: document.getElementById("type").value,

            });
            xhr.setRequestHeader('Content-Type', 'application/json');
            console.log(data);
            xhr.send(data);

            // document.getElementById("modalBody").className = "modal__content__body__hidden";
            // document.getElementById("modalActions").className = "modal__content__action__hidden";
            // document.getElementById("modalMessage").className = "modal__content__message";

        } else {
            console.log(errorMsg);
            document.getElementById("modalErrorMessage").innerHTML = errorMsg.substr(0, errorMsg.length - 1) + ".";
        }
    }


</script>


</body>

</html>