% import helpers

<html style="overflow-y: scroll">
<head>
	<title> RaspCTL</title>
	<link href="/static/css/bootstrap.min.css" rel="stylesheet" media="screen">
    <style>
    	body {
    		padding-top: 60px; /* 60px to make the container go all the way to the bottom of the topbar */
      	}

		input[type="text"] {
			height: 26px;
		}
    </style>
</head>
<body>

    <div class="navbar navbar-inverse navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container">
          <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </a>
          <a class="brand" href="/">RaspCTL</a>
          <div class="nav-collapse collapse">
            <ul class="nav">
              <li class="{{ helpers.is_tab_active('commands')  }}"><a href="/commands">Commands</a></li>
              <li class="{{ helpers.is_tab_active('services') }}"><a href="/services">Services</a></li>
              <li class="{{ helpers.is_tab_active('radio') }}"><a href="/radio">Radio</a></li>
              <li class="{{ helpers.is_tab_active('alarm') }}"><a href="/alarm">Alarm</a></li>
              <li class="{{ helpers.is_tab_active('webcam') }}"><a href="/webcam">Webcam</a></li>
              <li class="{{ helpers.is_tab_active('config') }}"><a href="/config">Configuration</a></li>
              <li class="{{ helpers.is_tab_active('about') }}"><a href="/about">About</a></li>
              <li><a style="color: red;" href="/logout">Logout</a></li>
            </ul>
          </div><!--/.nav-collapse -->
        </div>
      </div>
    </div>

	<script src="/static/js/jquery-1.9.0.min.js"></script>
	<script src="/static/js/bootstrap.min.js"></script>
	<script src="/static/js/bootbox.min.js"></script>

	<div class="container">
		%include
    </div> <!-- /container -->

</body>
</html>
