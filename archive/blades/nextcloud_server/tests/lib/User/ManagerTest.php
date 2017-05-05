<?php

/**
 * Copyright (c) 2013 Robin Appelman <icewind@owncloud.com>
 * This file is licensed under the Affero General Public License version 3 or
 * later.
 * See the COPYING-README file.
 */

namespace Test\User;
use OC\User\Database;
use OCP\IConfig;
use OCP\IUser;
use Test\TestCase;

/**
 * Class ManagerTest
 *
 * @group DB
 *
 * @package Test\User
 */
class ManagerTest extends TestCase {

	/** @var IConfig */
	private $config;

	public function setUp() {
		parent::setUp();

		$this->config = $this->createMock(IConfig::class);
	}

	public function testGetBackends() {
		$userDummyBackend = $this->createMock(\Test\Util\User\Dummy::class);
		$manager = new \OC\User\Manager($this->config);
		$manager->registerBackend($userDummyBackend);
		$this->assertEquals([$userDummyBackend], $manager->getBackends());
		$dummyDatabaseBackend = $this->createMock(Database::class);
		$manager->registerBackend($dummyDatabaseBackend);
		$this->assertEquals([$userDummyBackend, $dummyDatabaseBackend], $manager->getBackends());
	}


	public function testUserExistsSingleBackendExists() {
		/**
		 * @var \Test\Util\User\Dummy | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);
		$backend->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(true));

		$manager = new \OC\User\Manager($this->config);
		$manager->registerBackend($backend);

		$this->assertTrue($manager->userExists('foo'));
	}

	public function testUserExistsSingleBackendNotExists() {
		/**
		 * @var \Test\Util\User\Dummy | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);
		$backend->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(false));

		$manager = new \OC\User\Manager($this->config);
		$manager->registerBackend($backend);

		$this->assertFalse($manager->userExists('foo'));
	}

	public function testUserExistsNoBackends() {
		$manager = new \OC\User\Manager($this->config);

		$this->assertFalse($manager->userExists('foo'));
	}

	public function testUserExistsTwoBackendsSecondExists() {
		/**
		 * @var \Test\Util\User\Dummy | \PHPUnit_Framework_MockObject_MockObject $backend1
		 */
		$backend1 = $this->createMock(\Test\Util\User\Dummy::class);
		$backend1->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(false));

