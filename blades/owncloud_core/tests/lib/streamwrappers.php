<?php
/**
 * ownCloud
 *
 * @author Robin Appelman
 * @copyright 2012 Robin Appelman icewind@owncloud.com
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU AFFERO GENERAL PUBLIC LICENSE
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU AFFERO GENERAL PUBLIC LICENSE for more details.
 *
 * You should have received a copy of the GNU Affero General Public
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

class Test_StreamWrappers extends PHPUnit_Framework_TestCase {
	public function testFakeDir() {
		$items = array('foo', 'bar');
		\OC\Files\Stream\Dir::register('test', $items);
		$dh = opendir('fakedir://test');
		$result = array();
		while ($file = readdir($dh)) {
			$result[] = $file;
			$this->assertContains($file, $items);
		}
		$this->assertEquals(count($items), count($result));
	}

	public function testCloseStream() {
		//ensure all basic stream stuff works
		$sourceFile = OC::$SERVERROOT . '/tests/data/lorem.txt';
		$tmpFile = OC_Helper::TmpFile('.txt');
		$file = 'close://' . $tmpFile;
		$this->assertTrue(file_exists($file));
		file_put_contents($file, file_get_contents($sourceFile));
		$this->assertEquals(file_get_contents($sourceFile), file_get_contents($file));
		unlink($file);
		clearstatcache();
		$this->assertFalse(file_exists($file));

		//test callback
		$tmpFile = OC_Helper::TmpFile('.txt');
		$file = 'close://' . $tmpFile;
		\OC\Files\Stream\Close::registerCallback($tmpFile, array('Test_StreamWrappers', 'closeCallBack'));
		$fh = fopen($file, 'w');
		fwrite($fh, 'asd');
		try {
			fclose($fh);
			$this->fail('Expected exception');
		} catch (Exception $e) {
			$path = $e->getMessage();
			$this->assertEquals($path, $tmpFile);
		}
	}

	public static function closeCallBack($path) {
		throw new Exception($path);
	}

	public function testOC() {
		\OC\Files\Filesystem::clearMounts();
		$storage = new \OC\Files\Storage\Temporary(array());
		$storage->file_put_contents('foo.txt', 'asd');
		\OC\Files\Filesystem::mount($storage, array(), '/');

		$this->assertTrue(file_exists('oc:///foo.txt'));
		$this->assertEquals('asd', file_get_contents('oc:///foo.txt'));
		$this->assertEquals(array('.', '..', 'foo.txt'), scandir('oc:///'));

		file_put_contents('oc:///bar.txt', 'qwerty');
		$this->assertEquals('qwerty', $storage->file_get_contents('bar.txt'));
		$this->assertEquals(array('.', '..', 'bar.txt', 'foo.txt'), scandir('oc:///'));
		$this->assertEquals('qwerty', file_get_contents('oc:///bar.txt'));

		unlink('oc:///foo.txt');
		$this->assertEquals(array('.', '..', 'bar.txt'), scandir('oc:///'));
	}
}
