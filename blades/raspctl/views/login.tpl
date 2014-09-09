<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>Login &middot; RaspCTL</title>
    <meta name="author" content="Jan Carreras Prat">
    <link href="/static/css/bootstrap.css" rel="stylesheet">
    <link href="/static/css/login.css" rel="stylesheet">
    <link href="/static/css/bootstrap-responsive.css" rel="stylesheet">
</head>

<body>
    <noscript>
        <div class="error message" style="color: red; text-align:center;">
            <h3>Ooops!</h3>
            <p>
                I'm sorry! I've detected that you are blocking JavaScript (And I'm cool with that!) but this
                site just works <b>if JavaScript is enabled</b>.<br /> 
                Please, consider to whitelist this site for being able to use it. Thanks!
            </p>
        </div>
		<br />
    </noscript>

    <div class="container">
      <form class="form-signin" method="post" action="/login">
        <h2 class="form-signin-heading">Please sign in</h2>
        <input type="text" class="input-block-level" placeholder="Username" name="username">
        <input type="password" class="input-block-level" placeholder="Password" id="password" name="password">
        <div style="text-align: center">
            <button class="btn btn-large btn-primary" type="submit">Sign in</button>
        </div>
      </form>
    </div>

	<div class="container" style="text-align: center;">
		<p>The default username/password is admin:admin. <br />
		PLEASE, change the password in the configuration tab as soon as possible or 10 kittens <br /> on the
		other side of the world will suffer diarrea and cough attack! At the same time!</p>
	</div>

	<br /> <br />
	
	<div class="container" style="text-align: center; color: grey;">
		Copyright 2013 - Jan Carreras Prat &lt;jcarreras@krenel.org&gt; <br />
		GPL3 project - Official webpage <a href="http://raspctl.com">Raspctl.com</a>
	</div>
  </body>
</html>
