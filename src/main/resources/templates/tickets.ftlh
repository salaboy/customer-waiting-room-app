
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
            <h2>Purchase your tickets.</h2>
            <p>Your buying ID is ${sessionId}</p>

        </div>
        <div class="queue-form">
            <form class="form" action="">
                <div class="form-field">
                    <label>Type</label>
                    <input type="text">
                </div>
                <div class="form-field small">
                    <label>Quantity</label>
                    <input type="number">
                </div>

            </form>

        </div>
    </div>
</div>
<div class="button-layer">
    <a class="main-button " >
        Buy Tickets
    </a>
</div>



<script src="js/vendor/modernizr-3.7.1.min.js"></script>
<script src="https://code.jquery.com/jquery-3.4.1.min.js" integrity="sha256-CSXorXvZcTkaix6Yvo6HppcZGetbYMGWSFlBw8HfCJo=" crossorigin="anonymous"></script>
<script>window.jQuery || document.write('<script src="js/vendor/jquery-3.4.1.min.js"><\/script>')</script>
<script src="js/plugins.js"></script>
<script src="js/main.js"></script>
<script type="text/javascript">
 function buyTickets(){
     console.log("buy tickets clicked! ")
 }

</script>




</body>

</html>
