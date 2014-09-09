%rebase base

<br />

<h3 class="text-info">Radio alarms</h3>

<hr />

<br />

<a class="btn" href="/alarm/edit/new" title="New alarm"> <i class="icon-plus-sign"></i> New alarm </a>

<table class="table table-hover">
	<thead>
		<tr>
			<th>Date</th>
			<th>Hour</th>
			<th>Name</th>
			<th>Action</th>
			<th>Options</th>
		</tr>
	</thead>
	<tbody id="services_list">
		% for alarm in alarms:
		<tr>
			<td>{{alarm.date}}</td>
			<td>{{alarm.hour}}</td>
			<td>{{alarm.name}}</td>
			<td>{{alarm.action}}</td>
			<td>
				<a class="btn action" href="/alarm/edit/{{alarm.id_}}" title="Edit"><i class="icon-wrench"></i></a>
				<a class="btn action remove" href="/alarm/delete/{{alarm.id_}}" title="Delete"><i class="icon-remove"></i></a>
			</td>
		</tr>
		% end
	</tbody>
</table>

<script src="/static/js/alarms.js"></script>
