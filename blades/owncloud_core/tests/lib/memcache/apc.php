<?php

/**
 * Copyright (c) 2013 Robin Appelman <icewind@owncloud.com>
 * This file is licensed under the Affero General Public License version 3 or
 * later.
 * See the COPYING-README file.
 */

namespace Test\Memcache;

class APC extends Cache {
	public function setUp() {
		if(!\OC\Memcache\APC::isAvailable()) {
			$this->markTestSkipped('The apc extension is not available.');
			return;
		}
		if(\OC\Memcache\APCu::isAvailable()) {
			$this->markTestSkipped('The apc extension is emulated by ACPu.');
			return;
		}
		$this->instance=new \OC\Memcache\APC(uniqid());
	}
}
