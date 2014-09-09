%rebase base

<!-- VOLUME -->
<div class="pagination" style="float: right;">
	<ul id="volume">
		<li><a title="Volume" href="/radio/volume/0">0</a></li>
		<li><a title="Volume" href="/radio/volume/10">10</a></li>
		<li><a title="Volume" href="/radio/volume/20">20</a></li>
		<li><a title="Volume" href="/radio/volume/30">30</a></li>
		<li><a title="Volume" href="/radio/volume/40">40</a></li>
		<li><a title="Volume" href="/radio/volume/50">50</a></li>
		<li><a title="Volume" href="/radio/volume/60">60</a></li>
		<li><a title="Volume" href="/radio/volume/70">70</a></li>
		<li><a title="Volume" href="/radio/volume/80">80</a></li>
		<li><a title="Volume" href="/radio/volume/90">90</a></li>
		<li><a title="Volume" href="/radio/volume/100">100</a></li>
	</ul>
</div>
<!-- END VOLUME -->

<!-- ADD NEW RADIO BTN -->
<p>
	<br />
	<a id ="add_new_radio"href="#new_radio"> <i class="icon-plus"></i> Add new radio </a>
</p>
<!-- END ADD NEW RADIO BTN -->


<br /> <br />


<!-- SUCCESS MESSAGE -->
% if successfully_saved:
	<div class="alert alert-success">The radios have been saved!</div>
% end
<!-- END SUCCESS MESSAGE -->

<br /> <br />

<!-- TABLE THAT HAS A TEMPLATE ON IT -->
<table class="hide">
<tr id="tmpl" class="hide">
	<td>
		<input type="text" name="name_UUIDNAME" value="" class="name" />
	</td>
	<td>
		<input type="text" name="stream_UUIDSTREAM" value="" class="stream" />
	</td>
	<td>
		<a class="btn launch" href="#" title="Start" id="foo">
			<i class="icon-play"></i>
		</a>
	</td>
	<td>
		<a class="btn launch" href="/radio/stop" title="Stop">
			<i class="icon-stop"></i>
		</a>
	</td>
</tr>
</table>
<!-- END OF TEMPLATE -->


<form action="/radio/save" method="post">
	<table class="table">
		<thead>
			<tr>
				<th>Radio name</th>
				<th>Stream</th>
				<th>Play</th>
				<th>Stop</th>
			</tr>
		</thead>
		<tbody id="radios">
			% for i, (name, stream) in enumerate(radios, 0):
			<tr>
				<td>
					<input type="text" name="name_{{i}}" value="{{name}}" class="name" />
				</td>
				<td>
					<input type="text" name="stream_{{i}}" value="{{stream}}" class="stream" />
				</td>
				<td>
					<a class="btn launch" href="/radio/play?stream=" title="Start">
						<i class="icon-play"></i>
					</a>
				</td>
				<td>
					<a class="btn launch" href="/radio/stop?stream=" title="Stop">
						<i class="icon-stop"></i>
					</a>
				</td>
			</tr>
			% end

		</tbody>
	</table>

	<div class="form-actions">
		<button type="submit" class="btn btn-primary">Save changes</button>
	</div>
</form>

<p>Note: If you want to <b>delete</b> a radio, just leave empty the Radio Name or the Strem.</p>
<p>See the <a href="/radio/install">instructions</a> on how to install/configure MPD/MPC.</p>

<br />

<script src="/static/js/radio.js"></script>
