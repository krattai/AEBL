<?php
/**
 * @copyright Copyright (c) 2016, ownCloud, Inc.
 *
 * @author Arthur Schiwon <blizzz@arthur-schiwon.de>
 * @author Joas Schilling <coding@schilljs.com>
 * @author Lukas Reschke <lukas@statuscode.ch>
 * @author michag86 <micha_g@arcor.de>
 * @author Morris Jobke <hey@morrisjobke.de>
 * @author Roeland Jago Douma <roeland@famdouma.nl>
 * @author Thomas Müller <thomas.mueller@tmit.eu>
 * @author Tom Needham <tom@owncloud.com>
 *
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

namespace OCA\Provisioning_API\Tests\Controller;

use OC\Accounts\AccountManager;
use OCA\Provisioning_API\Controller\UsersController;
use OCP\AppFramework\Http\DataResponse;
use OCP\IGroup;
use OCP\IRequest;
use OCP\IUser;
use OCP\IUserManager;
use OCP\IConfig;
use OCP\IUserSession;
use PHPUnit_Framework_MockObject_MockObject;
use Test\TestCase as OriginalTest;
use OCP\ILogger;

class UsersControllerTest extends OriginalTest {

	/** @var IUserManager | PHPUnit_Framework_MockObject_MockObject */
	protected $userManager;
	/** @var IConfig | PHPUnit_Framework_MockObject_MockObject */
	protected $config;
	/** @var \OC\Group\Manager | PHPUnit_Framework_MockObject_MockObject */
	protected $groupManager;
	/** @var IUserSession | PHPUnit_Framework_MockObject_MockObject */
	protected $userSession;
	/** @var ILogger | PHPUnit_Framework_MockObject_MockObject */
	protected $logger;
	/** @var UsersController | PHPUnit_Framework_MockObject_MockObject */
	protected $api;
	/** @var  AccountManager | PHPUnit_Framework_MockObject_MockObject */
	protected $accountManager;
	/** @var  IRequest | PHPUnit_Framework_MockObject_MockObject */
	protected $request;

	protected function tearDown() {
		parent::tearDown();
	}

	protected function setUp() {
		parent::setUp();

		$this->userManager = $this->getMockBuilder('OCP\IUserManager')
			->disableOriginalConstructor()
			->getMock();
		$this->config = $this->getMockBuilder('OCP\IConfig')
			->disableOriginalConstructor()
			->getMock();
		$this->groupManager = $this->getMockBuilder('OC\Group\Manager')
			->disableOriginalConstructor()
			->getMock();
		$this->userSession = $this->getMockBuilder('OCP\IUserSession')
			->disableOriginalConstructor()
			->getMock();
		$this->logger = $this->getMockBuilder('OCP\ILogger')
			->disableOriginalConstructor()
			->getMock();
		$this->request = $this->getMockBuilder('OCP\IRequest')
			->disableOriginalConstructor()
			->getMock();
		$this->accountManager = $this->getMockBuilder(AccountManager::class)
			->disableOriginalConstructor()
			->getMock();
		$this->api = $this->getMockBuilder('OCA\Provisioning_API\Controller\UsersController')
			->setConstructorArgs([
				'provisioning_api',
				$this->request,
				$this->userManager,
				$this->config,
				$this->groupManager,
				$this->userSession,
				$this->accountManager,
				$this->logger,
			])
			->setMethods(['fillStorageInfo'])
			->getMock();
	}

	public function testGetUsersAsAdmin() {
		$loggedInUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$loggedInUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('admin'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->will($this->returnValue(true));
		$this->userManager
			->expects($this->once())
			->method('search')
			->with('MyCustomSearch', null, null)
			->will($this->returnValue(['Admin' => [], 'Foo' => [], 'Bar' => []]));

		$expected = ['users' => [
				'Admin',
				'Foo',
				'Bar',
			],
		];
		$this->assertEquals($expected, $this->api->getUsers('MyCustomSearch')->getData());
	}

	public function testGetUsersAsSubAdmin() {
		$loggedInUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$loggedInUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('subadmin'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->will($this->returnValue(false));
		$firstGroup = $this->getMockBuilder('OCP\IGroup')
			->disableOriginalConstructor()
			->getMock();
		$firstGroup
			->expects($this->once())
			->method('getGID')
			->will($this->returnValue('FirstGroup'));
		$secondGroup = $this->getMockBuilder('OCP\IGroup')
			->disableOriginalConstructor()
			->getMock();
		$secondGroup
			->expects($this->once())
			->method('getGID')
			->will($this->returnValue('SecondGroup'));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$subAdminManager
			->expects($this->once())
			->method('isSubAdmin')
			->with($loggedInUser)
			->will($this->returnValue(true));
		$subAdminManager
			->expects($this->once())
			->method('getSubAdminsGroups')
			->with($loggedInUser)
			->will($this->returnValue([$firstGroup, $secondGroup]));
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));
		$this->groupManager
			->expects($this->any())
			->method('displayNamesInGroup')
			->will($this->onConsecutiveCalls(['AnotherUserInTheFirstGroup' => []], ['UserInTheSecondGroup' => []]));

		$expected = [
			'users' => [
				'AnotherUserInTheFirstGroup',
				'UserInTheSecondGroup',
			],
		];
		$this->assertEquals($expected, $this->api->getUsers('MyCustomSearch')->getData());
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 102
	 */
	public function testAddUserAlreadyExisting() {
		$this->userManager
			->expects($this->once())
			->method('userExists')
			->with('AlreadyExistingUser')
			->will($this->returnValue(true));
		$this->logger
			->expects($this->once())
			->method('error')
			->with('Failed addUser attempt: User already exists.', ['app' => 'ocs_api']);
		$loggedInUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$loggedInUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('adminUser'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('adminUser')
			->willReturn(true);

		$this->api->addUser('AlreadyExistingUser', null, null);
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 104
	 * @expectedExceptionMessage group NonExistingGroup does not exist
	 */
	public function testAddUserNonExistingGroup() {
		$this->userManager
			->expects($this->once())
			->method('userExists')
			->with('NewUser')
			->willReturn(false);
		$loggedInUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$loggedInUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('adminUser'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('adminUser')
			->willReturn(true);
		$this->groupManager
			->expects($this->once())
			->method('groupExists')
			->with('NonExistingGroup')
			->willReturn(false);

		$this->api->addUser('NewUser', 'pass', ['NonExistingGroup']);
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 104
	 * @expectedExceptionMessage group NonExistingGroup does not exist
	 */
	public function testAddUserExistingGroupNonExistingGroup() {
		$this->userManager
			->expects($this->once())
			->method('userExists')
			->with('NewUser')
			->willReturn(false);
		$loggedInUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$loggedInUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('adminUser'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('adminUser')
			->willReturn(true);
		$this->groupManager
			->expects($this->exactly(2))
			->method('groupExists')
			->withConsecutive(
				['ExistingGroup'],
				['NonExistingGroup']
			)
			->will($this->returnValueMap([
				['ExistingGroup', true],
				['NonExistingGroup', false]
			]));

		$this->api->addUser('NewUser', 'pass', ['ExistingGroup', 'NonExistingGroup']);
	}

	public function testAddUserSuccessful() {
		$this->userManager
			->expects($this->once())
			->method('userExists')
			->with('NewUser')
			->will($this->returnValue(false));
		$this->userManager
			->expects($this->once())
			->method('createUser')
			->with('NewUser', 'PasswordOfTheNewUser');
		$this->logger
			->expects($this->once())
			->method('info')
			->with('Successful addUser call with userid: NewUser', ['app' => 'ocs_api']);
		$loggedInUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$loggedInUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('adminUser'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('adminUser')
			->willReturn(true);

		$this->assertEquals([], $this->api->addUser('NewUser', 'PasswordOfTheNewUser')->getData());
	}

	public function testAddUserExistingGroup() {
		$this->userManager
			->expects($this->once())
			->method('userExists')
			->with('NewUser')
			->willReturn(false);
		$loggedInUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$loggedInUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('adminUser'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('adminUser')
			->willReturn(true);
		$this->groupManager
			->expects($this->once())
			->method('groupExists')
			->with('ExistingGroup')
			->willReturn(true);
		$user = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$this->userManager
			->expects($this->once())
			->method('createUser')
			->with('NewUser', 'PasswordOfTheNewUser')
			->willReturn($user);
		$group = $this->getMockBuilder('OCP\IGroup')
			->disableOriginalConstructor()
			->getMock();
		$group
			->expects($this->once())
			->method('addUser')
			->with($user);
		$this->groupManager
			->expects($this->once())
			->method('get')
			->with('ExistingGroup')
			->willReturn($group);
		$this->logger
			->expects($this->exactly(2))
			->method('info')
			->withConsecutive(
				['Successful addUser call with userid: NewUser', ['app' => 'ocs_api']],
				['Added userid NewUser to group ExistingGroup', ['app' => 'ocs_api']]
			);

		$this->assertEquals([], $this->api->addUser('NewUser', 'PasswordOfTheNewUser', ['ExistingGroup'])->getData());
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 101
	 * @expectedExceptionMessage Bad request
	 */
	public function testAddUserUnsuccessful() {
		$this->userManager
			->expects($this->once())
			->method('userExists')
			->with('NewUser')
			->will($this->returnValue(false));
		$this->userManager
			->expects($this->once())
			->method('createUser')
			->with('NewUser', 'PasswordOfTheNewUser')
			->will($this->throwException(new \Exception('User backend not found.')));
		$this->logger
			->expects($this->once())
			->method('error')
			->with('Failed addUser attempt with exception: User backend not found.', ['app' => 'ocs_api']);
		$loggedInUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$loggedInUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('adminUser'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('adminUser')
			->willReturn(true);

		$this->api->addUser('NewUser', 'PasswordOfTheNewUser');
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 106
	 * @expectedExceptionMessage no group specified (required for subadmins)
	 */
	public function testAddUserAsSubAdminNoGroup() {
		$loggedInUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$loggedInUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('regularUser'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('regularUser')
			->willReturn(false);
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->with()
			->willReturn($subAdminManager);

		$this->api->addUser('NewUser', 'PasswordOfTheNewUser', null);
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 105
	 * @expectedExceptionMessage insufficient privileges for group ExistingGroup
	 */
	public function testAddUserAsSubAdminValidGroupNotSubAdmin() {
		$loggedInUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$loggedInUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('regularUser'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('regularUser')
			->willReturn(false);
		$existingGroup = $this->getMockBuilder('\OCP\IGroup')->disableOriginalConstructor()->getMock();
		$this->groupManager
			->expects($this->once())
			->method('get')
			->with('ExistingGroup')
			->willReturn($existingGroup);
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$subAdminManager
			->expects($this->once())
			->method('isSubAdminOfGroup')
			->with($loggedInUser, $existingGroup)
			->willReturn(false);
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->with()
			->willReturn($subAdminManager);
		$this->groupManager
			->expects($this->once())
			->method('groupExists')
			->with('ExistingGroup')
			->willReturn(true);

		$this->api->addUser('NewUser', 'PasswordOfTheNewUser', ['ExistingGroup'])->getData();
	}

	public function testAddUserAsSubAdminExistingGroups() {
		$this->userManager
			->expects($this->once())
			->method('userExists')
			->with('NewUser')
			->willReturn(false);
		$loggedInUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$loggedInUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('subAdminUser'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('subAdminUser')
			->willReturn(false);
		$this->groupManager
			->expects($this->exactly(2))
			->method('groupExists')
			->withConsecutive(
				['ExistingGroup1'],
				['ExistingGroup2']
			)
			->willReturn(true);
		$user = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$this->userManager
			->expects($this->once())
			->method('createUser')
			->with('NewUser', 'PasswordOfTheNewUser')
			->willReturn($user);
		$existingGroup1 = $this->getMockBuilder('OCP\IGroup')
			->disableOriginalConstructor()
			->getMock();
		$existingGroup2 = $this->getMockBuilder('OCP\IGroup')
			->disableOriginalConstructor()
			->getMock();
		$existingGroup1
			->expects($this->once())
			->method('addUser')
			->with($user);
		$existingGroup2
			->expects($this->once())
			->method('addUser')
			->with($user);
		$this->groupManager
			->expects($this->exactly(4))
			->method('get')
			->withConsecutive(
				['ExistingGroup1'],
				['ExistingGroup2'],
				['ExistingGroup1'],
				['ExistingGroup2']
			)
			->will($this->returnValueMap([
				['ExistingGroup1', $existingGroup1],
				['ExistingGroup2', $existingGroup2]
			]));
		$this->logger
			->expects($this->exactly(3))
			->method('info')
			->withConsecutive(
				['Successful addUser call with userid: NewUser', ['app' => 'ocs_api']],
				['Added userid NewUser to group ExistingGroup1', ['app' => 'ocs_api']],
				['Added userid NewUser to group ExistingGroup2', ['app' => 'ocs_api']]
			);
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->willReturn($subAdminManager);
		$subAdminManager
			->expects($this->exactly(2))
			->method('isSubAdminOfGroup')
			->withConsecutive(
				[$loggedInUser, $existingGroup1],
				[$loggedInUser, $existingGroup2]
			)
			->willReturn(true);

		$this->assertEquals([], $this->api->addUser('NewUser', 'PasswordOfTheNewUser', ['ExistingGroup1', 'ExistingGroup2'])->getData());
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 998
	 * @expectedExceptionMessage The requested user could not be found
	 */
	public function testGetUserTargetDoesNotExist() {
		$loggedInUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToGet')
			->will($this->returnValue(null));

		$this->api->getUser('UserToGet');
	}

	public function testGetUserAsAdmin() {
		$loggedInUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$loggedInUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('admin'));
		$targetUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$targetUser->expects($this->once())
			->method('getEMailAddress')
			->willReturn('demo@owncloud.org');
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToGet')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('admin')
			->will($this->returnValue(true));
		$this->accountManager->expects($this->any())->method('getUser')
			->with($targetUser)
			->willReturn(
				[
					AccountManager::PROPERTY_ADDRESS => ['value' => 'address'],
					AccountManager::PROPERTY_PHONE => ['value' => 'phone'],
					AccountManager::PROPERTY_TWITTER => ['value' => 'twitter'],
					AccountManager::PROPERTY_WEBSITE => ['value' => 'website'],
				]
			);
		$this->config
			->expects($this->at(0))
			->method('getUserValue')
			->with('UserToGet', 'core', 'enabled', 'true')
			->will($this->returnValue('true'));
		$this->api
			->expects($this->once())
			->method('fillStorageInfo')
			->with('UserToGet')
			->will($this->returnValue(['DummyValue']));
		$targetUser
			->expects($this->once())
			->method('getDisplayName')
			->will($this->returnValue('Demo User'));
		$targetUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('UID'));

		$expected = [
			'id' => 'UID',
			'enabled' => 'true',
			'quota' => ['DummyValue'],
			'email' => 'demo@owncloud.org',
			'displayname' => 'Demo User',
			'phone' => 'phone',
			'address' => 'address',
			'webpage' => 'website',
			'twitter' => 'twitter'
		];
		$this->assertEquals($expected, $this->api->getUser('UserToGet')->getData());
	}

	public function testGetUserAsSubAdminAndUserIsAccessible() {
		$loggedInUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$loggedInUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('subadmin'));
		$targetUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$targetUser
				->expects($this->once())
				->method('getEMailAddress')
				->willReturn('demo@owncloud.org');
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToGet')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('subadmin')
			->will($this->returnValue(false));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()
			->getMock();
		$subAdminManager
			->expects($this->once())
			->method('isUserAccessible')
			->with($loggedInUser, $targetUser)
			->will($this->returnValue(true));
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));
		$this->config
			->expects($this->at(0))
			->method('getUserValue')
			->with('UserToGet', 'core', 'enabled', 'true')
			->will($this->returnValue('true'));
		$this->api
			->expects($this->once())
			->method('fillStorageInfo')
			->with('UserToGet')
			->will($this->returnValue(['DummyValue']));
		$targetUser
			->expects($this->once())
			->method('getDisplayName')
			->will($this->returnValue('Demo User'));
		$targetUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('UID'));
		$this->accountManager->expects($this->any())->method('getUser')
			->with($targetUser)
			->willReturn(
				[
					AccountManager::PROPERTY_ADDRESS => ['value' => 'address'],
					AccountManager::PROPERTY_PHONE => ['value' => 'phone'],
					AccountManager::PROPERTY_TWITTER => ['value' => 'twitter'],
					AccountManager::PROPERTY_WEBSITE => ['value' => 'website'],
				]
			);

		$expected = [
			'id' => 'UID',
			'enabled' => 'true',
			'quota' => ['DummyValue'],
			'email' => 'demo@owncloud.org',
			'displayname' => 'Demo User',
			'phone' => 'phone',
			'address' => 'address',
			'webpage' => 'website',
			'twitter' => 'twitter'
		];
		$this->assertEquals($expected, $this->api->getUser('UserToGet')->getData());
	}


	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 997
	 */
	public function testGetUserAsSubAdminAndUserIsNotAccessible() {
		$loggedInUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$loggedInUser
			->expects($this->exactly(2))
			->method('getUID')
			->will($this->returnValue('subadmin'));
		$targetUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToGet')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('subadmin')
			->will($this->returnValue(false));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()
			->getMock();
		$subAdminManager
			->expects($this->once())
			->method('isUserAccessible')
			->with($loggedInUser, $targetUser)
			->will($this->returnValue(false));
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));

		$this->api->getUser('UserToGet');
	}

	public function testGetUserAsSubAdminSelfLookup() {
		$loggedInUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$loggedInUser
			->expects($this->exactly(2))
			->method('getUID')
			->will($this->returnValue('subadmin'));
		$targetUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('subadmin')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('subadmin')
			->will($this->returnValue(false));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()
			->getMock();
		$subAdminManager
			->expects($this->once())
			->method('isUserAccessible')
			->with($loggedInUser, $targetUser)
			->will($this->returnValue(false));
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));
		$this->api
			->expects($this->once())
			->method('fillStorageInfo')
			->with('subadmin')
			->will($this->returnValue(['DummyValue']));
		$targetUser
			->expects($this->once())
			->method('getDisplayName')
			->will($this->returnValue('Subadmin User'));
		$targetUser
			->expects($this->once())
			->method('getEMailAddress')
			->will($this->returnValue('subadmin@owncloud.org'));
		$targetUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('UID'));
		$this->accountManager->expects($this->any())->method('getUser')
			->with($targetUser)
			->willReturn(
				[
					AccountManager::PROPERTY_ADDRESS => ['value' => 'address'],
					AccountManager::PROPERTY_PHONE => ['value' => 'phone'],
					AccountManager::PROPERTY_TWITTER => ['value' => 'twitter'],
					AccountManager::PROPERTY_WEBSITE => ['value' => 'website'],
				]
			);

		$expected = [
			'id' => 'UID',
			'quota' => ['DummyValue'],
			'email' => 'subadmin@owncloud.org',
			'displayname' => 'Subadmin User',
			'phone' => 'phone',
			'address' => 'address',
			'webpage' => 'website',
			'twitter' => 'twitter'
		];
		$this->assertEquals($expected, $this->api->getUser('subadmin')->getData());
	}

	public function testEditUserRegularUserSelfEditChangeDisplayName() {
		$loggedInUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$loggedInUser
			->expects($this->any())
			->method('getUID')
			->will($this->returnValue('UserToEdit'));
		$targetUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToEdit')
			->will($this->returnValue($targetUser));
		$targetUser
			->expects($this->once())
			->method('setDisplayName')
			->with('NewDisplayName');

		$this->assertEquals([], $this->api->editUser('UserToEdit', 'display', 'NewDisplayName')->getData());
	}

	public function testEditUserRegularUserSelfEditChangeEmailValid() {
		$loggedInUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$loggedInUser
			->expects($this->any())
			->method('getUID')
			->will($this->returnValue('UserToEdit'));
		$targetUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToEdit')
			->will($this->returnValue($targetUser));
		$targetUser
			->expects($this->once())
			->method('setEMailAddress')
			->with('demo@owncloud.org');

		$this->assertEquals([], $this->api->editUser('UserToEdit', 'email', 'demo@owncloud.org')->getData());
	}


	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 102
	 */
	public function testEditUserRegularUserSelfEditChangeEmailInvalid() {
		$loggedInUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$loggedInUser
			->expects($this->any())
			->method('getUID')
			->will($this->returnValue('UserToEdit'));
		$targetUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToEdit')
			->will($this->returnValue($targetUser));

		$this->api->editUser('UserToEdit', 'email', 'demo.org');
	}

	public function testEditUserRegularUserSelfEditChangePassword() {
		$loggedInUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$loggedInUser
			->expects($this->any())
			->method('getUID')
			->will($this->returnValue('UserToEdit'));
		$targetUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToEdit')
			->will($this->returnValue($targetUser));
		$targetUser
			->expects($this->once())
			->method('setPassword')
			->with('NewPassword');

		$this->assertEquals([], $this->api->editUser('UserToEdit', 'password', 'NewPassword')->getData());
	}


	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 997
	 */
	public function testEditUserRegularUserSelfEditChangeQuota() {
		$loggedInUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$loggedInUser
			->expects($this->any())
			->method('getUID')
			->will($this->returnValue('UserToEdit'));
		$targetUser = $this->getMockBuilder('OCP\IUser')
			->disableOriginalConstructor()
			->getMock();
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToEdit')
			->will($this->returnValue($targetUser));

		$this->api->editUser('UserToEdit', 'quota', 'NewQuota');
	}

	public function testEditUserAdminUserSelfEditChangeValidQuota() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();;
		$loggedInUser
			->expects($this->any())
			->method('getUID')
			->will($this->returnValue('UserToEdit'));
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetUser->expects($this->once())
			->method('setQuota')
			->with('2.9 MB');
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToEdit')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('UserToEdit')
			->will($this->returnValue(true));

		$this->assertEquals([], $this->api->editUser('UserToEdit', 'quota', '3042824')->getData());
	}


	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 103
	 * @expectedExceptionMessage Invalid quota value ABC
	 */
	public function testEditUserAdminUserSelfEditChangeInvalidQuota() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->any())
			->method('getUID')
			->will($this->returnValue('UserToEdit'));
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToEdit')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('UserToEdit')
			->will($this->returnValue(true));

		$this->api->editUser('UserToEdit', 'quota', 'ABC');
	}

	public function testEditUserAdminUserEditChangeValidQuota() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->any())
			->method('getUID')
			->will($this->returnValue('admin'));
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetUser->expects($this->once())
			->method('setQuota')
			->with('2.9 MB');
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToEdit')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('admin')
			->will($this->returnValue(true));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()
			->getMock();
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));

		$this->assertEquals([], $this->api->editUser('UserToEdit', 'quota', '3042824')->getData());
	}

	public function testEditUserSubadminUserAccessible() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->any())
			->method('getUID')
			->will($this->returnValue('subadmin'));
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetUser->expects($this->once())
			->method('setQuota')
			->with('2.9 MB');
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToEdit')
			->will($this->returnValue($targetUser));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()
			->getMock();
		$subAdminManager
			->expects($this->once())
			->method('isUserAccessible')
			->with($loggedInUser, $targetUser)
			->will($this->returnValue(true));
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));

		$this->assertEquals([], $this->api->editUser('UserToEdit', 'quota', '3042824')->getData());
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 997
	 */
	public function testEditUserSubadminUserInaccessible() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->any())
			->method('getUID')
			->will($this->returnValue('subadmin'));
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToEdit')
			->will($this->returnValue($targetUser));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()
			->getMock();
		$subAdminManager
			->expects($this->once())
			->method('isUserAccessible')
			->with($loggedInUser, $targetUser)
			->will($this->returnValue(false));
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));

		$this->api->editUser('UserToEdit', 'quota', 'value');
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 101
	 */
	public function testDeleteUserNotExistingUser() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->any())
			->method('getUID')
			->will($this->returnValue('UserToEdit'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToDelete')
			->will($this->returnValue(null));

		$this->api->deleteUser('UserToDelete');
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 101
	 */
	public function testDeleteUserSelf() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->any())
			->method('getUID')
			->will($this->returnValue('UserToDelete'));
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('UserToDelete'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToDelete')
			->will($this->returnValue($targetUser));

		$this->api->deleteUser('UserToDelete');
	}

	public function testDeleteSuccessfulUserAsAdmin() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->any())
			->method('getUID')
			->will($this->returnValue('admin'));
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('UserToDelete'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToDelete')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('admin')
			->will($this->returnValue(true));
		$targetUser
			->expects($this->once())
			->method('delete')
			->will($this->returnValue(true));

		$this->assertEquals([], $this->api->deleteUser('UserToDelete')->getData());
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 101
	 */
	public function testDeleteUnsuccessfulUserAsAdmin() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->any())
			->method('getUID')
			->will($this->returnValue('admin'));
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('UserToDelete'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToDelete')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('admin')
			->will($this->returnValue(true));
		$targetUser
			->expects($this->once())
			->method('delete')
			->will($this->returnValue(false));

		$this->api->deleteUser('UserToDelete');
	}

	public function testDeleteSuccessfulUserAsSubadmin() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->any())
			->method('getUID')
			->will($this->returnValue('subadmin'));
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('UserToDelete'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToDelete')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('subadmin')
			->will($this->returnValue(false));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$subAdminManager
			->expects($this->once())
			->method('isUserAccessible')
			->with($loggedInUser, $targetUser)
			->will($this->returnValue(true));
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));
		$targetUser
			->expects($this->once())
			->method('delete')
			->will($this->returnValue(true));

		$this->assertEquals([], $this->api->deleteUser('UserToDelete')->getData());
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 101
	 */
	public function testDeleteUnsuccessfulUserAsSubadmin() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->any())
			->method('getUID')
			->will($this->returnValue('subadmin'));
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('UserToDelete'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToDelete')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('subadmin')
			->will($this->returnValue(false));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$subAdminManager
			->expects($this->once())
			->method('isUserAccessible')
			->with($loggedInUser, $targetUser)
			->will($this->returnValue(true));
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));
		$targetUser
			->expects($this->once())
			->method('delete')
			->will($this->returnValue(false));

		$this->api->deleteUser('UserToDelete');
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 997
	 */
	public function testDeleteUserAsSubAdminAndUserIsNotAccessible() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->any())
			->method('getUID')
			->will($this->returnValue('subadmin'));
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('UserToDelete'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToDelete')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('subadmin')
			->will($this->returnValue(false));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$subAdminManager
			->expects($this->once())
			->method('isUserAccessible')
			->with($loggedInUser, $targetUser)
			->will($this->returnValue(false));
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));

		$this->api->deleteUser('UserToDelete');
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 998
	 */
	public function testGetUsersGroupsTargetUserNotExisting() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));

		$this->api->getUsersGroups('UserToLookup');
	}

	public function testGetUsersGroupsSelfTargetted() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('UserToLookup'));
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('UserToLookup'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToLookup')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('getUserGroupIds')
			->with($targetUser)
			->will($this->returnValue(['DummyValue']));

		$this->assertEquals(['groups' => ['DummyValue']], $this->api->getUsersGroups('UserToLookup')->getData());
	}

	public function testGetUsersGroupsForAdminUser() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->exactly(2))
			->method('getUID')
			->will($this->returnValue('admin'));
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('UserToLookup'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToLookup')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('getUserGroupIds')
			->with($targetUser)
			->will($this->returnValue(['DummyValue']));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('admin')
			->will($this->returnValue(true));

		$this->assertEquals(['groups' => ['DummyValue']], $this->api->getUsersGroups('UserToLookup')->getData());
	}

	public function testGetUsersGroupsForSubAdminUserAndUserIsAccessible() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->exactly(2))
			->method('getUID')
			->will($this->returnValue('subadmin'));
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('UserToLookup'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToLookup')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('subadmin')
			->will($this->returnValue(false));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$subAdminManager
			->expects($this->once())
			->method('isUserAccessible')
			->with($loggedInUser, $targetUser)
			->will($this->returnValue(true));
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));
		$group1 = $this->getMockBuilder('\OCP\IGroup')->disableOriginalConstructor()->getMock();
		$group1
			->expects($this->any())
			->method('getGID')
			->will($this->returnValue('Group1'));
		$group2 = $this->getMockBuilder('\OCP\IGroup')->disableOriginalConstructor()->getMock();
		$group2
			->expects($this->any())
			->method('getGID')
			->will($this->returnValue('Group2'));
		$subAdminManager
			->expects($this->once())
			->method('getSubAdminsGroups')
			->with($loggedInUser)
			->will($this->returnValue([$group1, $group2]));
		$this->groupManager
			->expects($this->any())
			->method('getUserGroupIds')
			->with($targetUser)
			->will($this->returnValue(['Group1']));

		$this->assertEquals(['groups' => ['Group1']], $this->api->getUsersGroups('UserToLookup')->getData());
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 997
	 */
	public function testGetUsersGroupsForSubAdminUserAndUserIsInaccessible() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->exactly(2))
			->method('getUID')
			->will($this->returnValue('subadmin'));
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('UserToLookup'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('UserToLookup')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('subadmin')
			->will($this->returnValue(false));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$subAdminManager
			->expects($this->once())
			->method('isUserAccessible')
			->with($loggedInUser, $targetUser)
			->will($this->returnValue(false));
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));
		$this->groupManager
			->expects($this->any())
			->method('getUserGroupIds')
			->with($targetUser)
			->will($this->returnValue(['Group1']));

		$this->api->getUsersGroups('UserToLookup');
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 102
	 */
	public function testAddToGroupWithTargetGroupNotExisting() {
		$this->groupManager->expects($this->once())
			->method('get')
			->with('GroupToAddTo')
			->willReturn(null);

		$this->api->addToGroup('TargetUser', 'GroupToAddTo');
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 101
	 */
	public function testAddToGroupWithNoGroupSpecified() {
		$this->api->addToGroup('TargetUser');
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 103
	 */
	public function testAddToGroupWithTargetUserNotExisting() {
		$targetGroup = $this->createMock(IGroup::class);
		$this->groupManager->expects($this->once())
			->method('get')
			->with('GroupToAddTo')
			->willReturn($targetGroup);

		$this->api->addToGroup('TargetUser', 'GroupToAddTo');
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 104
	 */
	public function testAddToGroupNoSubadmin() {
		$targetUser = $this->createMock(IUser::class);
		$loggedInUser = $this->createMock(IUser::class);
		$loggedInUser->expects($this->once())
			->method('getUID')
			->willReturn('subadmin');

		$targetGroup = $this->createMock(IGroup::class);
		$targetGroup->expects($this->never())
			->method('addUser')
			->with($targetUser);

		$this->groupManager->expects($this->once())
			->method('get')
			->with('GroupToAddTo')
			->willReturn($targetGroup);


		$subAdminManager = $this->createMock(\OC\SubAdmin::class);
		$subAdminManager->expects($this->once())
			->method('isSubAdminOfGroup')
			->with($loggedInUser, $targetGroup)
			->willReturn(false);

		$this->groupManager->expects($this->once())
			->method('getSubAdmin')
			->willReturn($subAdminManager);
		$this->groupManager->expects($this->once())
			->method('isAdmin')
			->with('subadmin')
			->willReturn(false);

		$this->userManager->expects($this->once())
			->method('get')
			->with('TargetUser')
			->willReturn($targetUser);

		$this->userSession->expects($this->once())
			->method('getUser')
			->willReturn($loggedInUser);

		$this->api->addToGroup('TargetUser', 'GroupToAddTo');
	}

	public function testAddToGroupSuccessAsSubadmin() {
		$targetUser = $this->createMock(IUser::class);
		$loggedInUser = $this->createMock(IUser::class);
		$loggedInUser->expects($this->once())
			->method('getUID')
			->willReturn('subadmin');

		$targetGroup = $this->createMock(IGroup::class);
		$targetGroup->expects($this->once())
			->method('addUser')
			->with($targetUser);

		$this->groupManager->expects($this->once())
			->method('get')
			->with('GroupToAddTo')
			->willReturn($targetGroup);


		$subAdminManager = $this->createMock(\OC\SubAdmin::class);
		$subAdminManager->expects($this->once())
			->method('isSubAdminOfGroup')
			->with($loggedInUser, $targetGroup)
			->willReturn(true);

		$this->groupManager->expects($this->once())
			->method('getSubAdmin')
			->willReturn($subAdminManager);
		$this->groupManager->expects($this->once())
			->method('isAdmin')
			->with('subadmin')
			->willReturn(false);

		$this->userManager->expects($this->once())
			->method('get')
			->with('TargetUser')
			->willReturn($targetUser);

		$this->userSession->expects($this->once())
			->method('getUser')
			->willReturn($loggedInUser);

		$this->assertEquals(new DataResponse(), $this->api->addToGroup('TargetUser', 'GroupToAddTo'));
	}

	public function testAddToGroupSuccessAsAdmin() {
		$targetUser = $this->createMock(IUser::class);
		$loggedInUser = $this->createMock(IUser::class);
		$loggedInUser->expects($this->once())
			->method('getUID')
			->willReturn('admin');

		$targetGroup = $this->createMock(IGroup::class);
		$targetGroup->expects($this->once())
			->method('addUser')
			->with($targetUser);

		$this->groupManager->expects($this->once())
			->method('get')
			->with('GroupToAddTo')
			->willReturn($targetGroup);


		$subAdminManager = $this->createMock(\OC\SubAdmin::class);
		$subAdminManager->expects($this->never())
			->method('isSubAdminOfGroup');

		$this->groupManager->expects($this->once())
			->method('getSubAdmin')
			->willReturn($subAdminManager);
		$this->groupManager->expects($this->once())
			->method('isAdmin')
			->with('admin')
			->willReturn(true);

		$this->userManager->expects($this->once())
			->method('get')
			->with('TargetUser')
			->willReturn($targetUser);

		$this->userSession->expects($this->once())
			->method('getUser')
			->willReturn($loggedInUser);

		$this->assertEquals(new DataResponse(), $this->api->addToGroup('TargetUser', 'GroupToAddTo'));
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 101
	 */
	public function testRemoveFromGroupWithNoTargetGroup() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));

		$this->api->removeFromGroup('TargetUser', null);
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 102
	 */
	public function testRemoveFromGroupWithNotExistingTargetGroup() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->groupManager
			->expects($this->once())
			->method('get')
			->with('TargetGroup')
			->will($this->returnValue(null));

		$this->api->removeFromGroup('TargetUser', 'TargetGroup');
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 103
	 */
	public function testRemoveFromGroupWithNotExistingTargetUser() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetGroup = $this->getMockBuilder('\OCP\IGroup')->disableOriginalConstructor()->getMock();
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->groupManager
			->expects($this->once())
			->method('get')
			->with('TargetGroup')
			->will($this->returnValue($targetGroup));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('TargetUser')
			->will($this->returnValue(null));

		$this->api->removeFromGroup('TargetUser', 'TargetGroup');
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 104
	 */
	public function testRemoveFromGroupWithoutPermission() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->once())
			->method('getUID')
			->will($this->returnValue('unauthorizedUser'));
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetGroup = $this->getMockBuilder('\OCP\IGroup')->disableOriginalConstructor()->getMock();
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->groupManager
			->expects($this->once())
			->method('get')
			->with('TargetGroup')
			->will($this->returnValue($targetGroup));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('TargetUser')
			->will($this->returnValue($targetUser));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->with('unauthorizedUser')
			->will($this->returnValue(false));

		$this->api->removeFromGroup('TargetUser', 'TargetGroup');
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 105
	 * @expectedExceptionMessage Cannot remove yourself from the admin group
	 */
	public function testRemoveFromGroupAsAdminFromAdmin() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->any())
			->method('getUID')
			->will($this->returnValue('admin'));
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetGroup = $this->getMockBuilder('\OCP\IGroup')->disableOriginalConstructor()->getMock();
		$targetGroup
			->expects($this->once())
			->method('getGID')
			->will($this->returnValue('admin'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->groupManager
			->expects($this->once())
			->method('get')
			->with('admin')
			->will($this->returnValue($targetGroup));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('admin')
			->will($this->returnValue($targetUser));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));
		$this->groupManager
			->expects($this->any())
			->method('isAdmin')
			->with('admin')
			->will($this->returnValue(true));

		$this->api->removeFromGroup('admin', 'admin');
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 105
	 * @expectedExceptionMessage Cannot remove yourself from this group as you are a SubAdmin
	 */
	public function testRemoveFromGroupAsSubAdminFromSubAdmin() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->any())
			->method('getUID')
			->will($this->returnValue('subadmin'));
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetGroup = $this->getMockBuilder('\OCP\IGroup')->disableOriginalConstructor()->getMock();
		$targetGroup
			->expects($this->any())
			->method('getGID')
			->will($this->returnValue('subadmin'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->groupManager
			->expects($this->once())
			->method('get')
			->with('subadmin')
			->will($this->returnValue($targetGroup));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('subadmin')
			->will($this->returnValue($targetUser));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$subAdminManager
			->expects($this->once())
			->method('isSubAdminofGroup')
			->with($loggedInUser, $targetGroup)
			->will($this->returnValue(true));
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));
		$this->groupManager
			->expects($this->any())
			->method('isAdmin')
			->with('subadmin')
			->will($this->returnValue(false));

		$this->api->removeFromGroup('subadmin', 'subadmin');
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 105
	 * @expectedExceptionMessage Cannot remove user from this group as this is the only remaining group you are a SubAdmin of
	 */
	public function testRemoveFromGroupAsSubAdminFromLastSubAdminGroup() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->any())
			->method('getUID')
			->will($this->returnValue('subadmin'));
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetGroup = $this->getMockBuilder('\OCP\IGroup')->disableOriginalConstructor()->getMock();
		$targetGroup
			->expects($this->any())
			->method('getGID')
			->will($this->returnValue('subadmin'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->groupManager
			->expects($this->once())
			->method('get')
			->with('subadmin')
			->will($this->returnValue($targetGroup));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('AnotherUser')
			->will($this->returnValue($targetUser));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$subAdminManager
			->expects($this->once())
			->method('isSubAdminofGroup')
			->with($loggedInUser, $targetGroup)
			->will($this->returnValue(true));
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));
		$subAdminManager
			->expects($this->once())
			->method('getSubAdminsGroups')
			->with($loggedInUser)
			->will($this->returnValue([$targetGroup]));

		$this->groupManager
			->expects($this->any())
			->method('isAdmin')
			->with('subadmin')
			->will($this->returnValue(false));
		$this->groupManager
			->expects($this->once())
			->method('getUserGroupIds')
			->with($targetUser)
			->willReturn(['subadmin', 'other group']);

		$this->api->removeFromGroup('AnotherUser', 'subadmin');
	}

	public function testRemoveFromGroupSuccessful() {
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->any())
			->method('getUID')
			->will($this->returnValue('admin'));
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetGroup = $this->getMockBuilder('\OCP\IGroup')->disableOriginalConstructor()->getMock();
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->groupManager
			->expects($this->once())
			->method('get')
			->with('admin')
			->will($this->returnValue($targetGroup));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('AnotherUser')
			->will($this->returnValue($targetUser));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));
		$this->groupManager
			->expects($this->any())
			->method('isAdmin')
			->with('admin')
			->will($this->returnValue(true));
		$targetGroup
			->expects($this->once())
			->method('removeUser')
			->with($targetUser);

		$this->assertEquals([], $this->api->removeFromGroup('AnotherUser', 'admin')->getData());
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 101
	 * @expectedExceptionMessage User does not exist
	 */
	public function testAddSubAdminWithNotExistingTargetUser() {
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('NotExistingUser')
			->will($this->returnValue(null));

		$this->api->addSubAdmin('NotExistingUser', null);
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 102
	 * @expectedExceptionMessage Group:NotExistingGroup does not exist
	 */
	public function testAddSubAdminWithNotExistingTargetGroup() {

		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('ExistingUser')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('get')
			->with('NotExistingGroup')
			->will($this->returnValue(null));

		$this->api->addSubAdmin('ExistingUser', 'NotExistingGroup');
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 103
	 * @expectedExceptionMessage Cannot create subadmins for admin group
	 */
	public function testAddSubAdminToAdminGroup() {
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetGroup = $this->getMockBuilder('\OCP\IGroup')->disableOriginalConstructor()->getMock();
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('ExistingUser')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('get')
			->with('ADmiN')
			->will($this->returnValue($targetGroup));

		$this->api->addSubAdmin('ExistingUser', 'ADmiN');
	}

	public function testAddSubAdminTwice() {
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetGroup = $this->getMockBuilder('\OCP\IGroup')->disableOriginalConstructor()->getMock();
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('ExistingUser')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('get')
			->with('TargetGroup')
			->will($this->returnValue($targetGroup));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$subAdminManager
			->expects($this->once())
			->method('isSubAdminOfGroup')
			->with($targetUser, $targetGroup)
			->will($this->returnValue(true));
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));

		$this->assertEquals([], $this->api->addSubAdmin('ExistingUser', 'TargetGroup')->getData());
	}

	public function testAddSubAdminSuccessful() {
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetGroup = $this->getMockBuilder('\OCP\IGroup')->disableOriginalConstructor()->getMock();
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('ExistingUser')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('get')
			->with('TargetGroup')
			->will($this->returnValue($targetGroup));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$subAdminManager
			->expects($this->once())
			->method('isSubAdminOfGroup')
			->with($targetUser, $targetGroup)
			->will($this->returnValue(false));
		$subAdminManager
			->expects($this->once())
			->method('createSubAdmin')
			->with($targetUser, $targetGroup)
			->will($this->returnValue(true));
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));

		$this->assertEquals([], $this->api->addSubAdmin('ExistingUser', 'TargetGroup')->getData());
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 103
	 * @expectedExceptionMessage Unknown error occurred
	 */
	public function testAddSubAdminUnsuccessful() {
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetGroup = $this->getMockBuilder('\OCP\IGroup')->disableOriginalConstructor()->getMock();
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('ExistingUser')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('get')
			->with('TargetGroup')
			->will($this->returnValue($targetGroup));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$subAdminManager
			->expects($this->once())
			->method('isSubAdminOfGroup')
			->with($targetUser, $targetGroup)
			->will($this->returnValue(false));
		$subAdminManager
			->expects($this->once())
			->method('createSubAdmin')
			->with($targetUser, $targetGroup)
			->will($this->returnValue(false));
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));

		$this->api->addSubAdmin('ExistingUser', 'TargetGroup');
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 101
	 * @expectedExceptionMessage User does not exist
	 */
	public function testRemoveSubAdminNotExistingTargetUser() {
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('NotExistingUser')
			->will($this->returnValue(null));

		$this->api->removeSubAdmin('NotExistingUser', 'GroupToDeleteFrom');
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 101
	 * @expectedExceptionMessage Group does not exist
	 */
	public function testRemoveSubAdminNotExistingTargetGroup() {
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('ExistingUser')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('get')
			->with('GroupToDeleteFrom')
			->will($this->returnValue(null));

		$this->api->removeSubAdmin('ExistingUser', 'GroupToDeleteFrom');
	}


	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 102
	 * @expectedExceptionMessage User is not a subadmin of this group
	 */
	public function testRemoveSubAdminFromNotASubadmin() {
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetGroup = $this->getMockBuilder('\OCP\IGroup')->disableOriginalConstructor()->getMock();
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('ExistingUser')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('get')
			->with('GroupToDeleteFrom')
			->will($this->returnValue($targetGroup));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$subAdminManager
			->expects($this->once())
			->method('isSubAdminOfGroup')
			->with($targetUser, $targetGroup)
			->will($this->returnValue(false));
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));

		$this->api->removeSubAdmin('ExistingUser', 'GroupToDeleteFrom');
	}

	public function testRemoveSubAdminSuccessful() {
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetGroup = $this->getMockBuilder('\OCP\IGroup')->disableOriginalConstructor()->getMock();
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('ExistingUser')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('get')
			->with('GroupToDeleteFrom')
			->will($this->returnValue($targetGroup));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$subAdminManager
			->expects($this->once())
			->method('isSubAdminOfGroup')
			->with($targetUser, $targetGroup)
			->will($this->returnValue(true));
		$subAdminManager
			->expects($this->once())
			->method('deleteSubAdmin')
			->with($targetUser, $targetGroup)
			->will($this->returnValue(true));
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));

		$this->assertEquals([], $this->api->removeSubAdmin('ExistingUser', 'GroupToDeleteFrom')->getData());
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 103
	 * @expectedExceptionMessage Unknown error occurred
	 */
	public function testRemoveSubAdminUnsuccessful() {
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetGroup = $this->getMockBuilder('\OCP\IGroup')->disableOriginalConstructor()->getMock();
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('ExistingUser')
			->will($this->returnValue($targetUser));
		$this->groupManager
			->expects($this->once())
			->method('get')
			->with('GroupToDeleteFrom')
			->will($this->returnValue($targetGroup));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$subAdminManager
			->expects($this->once())
			->method('isSubAdminOfGroup')
			->with($targetUser, $targetGroup)
			->will($this->returnValue(true));
		$subAdminManager
			->expects($this->once())
			->method('deleteSubAdmin')
			->with($targetUser, $targetGroup)
			->will($this->returnValue(false));
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));

		$this->api->removeSubAdmin('ExistingUser', 'GroupToDeleteFrom');
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 101
	 * @expectedExceptionMessage User does not exist
	 */
	public function testGetUserSubAdminGroupsNotExistingTargetUser() {
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('RequestedUser')
			->will($this->returnValue(null));

		$this->api->getUserSubAdminGroups('RequestedUser');
	}

	public function testGetUserSubAdminGroupsWithGroups() {
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetGroup = $this->getMockBuilder('\OCP\IGroup')->disableOriginalConstructor()->getMock();
		$targetGroup
			->expects($this->once())
			->method('getGID')
			->will($this->returnValue('TargetGroup'));
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('RequestedUser')
			->will($this->returnValue($targetUser));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$subAdminManager
			->expects($this->once())
			->method('getSubAdminsGroups')
			->with($targetUser)
			->will($this->returnValue([$targetGroup]));
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));

		$this->assertEquals(['TargetGroup'], $this->api->getUserSubAdminGroups('RequestedUser')->getData());
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 * @expectedExceptionCode 102
	 * @expectedExceptionMessage Unknown error occurred
	 */
	public function testGetUserSubAdminGroupsWithoutGroups() {
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('RequestedUser')
			->will($this->returnValue($targetUser));
		$subAdminManager = $this->getMockBuilder('OC\SubAdmin')
			->disableOriginalConstructor()->getMock();
		$subAdminManager
			->expects($this->once())
			->method('getSubAdminsGroups')
			->with($targetUser)
			->will($this->returnValue([]));
		$this->groupManager
			->expects($this->once())
			->method('getSubAdmin')
			->will($this->returnValue($subAdminManager));

		$this->api->getUserSubAdminGroups('RequestedUser');
	}

	public function testEnableUser() {
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetUser->expects($this->once())
			->method('setEnabled')
			->with(true);
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('RequestedUser')
			->will($this->returnValue($targetUser));
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->exactly(2))
			->method('getUID')
			->will($this->returnValue('admin'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->will($this->returnValue(true));

		$this->assertEquals([], $this->api->enableUser('RequestedUser')->getData());
	}

	public function testDisableUser() {
		$targetUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$targetUser->expects($this->once())
			->method('setEnabled')
			->with(false);
		$this->userManager
			->expects($this->once())
			->method('get')
			->with('RequestedUser')
			->will($this->returnValue($targetUser));
		$loggedInUser = $this->getMockBuilder('\OCP\IUser')->disableOriginalConstructor()->getMock();
		$loggedInUser
			->expects($this->exactly(2))
			->method('getUID')
			->will($this->returnValue('admin'));
		$this->userSession
			->expects($this->once())
			->method('getUser')
			->will($this->returnValue($loggedInUser));
		$this->groupManager
			->expects($this->once())
			->method('isAdmin')
			->will($this->returnValue(true));

		$this->assertEquals([], $this->api->disableUser('RequestedUser')->getData());
	}

	public function testGetCurrentUserLoggedIn() {

		$user = $this->getMock(IUser::class);
		$user->expects($this->once())->method('getUID')->willReturn('UID');

		$this->userSession->expects($this->once())->method('getUser')
			->willReturn($user);

		/** @var UsersController | PHPUnit_Framework_MockObject_MockObject $api */
		$api = $this->getMockBuilder('OCA\Provisioning_API\Controller\UsersController')
			->setConstructorArgs([
				'provisioning_api',
				$this->request,
				$this->userManager,
				$this->config,
				$this->groupManager,
				$this->userSession,
				$this->accountManager,
				$this->logger,
			])
			->setMethods(['getUser'])
			->getMock();

		$api->expects($this->once())->method('getUser')->with('UID')
			->willReturn(
				[
					'id' => 'UID',
					'enabled' => 'true',
					'quota' => ['DummyValue'],
					'email' => 'demo@owncloud.org',
					'displayname' => 'Demo User',
					'phone' => 'phone',
					'address' => 'address',
					'webpage' => 'website',
					'twitter' => 'twitter'
				]
			);

		$expected = [
			'id' => 'UID',
			'enabled' => 'true',
			'quota' => ['DummyValue'],
			'email' => 'demo@owncloud.org',
			'phone' => 'phone',
			'address' => 'address',
			'webpage' => 'website',
			'twitter' => 'twitter',
			'display-name' => 'Demo User'
		];

		$this->assertSame($expected, $api->getCurrentUser());
	}

	/**
	 * @expectedException \OCP\AppFramework\OCS\OCSException
	 */
	public function testGetCurrentUserNotLoggedIn() {

		$this->userSession->expects($this->once())->method('getUser')
			->willReturn(null);

		$this->api->getCurrentUser();
	}


}
