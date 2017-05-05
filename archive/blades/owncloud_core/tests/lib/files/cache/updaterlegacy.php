<?php
/**
 * Copyright (c) 2012 Robin Appelman <icewind@owncloud.com>
 * This file is licensed under the Affero General Public License version 3 or
 * later.
 * See the COPYING-README file.
 */

namespace Test\Files\Cache;

use \OC\Files\Filesystem as Filesystem;
use OC\Files\Storage\Temporary;

class UpdaterLegacy extends \PHPUnit_Framework_TestCase {
	/**
	 * @var \OC\Files\Storage\Storage $storage
	 */
	private $storage;

	/**
	 * @var \OC\Files\Cache\Scanner $scanner
	 */
	private $scanner;

	private $stateFilesEncryption;

	/**
	 * @var \OC\Files\Cache\Cache $cache
	 */
	private $cache;

	private static $user;

	public function setUp() {

		// remember files_encryption state
		$this->stateFilesEncryption = \OC_App::isEnabled('files_encryption');
		// we want to tests with the encryption app disabled
		\OC_App::disable('files_encryption');

		$this->storage = new \OC\Files\Storage\Temporary(array());
		$textData = "dummy file data\n";
		$imgData = file_get_contents(\OC::$SERVERROOT . '/core/img/logo.png');
		$this->storage->mkdir('folder');
		$this->storage->file_put_contents('foo.txt', $textData);
		$this->storage->file_put_contents('foo.png', $imgData);
		$this->storage->file_put_contents('folder/bar.txt', $textData);
		$this->storage->file_put_contents('folder/bar2.txt', $textData);

		$this->scanner = $this->storage->getScanner();
		$this->scanner->scan('');
		$this->cache = $this->storage->getCache();

		\OC\Files\Filesystem::tearDown();
		if (!self::$user) {
			self::$user = uniqid();
		}

		\OC_User::createUser(self::$user, 'password');
		\OC_User::setUserId(self::$user);

		\OC\Files\Filesystem::init(self::$user, '/' . self::$user . '/files');

		Filesystem::clearMounts();
		Filesystem::mount($this->storage, array(), '/' . self::$user . '/files');

		\OC_Hook::clear('OC_Filesystem');
	}

	public function tearDown() {
		if ($this->cache) {
			$this->cache->clear();
		}
		$result = \OC_User::deleteUser(self::$user);
		$this->assertTrue($result);
		Filesystem::tearDown();
		// reset app files_encryption
		if ($this->stateFilesEncryption) {
			\OC_App::enable('files_encryption');
		}
	}

	public function testWrite() {
		$textSize = strlen("dummy file data\n");
		$imageSize = filesize(\OC::$SERVERROOT . '/core/img/logo.png');
		$this->cache->put('foo.txt', array('mtime' => 100, 'storage_mtime' => 150));
		$rootCachedData = $this->cache->get('');
		$this->assertEquals(3 * $textSize + $imageSize, $rootCachedData['size']);

		$fooCachedData = $this->cache->get('foo.txt');
		Filesystem::file_put_contents('foo.txt', 'asd');
		$cachedData = $this->cache->get('foo.txt');
		$this->assertEquals(3, $cachedData['size']);
		$this->assertInternalType('string', $fooCachedData['etag']);
		$this->assertInternalType('string', $cachedData['etag']);
		$this->assertNotSame($fooCachedData['etag'], $cachedData['etag']);
		$cachedData = $this->cache->get('');
		$this->assertEquals(2 * $textSize + $imageSize + 3, $cachedData['size']);
		$this->assertInternalType('string', $rootCachedData['etag']);
		$this->assertInternalType('string', $cachedData['etag']);
		$this->assertNotSame($rootCachedData['etag'], $cachedData['etag']);
		$rootCachedData = $cachedData;

		$this->assertFalse($this->cache->inCache('bar.txt'));
		Filesystem::file_put_contents('bar.txt', 'asd');
		$this->assertTrue($this->cache->inCache('bar.txt'));
		$cachedData = $this->cache->get('bar.txt');
		$this->assertEquals(3, $cachedData['size']);
		$mtime = $cachedData['mtime'];
		$cachedData = $this->cache->get('');
		$this->assertEquals(2 * $textSize + $imageSize + 2 * 3, $cachedData['size']);
		$this->assertInternalType('string', $rootCachedData['etag']);
		$this->assertInternalType('string', $cachedData['etag']);
		$this->assertNotSame($rootCachedData['etag'], $cachedData['etag']);
		$this->assertGreaterThanOrEqual($rootCachedData['mtime'], $mtime);
	}

