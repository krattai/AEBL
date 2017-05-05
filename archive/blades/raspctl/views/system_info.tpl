<div class="span4">
	<h3 class="text-info"> Basic </h3>
	<dl class="dl-horizontal">
		<dt>Hostname</dt>
		<dd>{{info['HOSTNAME']}}</dd>
		<dt>IP address</dt>
		<dd>{{info['IP_ADDRESS']}}</dd>
		<dt>Uptime</dt>
		<dd>{{info['UPTIME']}}</dd>
	</dl>

	<hr />

	<h3 class="text-info"> Processor </h3>
	<dl>
		<dt>CPU Name</dt>
		<dd>{{info['PROCESSOR_NAME'].strip() or info['PROCESSOR_NAME2']}}</dd>
		<dt>Temperature</dt>
		<dd>{{"%.2f ºC / %.2f ºF" % (temp['c'], temp['f']) if temp else "unknown"}}</dd>
		<dt>Bogomits</dt>
		<dd>{{info['PROCESSOR_BOGOMITS']}}</dd>
		<dt>Current speed (Hz)</dt>
		<dd>{{info['PROCESSOR_CURRENT_SPEED']}}</dd>
		<dt>Overclocked speed (MHz)</dt>
		<dd>{{info['PROCESSOR_OVERLOCK'].strip() or '--'}}</dd>
		<dt>Load Average</dt>
		<dd>{{info['LOAD_AVG']}}</dd>
	</dl>

	<hr />

	<h3 class="text-info">Top CPU processes</h3>
	<dl class="dl-horizontal">
		% for process in info['TOP_PROCESSES'].split('#'):
			% if process:
				% usage, pid, name = process.split(' ', 2)
				<dt title="{{name}}">{{name}}</dt>
				<dd>PID: {{pid}} - {{usage}}%</dd>
			% end
		% end
	</dl>

	<hr />

	<h3 class="text-info">Top MEMORY processes</h3>
	<dl class="dl-horizontal">
		% for process in info['TOP_MEMORY'].split('#'):
			% if process:
				% usage, pid, name = process.split(' ', 2)
				<dt title="{{name}}">{{name}}</dt>
				<dd>PID: {{pid}} - {{usage}}%</dd>
			% end
		% end
	</dl>

</div>

<div class="span5">
	<h3 class="text-info">Memory usage</h3>
	% used = int(float(info['USED_MEMORY']) / float(info['MEMORY_TOTAL']) * 100)
	% free = int(float(info['FREE_MEMORY']) / float(info['MEMORY_TOTAL']) * 100)
	% if used < 70:
	%   color = "success"
	% else:
	%   if used < 85:
	%     color = "warning"
	%   else:
	%     color = "danger"
	%   end
	% end

	<div class="progress progress-{{color}}">
		<div class="bar" style="width: {{used}}%;"></div>
	</div>
	<dl class="dl-horizontal">
		<dt>Total memory</dt>
		<dd>{{h.sizeof_pretty(info['MEMORY_TOTAL'])}}</dd>
		<dt>Used</dt>
		<dd>{{h.sizeof_pretty(info['USED_MEMORY'])}} <b>({{used}}%)</b></dd>
		<dt>Free</dt>
		<dd>{{h.sizeof_pretty(info['FREE_MEMORY'])}} ({{free}}%)</dd>
	</dl>

	<hr />

	<h3 class="text-info">Disk usage</h3>
	% if not info['DISK_TOTAL']:
		<div>
			<p><span>Error! We have been unable to retreive the disk usage information!</span></p>
		</div>
	% else:
		% clean = lambda str: float(filter(lambda x: x.isdigit() or '.' == x, str.replace(',', '.')))
		% used = int(clean(info['DISK_USED']) / clean(info['DISK_TOTAL']) * 100)
		% free = int(clean(info['DISK_FREE']) / clean(info['DISK_TOTAL']) * 100)
		% if used < 70:
		%   color = "success"
		% else:
		%   if used < 85:
		%     color = "warning"
		%   else:
		%     color = "danger"
		%   end
		% end
		<div class="progress progress-{{color}}">
			<div class="bar" style="width: {{used}}%;"></div>
		</div>
		<dl class="dl-horizontal">
			<dt>Total HDD space</dt>
			<dd>{{h.sizeof_pretty(info['DISK_TOTAL'])}}</dd>
			<dt>Used</dt>
			<dd>{{h.sizeof_pretty(info['DISK_USED'])}} <b>({{used}}%)</b></dd>
			<dt>Free</dt>
			<dd>{{h.sizeof_pretty(info['DISK_FREE'])}} ({{free}}%)</dd>
		</dl>
	% end

</div>
