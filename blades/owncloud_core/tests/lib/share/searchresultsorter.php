<?php
/**
* ownCloud
*
* @author Arthur Schiwon
* @copyright 2014 Arthur Schiwon <blizzz@owncloud.com>
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
*/

class Test_Share_Search extends \PHPUnit_Framework_TestCase {
	public function testSort() {
		$search = 'lin';
		$sorter = new \OC\Share\SearchResultSorter($search, 'foobar');

		$result = array(
			array('foobar' => 'woot'),
			array('foobar' => 'linux'),
			array('foobar' => 'Linus'),
			array('foobar' => 'Bicyclerepairwoman'),
		);

		usort($result, array($sorter, 'sort'));
		$this->assertTrue($result[0]['foobar'] === 'Linus');
		$this->assertTrue($result[1]['foobar'] === 'linux');
		$this->assertTrue($result[2]['foobar'] === 'Bicyclerepairwoman');
		$this->assertTrue($result[3]['foobar'] === 'woot');
	}

	/**
     * @expectedException PHPUnit_Framework_Error
     */
	public function testSortWrongLog() {
		$sorter = new \OC\Share\SearchResultSorter('foo', 'bar', 'UTF-8', 'foobar');
	}
}
