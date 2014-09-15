<?php

/**
 * Copyright (c) 2013 Robin Appelman <icewind@owncloud.com>
 * This file is licensed under the Affero General Public License version 3 or
 * later.
 * See the COPYING-README file.
 */

namespace Test\User;

class Manager extends \PHPUnit_Framework_TestCase {
	public function testUserExistsSingleBackendExists() {
		/**
		 * @var \OC_User_Dummy | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->getMock('\OC_User_Dummy');
		$backend->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(true));

		$manager = new \OC\User\Manager();
		$manager->registerBackend($backend);

		$this->assertTrue($manager->userExists('foo'));
	}

	public function testUserExistsSingleBackendNotExists() {
		/**
		 * @var \OC_User_Dummy | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->getMock('\OC_User_Dummy');
		$backend->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(false));

		$manager = new \OC\User\Manager();
		$manager->registerBackend($backend);

		$this->assertFalse($manager->userExists('foo'));
	}

	public function testUserExistsNoBackends() {
		$manager = new \OC\User\Manager();

		$this->assertFalse($manager->userExists('foo'));
	}

	public function testUserExistsTwoBackendsSecondExists() {
		/**
		 * @var \OC_User_Dummy | \PHPUnit_Framework_MockObject_MockObject $backend1
		 */
		$backend1 = $this->getMock('\OC_User_Dummy');
		$backend1->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(false));

