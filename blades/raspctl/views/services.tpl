% rebase base

% import config

<p> <i>Service</i> is used for checking the status of the services in /etc/init.d/* and doing the most standart admin actions. </p>

% if config.SHOW_DETAILED_INFO:
	Read the PRIVILEGED COMMANDS section from README and the comments of the file scripts/exec.sh for further information.
% end

% if not config.SERVICE_EXECUTION:
	<h5 class="text-error offset2">The service execution is <b>DISABLED</b>. You can enable it in <a href="/config">config</a>.</h5>
% end

<br /> <br />


<div class="row">
	<div class="form-inline offset3 span4">
		<label for="search">Search</label>
		<input type="text" id="search"  class="input-large search-query" placeholder="Service name" style="height: 30px" />
	</div>
	<div class="span3 offset2">
		<label for="show_favorite" class="checkbox">
			<input type="checkbox" id="show_favorite" {{"checked=checked" if filter_favorites else ""}} />
			Show only favorites	
		</label>
	</div>
</div>


<br /> <br />

<table class="table table-hover">
	<thead>
		<tr>
			<th>Name</th>
			<th>Actions</th>
			<th>Status</th>
			<th>Favorite</th>
		</tr>
	</thead>
	<tbody id="services_list">

	% for service in services:
		<tr id="tr_{{service}}" class="service_line" service_name="{{service}}">
			<td style="width: 195px">{{service}}</td>
			<td style="width: 240px">
				<a class="btn action" href="/service/{{service}}/start" title="Start"><i class="icon-play"></i></a>
				<a class="btn action" href="/service/{{service}}/reload" title="Reload"><i class="icon-repeat"></i></a>
				<a class="btn action" href="/service/{{service}}/restart" title="Restart"><i class="icon-refresh"></i></a>
				<a class="btn action" href="/service/{{service}}/stop" title="Stop"><i class="icon-stop"></i></a>
				<a class="btn action status" href="/service/{{service}}/status" title="Status"><i class="icon-info-sign"></i></a>
			</td>
			<td style="width: 380px;"><span class="cmd_response"></span></td>
			<td>
				<a class="btn action favorite {{'btn-success' if service in favorite_services else ''}}" href="/service/{{service}}/favorite" title="Mark as favorite"><i class="icon-star"></i></a>
			</td>
		</tr>
	% end
	</tbody>
</table>

% if not services:
	<i class="offset4">nothing to show here...</i>
	
% end

<script type="text/javascript">
	$(document).ready(function() {
		// Search box logic (and highlighting)

		search_fnx = function(element) {

			var show_favorites = $('#show_favorite')[0].checked;
			var search_pattern = $('#search')[0].value
			re = new RegExp(search_pattern, "i");
			$('.service_line').each(function() {
				var service_name = $(this)[0].getAttribute('service_name');
				var favorite_btt = $('.service_line')[0].getElementsByClassName("favorite")
				// Ok, detecting if the element is favourite or not depending on btn-success is not he most
				// beautiful thing. TODO: Fix it...
				var is_favorite = $(favorite_btt).hasClass('btn-success');

				if (re.test(service_name))  {
					// Highlight the matching substring
					content = service_name.replace(re, "<b style='color:red'>" + search_pattern + "</b>");
					$($(this).children()[0]).html(content);
					$(this).removeClass('hide');
				} else {
					$(this).addClass('hide');
				}

			});
		};

		$('#search').keyup(function(event) {
			search_fnx($(this));
		});


		// Send the requests with AJAX instead of following the links and append the response to the page
		$('.action').click(function(event) {
			event.preventDefault();
			var container = $(event.target).parents('tr')[0].getElementsByClassName('cmd_response');

			$.get(this.href, {}, function(response) {
				data = $('<div/>').append(response);
			    $(data).appendTo(container);
			})
		});

		// Get the status of the favourite services
		var get_status_of_favorite = function() {
			$('.cmd_response').each(function() {$(this).html("")});
			$('.action.btn-success').each(function(element) {
				// This is a little bit obscure. First we pick up the parent...
				var parent_tr = $(this).parents('tr')[0];
				// ... then we search the STATUS button ...
				var status_button = parent_tr.getElementsByClassName('status')
				// ... and we trigger the click action.
				$(status_button).trigger('click');
			});
		};
		get_status_of_favorite();

		$('.favorite').click(function(element) {
			$(this).toggleClass('btn-success');
			get_status_of_favorite();
		});

		$('#show_favorite').change(function() {
			location.href = "/services?filter_favorites=" + $('#show_favorite')[0].checked;
		});

		

	});
</script>
