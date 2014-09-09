%rebase base


% if data.id_ == "": # New
	<h3 class="text-info"> New command </h3>
% else: # edit
	<h3 class="text-info"> Editing {{data.class_}}/{{data.action}}</h3>
% end
<hr />

<br />


<form class="form-horizontal" action="/command/save" method="post" >

	<input type="hidden" name="id" value="{{data.id_}}" />

	<div class="control-group">
		<label class="control-label" for="class">Class</label>
		<div class="controls">
			<input type="text" name="class" placeholder="Class" value="{{data.class_}}">
			<abbr title="The category that identifies the type of command. (only lowercase and using chars from a-z and 0-9)">Help</abbr>
			<abbr title="music, admin, system, etc...">Example</abbr>
		</div>
	</div>

	<div class="control-group">
		<label class="control-label" for="action">Action</label>
		<div class="controls">
			<input type="text" name="action" placeholder="Action" value="{{data.action}}">
			<abbr title="Name of the action. Usually a verb.">Help</abbr>
			<abbr title="run, update, up, pause, play, etc...">Example</abbr>
		</div>
	</div>

	<div class="control-group">
		<label class="control-label" for="command">Command</label>
		<div class="controls">
			<input type="text" name="command" placeholder="Command" value="{{data.command}}" class="input-xxlarge">
			<abbr title="The command that will be executed">Help</abbr>
			<abbr title="poweroff">Example</abbr>
		</div>
	</div>

	<div class="form-actions">
		<button type="submit" class="btn btn-primary">Save changes</button>
	</div>
</form>
<hr />

	% if data.id_:
			<a class="offset1" href="/execute?class={{data.class_}}&action={{data.action}}">http://raspberryip/execute?class={{data.class_}}&action={{data.action}}</a>
	% end