		/**
		 * @var \OC_User_Dummy | \PHPUnit_Framework_MockObject_MockObject $backend2
		 */
		$backend2 = $this->getMock('\OC_User_Dummy');
		$backend2->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(true));

		$manager = new \OC\User\Manager();
		$manager->registerBackend($backend1);
		$manager->registerBackend($backend2);

		$this->assertTrue($manager->userExists('foo'));
	}

	public function testUserExistsTwoBackendsFirstExists() {
		/**
		 * @var \OC_User_Dummy | \PHPUnit_Framework_MockObject_MockObject $backend1
		 */
		$backend1 = $this->getMock('\OC_User_Dummy');
		$backend1->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(true));

		/**
		 * @var \OC_User_Dummy | \PHPUnit_Framework_MockObject_MockObject $backend2
		 */
		$backend2 = $this->getMock('\OC_User_Dummy');
		$backend2->expects($this->never())
			->method('userExists');

		$manager = new \OC\User\Manager();
		$manager->registerBackend($backend1);
		$manager->registerBackend($backend2);

		$this->assertTrue($manager->userExists('foo'));
	}

	public function testCheckPassword() {
		/**
		 * @var \OC_User_Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->getMock('\OC_User_Dummy');
		$backend->expects($this->once())
			->method('checkPassword')
			->with($this->equalTo('foo'), $this->equalTo('bar'))
			->will($this->returnValue(true));

		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnCallback(function ($actions) {
				if ($actions === \OC_USER_BACKEND_CHECK_PASSWORD) {
					return true;
				} else {
					return false;
				}
			}));

		$manager = new \OC\User\Manager();
		$manager->registerBackend($backend);

		$user = $manager->checkPassword('foo', 'bar');
		$this->assertTrue($user instanceof \OC\User\User);
	}

	public function testCheckPasswordNotSupported() {
		/**
		 * @var \OC_User_Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->getMock('\OC_User_Dummy');
		$backend->expects($this->never())
			->method('checkPassword');

		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnValue(false));

		$manager = new \OC\User\Manager();
		$manager->registerBackend($backend);

		$this->assertFalse($manager->checkPassword('foo', 'bar'));
	}

	public function testGetOneBackendExists() {
		/**
		 * @var \OC_User_Dummy | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->getMock('\OC_User_Dummy');
		$backend->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(true));

		$manager = new \OC\User\Manager();
		$manager->registerBackend($backend);

		$this->assertEquals('foo', $manager->get('foo')->getUID());
	}

	public function testGetOneBackendNotExists() {
		/**
		 * @var \OC_User_Dummy | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->getMock('\OC_User_Dummy');
		$backend->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(false));

		$manager = new \OC\User\Manager();
		$manager->registerBackend($backend);

		$this->assertEquals(null, $manager->get('foo'));
	}

	public function testSearchOneBackend() {
		/**
		 * @var \OC_User_Dummy | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->getMock('\OC_User_Dummy');
		$backend->expects($this->once())
			->method('getUsers')
			->with($this->equalTo('fo'))
			->will($this->returnValue(array('foo', 'afoo')));

		$manager = new \OC\User\Manager();
		$manager->registerBackend($backend);

		$result = $manager->search('fo');
		$this->assertEquals(2, count($result));
		$this->assertEquals('afoo', array_shift($result)->getUID());
		$this->assertEquals('foo', array_shift($result)->getUID());
	}

	public function testSearchTwoBackendLimitOffset() {
		/**
		 * @var \OC_User_Dummy | \PHPUnit_Framework_MockObject_MockObject $backend1
		 */
		$backend1 = $this->getMock('\OC_User_Dummy');
		$backend1->expects($this->once())
			->method('getUsers')
			->with($this->equalTo('fo'), $this->equalTo(3), $this->equalTo(1))
			->will($this->returnValue(array('foo1', 'foo2')));

		/**
		 * @var \OC_User_Dummy | \PHPUnit_Framework_MockObject_MockObject $backend2
		 */
		$backend2 = $this->getMock('\OC_User_Dummy');
		$backend2->expects($this->once())
			->method('getUsers')
			->with($this->equalTo('fo'), $this->equalTo(3), $this->equalTo(1))
			->will($this->returnValue(array('foo3')));

		$manager = new \OC\User\Manager();
		$manager->registerBackend($backend1);
		$manager->registerBackend($backend2);

		$result = $manager->search('fo', 3, 1);
		$this->assertEquals(3, count($result));
		$this->assertEquals('foo1', array_shift($result)->getUID());
		$this->assertEquals('foo2', array_shift($result)->getUID());
		$this->assertEquals('foo3', array_shift($result)->getUID());
	}

	public function testCreateUserSingleBackendNotExists() {
		/**
		 * @var \OC_User_Dummy | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->getMock('\OC_User_Dummy');
		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnValue(true));

		$backend->expects($this->once())
			->method('createUser')
			->with($this->equalTo('foo'), $this->equalTo('bar'));

		$backend->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(false));

		$manager = new \OC\User\Manager();
		$manager->registerBackend($backend);

		$user = $manager->createUser('foo', 'bar');
		$this->assertEquals('foo', $user->getUID());
	}

	/**
	 * @expectedException \Exception
	 */
	public function testCreateUserSingleBackendExists() {
		/**
		 * @var \OC_User_Dummy | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->getMock('\OC_User_Dummy');
		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnValue(true));

		$backend->expects($this->never())
			->method('createUser');

		$backend->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(true));

		$manager = new \OC\User\Manager();
		$manager->registerBackend($backend);

		$manager->createUser('foo', 'bar');
	}

	public function testCreateUserSingleBackendNotSupported() {
		/**
		 * @var \OC_User_Dummy | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->getMock('\OC_User_Dummy');
		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnValue(false));

		$backend->expects($this->never())
			->method('createUser');

		$backend->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(false));

		$manager = new \OC\User\Manager();
		$manager->registerBackend($backend);

		$this->assertFalse($manager->createUser('foo', 'bar'));
	}

	public function testCreateUserNoBackends() {
		$manager = new \OC\User\Manager();

		$this->assertFalse($manager->createUser('foo', 'bar'));
	}

	/**
	 * @expectedException \Exception
	 */
	public function testCreateUserTwoBackendExists() {
		/**
		 * @var \OC_User_Dummy | \PHPUnit_Framework_MockObject_MockObject $backend1
		 */
		$backend1 = $this->getMock('\OC_User_Dummy');
		$backend1->expects($this->any())
			->method('implementsActions')
			->will($this->returnValue(true));

		$backend1->expects($this->never())
			->method('createUser');

		$backend1->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(false));

		/**
		 * @var \OC_User_Dummy | \PHPUnit_Framework_MockObject_MockObject $backend2
		 */
		$backend2 = $this->getMock('\OC_User_Dummy');
		$backend2->expects($this->any())
			->method('implementsActions')
			->will($this->returnValue(true));

		$backend2->expects($this->never())
			->method('createUser');

		$backend2->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(true));

		$manager = new \OC\User\Manager();
		$manager->registerBackend($backend1);
		$manager->registerBackend($backend2);

		$manager->createUser('foo', 'bar');
	}

	public function testCountUsersNoBackend() {
		$manager = new \OC\User\Manager();

		$result = $manager->countUsers();
		$this->assertTrue(is_array($result));
		$this->assertTrue(empty($result));
	}

	public function testCountUsersOneBackend() {
		/**
		 * @var \OC_User_Dummy | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->getMock('\OC_User_Dummy');
		$backend->expects($this->once())
			->method('countUsers')
			->will($this->returnValue(7));

		$backend->expects($this->once())
			->method('implementsActions')
			->with(\OC_USER_BACKEND_COUNT_USERS)
			->will($this->returnValue(true));

		$manager = new \OC\User\Manager();
		$manager->registerBackend($backend);

		$result = $manager->countUsers();
		$keys = array_keys($result);
		$this->assertTrue(strpos($keys[0], 'Mock_OC_User_Dummy') !== false);

		$users = array_shift($result);
		$this->assertEquals(7, $users);
	}

	public function testCountUsersTwoBackends() {
		/**
		 * @var \OC_User_Dummy | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend1 = $this->getMock('\OC_User_Dummy');
		$backend1->expects($this->once())
			->method('countUsers')
			->will($this->returnValue(7));

		$backend1->expects($this->once())
			->method('implementsActions')
			->with(\OC_USER_BACKEND_COUNT_USERS)
			->will($this->returnValue(true));

		$backend2 = $this->getMock('\OC_User_Dummy');
		$backend2->expects($this->once())
			->method('countUsers')
			->will($this->returnValue(16));

		$backend2->expects($this->once())
			->method('implementsActions')
			->with(\OC_USER_BACKEND_COUNT_USERS)
			->will($this->returnValue(true));

		$manager = new \OC\User\Manager();
		$manager->registerBackend($backend1);
		$manager->registerBackend($backend2);

		$result = $manager->countUsers();
		//because the backends have the same class name, only one value expected
		$this->assertEquals(1, count($result));
		$keys = array_keys($result);
		$this->assertTrue(strpos($keys[0], 'Mock_OC_User_Dummy') !== false);

		$users = array_shift($result);
		//users from backends shall be summed up
		$this->assertEquals(7+16, $users);
	}
}
