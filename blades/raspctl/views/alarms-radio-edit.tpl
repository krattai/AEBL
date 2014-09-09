%rebase base

<h3 class="text-info"><a style="text-decoration:underline;" href="/alarm/radio">Alarms list</a> > Editing Alarm</h3>

<hr />

<form action="/alarm/save" class="form-horizontal" method="post">

	<input type="hidden" name="id_" value="{{alarm.id_}}" />

	<div class="control-group">
		<label class="control-label" for="class">Alarm Name</label>
		<div class="controls">
			<input type="text" id="name" name="name" value="{{alarm.name}}" placeholder="The name of the alarm" /> <br />
		</div>
	</div>

	<br />

	<div class="control-group">
		<label class="control-label" for="class">Date</label>
		<div class="controls">
			<input type="text" id="date" name="date" value="{{alarm.date}}" placeholder="yyyy-mm-dd format" /> <br />
		</div>
	</div>

	<div class="control-group">
		<label class="control-label" for="class">Hour</label>
		<div class="controls">
			<input type="text" id="hour" name="hour" value="{{alarm.hour}}" placeholder="hh:mm:ss format" /> <br />
		</div>
	</div>

	<div class="control-group">
		<label class="control-label" for="class">Action</label>
		<div class="controls">
			<select id="action" name="action">
				% for value, name in (("play", "Play"), ("stop", "Stop")):
					% if value == alarm.action:
						<option selected="selected" value="{{value}}">{{name}}</option>
					% else:
						<option value="{{value}}">{{name}}</option>
					% end
				% end
			</select>
		</div>
	</div>

	<div class="control-group">
		<label class="control-label" for="class">Volume</label>
		<div class="controls">
			<select id="volume" name="volume">
				% for i in range(0, 110, 10):
					% if i == alarm.volume:
						<option selected="selected" value="{{i}}">{{i}}</option>
					% else:
						<option value="{{i}}">{{i}}</option>
					% end
				% end
			</select>
		</div>
	</div>

	<div class="control-group">
		<label class="control-label" for="class">Radio Name</label>
		<div class="controls">
			<select id="radio_name" name="stream">
				% for name, stream in radios:
					% if stream == alarm.stream:
						<option selected="selected" value="{{stream}}">{{name}}</option>
					% else:
						<option value="{{stream}}">{{name}}</option>
					% end
				% end
			</select>
		</div>
	</div>
	
	<div class="form-actions">
		<button type="submit" class="btn btn-primary">Save changes</button>
	</div>
</form>
