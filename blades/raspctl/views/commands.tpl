%rebase base

% import config

<p> <i>Commands</i> section is used when you want to define some commands that will be executed on the Raspberry Pi. The commands can be executed either from the web interface or using a HTTP API. The commands are executed non-interactively! You don't even see the output of the commands! </p>

% if config.COMMAND_EXECUTION == False:
	<p class="text-warning">The command execution is DISABLED. You can activate it  thru the <a href="/config">configuration</a>.</p>
% end

% if config.SHOW_DETAILED_INFO:

	<p class="text-error"> Be very careful when using this tool because ANY command can be executed, even "rm -rf /". The UID (User ID) of the one who is running the web application will be used. It is strongly recommended to NOT use root user for obvious reasons. Take care.  </p>

	<p>Let's explain each item:</p>

	<dl class="dl-horizontal">
		<dt>Class</dt>
		<dd>Used for defining a generic name. Same as Category. Just for being able to group all the commands by the same subject or type.</dd>
		<dt>Action </dt>
		<dd> Just a descriptive name of the action this command will perform. Only letters, numbers and the '_' character can be used (because it must be URL friendly in order to be used in the HTTP API)</dd>
		<dt>Command</dt>
		<dd>The command itself. This command will be executed in the shell. The command can receive parameters too (not true, is in my <span class="label label-important">TODO</span> list)</dd>
	</dl>

	<p> The URL API is very easy to use. You just have to do a request to: </p>

	<p> http://your-rasperry-ip<b>/execute?class=CLASS&amp;action=ACTION&amp;param1=FOO</b> </p>

	<p> Where CLASS and ACTION are required fields and will be used for searching the command, if any match is found, the command will be executed passing the given parameters </p>

% end

<br />
<a class="btn" href="/command/edit/new" title="New element"> <i class="icon-plus-sign"></i> New command </a>
<br /> <br /> <br />


<table class="table table-hover">
	<thead>
		<tr>
			<th>Class</th>
			<th>Action</th>
			<th>Command</th>
			<th>Options</th>
		</tr>
	</thead>
	<tbody>

	% for row in rows:
		<tr>
			<td> {{row.class_}} </td>
			<td> {{row.action}} </td>
			<td> {{row.command}} </td>
			<td>
				<a class="btn launch" href="/execute?class={{row.class_}}&action={{row.action}}" title="Launch"><i class="icon-play"></i></a>
				<a class="btn" href="/command/edit/{{row.id_}}" title="Edit"><i class="icon-wrench"></i></a>
				<a class="btn remove" href="/command/delete/{{row.id_}}" title="Remove"><i class="icon-remove"></i></a>
			</td>
		</tr>
	% end
	</tbody>
</table>
	% if not rows:
		<div style="text-align: center" class="alert alert-info">Add a command by clicking in New Command button</div>
	% end


<p><b>Caution:</b> If you run a command that take a lot to execute, the RaspCTL will be 'blocked' until the command finishes. If you want to run a command that take too long to execute you may want to use "&" for executing it in background.</p>
<p><b>Note:</b> The commands are being executed from the raspctl's Home Path. Do not assume that the commands are launched using the /home/pi Path. If you are trying to run a custom command or script, use the <b>full path</b> to your script (and be sure is world readable/executable).</p>

<script src="/static/js/commands.js"></script>