	public function testWriteWithMountPoints() {
		$storage2 = new \OC\Files\Storage\Temporary(array());
		$storage2->getScanner()->scan(''); //initialize etags
		$cache2 = $storage2->getCache();
		Filesystem::mount($storage2, array(), '/' . self::$user . '/files/folder/substorage');
		$folderCachedData = $this->cache->get('folder');
		$substorageCachedData = $cache2->get('');
		Filesystem::file_put_contents('folder/substorage/foo.txt', 'asd');
		$this->assertTrue($cache2->inCache('foo.txt'));
		$cachedData = $cache2->get('foo.txt');
		$this->assertEquals(3, $cachedData['size']);
		$mtime = $cachedData['mtime'];

		$cachedData = $cache2->get('');
		$this->assertInternalType('string', $substorageCachedData['etag']);
		$this->assertInternalType('string', $cachedData['etag']);
		$this->assertNotSame($substorageCachedData['etag'], $cachedData['etag']);

		$cachedData = $this->cache->get('folder');
		$this->assertInternalType('string', $folderCachedData['etag']);
		$this->assertInternalType('string', $cachedData['etag']);
		$this->assertNotSame($folderCachedData['etag'], $cachedData['etag']);
	}

	public function testDelete() {
		$textSize = strlen("dummy file data\n");
		$imageSize = filesize(\OC::$SERVERROOT . '/core/img/logo.png');
		$rootCachedData = $this->cache->get('');
		$this->assertEquals(3 * $textSize + $imageSize, $rootCachedData['size']);

		$this->assertTrue($this->cache->inCache('foo.txt'));
		Filesystem::unlink('foo.txt');
		$this->assertFalse($this->cache->inCache('foo.txt'));
		$cachedData = $this->cache->get('');
		$this->assertEquals(2 * $textSize + $imageSize, $cachedData['size']);
		$this->assertInternalType('string', $rootCachedData['etag']);
		$this->assertInternalType('string', $cachedData['etag']);
		$this->assertNotSame($rootCachedData['etag'], $cachedData['etag']);
		$this->assertGreaterThanOrEqual($rootCachedData['mtime'], $cachedData['mtime']);
		$rootCachedData = $cachedData;

		Filesystem::mkdir('bar_folder');
		$this->assertTrue($this->cache->inCache('bar_folder'));
		$cachedData = $this->cache->get('');
		$this->assertInternalType('string', $rootCachedData['etag']);
		$this->assertInternalType('string', $cachedData['etag']);
		$this->assertNotSame($rootCachedData['etag'], $cachedData['etag']);
		$rootCachedData = $cachedData;
		Filesystem::rmdir('bar_folder');
		$this->assertFalse($this->cache->inCache('bar_folder'));
		$cachedData = $this->cache->get('');
		$this->assertInternalType('string', $rootCachedData['etag']);
		$this->assertInternalType('string', $cachedData['etag']);
		$this->assertNotSame($rootCachedData['etag'], $cachedData['etag']);
		$this->assertGreaterThanOrEqual($rootCachedData['mtime'], $cachedData['mtime']);
	}

