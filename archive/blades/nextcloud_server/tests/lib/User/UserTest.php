<?php

/**
 * Copyright (c) 2013 Robin Appelman <icewind@owncloud.com>
 * This file is licensed under the Affero General Public License version 3 or
 * later.
 * See the COPYING-README file.
 */

namespace Test\User;

use OC\Hooks\PublicEmitter;
use OC\User\User;
use OCP\Comments\ICommentsManager;
use OCP\IConfig;
use OCP\IUser;
use OCP\Notification\IManager as INotificationManager;
use OCP\Notification\INotification;
use Test\TestCase;

/**
 * Class UserTest
 *
 * @group DB
 *
 * @package Test\User
 */
class UserTest extends TestCase {
	public function testDisplayName() {
		/**
		 * @var \OC\User\Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\OC\User\Backend::class);
		$backend->expects($this->once())
			->method('getDisplayName')
			->with($this->equalTo('foo'))
			->will($this->returnValue('Foo'));

		$backend->expects($this->any())
			->method('implementsActions')
			->with($this->equalTo(\OC\User\Backend::GET_DISPLAYNAME))
			->will($this->returnValue(true));

		$user = new User('foo', $backend);
		$this->assertEquals('Foo', $user->getDisplayName());
	}

	/**
	 * if the display name contain whitespaces only, we expect the uid as result
	 */
	public function testDisplayNameEmpty() {
		/**
		 * @var \OC\User\Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\OC\User\Backend::class);
		$backend->expects($this->once())
			->method('getDisplayName')
			->with($this->equalTo('foo'))
			->will($this->returnValue('  '));

		$backend->expects($this->any())
			->method('implementsActions')
			->with($this->equalTo(\OC\User\Backend::GET_DISPLAYNAME))
			->will($this->returnValue(true));

		$user = new User('foo', $backend);
		$this->assertEquals('foo', $user->getDisplayName());
	}

	public function testDisplayNameNotSupported() {
		/**
		 * @var \OC\User\Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\OC\User\Backend::class);
		$backend->expects($this->never())
			->method('getDisplayName');

		$backend->expects($this->any())
			->method('implementsActions')
			->with($this->equalTo(\OC\User\Backend::GET_DISPLAYNAME))
			->will($this->returnValue(false));

		$user = new User('foo', $backend);
		$this->assertEquals('foo', $user->getDisplayName());
	}

	public function testSetPassword() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);
		$backend->expects($this->once())
			->method('setPassword')
			->with($this->equalTo('foo'), $this->equalTo('bar'));

		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnCallback(function ($actions) {
				if ($actions === \OC\User\Backend::SET_PASSWORD) {
					return true;
				} else {
					return false;
				}
			}));

		$user = new User('foo', $backend);
		$this->assertTrue($user->setPassword('bar',''));
	}

	public function testSetPasswordNotSupported() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);
		$backend->expects($this->never())
			->method('setPassword');

		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnValue(false));

		$user = new User('foo', $backend);
		$this->assertFalse($user->setPassword('bar',''));
	}

	public function testChangeAvatarSupportedYes() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(AvatarUserDummy::class);
		$backend->expects($this->once())
			->method('canChangeAvatar')
			->with($this->equalTo('foo'))
			->will($this->returnValue(true));

		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnCallback(function ($actions) {
				if ($actions === \OC\User\Backend::PROVIDE_AVATAR) {
					return true;
				} else {
					return false;
				}
			}));

		$user = new User('foo', $backend);
		$this->assertTrue($user->canChangeAvatar());
	}

	public function testChangeAvatarSupportedNo() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(AvatarUserDummy::class);
		$backend->expects($this->once())
			->method('canChangeAvatar')
			->with($this->equalTo('foo'))
			->will($this->returnValue(false));

		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnCallback(function ($actions) {
				if ($actions === \OC\User\Backend::PROVIDE_AVATAR) {
					return true;
				} else {
					return false;
				}
			}));

		$user = new User('foo', $backend);
		$this->assertFalse($user->canChangeAvatar());
	}

	public function testChangeAvatarNotSupported() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(AvatarUserDummy::class);
		$backend->expects($this->never())
			->method('canChangeAvatar');

		$backend->expects($this->any())
			->method('implementsActions')
			->willReturn(false);

		$user = new User('foo', $backend);
		$this->assertTrue($user->canChangeAvatar());
	}

	public function testDelete() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);
		$backend->expects($this->once())
			->method('deleteUser')
			->with($this->equalTo('foo'));

		$user = new User('foo', $backend);
		$this->assertTrue($user->delete());
	}

	public function testDeleteWithDifferentHome() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(Dummy::class);

		$backend->expects($this->at(0))
			->method('implementsActions')
			->will($this->returnCallback(function ($actions) {
				if ($actions === Backend::GET_HOME) {
					return true;
				} else {
					return false;
				}
			}));

		// important: getHome MUST be called before deleteUser because
		// once the user is deleted, getHome implementations might not
		// return anything
		$backend->expects($this->at(1))
			->method('getHome')
			->with($this->equalTo('foo'))
			->will($this->returnValue('/home/foo'));

		$backend->expects($this->at(2))
			->method('deleteUser')
			->with($this->equalTo('foo'));

		$user = new User('foo', $backend);
		$this->assertTrue($user->delete());
	}

	public function testGetHome() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);
		$backend->expects($this->once())
			->method('getHome')
			->with($this->equalTo('foo'))
			->will($this->returnValue('/home/foo'));

		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnCallback(function ($actions) {
				if ($actions === \OC\User\Backend::GET_HOME) {
					return true;
				} else {
					return false;
				}
			}));

		$user = new User('foo', $backend);
		$this->assertEquals('/home/foo', $user->getHome());
	}

	public function testGetBackendClassName() {
		$user = new User('foo', new \Test\Util\User\Dummy());
		$this->assertEquals('Dummy', $user->getBackendClassName());
		$user = new User('foo', new \OC\User\Database());
		$this->assertEquals('Database', $user->getBackendClassName());
	}

	public function testGetHomeNotSupported() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);
		$backend->expects($this->never())
			->method('getHome');

		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnValue(false));

		$allConfig = $this->getMockBuilder('\OCP\IConfig')
			->disableOriginalConstructor()
			->getMock();
		$allConfig->expects($this->any())
			->method('getUserValue')
			->will($this->returnValue(true));
		$allConfig->expects($this->any())
			->method('getSystemValue')
			->with($this->equalTo('datadirectory'))
			->will($this->returnValue('arbitrary/path'));

		$user = new User('foo', $backend, null, $allConfig);
		$this->assertEquals('arbitrary/path/foo', $user->getHome());
	}

	public function testCanChangePassword() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);

		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnCallback(function ($actions) {
				if ($actions === \OC\User\Backend::SET_PASSWORD) {
					return true;
				} else {
					return false;
				}
			}));

		$user = new User('foo', $backend);
		$this->assertTrue($user->canChangePassword());
	}

	public function testCanChangePasswordNotSupported() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);

		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnValue(false));

		$user = new User('foo', $backend);
		$this->assertFalse($user->canChangePassword());
	}

	public function testCanChangeDisplayName() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);

		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnCallback(function ($actions) {
				if ($actions === \OC\User\Backend::SET_DISPLAYNAME) {
					return true;
				} else {
					return false;
				}
			}));

		$user = new User('foo', $backend);
		$this->assertTrue($user->canChangeDisplayName());
	}

	public function testCanChangeDisplayNameNotSupported() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);

		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnValue(false));

		$user = new User('foo', $backend);
		$this->assertFalse($user->canChangeDisplayName());
	}

	public function testSetDisplayNameSupported() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\OC\User\Database::class);

		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnCallback(function ($actions) {
				if ($actions === \OC\User\Backend::SET_DISPLAYNAME) {
					return true;
				} else {
					return false;
				}
			}));

		$backend->expects($this->once())
			->method('setDisplayName')
			->with('foo','Foo')
			->willReturn(true);

		$user = new User('foo', $backend);
		$this->assertTrue($user->setDisplayName('Foo'));
		$this->assertEquals('Foo',$user->getDisplayName());
	}

	/**
	 * don't allow display names containing whitespaces only
	 */
	public function testSetDisplayNameEmpty() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\OC\User\Database::class);

		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnCallback(function ($actions) {
				if ($actions === \OC\User\Backend::SET_DISPLAYNAME) {
					return true;
				} else {
					return false;
				}
			}));

