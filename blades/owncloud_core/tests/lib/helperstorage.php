<?php
/**
 * Copyright (c) 2014 Vincent Petry <pvince81@owncloud.com>
 * This file is licensed under the Affero General Public License version 3 or
 * later.
 * See the COPYING-README file.
 */

/**
 * Test the storage functions of OC_Helper
 */
class Test_Helper_Storage extends PHPUnit_Framework_TestCase {
	private $user;
	private $storageMock;

	public function setUp() {
		$this->user = 'user_' . uniqid();
		\OC_User::createUser($this->user, $this->user);

		\OC\Files\Filesystem::tearDown();
		\OC_User::setUserId($this->user);
		\OC\Files\Filesystem::init($this->user, '/' . $this->user . '/files');
		\OC\Files\Filesystem::clearMounts();

		$this->storageMock = null;
	}

	public function tearDown() {
		$this->user = null;

		if ($this->storageMock) {
			$this->storageMock->getCache()->clear();
			$this->storageMock = null;
		}
		\OC\Files\Filesystem::tearDown();

		\OC_User::setUserId('');
		\OC_User::deleteUser($this->user);
		\OC_Preferences::deleteUser($this->user);
	}

	/**
	 * Returns a storage mock that returns the given value as
	 * free space
	 *
	 * @param int $freeSpace free space value
	 * @return \OC\Files\Storage\Storage
	 */
	private function getStorageMock($freeSpace = 12) {
		$this->storageMock = $this->getMock(
			'\OC\Files\Storage\Temporary',
			array('free_space'),
			array('')
		);


		$this->storageMock->expects($this->once())
			->method('free_space')
			->will($this->returnValue(12));
		return $this->storageMock;
	}

	/**
	 * Test getting the storage info
	 */
	function testGetStorageInfo() {
		$homeStorage = $this->getStorageMock(12);
		\OC\Files\Filesystem::mount($homeStorage, array(), '/' . $this->user . '/files');
		$homeStorage->file_put_contents('test.txt', '01234');

		$storageInfo = \OC_Helper::getStorageInfo('');
		$this->assertEquals(12, $storageInfo['free']);
		$this->assertEquals(5, $storageInfo['used']);
		$this->assertEquals(17, $storageInfo['total']);
	}

	/**
	 * Test getting the storage info, ignoring extra mount points
	 */
	function testGetStorageInfoExcludingExtStorage() {
		$homeStorage = $this->getStorageMock(12);
		\OC\Files\Filesystem::mount($homeStorage, array(), '/' . $this->user . '/files');
		$homeStorage->file_put_contents('test.txt', '01234');

		$extStorage = new \OC\Files\Storage\Temporary(array());
		$extStorage->file_put_contents('extfile.txt', 'abcdefghijklmnopq');
		$extStorage->getScanner()->scan(''); // update root size

		\OC\Files\Filesystem::mount($extStorage, array(), '/' . $this->user . '/files/ext');

		$storageInfo = \OC_Helper::getStorageInfo('');
		$this->assertEquals(12, $storageInfo['free']);
		$this->assertEquals(5, $storageInfo['used']);
		$this->assertEquals(17, $storageInfo['total']);
	}

	/**
	 * Test getting the storage info, including extra mount points
	 */
	function testGetStorageInfoIncludingExtStorage() {
		$homeStorage = new \OC\Files\Storage\Temporary(array());
		\OC\Files\Filesystem::mount($homeStorage, array(), '/' . $this->user . '/files');
		$homeStorage->file_put_contents('test.txt', '01234');

		$extStorage = new \OC\Files\Storage\Temporary(array());
		$extStorage->file_put_contents('extfile.txt', 'abcdefghijklmnopq');
		$extStorage->getScanner()->scan(''); // update root size

		\OC\Files\Filesystem::mount($extStorage, array(), '/' . $this->user . '/files/ext');

		$oldConfig = \OC_Config::getValue('quota_include_external_storage', false);
		\OC_Config::setValue('quota_include_external_storage', 'true');

		$config = \OC::$server->getConfig();
		$userQuota = $config->setUserValue($this->user, 'files', 'quota', '25');

		$storageInfo = \OC_Helper::getStorageInfo('');
		$this->assertEquals(3, $storageInfo['free']);
		$this->assertEquals(22, $storageInfo['used']);
		$this->assertEquals(25, $storageInfo['total']);

		\OC_Config::setValue('quota_include_external_storage', $oldConfig);
		$userQuota = $config->setUserValue($this->user, 'files', 'quota', 'default');
	}

