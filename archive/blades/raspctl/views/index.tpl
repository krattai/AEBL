% rebase base


<div id="content"></div>


<script type="text/javascript">

$(document).ready(function() {

	var load = function() {
		$.get('/system_info', function(data) {
			$('#content').html(data);
		});
	}
	load();
	// Every 2 seconds refresh de information of the dashboard
	setInterval(load, 30000);
});

</script>