	public function testDeleteWithMountPoints() {
		$storage2 = new \OC\Files\Storage\Temporary(array());
		$cache2 = $storage2->getCache();
		Filesystem::mount($storage2, array(), '/' . self::$user . '/files/folder/substorage');
		Filesystem::file_put_contents('folder/substorage/foo.txt', 'asd');
		$this->assertTrue($cache2->inCache('foo.txt'));
		$folderCachedData = $this->cache->get('folder');
		$substorageCachedData = $cache2->get('');
		Filesystem::unlink('folder/substorage/foo.txt');
		$this->assertFalse($cache2->inCache('foo.txt'));

		$cachedData = $cache2->get('');
		$this->assertInternalType('string', $substorageCachedData['etag']);
		$this->assertInternalType('string', $cachedData['etag']);
		$this->assertNotSame($substorageCachedData['etag'], $cachedData['etag']);
		$this->assertGreaterThanOrEqual($substorageCachedData['mtime'], $cachedData['mtime']);

		$cachedData = $this->cache->get('folder');
		$this->assertInternalType('string', $folderCachedData['etag']);
		$this->assertInternalType('string', $cachedData['etag']);
		$this->assertNotSame($folderCachedData['etag'], $cachedData['etag']);
		$this->assertGreaterThanOrEqual($folderCachedData['mtime'], $cachedData['mtime']);
	}

	public function testRename() {
		$textSize = strlen("dummy file data\n");
		$imageSize = filesize(\OC::$SERVERROOT . '/core/img/logo.png');
		$rootCachedData = $this->cache->get('');
		$this->assertEquals(3 * $textSize + $imageSize, $rootCachedData['size']);

		$this->assertTrue($this->cache->inCache('foo.txt'));
		$fooCachedData = $this->cache->get('foo.txt');
		$this->assertFalse($this->cache->inCache('bar.txt'));
		Filesystem::rename('foo.txt', 'bar.txt');
		$this->assertFalse($this->cache->inCache('foo.txt'));
		$this->assertTrue($this->cache->inCache('bar.txt'));
		$cachedData = $this->cache->get('bar.txt');
		$this->assertEquals($fooCachedData['fileid'], $cachedData['fileid']);
		$mtime = $cachedData['mtime'];
		$cachedData = $this->cache->get('');
		$this->assertEquals(3 * $textSize + $imageSize, $cachedData['size']);
		$this->assertInternalType('string', $rootCachedData['etag']);
		$this->assertInternalType('string', $cachedData['etag']);
		$this->assertNotSame($rootCachedData['etag'], $cachedData['etag']);
	}

	public function testRenameExtension() {
		$fooCachedData = $this->cache->get('foo.txt');
		$this->assertEquals('text/plain', $fooCachedData['mimetype']);
		Filesystem::rename('foo.txt', 'foo.abcd');
		$fooCachedData = $this->cache->get('foo.abcd');
		$this->assertEquals('application/octet-stream', $fooCachedData['mimetype']);
	}

	public function testRenameWithMountPoints() {
		$storage2 = new \OC\Files\Storage\Temporary(array());
		$cache2 = $storage2->getCache();
		Filesystem::mount($storage2, array(), '/' . self::$user . '/files/folder/substorage');
		Filesystem::file_put_contents('folder/substorage/foo.txt', 'asd');
		$this->assertTrue($cache2->inCache('foo.txt'));
		$folderCachedData = $this->cache->get('folder');
		$substorageCachedData = $cache2->get('');
		$fooCachedData = $cache2->get('foo.txt');
		Filesystem::rename('folder/substorage/foo.txt', 'folder/substorage/bar.txt');
		$this->assertFalse($cache2->inCache('foo.txt'));
		$this->assertTrue($cache2->inCache('bar.txt'));
		$cachedData = $cache2->get('bar.txt');
		$this->assertEquals($fooCachedData['fileid'], $cachedData['fileid']);
		$mtime = $cachedData['mtime'];

		$cachedData = $cache2->get('');
		$this->assertInternalType('string', $substorageCachedData['etag']);
		$this->assertInternalType('string', $cachedData['etag']);
		$this->assertNotSame($substorageCachedData['etag'], $cachedData['etag']);
		// rename can cause mtime change - invalid assert
//		$this->assertEquals($mtime, $cachedData['mtime']);

		$cachedData = $this->cache->get('folder');
		$this->assertInternalType('string', $folderCachedData['etag']);
		$this->assertInternalType('string', $cachedData['etag']);
		$this->assertNotSame($folderCachedData['etag'], $cachedData['etag']);
		// rename can cause mtime change - invalid assert
//		$this->assertEquals($mtime, $cachedData['mtime']);
	}