		/**
		 * @var \Test\Util\User\Dummy | \PHPUnit_Framework_MockObject_MockObject $backend2
		 */
		$backend2 = $this->createMock(\Test\Util\User\Dummy::class);
		$backend2->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(true));

		$manager = new \OC\User\Manager($this->config);
		$manager->registerBackend($backend1);
		$manager->registerBackend($backend2);

		$this->assertTrue($manager->userExists('foo'));
	}

	public function testUserExistsTwoBackendsFirstExists() {
		/**
		 * @var \Test\Util\User\Dummy | \PHPUnit_Framework_MockObject_MockObject $backend1
		 */
		$backend1 = $this->createMock(\Test\Util\User\Dummy::class);
		$backend1->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(true));

		/**
		 * @var \Test\Util\User\Dummy | \PHPUnit_Framework_MockObject_MockObject $backend2
		 */
		$backend2 = $this->createMock(\Test\Util\User\Dummy::class);
		$backend2->expects($this->never())
			->method('userExists');

		$manager = new \OC\User\Manager($this->config);
		$manager->registerBackend($backend1);
		$manager->registerBackend($backend2);

		$this->assertTrue($manager->userExists('foo'));
	}

	public function testCheckPassword() {
		/**
		 * @var \OC\User\Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);
		$backend->expects($this->once())
			->method('checkPassword')
			->with($this->equalTo('foo'), $this->equalTo('bar'))
			->will($this->returnValue(true));

		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnCallback(function ($actions) {
				if ($actions === \OC\USER\BACKEND::CHECK_PASSWORD) {
					return true;
				} else {
					return false;
				}
			}));

		$manager = new \OC\User\Manager($this->config);
		$manager->registerBackend($backend);

		$user = $manager->checkPassword('foo', 'bar');
		$this->assertTrue($user instanceof \OC\User\User);
	}

	public function testCheckPasswordNotSupported() {
		/**
		 * @var \OC\User\Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);
		$backend->expects($this->never())
			->method('checkPassword');

		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnValue(false));

		$manager = new \OC\User\Manager($this->config);
		$manager->registerBackend($backend);

		$this->assertFalse($manager->checkPassword('foo', 'bar'));
	}

	public function testGetOneBackendExists() {
		/**
		 * @var \Test\Util\User\Dummy | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);
		$backend->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(true));

		$manager = new \OC\User\Manager($this->config);
		$manager->registerBackend($backend);

		$this->assertEquals('foo', $manager->get('foo')->getUID());
	}

	public function testGetOneBackendNotExists() {
		/**
		 * @var \Test\Util\User\Dummy | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);
		$backend->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(false));

		$manager = new \OC\User\Manager($this->config);
		$manager->registerBackend($backend);

		$this->assertEquals(null, $manager->get('foo'));
	}

	public function testSearchOneBackend() {
		/**
		 * @var \Test\Util\User\Dummy | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);
		$backend->expects($this->once())
			->method('getUsers')
			->with($this->equalTo('fo'))
			->will($this->returnValue(array('foo', 'afoo')));

		$manager = new \OC\User\Manager($this->config);
		$manager->registerBackend($backend);

		$result = $manager->search('fo');
		$this->assertEquals(2, count($result));
		$this->assertEquals('afoo', array_shift($result)->getUID());
		$this->assertEquals('foo', array_shift($result)->getUID());
	}

	public function testSearchTwoBackendLimitOffset() {
		/**
		 * @var \Test\Util\User\Dummy | \PHPUnit_Framework_MockObject_MockObject $backend1
		 */
		$backend1 = $this->createMock(\Test\Util\User\Dummy::class);
		$backend1->expects($this->once())
			->method('getUsers')
			->with($this->equalTo('fo'), $this->equalTo(3), $this->equalTo(1))
			->will($this->returnValue(array('foo1', 'foo2')));

		/**
		 * @var \Test\Util\User\Dummy | \PHPUnit_Framework_MockObject_MockObject $backend2
		 */
		$backend2 = $this->createMock(\Test\Util\User\Dummy::class);
		$backend2->expects($this->once())
			->method('getUsers')
			->with($this->equalTo('fo'), $this->equalTo(3), $this->equalTo(1))
			->will($this->returnValue(array('foo3')));

		$manager = new \OC\User\Manager($this->config);
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
		 * @var \Test\Util\User\Dummy | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);
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

		$manager = new \OC\User\Manager($this->config);
		$manager->registerBackend($backend);

		$user = $manager->createUser('foo', 'bar');
		$this->assertEquals('foo', $user->getUID());
	}

	/**
	 * @expectedException \Exception
	 */
	public function testCreateUserSingleBackendExists() {
		/**
		 * @var \Test\Util\User\Dummy | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);
		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnValue(true));

		$backend->expects($this->never())
			->method('createUser');

		$backend->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(true));

		$manager = new \OC\User\Manager($this->config);
		$manager->registerBackend($backend);

		$manager->createUser('foo', 'bar');
	}

	public function testCreateUserSingleBackendNotSupported() {
		/**
		 * @var \Test\Util\User\Dummy | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);
		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnValue(false));

		$backend->expects($this->never())
			->method('createUser');

		$backend->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(false));

		$manager = new \OC\User\Manager($this->config);
		$manager->registerBackend($backend);

		$this->assertFalse($manager->createUser('foo', 'bar'));
	}

	public function testCreateUserNoBackends() {
		$manager = new \OC\User\Manager($this->config);

		$this->assertFalse($manager->createUser('foo', 'bar'));
	}

	/**
	 * @expectedException \Exception
	 */
	public function testCreateUserTwoBackendExists() {
		/**
		 * @var \Test\Util\User\Dummy | \PHPUnit_Framework_MockObject_MockObject $backend1
		 */
		$backend1 = $this->createMock(\Test\Util\User\Dummy::class);
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
		 * @var \Test\Util\User\Dummy | \PHPUnit_Framework_MockObject_MockObject $backend2
		 */
		$backend2 = $this->createMock(\Test\Util\User\Dummy::class);
		$backend2->expects($this->any())
			->method('implementsActions')
			->will($this->returnValue(true));

		$backend2->expects($this->never())
			->method('createUser');

		$backend2->expects($this->once())
			->method('userExists')
			->with($this->equalTo('foo'))
			->will($this->returnValue(true));

		$manager = new \OC\User\Manager($this->config);
		$manager->registerBackend($backend1);
		$manager->registerBackend($backend2);

		$manager->createUser('foo', 'bar');
	}

	public function testCountUsersNoBackend() {
		$manager = new \OC\User\Manager($this->config);

		$result = $manager->countUsers();
		$this->assertTrue(is_array($result));
		$this->assertTrue(empty($result));
	}

	public function testCountUsersOneBackend() {
		/**
		 * @var \Test\Util\User\Dummy | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);
		$backend->expects($this->once())
			->method('countUsers')
			->will($this->returnValue(7));

		$backend->expects($this->once())
			->method('implementsActions')
			->with(\OC\USER\BACKEND::COUNT_USERS)
			->will($this->returnValue(true));

		$backend->expects($this->once())
			->method('getBackendName')
			->will($this->returnValue('Mock_Test_Util_User_Dummy'));

		$manager = new \OC\User\Manager($this->config);
		$manager->registerBackend($backend);

		$result = $manager->countUsers();
		$keys = array_keys($result);
		$this->assertTrue(strpos($keys[0], 'Mock_Test_Util_User_Dummy') !== false);

		$users = array_shift($result);
		$this->assertEquals(7, $users);
	}

	public function testCountUsersTwoBackends() {
		/**
		 * @var \Test\Util\User\Dummy | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend1 = $this->createMock(\Test\Util\User\Dummy::class);
		$backend1->expects($this->once())
			->method('countUsers')
			->will($this->returnValue(7));

		$backend1->expects($this->once())
			->method('implementsActions')
			->with(\OC\USER\BACKEND::COUNT_USERS)
			->will($this->returnValue(true));
		$backend1->expects($this->once())
			->method('getBackendName')
			->will($this->returnValue('Mock_Test_Util_User_Dummy'));

		$backend2 = $this->createMock(\Test\Util\User\Dummy::class);
		$backend2->expects($this->once())
			->method('countUsers')
			->will($this->returnValue(16));

		$backend2->expects($this->once())
			->method('implementsActions')
			->with(\OC\USER\BACKEND::COUNT_USERS)
			->will($this->returnValue(true));
		$backend2->expects($this->once())
			->method('getBackendName')
			->will($this->returnValue('Mock_Test_Util_User_Dummy'));

		$manager = new \OC\User\Manager($this->config);
		$manager->registerBackend($backend1);
		$manager->registerBackend($backend2);

		$result = $manager->countUsers();
		//because the backends have the same class name, only one value expected
		$this->assertEquals(1, count($result));
		$keys = array_keys($result);
		$this->assertTrue(strpos($keys[0], 'Mock_Test_Util_User_Dummy') !== false);

		$users = array_shift($result);
		//users from backends shall be summed up
		$this->assertEquals(7 + 16, $users);
	}

	public function testCountUsersOnlySeen() {
		$manager = \OC::$server->getUserManager();
		// count other users in the db before adding our own
		$countBefore = $manager->countUsers(true);

		//Add test users
		$user1 = $manager->createUser('testseencount1', 'testseencount1');
		$user1->updateLastLoginTimestamp();

		$user2 = $manager->createUser('testseencount2', 'testseencount2');
		$user2->updateLastLoginTimestamp();

		$user3 = $manager->createUser('testseencount3', 'testseencount3');

		$user4 = $manager->createUser('testseencount4', 'testseencount4');
		$user4->updateLastLoginTimestamp();

		$this->assertEquals($countBefore + 3, $manager->countUsers(true));

		//cleanup
		$user1->delete();
		$user2->delete();
		$user3->delete();
		$user4->delete();
	}

	public function testCallForSeenUsers() {
		$manager = \OC::$server->getUserManager();
		// count other users in the db before adding our own
		$count = 0;
		$function = function (IUser $user) use (&$count) {
			$count++;
		};
		$manager->callForAllUsers($function, '', true);
		$countBefore = $count;

		//Add test users
		$user1 = $manager->createUser('testseen1', 'testseen1');
		$user1->updateLastLoginTimestamp();

		$user2 = $manager->createUser('testseen2', 'testseen2');
		$user2->updateLastLoginTimestamp();

		$user3 = $manager->createUser('testseen3', 'testseen3');

		$user4 = $manager->createUser('testseen4', 'testseen4');
		$user4->updateLastLoginTimestamp();

		$count = 0;
		$manager->callForAllUsers($function, '', true);

		$this->assertEquals($countBefore + 3, $count);

		//cleanup
		$user1->delete();
		$user2->delete();
		$user3->delete();
		$user4->delete();
	}

	public function testDeleteUser() {
		$config = $this->getMockBuilder('OCP\IConfig')
			->disableOriginalConstructor()
			->getMock();
		$config
				->expects($this->at(0))
				->method('getUserValue')
				->with('foo', 'core', 'enabled')
				->will($this->returnValue(true));
		$config
				->expects($this->at(1))
				->method('getUserValue')
				->with('foo', 'login', 'lastLogin')
				->will($this->returnValue(0));

		$manager = new \OC\User\Manager($config);
		$backend = new \Test\Util\User\Dummy();

		$manager->registerBackend($backend);
		$backend->createUser('foo', 'bar');
		$this->assertTrue($manager->userExists('foo'));
		$manager->get('foo')->delete();
		$this->assertFalse($manager->userExists('foo'));
	}
}