		$user = new User('foo', $backend);
		$this->assertFalse($user->setDisplayName(' '));
		$this->assertEquals('foo',$user->getDisplayName());
	}

	public function testSetDisplayNameNotSupported() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\OC\User\Database::class);

		$backend->expects($this->any())
			->method('implementsActions')
			->willReturn(false);

		$backend->expects($this->never())
			->method('setDisplayName');

		$user = new User('foo', $backend);
		$this->assertFalse($user->setDisplayName('Foo'));
		$this->assertEquals('foo',$user->getDisplayName());
	}

	public function testSetPasswordHooks() {
		$hooksCalled = 0;
		$test = $this;

		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);
		$backend->expects($this->once())
			->method('setPassword');

		/**
		 * @param User $user
		 * @param string $password
		 */
		$hook = function ($user, $password) use ($test, &$hooksCalled) {
			$hooksCalled++;
			$test->assertEquals('foo', $user->getUID());
			$test->assertEquals('bar', $password);
		};

		$emitter = new PublicEmitter();
		$emitter->listen('\OC\User', 'preSetPassword', $hook);
		$emitter->listen('\OC\User', 'postSetPassword', $hook);

		$backend->expects($this->any())
			->method('implementsActions')
			->will($this->returnCallback(function ($actions) {
				if ($actions === \OC\User\Backend::SET_PASSWORD) {
					return true;
				} else {
					return false;
				}
			}));

		$user = new User('foo', $backend, $emitter);

		$user->setPassword('bar','');
		$this->assertEquals(2, $hooksCalled);
	}

	public function dataDeleteHooks() {
		return [
			[true, 2],
			[false, 1],
		];
	}

	/**
	 * @dataProvider dataDeleteHooks
	 * @param bool $result
	 * @param int $expectedHooks
	 */
	public function testDeleteHooks($result, $expectedHooks) {
		$hooksCalled = 0;
		$test = $this;

		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);
		$backend->expects($this->once())
			->method('deleteUser')
			->willReturn($result);
		$emitter = new PublicEmitter();
		$user = new User('foo', $backend, $emitter);

		/**
		 * @param User $user
		 */
		$hook = function ($user) use ($test, &$hooksCalled) {
			$hooksCalled++;
			$test->assertEquals('foo', $user->getUID());
		};

		$emitter->listen('\OC\User', 'preDelete', $hook);
		$emitter->listen('\OC\User', 'postDelete', $hook);

		$config = $this->createMock(IConfig::class);
		$commentsManager = $this->createMock(ICommentsManager::class);
		$notificationManager = $this->createMock(INotificationManager::class);

		if ($result) {
			$config->expects($this->once())
				->method('deleteAllUserValues')
				->with('foo');

			$commentsManager->expects($this->once())
				->method('deleteReferencesOfActor')
				->with('users', 'foo');
			$commentsManager->expects($this->once())
				->method('deleteReadMarksFromUser')
				->with($user);

			$notification = $this->createMock(INotification::class);
			$notification->expects($this->once())
				->method('setUser')
				->with('foo');

			$notificationManager->expects($this->once())
				->method('createNotification')
				->willReturn($notification);
			$notificationManager->expects($this->once())
				->method('markProcessed')
				->with($notification);
		} else {
			$config->expects($this->never())
				->method('deleteAllUserValues');

			$commentsManager->expects($this->never())
				->method('deleteReferencesOfActor');
			$commentsManager->expects($this->never())
				->method('deleteReadMarksFromUser');

			$notificationManager->expects($this->never())
				->method('createNotification');
			$notificationManager->expects($this->never())
				->method('markProcessed');
		}

		$this->overwriteService('NotificationManager', $notificationManager);
		$this->overwriteService('CommentsManager', $commentsManager);
		$this->overwriteService('AllConfig', $config);

		$this->assertSame($result, $user->delete());

		$this->restoreService('AllConfig');
		$this->restoreService('CommentsManager');
		$this->restoreService('NotificationManager');

		$this->assertEquals($expectedHooks, $hooksCalled);
	}

	public function testGetCloudId() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);
		$urlGenerator = $this->getMockBuilder('\OC\URLGenerator')
				->setMethods(['getAbsoluteURL'])
				->disableOriginalConstructor()->getMock();
		$urlGenerator
				->expects($this->any())
				->method('getAbsoluteURL')
				->withAnyParameters()
				->willReturn('http://localhost:8888/owncloud');
		$user = new User('foo', $backend, null, null, $urlGenerator);
		$this->assertEquals('foo@localhost:8888/owncloud', $user->getCloudId());
	}

	public function testSetEMailAddressEmpty() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);

		$test = $this;
		$hooksCalled = 0;

		/**
		 * @param IUser $user
		 * @param string $feature
		 * @param string $value
		 */
		$hook = function (IUser $user, $feature, $value) use ($test, &$hooksCalled) {
			$hooksCalled++;
			$test->assertEquals('eMailAddress', $feature);
			$test->assertEquals('', $value);
		};

		$emitter = new PublicEmitter();
		$emitter->listen('\OC\User', 'changeUser', $hook);

		$config = $this->createMock(IConfig::class);
		$config->expects($this->once())
			->method('deleteUserValue')
			->with(
				'foo',
				'settings',
				'email'
			);

		$user = new User('foo', $backend, $emitter, $config);
		$user->setEMailAddress('');
	}

	public function testSetEMailAddress() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);

		$test = $this;
		$hooksCalled = 0;

		/**
		 * @param IUser $user
		 * @param string $feature
		 * @param string $value
		 */
		$hook = function (IUser $user, $feature, $value) use ($test, &$hooksCalled) {
			$hooksCalled++;
			$test->assertEquals('eMailAddress', $feature);
			$test->assertEquals('foo@bar.com', $value);
		};

		$emitter = new PublicEmitter();
		$emitter->listen('\OC\User', 'changeUser', $hook);

		$config = $this->createMock(IConfig::class);
		$config->expects($this->once())
			->method('setUserValue')
			->with(
				'foo',
				'settings',
				'email',
				'foo@bar.com'
			);

		$user = new User('foo', $backend, $emitter, $config);
		$user->setEMailAddress('foo@bar.com');
	}

	public function testGetLastLogin() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);

		$config = $this->createMock(IConfig::class);
		$config->method('getUserValue')
			->will($this->returnCallback(function ($uid, $app, $key, $default) {
				if ($uid === 'foo' && $app === 'login' && $key === 'lastLogin') {
					return 42;
				} else {
					return $default;
				}
			}));

		$user = new User('foo', $backend, null, $config);
		$this->assertSame(42, $user->getLastLogin());
	}

	public function testSetEnabled() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);

		$config = $this->createMock(IConfig::class);
		$config->expects($this->once())
			->method('setUserValue')
			->with(
				$this->equalTo('foo'),
				$this->equalTo('core'),
				$this->equalTo('enabled'),
				'true'
			);

		$user = new User('foo', $backend, null, $config);
		$user->setEnabled(true);
	}

	public function testSetDisabled() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);

		$config = $this->createMock(IConfig::class);
		$config->expects($this->once())
			->method('setUserValue')
			->with(
				$this->equalTo('foo'),
				$this->equalTo('core'),
				$this->equalTo('enabled'),
				'false'
			);

		$user = new User('foo', $backend, null, $config);
		$user->setEnabled(false);
	}

	public function testGetEMailAddress() {
		/**
		 * @var Backend | \PHPUnit_Framework_MockObject_MockObject $backend
		 */
		$backend = $this->createMock(\Test\Util\User\Dummy::class);

		$config = $this->createMock(IConfig::class);
		$config->method('getUserValue')
			->will($this->returnCallback(function ($uid, $app, $key, $default) {
				if ($uid === 'foo' && $app === 'settings' && $key === 'email') {
					return 'foo@bar.com';
				} else {
					return $default;
				}
			}));

		$user = new User('foo', $backend, null, $config);
		$this->assertSame('foo@bar.com', $user->getEMailAddress());
	}
}
