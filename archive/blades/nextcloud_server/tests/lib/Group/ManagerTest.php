<?php

/**
 * @author Robin Appelman <icewind@owncloud.com>
 * @author Vincent Petry <pvince81@owncloud.com>
 *
 * @copyright Copyright (c) 2016, ownCloud GmbH.
 * @license AGPL-3.0
 *
 * This code is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License, version 3,
 * as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License, version 3,
 * along with this program.  If not, see <http://www.gnu.org/licenses/>
 *
 */
namespace Test\Group;

use OC\User\Manager;
use OCP\IUser;
use OCP\GroupInterface;

class ManagerTest extends \Test\TestCase {
	/** @var Manager|\PHPUnit_Framework_MockObject_MockObject $userManager */
	protected $userManager;

	protected function setUp() {
		parent::setUp();

		$this->userManager = $this->createMock(Manager::class);
	}

	private function getTestUser($userId) {
		$mockUser = $this->createMock(IUser::class);
		$mockUser->expects($this->any())
			->method('getUID')
			->will($this->returnValue($userId));
		$mockUser->expects($this->any())
			->method('getDisplayName')
			->will($this->returnValue($userId));
		return $mockUser;
	}

	private function getTestBackend($implementedActions = null) {
		if (is_null($implementedActions)) {
			$implementedActions =
				GroupInterface::ADD_TO_GROUP |
				GroupInterface::REMOVE_FROM_GOUP |
				GroupInterface::COUNT_USERS |
				GroupInterface::CREATE_GROUP |
				GroupInterface::DELETE_GROUP;
		}
		// need to declare it this way due to optional methods
		// thanks to the implementsActions logic
		$backend = $this->getMockBuilder(\OCP\GroupInterface::class)
			->disableOriginalConstructor()
			->setMethods([
				'getGroupDetails',
				'implementsActions',
				'getUserGroups',
				'inGroup',
				'getGroups',
				'groupExists',
				'usersInGroup',
				'createGroup',
				'addToGroup',
				'removeFromGroup',
			])
			->getMock();
		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnCallback(function($actions) use ($implementedActions) {
				return (bool)($actions & $implementedActions);
			}));
		return $backend;
	}

	public function testGet() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend
		 */
		$backend = $this->getTestBackend();
		$backend->expects($this->any())
			->method('groupExists')
			->with('group1')
			->will($this->returnValue(true));

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend);

		$group = $manager->get('group1');
		$this->assertNotNull($group);
		$this->assertEquals('group1', $group->getGID());
	}

	public function testGetNoBackend() {
		$manager = new \OC\Group\Manager($this->userManager);

		$this->assertNull($manager->get('group1'));
	}

	public function testGetNotExists() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend
		 */
		$backend = $this->getTestBackend();
		$backend->expects($this->once())
			->method('groupExists')
			->with('group1')
			->will($this->returnValue(false));

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend);

		$this->assertNull($manager->get('group1'));
	}

	public function testGetDeleted() {
		$backend = new \Test\Util\Group\Dummy();
		$backend->createGroup('group1');

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend);

		$group = $manager->get('group1');
		$group->delete();
		$this->assertNull($manager->get('group1'));
	}

	public function testGetMultipleBackends() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend1
		 */
		$backend1 = $this->getTestBackend();
		$backend1->expects($this->any())
			->method('groupExists')
			->with('group1')
			->will($this->returnValue(false));

		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend2
		 */
		$backend2 = $this->getTestBackend();
		$backend2->expects($this->any())
			->method('groupExists')
			->with('group1')
			->will($this->returnValue(true));

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend1);
		$manager->addBackend($backend2);

		$group = $manager->get('group1');
		$this->assertNotNull($group);
		$this->assertEquals('group1', $group->getGID());
	}

	public function testCreate() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend
		 */
		$backendGroupCreated = false;
		$backend = $this->getTestBackend();
		$backend->expects($this->any())
			->method('groupExists')
			->with('group1')
			->will($this->returnCallback(function () use (&$backendGroupCreated) {
				return $backendGroupCreated;
			}));
		$backend->expects($this->once())
			->method('createGroup')
			->will($this->returnCallback(function () use (&$backendGroupCreated) {
				$backendGroupCreated = true;
			}));;

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend);

		$group = $manager->createGroup('group1');
		$this->assertEquals('group1', $group->getGID());
	}

	public function testCreateExists() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend
		 */
		$backend = $this->getTestBackend();
		$backend->expects($this->any())
			->method('groupExists')
			->with('group1')
			->will($this->returnValue(true));
		$backend->expects($this->never())
			->method('createGroup');

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend);

		$group = $manager->createGroup('group1');
		$this->assertEquals('group1', $group->getGID());
	}

	public function testSearch() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend
		 */
		$backend = $this->getTestBackend();
		$backend->expects($this->once())
			->method('getGroups')
			->with('1')
			->will($this->returnValue(array('group1')));
		$backend->expects($this->once())
			->method('groupExists')
			->with('group1')
			->will($this->returnValue(true));

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend);

		$groups = $manager->search('1');
		$this->assertEquals(1, count($groups));
		$group1 = reset($groups);
		$this->assertEquals('group1', $group1->getGID());
	}

	public function testSearchMultipleBackends() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend1
		 */
		$backend1 = $this->getTestBackend();
		$backend1->expects($this->once())
			->method('getGroups')
			->with('1')
			->will($this->returnValue(array('group1')));
		$backend1->expects($this->any())
			->method('groupExists')
			->will($this->returnValue(true));

		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend2
		 */
		$backend2 = $this->getTestBackend();
		$backend2->expects($this->once())
			->method('getGroups')
			->with('1')
			->will($this->returnValue(array('group12', 'group1')));
		$backend2->expects($this->any())
			->method('groupExists')
			->will($this->returnValue(true));

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend1);
		$manager->addBackend($backend2);

		$groups = $manager->search('1');
		$this->assertEquals(2, count($groups));
		$group1 = reset($groups);
		$group12 = next($groups);
		$this->assertEquals('group1', $group1->getGID());
		$this->assertEquals('group12', $group12->getGID());
	}

	public function testSearchMultipleBackendsLimitAndOffset() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend1
		 */
		$backend1 = $this->getTestBackend();
		$backend1->expects($this->once())
			->method('getGroups')
			->with('1', 2, 1)
			->will($this->returnValue(array('group1')));
		$backend1->expects($this->any())
			->method('groupExists')
			->will($this->returnValue(true));

		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend2
		 */
		$backend2 = $this->getTestBackend();
		$backend2->expects($this->once())
			->method('getGroups')
			->with('1', 2, 1)
			->will($this->returnValue(array('group12')));
		$backend2->expects($this->any())
			->method('groupExists')
			->will($this->returnValue(true));

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend1);
		$manager->addBackend($backend2);

		$groups = $manager->search('1', 2, 1);
		$this->assertEquals(2, count($groups));
		$group1 = reset($groups);
		$group12 = next($groups);
		$this->assertEquals('group1', $group1->getGID());
		$this->assertEquals('group12', $group12->getGID());
	}

	public function testGetUserGroups() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend
		 */
		$backend = $this->getTestBackend();
		$backend->expects($this->once())
			->method('getUserGroups')
			->with('user1')
			->will($this->returnValue(array('group1')));
		$backend->expects($this->any())
			->method('groupExists')
			->with('group1')
			->will($this->returnValue(true));

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend);

		$groups = $manager->getUserGroups($this->getTestUser('user1'));
		$this->assertEquals(1, count($groups));
		$group1 = reset($groups);
		$this->assertEquals('group1', $group1->getGID());
	}

	public function testGetUserGroupIds() {
		/** @var \PHPUnit_Framework_MockObject_MockObject|\OC\Group\Manager $manager */
		$manager = $this->getMockBuilder('OC\Group\Manager')
			->disableOriginalConstructor()
			->setMethods(['getUserGroups'])
			->getMock();
		$manager->expects($this->once())
			->method('getUserGroups')
			->willReturn([
				'123' => '123',
				'abc' => 'abc',
			]);

		/** @var \OC\User\User $user */
		$user = $this->getMockBuilder('OC\User\User')
			->disableOriginalConstructor()
			->getMock();

		$groups = $manager->getUserGroupIds($user);
		$this->assertEquals(2, count($groups));

		foreach ($groups as $group) {
			$this->assertInternalType('string', $group);
		}
	}

	public function testInGroup() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend
		 */
		$backend = $this->getTestBackend();
		$backend->expects($this->once())
			->method('getUserGroups')
			->with('user1')
			->will($this->returnValue(array('group1', 'admin', 'group2')));
		$backend->expects($this->any())
			->method('groupExists')
			->will($this->returnValue(true));

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend);

		$this->assertTrue($manager->isInGroup('user1', 'group1'));
	}

	public function testIsAdmin() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend
		 */
		$backend = $this->getTestBackend();
		$backend->expects($this->once())
			->method('getUserGroups')
			->with('user1')
			->will($this->returnValue(array('group1', 'admin', 'group2')));
		$backend->expects($this->any())
			->method('groupExists')
			->will($this->returnValue(true));

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend);

		$this->assertTrue($manager->isAdmin('user1'));
	}

	public function testNotAdmin() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend
		 */
		$backend = $this->getTestBackend();
		$backend->expects($this->once())
			->method('getUserGroups')
			->with('user1')
			->will($this->returnValue(array('group1', 'group2')));
		$backend->expects($this->any())
			->method('groupExists')
			->will($this->returnValue(true));

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend);

		$this->assertFalse($manager->isAdmin('user1'));
	}

	public function testGetUserGroupsMultipleBackends() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend1
		 */
		$backend1 = $this->getTestBackend();
		$backend1->expects($this->once())
			->method('getUserGroups')
			->with('user1')
			->will($this->returnValue(array('group1')));
		$backend1->expects($this->any())
			->method('groupExists')
			->will($this->returnValue(true));

		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend2
		 */
		$backend2 = $this->getTestBackend();
		$backend2->expects($this->once())
			->method('getUserGroups')
			->with('user1')
			->will($this->returnValue(array('group1', 'group2')));
		$backend1->expects($this->any())
			->method('groupExists')
			->will($this->returnValue(true));

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend1);
		$manager->addBackend($backend2);

		$groups = $manager->getUserGroups($this->getTestUser('user1'));
		$this->assertEquals(2, count($groups));
		$group1 = reset($groups);
		$group2 = next($groups);
		$this->assertEquals('group1', $group1->getGID());
		$this->assertEquals('group2', $group2->getGID());
	}

	public function testDisplayNamesInGroupWithOneUserBackend() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend
		 */
		$backend = $this->getTestBackend();
		$backend->expects($this->exactly(1))
			->method('groupExists')
			->with('testgroup')
			->will($this->returnValue(true));

		$backend->expects($this->any())
			->method('inGroup')
			->will($this->returnCallback(function($uid, $gid) {
				switch($uid) {
					case 'user1' : return false;
					case 'user2' : return true;
					case 'user3' : return false;
					case 'user33': return true;
					default:
						return null;
					}
			}));

		$userBackend = $this->getMockBuilder('\OC\User\Backend')
			->disableOriginalConstructor()
			->getMock();

		$this->userManager->expects($this->any())
			->method('searchDisplayName')
			->with('user3')
			->will($this->returnCallback(function($search, $limit, $offset) use ($userBackend) {
				switch($offset) {
					case 0 : return ['user3' => $this->getTestUser('user3'),
									'user33' => $this->getTestUser('user33')];
					case 2 : return [];
				}
				return null;
			}));
		$this->userManager->expects($this->any())
			->method('get')
			->will($this->returnCallback(function($uid) use ($userBackend) {
				switch($uid) {
					case 'user1' : return $this->getTestUser('user1');
					case 'user2' : return $this->getTestUser('user2');
					case 'user3' : return $this->getTestUser('user3');
					case 'user33': return $this->getTestUser('user33');
					default:
						return null;
				}
			}));

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend);

		$users = $manager->displayNamesInGroup('testgroup', 'user3');
		$this->assertEquals(1, count($users));
		$this->assertFalse(isset($users['user1']));
		$this->assertFalse(isset($users['user2']));
		$this->assertFalse(isset($users['user3']));
		$this->assertTrue(isset($users['user33']));
	}

	public function testDisplayNamesInGroupWithOneUserBackendWithLimitSpecified() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend
		 */
		$backend = $this->getTestBackend();
		$backend->expects($this->exactly(1))
			->method('groupExists')
			->with('testgroup')
			->will($this->returnValue(true));

				$backend->expects($this->any())
			->method('inGroup')
			->will($this->returnCallback(function($uid, $gid) {
					switch($uid) {
						case 'user1' : return false;
						case 'user2' : return true;
						case 'user3' : return false;
						case 'user33': return true;
						case 'user333': return true;
						default:
							return null;
					}
			}));

		$userBackend = $this->getMockBuilder('\OC\User\Backend')
			->disableOriginalConstructor()
			->getMock();

		$this->userManager->expects($this->any())
			->method('searchDisplayName')
			->with('user3')
			->will($this->returnCallback(function($search, $limit, $offset) use ($userBackend) {
				switch($offset) {
					case 0 : return ['user3' => $this->getTestUser('user3'),
									'user33' => $this->getTestUser('user33')];
					case 2 : return ['user333' => $this->getTestUser('user333')];
				}
				return null;
			}));
		$this->userManager->expects($this->any())
			->method('get')
			->will($this->returnCallback(function($uid) use ($userBackend) {
				switch($uid) {
					case 'user1' : return $this->getTestUser('user1');
					case 'user2' : return $this->getTestUser('user2');
					case 'user3' : return $this->getTestUser('user3');
					case 'user33': return $this->getTestUser('user33');
					case 'user333': return $this->getTestUser('user333');
					default:
						return null;
				}
			}));

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend);

		$users = $manager->displayNamesInGroup('testgroup', 'user3', 1);
		$this->assertEquals(1, count($users));
		$this->assertFalse(isset($users['user1']));
		$this->assertFalse(isset($users['user2']));
		$this->assertFalse(isset($users['user3']));
		$this->assertTrue(isset($users['user33']));
		$this->assertFalse(isset($users['user333']));
	}

	public function testDisplayNamesInGroupWithOneUserBackendWithLimitAndOffsetSpecified() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend
		 */
		$backend = $this->getTestBackend();
		$backend->expects($this->exactly(1))
			->method('groupExists')
			->with('testgroup')
			->will($this->returnValue(true));

		$backend->expects($this->any())
			->method('inGroup')
			->will($this->returnCallback(function($uid) {
					switch($uid) {
						case 'user1' : return false;
						case 'user2' : return true;
						case 'user3' : return false;
						case 'user33': return true;
						case 'user333': return true;
						default:
							return null;
					}
			}));

		$userBackend = $this->getMockBuilder('\OC\User\Backend')
			->disableOriginalConstructor()
			->getMock();

		$this->userManager->expects($this->any())
			->method('searchDisplayName')
			->with('user3')
			->will($this->returnCallback(function($search, $limit, $offset) use ($userBackend) {
				switch($offset) {
					case 0 :
						return [
							'user3' => $this->getTestUser('user3'),
							'user33' => $this->getTestUser('user33'),
							'user333' => $this->getTestUser('user333')
						];
				}
				return null;
			}));
		$this->userManager->expects($this->any())
			->method('get')
			->will($this->returnCallback(function($uid) use ($userBackend) {
				switch($uid) {
					case 'user1' : return $this->getTestUser('user1');
					case 'user2' : return $this->getTestUser('user2');
					case 'user3' : return $this->getTestUser('user3');
					case 'user33': return $this->getTestUser('user33');
					case 'user333': return $this->getTestUser('user333');
					default:
						return null;
				}
			}));

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend);

		$users = $manager->displayNamesInGroup('testgroup', 'user3', 1, 1);
		$this->assertEquals(1, count($users));
		$this->assertFalse(isset($users['user1']));
		$this->assertFalse(isset($users['user2']));
		$this->assertFalse(isset($users['user3']));
		$this->assertFalse(isset($users['user33']));
		$this->assertTrue(isset($users['user333']));
	}

	public function testDisplayNamesInGroupWithOneUserBackendAndSearchEmpty() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend
		 */
		$backend = $this->getTestBackend();
		$backend->expects($this->exactly(1))
			->method('groupExists')
			->with('testgroup')
			->will($this->returnValue(true));

				$backend->expects($this->once())
			->method('usersInGroup')
			->with('testgroup', '', -1, 0)
			->will($this->returnValue(array('user2', 'user33')));

		$userBackend = $this->getMockBuilder('\OC\User\Backend')
			->disableOriginalConstructor()
			->getMock();

		$this->userManager->expects($this->any())
			->method('get')
			->will($this->returnCallback(function($uid) use ($userBackend) {
				switch($uid) {
					case 'user1' : return $this->getTestUser('user1');
					case 'user2' : return $this->getTestUser('user2');
					case 'user3' : return $this->getTestUser('user3');
					case 'user33': return $this->getTestUser('user33');
					default:
						return null;
				}
			}));

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend);

		$users = $manager->displayNamesInGroup('testgroup', '');
		$this->assertEquals(2, count($users));
		$this->assertFalse(isset($users['user1']));
		$this->assertTrue(isset($users['user2']));
		$this->assertFalse(isset($users['user3']));
		$this->assertTrue(isset($users['user33']));
	}

	public function testDisplayNamesInGroupWithOneUserBackendAndSearchEmptyAndLimitSpecified() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend
		 */
		$backend = $this->getTestBackend();
		$backend->expects($this->exactly(1))
			->method('groupExists')
			->with('testgroup')
			->will($this->returnValue(true));

		$backend->expects($this->once())
			->method('usersInGroup')
			->with('testgroup', '', 1, 0)
			->will($this->returnValue(array('user2')));

		$userBackend = $this->getMockBuilder('\OC\User\Backend')
			->disableOriginalConstructor()
			->getMock();

		$this->userManager->expects($this->any())
			->method('get')
			->will($this->returnCallback(function($uid) use ($userBackend) {
				switch($uid) {
					case 'user1' : return $this->getTestUser('user1');
					case 'user2' : return $this->getTestUser('user2');
					case 'user3' : return $this->getTestUser('user3');
					case 'user33': return $this->getTestUser('user33');
					default:
						return null;
				}
			}));

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend);

		$users = $manager->displayNamesInGroup('testgroup', '', 1);
		$this->assertEquals(1, count($users));
		$this->assertFalse(isset($users['user1']));
		$this->assertTrue(isset($users['user2']));
		$this->assertFalse(isset($users['user3']));
		$this->assertFalse(isset($users['user33']));
	}

	public function testDisplayNamesInGroupWithOneUserBackendAndSearchEmptyAndLimitAndOffsetSpecified() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend
		 */
		$backend = $this->getTestBackend();
		$backend->expects($this->exactly(1))
			->method('groupExists')
			->with('testgroup')
			->will($this->returnValue(true));

		$backend->expects($this->once())
			->method('usersInGroup')
			->with('testgroup', '', 1, 1)
			->will($this->returnValue(array('user33')));

		$userBackend = $this->getMockBuilder('\OC\User\Backend')
			->disableOriginalConstructor()
			->getMock();

		$this->userManager->expects($this->any())
			->method('get')
			->will($this->returnCallback(function($uid) use ($userBackend) {
				switch($uid) {
					case 'user1' : return $this->getTestUser('user1');
					case 'user2' : return $this->getTestUser('user2');
					case 'user3' : return $this->getTestUser('user3');
					case 'user33': return $this->getTestUser('user33');
					default:
						return null;
				}
			}));

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend);

		$users = $manager->displayNamesInGroup('testgroup', '', 1, 1);
		$this->assertEquals(1, count($users));
		$this->assertFalse(isset($users['user1']));
		$this->assertFalse(isset($users['user2']));
		$this->assertFalse(isset($users['user3']));
		$this->assertTrue(isset($users['user33']));
	}

	public function testGetUserGroupsWithAddUser() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend
		 */
		$backend = $this->getTestBackend();
		$expectedGroups = [];
		$backend->expects($this->any())
			->method('getUserGroups')
			->with('user1')
			->will($this->returnCallback(function () use (&$expectedGroups) {
				return $expectedGroups;
			}));
		$backend->expects($this->any())
			->method('groupExists')
			->with('group1')
			->will($this->returnValue(true));

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend);

		// prime cache
		$user1 = $this->getTestUser('user1');
		$groups = $manager->getUserGroups($user1);
		$this->assertEquals(array(), $groups);

		// add user
		$group = $manager->get('group1');
		$group->addUser($user1);
		$expectedGroups = ['group1'];

		// check result
		$groups = $manager->getUserGroups($user1);
		$this->assertEquals(1, count($groups));
		$group1 = reset($groups);
		$this->assertEquals('group1', $group1->getGID());
	}

	public function testGetUserGroupsWithRemoveUser() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend
		 */
		$backend = $this->getTestBackend();
		$expectedGroups = ['group1'];
		$backend->expects($this->any())
			->method('getUserGroups')
			->with('user1')
			->will($this->returnCallback(function () use (&$expectedGroups) {
				return $expectedGroups;
			}));
		$backend->expects($this->any())
			->method('groupExists')
			->with('group1')
			->will($this->returnValue(true));
		$backend->expects($this->once())
			->method('inGroup')
			->will($this->returnValue(true));
		$backend->expects($this->once())
			->method('removeFromGroup')
			->will($this->returnValue(true));

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend);

		// prime cache
		$user1 = $this->getTestUser('user1');
		$groups = $manager->getUserGroups($user1);
		$this->assertEquals(1, count($groups));
		$group1 = reset($groups);
		$this->assertEquals('group1', $group1->getGID());

		// remove user
		$group = $manager->get('group1');
		$group->removeUser($user1);
		$expectedGroups = array();

		// check result
		$groups = $manager->getUserGroups($user1);
		$this->assertEquals($expectedGroups, $groups);
	}

	public function testGetUserIdGroups() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend
		 */
		$backend = $this->getTestBackend();
		$backend->expects($this->any())
			->method('getUserGroups')
			->with('user1')
			->will($this->returnValue(null));

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend);

		$groups = $manager->getUserIdGroups('user1');
		$this->assertEquals([], $groups);
	}

	public function testGroupDisplayName() {
		/**
		 * @var \PHPUnit_Framework_MockObject_MockObject | \OC\Group\Backend $backend
		 */
		$backend = $this->getTestBackend(
			GroupInterface::ADD_TO_GROUP |
			GroupInterface::REMOVE_FROM_GOUP |
			GroupInterface::COUNT_USERS |
			GroupInterface::CREATE_GROUP |
			GroupInterface::DELETE_GROUP |
			GroupInterface::GROUP_DETAILS
		);
		$backend->expects($this->any())
			->method('getGroupDetails')
			->will($this->returnValueMap([
				['group1', ['gid' => 'group1', 'displayName' => 'Group One']],
				['group2', ['gid' => 'group2']],
			]));

		$manager = new \OC\Group\Manager($this->userManager);
		$manager->addBackend($backend);

		// group with display name
		$group = $manager->get('group1');
		$this->assertNotNull($group);
		$this->assertEquals('group1', $group->getGID());
		$this->assertEquals('Group One', $group->getDisplayName());

		// group without display name
		$group = $manager->get('group2');
		$this->assertNotNull($group);
		$this->assertEquals('group2', $group->getGID());
		$this->assertEquals('group2', $group->getDisplayName());
	}

}