	public function testTouch() {
		$rootCachedData = $this->cache->get('');
		$fooCachedData = $this->cache->get('foo.txt');
		Filesystem::touch('foo.txt');
		$cachedData = $this->cache->get('foo.txt');
		$this->assertInternalType('string', $fooCachedData['etag']);
		$this->assertInternalType('string', $cachedData['etag']);
		$this->assertGreaterThanOrEqual($fooCachedData['mtime'], $cachedData['mtime']);

		$cachedData = $this->cache->get('');
		$this->assertInternalType('string', $rootCachedData['etag']);
		$this->assertInternalType('string', $cachedData['etag']);
		$this->assertNotSame($rootCachedData['etag'], $cachedData['etag']);
		$this->assertGreaterThanOrEqual($rootCachedData['mtime'], $cachedData['mtime']);
		$rootCachedData = $cachedData;

		$time = 1371006070;
		$barCachedData = $this->cache->get('folder/bar.txt');
		$folderCachedData = $this->cache->get('folder');
		Filesystem::touch('folder/bar.txt', $time);
		$cachedData = $this->cache->get('folder/bar.txt');
		$this->assertInternalType('string', $barCachedData['etag']);
		$this->assertInternalType('string', $cachedData['etag']);
		$this->assertNotSame($barCachedData['etag'], $cachedData['etag']);
		$this->assertEquals($time, $cachedData['mtime']);

		$cachedData = $this->cache->get('folder');
		$this->assertInternalType('string', $folderCachedData['etag']);
		$this->assertInternalType('string', $cachedData['etag']);
		$this->assertNotSame($folderCachedData['etag'], $cachedData['etag']);

		$cachedData = $this->cache->get('');
		$this->assertInternalType('string', $rootCachedData['etag']);
		$this->assertInternalType('string', $cachedData['etag']);
		$this->assertNotSame($rootCachedData['etag'], $cachedData['etag']);
		$this->assertEquals($time, $cachedData['mtime']);
	}

	public function testTouchWithMountPoints() {
		$storage2 = new \OC\Files\Storage\Temporary(array());
		$cache2 = $storage2->getCache();
		Filesystem::mount($storage2, array(), '/' . self::$user . '/files/folder/substorage');
		Filesystem::file_put_contents('folder/substorage/foo.txt', 'asd');
		$this->assertTrue($cache2->inCache('foo.txt'));
		$folderCachedData = $this->cache->get('folder');
		$substorageCachedData = $cache2->get('');
		$fooCachedData = $cache2->get('foo.txt');
		$cachedData = $cache2->get('foo.txt');
		$time = 1371006070;
		Filesystem::touch('folder/substorage/foo.txt', $time);
		$cachedData = $cache2->get('foo.txt');
		$this->assertInternalType('string', $fooCachedData['etag']);
		$this->assertInternalType('string', $cachedData['etag']);
		$this->assertNotSame($fooCachedData['etag'], $cachedData['etag']);
		$this->assertEquals($time, $cachedData['mtime']);

		$cachedData = $cache2->get('');
		$this->assertInternalType('string', $substorageCachedData['etag']);
		$this->assertInternalType('string', $cachedData['etag']);
		$this->assertNotSame($substorageCachedData['etag'], $cachedData['etag']);

		$cachedData = $this->cache->get('folder');
		$this->assertInternalType('string', $folderCachedData['etag']);
		$this->assertInternalType('string', $cachedData['etag']);
		$this->assertNotSame($folderCachedData['etag'], $cachedData['etag']);
		$this->assertEquals($time, $cachedData['mtime']);
	}

}
