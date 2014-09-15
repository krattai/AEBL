<?php
/**
 * Copyright (c) 2013 Robin Appelman <icewind@owncloud.com>
 * This file is licensed under the Affero General Public License version 3 or
 * later.
 * See the COPYING-README file.
 */

namespace Test\Files\Mount;

use \OC\Files\Storage\Temporary;

class LongId extends Temporary {
	public function getId() {
		return 'long:' . str_repeat('foo', 50) . parent::getId();
	}
}

class Manager extends \PHPUnit_Framework_TestCase {
	/**
	 * @var \OC\Files\Mount\Manager
	 */
	private $manager;

	public function setup() {
		$this->manager = new \OC\Files\Mount\Manager();
	}

	public function testFind() {
		$this->assertNull($this->manager->find('/'));

		$rootMount = new \OC\Files\Mount\Mount(new Temporary(array()), '/');
		$this->manager->addMount($rootMount);
		$this->assertEquals($rootMount, $this->manager->find('/'));
		$this->assertEquals($rootMount, $this->manager->find('/foo/bar'));

		$storage = new Temporary(array());
		$mount1 = new \OC\Files\Mount\Mount($storage, '/foo');
		$this->manager->addMount($mount1);
		$this->assertEquals($rootMount, $this->manager->find('/'));
		$this->assertEquals($mount1, $this->manager->find('/foo/bar'));

		$this->assertEquals(1, count($this->manager->findIn('/')));
		$mount2 = new \OC\Files\Mount\Mount(new Temporary(array()), '/bar');
		$this->manager->addMount($mount2);
		$this->assertEquals(2, count($this->manager->findIn('/')));

		$id = $mount1->getStorageId();
		$this->assertEquals(array($mount1), $this->manager->findByStorageId($id));

		$mount3 = new \OC\Files\Mount\Mount($storage, '/foo/bar');
		$this->manager->addMount($mount3);
		$this->assertEquals(array($mount1, $mount3), $this->manager->findByStorageId($id));
	}

	public function testLong() {
		$storage = new LongId(array());
		$mount = new \OC\Files\Mount\Mount($storage, '/foo');
		$this->manager->addMount($mount);

		$id = $mount->getStorageId();
		$storageId = $storage->getId();
		$this->assertEquals(array($mount), $this->manager->findByStorageId($id));
		$this->assertEquals(array($mount), $this->manager->findByStorageId($storageId));
		$this->assertEquals(array($mount), $this->manager->findByStorageId(md5($storageId)));
	}
}