	/**
	 * Test getting the storage info excluding extra mount points
	 * when user has no quota set, even when quota ext storage option
	 * was set
	 */
	function testGetStorageInfoIncludingExtStorageWithNoUserQuota() {
		$homeStorage = $this->getStorageMock(12);
		\OC\Files\Filesystem::mount($homeStorage, array(), '/' . $this->user . '/files');
		$homeStorage->file_put_contents('test.txt', '01234');

		$extStorage = new \OC\Files\Storage\Temporary(array());
		$extStorage->file_put_contents('extfile.txt', 'abcdefghijklmnopq');
		$extStorage->getScanner()->scan(''); // update root size

		\OC\Files\Filesystem::mount($extStorage, array(), '/' . $this->user . '/files/ext');

		$oldConfig = \OC_Config::getValue('quota_include_external_storage', false);
		\OC_Config::setValue('quota_include_external_storage', 'true');

		$storageInfo = \OC_Helper::getStorageInfo('');
		$this->assertEquals(12, $storageInfo['free']);
		$this->assertEquals(5, $storageInfo['used']);
		$this->assertEquals(17, $storageInfo['total']);

		\OC_Config::setValue('quota_include_external_storage', $oldConfig);
	}


	/**
	 * Test getting the storage info with quota enabled
	 */
	function testGetStorageInfoWithQuota() {
		$homeStorage = $this->getStorageMock(12);
		$homeStorage->file_put_contents('test.txt', '01234');
		$homeStorage = new \OC\Files\Storage\Wrapper\Quota(
			array(
				'storage' => $homeStorage,
				'quota' => 7
			)
		);
		\OC\Files\Filesystem::mount($homeStorage, array(), '/' . $this->user . '/files');

		$storageInfo = \OC_Helper::getStorageInfo('');
		$this->assertEquals(2, $storageInfo['free']);
		$this->assertEquals(5, $storageInfo['used']);
		$this->assertEquals(7, $storageInfo['total']);
	}

	/**
	 * Test getting the storage info when data exceeds quota
	 */
	function testGetStorageInfoWhenSizeExceedsQuota() {
		$homeStorage = $this->getStorageMock(12);
		$homeStorage->file_put_contents('test.txt', '0123456789');
		$homeStorage = new \OC\Files\Storage\Wrapper\Quota(
			array(
				'storage' => $homeStorage,
				'quota' => 7
			)
		);
		\OC\Files\Filesystem::mount($homeStorage, array(), '/' . $this->user . '/files');

		$storageInfo = \OC_Helper::getStorageInfo('');
		$this->assertEquals(0, $storageInfo['free']);
		$this->assertEquals(10, $storageInfo['used']);
		// total = quota
		$this->assertEquals(7, $storageInfo['total']);
	}

	/**
	 * Test getting the storage info when the remaining
	 * free storage space is less than the quota
	 */
	function testGetStorageInfoWhenFreeSpaceLessThanQuota() {
		$homeStorage = $this->getStorageMock(12);
		$homeStorage->file_put_contents('test.txt', '01234');
		$homeStorage = new \OC\Files\Storage\Wrapper\Quota(
			array(
				'storage' => $homeStorage,
				'quota' => 18
			)
		);
		\OC\Files\Filesystem::mount($homeStorage, array(), '/' . $this->user . '/files');

		$storageInfo = \OC_Helper::getStorageInfo('');
		$this->assertEquals(12, $storageInfo['free']);
		$this->assertEquals(5, $storageInfo['used']);
		// total = free + used (because quota > total)
		$this->assertEquals(17, $storageInfo['total']);
	}
}
