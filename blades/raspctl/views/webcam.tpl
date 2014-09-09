% rebase base

% import config

<p>Just takes a photo with the webcam and displays it to the same page. If you take more photos the old ones are overwitted.</p>

% if config.SHOW_DETAILED_INFO:

	<p>How it works? We use <b>fswebcam</b> program for taking the snapshot/photo. This applications tries to open /dev/video0 so we must have permissions for reading to this device (we must be in the VIDEO system group). The image is 640x480 pixels.</p>


% end


% if config.SHOW_TODO:
	<p><span class="label label-important">TODO:</span> We must be able to adjust the photo resolution from the configuration (because some webcams do not suport this format, thought), the input device (now is on /dev/video0 by default).</p>
% end

<h3 class="text-info"> Webcam </h3>
<hr />


% if not fswebcam_is_installed:
	<span class="text-error">An error occurred! In order to use the webcam you need to have installed <b>fswebcam</b> package. You can install it by doing <b>sudo aptitude update && sudo aptitude install fswebcam</b>. After that, you must check that the user you are using for executing RaspCTL is in VIDEO group. You can check that executing the command <b>"groups | grep video"</b>; if you don't have any result you must execute <b>sudo adduser $USER video</b> and reboot the Raspberry Pi. </span>
% end


	<br />
	<a id="take_picture" class="btn btn-primary offset3 span4" href="/take_picture">Take new picture</a>

<br /> <br />

<img id="picture" class="offset1" src="/static/img/webcam_last.jpg" width="640px" height="480px" onerror="imgError(this);" />

<br />

<hr />

<br />

<script type="text/javascript">

$(document).ready(function() {
	function imgError(image) {
	    image.onerror = "";
	    image.src = "/static/img/no_image.gif";
	    return true;
	}

	% if fswebcam_is_installed:
		$('#take_picture').bind('click', function(event) {
			event.preventDefault();
			// Launch the HTTP Request with ajax
			$.get(this.href, {}, function(response) {})
			setTimeout(function (){}, 3500); // Just wait 3.5 seconds
			d = new Date();
			// Reload the image without reloading the page (and avoiding cache problems)
			$("#picture").attr("src", "/static/img/webcam_last.jpg?" + d.getTime());
		});
	% else:
		$('#take_picture').bind('click', function(event) {
			event.preventDefault();
			bootbox.alert("Button disabled! Install the fswebcam package, please!", function() { });
		});
		$('#take_picture').removeClass('btn-primary');
		$('#take_picture').addClass('btn-inverse');
		$('#take_picture').href = "#";
	% end
});

</script>

