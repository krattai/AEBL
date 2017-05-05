<?php
/**
 * @copyright Copyright (c) 2016 Lukas Reschke <lukas@statuscode.ch>
 *
 * @license GNU AGPL version 3 or any later version
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

namespace OCA\User_LDAP\Tests;

use OCA\User_LDAP\ILDAPWrapper;
use OCA\User_LDAP\User_Proxy;
use OCP\IConfig;
use Test\TestCase;

class User_ProxyTest extends TestCase  {
	/** @var ILDAPWrapper|\PHPUnit_Framework_MockObject_MockObject */
	private $ldapWrapper;
	/** @var IConfig|\PHPUnit_Framework_MockObject_MockObject */
	private $config;
	/** @var User_Proxy|\PHPUnit_Framework_MockObject_MockObject */
	private $proxy;

	public function setUp() {
		parent::setUp();

		$this->ldapWrapper = $this->createMock(ILDAPWrapper::class);
		$this->config = $this->createMock(IConfig::class);
		$this->proxy = $this->getMockBuilder(User_Proxy::class)
			->setConstructorArgs([
				[],
				$this->ldapWrapper,
				$this->config,
			])
			->setMethods(['handleRequest'])
			->getMock();
	}

	public function testSetPassword() {
		$this->proxy
			->expects($this->once())
			->method('handleRequest')
			->with('MyUid', 'setPassword', ['MyUid', 'MyPassword'])
			->willReturn(true);

		$this->assertTrue($this->proxy->setPassword('MyUid', 'MyPassword'));
	}
}
