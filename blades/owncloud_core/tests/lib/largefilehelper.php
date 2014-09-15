<?php
/**
 * Copyright (c) 2014 Andreas Fischer <bantu@owncloud.com>
 * This file is licensed under the Affero General Public License version 3 or
 * later.
 * See the COPYING-README file.
 */

namespace Test;

class LargeFileHelper extends \PHPUnit_Framework_TestCase {
	protected $helper;

	public function setUp() {
		parent::setUp();
		$this->helper = new \OC\LargeFileHelper;
	}

	public function testFormatUnsignedIntegerFloat() {
		$this->assertSame(
			'9007199254740992',
			$this->helper->formatUnsignedInteger((float) 9007199254740992)
		);
	}

	public function testFormatUnsignedIntegerInt() {
		$this->assertSame(
			PHP_INT_SIZE === 4 ? '4294967295' : '18446744073709551615',
			$this->helper->formatUnsignedInteger(-1)
		);
	}

	public function testFormatUnsignedIntegerString() {
		$this->assertSame(
			'9007199254740993',
			$this->helper->formatUnsignedInteger('9007199254740993')
		);
	}

	/**
	* @expectedException \UnexpectedValueException
	*/
	public function testFormatUnsignedIntegerStringException() {
		$this->helper->formatUnsignedInteger('900ABCD254740993');
	}
}
