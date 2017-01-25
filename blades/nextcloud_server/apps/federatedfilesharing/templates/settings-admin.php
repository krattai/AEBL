<?php
/** @var \OCP\IL10N $l */
/** @var array $_ */
script('federatedfilesharing', 'settings-admin');
?>

<div id="fileSharingSettings" class="followupsection">
	<h3><?php p($l->t('Federated Cloud Sharing'));?></h3>
	<a target="_blank" rel="noreferrer" class="icon-info svg"
		title="<?php p($l->t('Open documentation'));?>"
		href="<?php p(link_to_docs('admin-sharing-federated')); ?>"></a>

	<p>
		<input type="checkbox" name="outgoing_server2server_share_enabled" id="outgoingServer2serverShareEnabled" class="checkbox"
			   value="1" <?php if ($_['outgoingServer2serverShareEnabled']) print_unescaped('checked="checked"'); ?> />
		<label for="outgoingServer2serverShareEnabled">
			<?php p($l->t('Allow users on this server to send shares to other servers'));?>
		</label>
	</p>

	<p>
		<input type="checkbox" name="incoming_server2server_share_enabled" id="incomingServer2serverShareEnabled" class="checkbox"
			   value="1" <?php if ($_['incomingServer2serverShareEnabled']) print_unescaped('checked="checked"'); ?> />
		<label for="incomingServer2serverShareEnabled">
			<?php p($l->t('Allow users on this server to receive shares from other servers'));?>
		</label><br/>
	</p>
	<p>
		<input type="checkbox" name="lookupServerEnabled" id="lookupServerEnabled" class="checkbox"
			   value="1" <?php if ($_['lookupServerEnabled']) print_unescaped('checked="checked"'); ?> />
		<label for="lookupServerEnabled">
			<?php p($l->t('Search global and public address book for users'));?>
		</label><br/>
	</p>
</div>
