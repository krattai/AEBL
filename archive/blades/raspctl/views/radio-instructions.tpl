%rebase base

<p><a href="http://en.wikipedia.org/wiki/Wikipedia:Too_long;_didn't_read">TL;DR</a>: You must
manually install mpd and mpc packaged and configure mpd to work with 'pulse'.</p>

<h1>Introduction</h1>
<p>The thing is that I'm using MPD (Media Player Daemon) for play music in the server side. But I didn't want to include this package as dependency of RaspCTL because maybe
there are people that don't need/want to play music on the Pi. <b>And that's why, if you want to use the
radio (that is pretty cool), you must install MPD by yourself.</b></p>

<p><b>You have a RPi for learning new things, right? If you are a newbe I'll try to teach you about
some things about daemons, configuration files, etc</b> I hope you learn something during the process.
If you already know how to install and configure stuff on GNU/Linux just execute the commands in the boxes.</p>

<h2>Install</h2>

<h3>Packets</h3>
<p>Basically we need to install MPD (Media Player Daemon) and MPC (Media Player Client). We'll use
"aptitude" but "apt-get" would do the job, too. <b>Aptitude and apt-get are packet managers and will download the packet and all
its depencencies and will install everything</b>. The "-y" parameter is the same as "--assume-yes" parameter
and it means that if a question is asked (such as DO YOU WANT TO INSTALL ALL THE REQUIRED DEPENDENCIES?)
the answer to this question will be YES, I DO. <b>You can find extra information about almost any any command
by reading its manual. You can do that typing "man &lt;command&gt;"</b>, in this case would be "man aptitude"
(for quitting the manual, press the key "q"). </p>

<pre class="code">
sudo aptitude install -y mpd mpc
</pre>

<h3>Configuration</h3>

<p>Usually all the programs you install have configuration files. This files can be in a diferent locations
but <b>if you have installed a daemon, usually the configuration files are in /etc/{name_of_the_package}</b>.</p>

<p>Oh. You don't know what a <b>daemon</b> is? <b>A daemon is basically a program like all the others but that is
running always in background, and don't have a user interface</b>. If you come from Windows you may ask: why in hell
I want a program running in background and without UI? The answer is simple: all the servers work this way. A web
server, a FTP server, mail server, music server (like in this case).... the examples are endless. The question would
be: why on hell do you want a web server running as a regular command (aka if you close the console, the server stops)
and with a graphical user interface? Nhá, there is no need for that.</p>

<p>But if the process is in background how do you configure it and start stop it? The configuration, as I said, is made
thru configuration that usually are in <i>/etc/{name_of_the_package</i>. And <b>for starting/stoping the daemons you must
go to <i>/etc/init.d/{name_of_the_package} {action}</i> where {action} can be start/stop/restart/....</b> If you want to
see all the parameters you can pass to the daemon, just leave the {action} empty and probably the package will tell you
what the options are.</p>

<p>In our case we must configure the file <i>/etc/mpd.conf</i>. I'll use "vim" as editor, but you should use the
editor of your choice (vim can be pretty hard to use):</p>

<pre class="code">
sudo vim /etc/mpd.conf
</pre>

<p>And around the line 200 we will find something like:</p>

<pre class="code">
audio_output {
	type		"alsa"
	name		"My ALSA Device"
	device		"hw:0,0"	# optional
	format		"44100:16:2"	# optional
	mixer_device	"default"	# optional
	mixer_control	"PCM"		# optional
	mixer_index	"0"		# optional
}
</pre>

<p>And this block must be commented and we will add other entry at the top:</p>

<pre class="code">
audio_output {
	type "pulse"
	name "My MPD PulseAudio Output"
}

#audio_output {
#	type		"alsa"
#	name		"My ALSA Device"
#	device		"hw:0,0"	# optional
#	format		"44100:16:2"	# optional
#	mixer_device	"default"	# optional
#	mixer_control	"PCM"		# optional
#	mixer_index	"0"		# optional
#}
</pre>

<p>Now save the file.</p>

<h3>Restarting</h3>
<p>As we have commented before, we need to restart the service now in order to make effective the changes
we have made in the configuration file. We can do that just by executing this command:</p>
<pre class="code">
sudo /etc/init.d/mpd restart
</pre>

<p>Of course, you can use the <a href="/services">Services</a> Tab, too, and click on the button Restart. It
does exactly the same job.</p>

<p><b>Now you have installed and configured both programs, you can click on the Radio tab in the Menu, and you
should be able to add radios, and play them.</b></p>
<br />

