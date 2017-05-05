<?php
/**
 * @copyright Copyright (c) 2016 Bjoern Schiessle <bjoern@schiessle.org>
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


namespace OCA\ShareByMail\Tests;


use OC\HintException;
use OCA\ShareByMail\ShareByMailProvider;
use OCP\Files\IRootFolder;
use OCP\IDBConnection;
use OCP\IL10N;
use OCP\ILogger;
use OCP\IURLGenerator;
use OCP\IUserManager;
use OCP\Mail\IMailer;
use OCP\Security\ISecureRandom;
use OCP\Share\Exceptions\ShareNotFound;
use OCP\Share\IManager;
use OCP\Share\IShare;
use Test\TestCase;

/**
 * Class ShareByMailProviderTest
 *
 * @package OCA\ShareByMail\Tests
 * @group DB
 */
class ShareByMailProviderTest extends TestCase {

	/** @var  IDBConnection */
	private $connection;

	/** @var  IManager */
	private $shareManager;

	/** @var  IL10N | \PHPUnit_Framework_MockObject_MockObject */
	private $l;

	/** @var  ILogger | \PHPUnit_Framework_MockObject_MockObject */
	private $logger;

	/** @var  IRootFolder | \PHPUnit_Framework_MockObject_MockObject */
	private $rootFolder;

	/** @var  IUserManager | \PHPUnit_Framework_MockObject_MockObject */
	private $userManager;

	/** @var  ISecureRandom | \PHPUnit_Framework_MockObject_MockObject */
	private $secureRandom;

	/** @var  IMailer | \PHPUnit_Framework_MockObject_MockObject */
	private $mailer;

	/** @var  IURLGenerator | \PHPUnit_Framework_MockObject_MockObject */
	private $urlGenerator;

	/** @var  IShare | \PHPUnit_Framework_MockObject_MockObject */
	private $share;

	/** @var  \OCP\Activity\IManager | \PHPUnit_Framework_MockObject_MockObject */
	private $activityManager;

	public function setUp() {
		parent::setUp();

		$this->shareManager = \OC::$server->getShareManager();
		$this->connection = \OC::$server->getDatabaseConnection();

		$this->l = $this->getMockBuilder('OCP\IL10N')->getMock();
		$this->l->method('t')
			->will($this->returnCallback(function($text, $parameters = []) {
				return vsprintf($text, $parameters);
			}));
		$this->logger = $this->getMockBuilder('OCP\ILogger')->getMock();
		$this->rootFolder = $this->getMockBuilder('OCP\Files\IRootFolder')->getMock();
		$this->userManager = $this->getMockBuilder('OCP\IUserManager')->getMock();
		$this->secureRandom = $this->getMockBuilder('\OCP\Security\ISecureRandom')->getMock();
		$this->mailer = $this->getMockBuilder('\OCP\Mail\IMailer')->getMock();
		$this->urlGenerator = $this->getMockBuilder('\OCP\IUrlGenerator')->getMock();
		$this->share = $this->getMockBuilder('\OCP\Share\IShare')->getMock();
		$this->activityManager = $this->getMockBuilder('OCP\Activity\IManager')->getMock();

		$this->userManager->expects($this->any())->method('userExists')->willReturn(true);
	}

	/**
	 * get instance of Mocked ShareByMailProvider
	 *
	 * @param array $mockedMethods internal methods which should be mocked
	 * @return \PHPUnit_Framework_MockObject_MockObject | ShareByMailProvider
	 */
	private function getInstance(array $mockedMethods = []) {

		$instance = $this->getMockBuilder('OCA\ShareByMail\ShareByMailProvider')
			->setConstructorArgs(
				[
					$this->connection,
					$this->secureRandom,
					$this->userManager,
					$this->rootFolder,
					$this->l,
					$this->logger,
					$this->mailer,
					$this->urlGenerator,
					$this->activityManager
				]
			);

		if (!empty($mockedMethods)) {
			$instance->setMethods($mockedMethods);
			return $instance->getMock();
		}

		return new ShareByMailProvider(
			$this->connection,
			$this->secureRandom,
			$this->userManager,
			$this->rootFolder,
			$this->l,
			$this->logger,
			$this->mailer,
			$this->urlGenerator,
			$this->activityManager
		);

	}

	public function tearDown() {
		$this->connection->getQueryBuilder()->delete('share')->execute();

		return parent::tearDown();
	}

	public function testCreate() {
		$share = $this->getMockBuilder('\OCP\Share\IShare')->getMock();
		$share->expects($this->once())->method('getSharedWith')->willReturn('user1');

		$instance = $this->getInstance(['getSharedWith', 'createMailShare', 'getRawShare', 'createShareObject', 'createActivity']);

		$instance->expects($this->once())->method('getSharedWith')->willReturn([]);
		$instance->expects($this->once())->method('createMailShare')->with($share)->willReturn(42);
		$instance->expects($this->once())->method('createActivity')->with($share);
		$instance->expects($this->once())->method('getRawShare')->with(42)->willReturn('rawShare');
		$instance->expects($this->once())->method('createShareObject')->with('rawShare')->willReturn('shareObject');

		$this->assertSame('shareObject',
			$instance->create($share)
		);
	}

	/**
	 * @expectedException \Exception
	 */
	public function testCreateFailed() {
		$this->share->expects($this->once())->method('getSharedWith')->willReturn('user1');
		$node = $this->getMockBuilder('OCP\Files\Node')->getMock();
		$node->expects($this->any())->method('getName')->willReturn('fileName');
		$this->share->expects($this->any())->method('getNode')->willReturn($node);

		$instance = $this->getInstance(['getSharedWith', 'createMailShare', 'getRawShare', 'createShareObject']);

		$instance->expects($this->once())->method('getSharedWith')->willReturn(['found']);
		$instance->expects($this->never())->method('createMailShare');
		$instance->expects($this->never())->method('getRawShare');
		$instance->expects($this->never())->method('createShareObject');

		$this->assertSame('shareObject',
			$instance->create($this->share)
		);
	}

	public function testCreateMailShare() {
		$this->share->expects($this->any())->method('getToken')->willReturn('token');
		$this->share->expects($this->once())->method('setToken')->with('token');
		$node = $this->getMockBuilder('OCP\Files\Node')->getMock();
		$node->expects($this->any())->method('getName')->willReturn('fileName');
		$this->share->expects($this->any())->method('getNode')->willReturn($node);

		$instance = $this->getInstance(['generateToken', 'addShareToDB', 'sendMailNotification']);

		$instance->expects($this->once())->method('generateToken')->willReturn('token');
		$instance->expects($this->once())->method('addShareToDB')->willReturn(42);
		$instance->expects($this->once())->method('sendMailNotification');
		$this->urlGenerator->expects($this->once())->method('linkToRouteAbsolute')
			->with('files_sharing.sharecontroller.showShare', ['token' => 'token']);
		$instance->expects($this->once())->method('sendMailNotification');

		$this->assertSame(42,
			$this->invokePrivate($instance, 'createMailShare', [$this->share])
		);

	}

	/**
	 * @expectedException \OC\HintException
	 */
	public function testCreateMailShareFailed() {
		$this->share->expects($this->any())->method('getToken')->willReturn('token');
		$this->share->expects($this->once())->method('setToken')->with('token');
		$node = $this->getMockBuilder('OCP\Files\Node')->getMock();
		$node->expects($this->any())->method('getName')->willReturn('fileName');
		$this->share->expects($this->any())->method('getNode')->willReturn($node);

		$instance = $this->getInstance(['generateToken', 'addShareToDB', 'sendMailNotification']);

		$instance->expects($this->once())->method('generateToken')->willReturn('token');
		$instance->expects($this->once())->method('addShareToDB')->willReturn(42);
		$instance->expects($this->once())->method('sendMailNotification');
		$this->urlGenerator->expects($this->once())->method('linkToRouteAbsolute')
			->with('files_sharing.sharecontroller.showShare', ['token' => 'token']);
		$instance->expects($this->once())->method('sendMailNotification')
			->willReturnCallback(
				function() {
					throw new \Exception('should be converted to a hint exception');
				}
			);

		$this->assertSame(42,
			$this->invokePrivate($instance, 'createMailShare', [$this->share])
		);

	}

	public function testGenerateToken() {
		$instance = $this->getInstance();

		$this->secureRandom->expects($this->once())->method('generate')->willReturn('token');

		$this->assertSame('token',
			$this->invokePrivate($instance, 'generateToken')
		);
	}

	public function testAddShareToDB() {
		$itemSource = 11;
		$itemType = 'file';
		$shareWith = 'user@server.com';
		$sharedBy = 'user1';
		$uidOwner = 'user2';
		$permissions = 1;
		$token = 'token';


		$instance = $this->getInstance();
		$id = $this->invokePrivate(
			$instance,
			'addShareToDB',
			[
				$itemSource,
				$itemType,
				$shareWith,
				$sharedBy,
				$uidOwner,
				$permissions,
				$token
			]
		);

		$qb = $this->connection->getQueryBuilder();
		$result = $qb->select('*')
			->from('share')
			->where($qb->expr()->eq('id', $qb->createNamedParameter($id)))
			->execute()->fetchAll();

		$this->assertSame(1, count($result));

		$this->assertSame($itemSource, (int)$result[0]['item_source']);
		$this->assertSame($itemType, $result[0]['item_type']);
		$this->assertSame($shareWith, $result[0]['share_with']);
		$this->assertSame($sharedBy, $result[0]['uid_initiator']);
		$this->assertSame($uidOwner, $result[0]['uid_owner']);
		$this->assertSame($permissions, (int)$result[0]['permissions']);
		$this->assertSame($token, $result[0]['token']);

	}

	public function testUpdate() {

		$itemSource = 11;
		$itemType = 'file';
		$shareWith = 'user@server.com';
		$sharedBy = 'user1';
		$uidOwner = 'user2';
		$permissions = 1;
		$token = 'token';


		$instance = $this->getInstance();

		$id = $this->createDummyShare($itemType, $itemSource, $shareWith, $sharedBy, $uidOwner, $permissions, $token);

		$this->share->expects($this->once())->method('getPermissions')->willReturn($permissions + 1);
		$this->share->expects($this->once())->method('getShareOwner')->willReturn($uidOwner);
		$this->share->expects($this->once())->method('getSharedBy')->willReturn($sharedBy);
		$this->share->expects($this->once())->method('getId')->willReturn($id);

		$this->assertSame($this->share,
			$instance->update($this->share)
		);

		$qb = $this->connection->getQueryBuilder();
		$result = $qb->select('*')
			->from('share')
			->where($qb->expr()->eq('id', $qb->createNamedParameter($id)))
			->execute()->fetchAll();

		$this->assertSame(1, count($result));

		$this->assertSame($itemSource, (int)$result[0]['item_source']);
		$this->assertSame($itemType, $result[0]['item_type']);
		$this->assertSame($shareWith, $result[0]['share_with']);
		$this->assertSame($sharedBy, $result[0]['uid_initiator']);
		$this->assertSame($uidOwner, $result[0]['uid_owner']);
		$this->assertSame($permissions + 1, (int)$result[0]['permissions']);
		$this->assertSame($token, $result[0]['token']);
	}

	public function testDelete() {
		$instance = $this->getInstance(['removeShareFromTable']);
		$this->share->expects($this->once())->method('getId')->willReturn(42);
		$instance->expects($this->once())->method('removeShareFromTable')->with(42);
		$instance->delete($this->share);
	}

	public function testGetShareById() {
		$instance = $this->getInstance(['createShareObject']);

		$itemSource = 11;
		$itemType = 'file';
		$shareWith = 'user@server.com';
		$sharedBy = 'user1';
		$uidOwner = 'user2';
		$permissions = 1;
		$token = 'token';

		$this->createDummyShare($itemType, $itemSource, $shareWith, "user1wrong", "user2wrong", $permissions, $token);
		$id2 = $this->createDummyShare($itemType, $itemSource, $shareWith, $sharedBy, $uidOwner, $permissions, $token);

		$instance->expects($this->once())->method('createShareObject')
			->willReturnCallback(
				function ($data) use ($uidOwner, $sharedBy, $id2) {
					$this->assertSame($uidOwner, $data['uid_owner']);
					$this->assertSame($sharedBy, $data['uid_initiator']);
					$this->assertSame($id2, (int)$data['id']);
					return $this->share;
				}
			);

		$result = $instance->getShareById($id2);

		$this->assertInstanceOf('OCP\Share\IShare', $result);
	}

	/**
	 * @expectedException \OCP\Share\Exceptions\ShareNotFound
	 */
	public function testGetShareByIdFailed() {
		$instance = $this->getInstance(['createShareObject']);

		$itemSource = 11;
		$itemType = 'file';
		$shareWith = 'user@server.com';
		$sharedBy = 'user1';
		$uidOwner = 'user2';
		$permissions = 1;
		$token = 'token';

		$id = $this->createDummyShare($itemType, $itemSource, $shareWith, $sharedBy, $uidOwner, $permissions, $token);

		$instance->getShareById($id+1);
	}

	public function testGetShareByPath() {

		$itemSource = 11;
		$itemType = 'file';
		$shareWith = 'user@server.com';
		$sharedBy = 'user1';
		$uidOwner = 'user2';
		$permissions = 1;
		$token = 'token';

		$node = $this->getMockBuilder('OCP\Files\Node')->getMock();
		$node->expects($this->once())->method('getId')->willReturn($itemSource);


		$instance = $this->getInstance(['createShareObject']);

		$this->createDummyShare($itemType, 111, $shareWith, $sharedBy, $uidOwner, $permissions, $token);
		$id = $this->createDummyShare($itemType, $itemSource, $shareWith, $sharedBy, $uidOwner, $permissions, $token);

		$instance->expects($this->once())->method('createShareObject')
			->willReturnCallback(
				function ($data) use ($uidOwner, $sharedBy, $id) {
					$this->assertSame($uidOwner, $data['uid_owner']);
					$this->assertSame($sharedBy, $data['uid_initiator']);
					$this->assertSame($id, (int)$data['id']);
					return $this->share;
				}
			);

		$result = $instance->getSharesByPath($node);

		$this->assertTrue(is_array($result));
		$this->assertSame(1, count($result));
		$this->assertInstanceOf('OCP\Share\IShare', $result[0]);
	}

	public function testGetShareByToken() {

		$itemSource = 11;
		$itemType = 'file';
		$shareWith = 'user@server.com';
		$sharedBy = 'user1';
		$uidOwner = 'user2';
		$permissions = 1;
		$token = 'token';

		$instance = $this->getInstance(['createShareObject']);

		$idMail = $this->createDummyShare($itemType, $itemSource, $shareWith, $sharedBy, $uidOwner, $permissions, $token);
		$idPublic = $this->createDummyShare($itemType, $itemSource, $shareWith, $sharedBy, $uidOwner, $permissions, $token, \OCP\Share::SHARE_TYPE_LINK);

		$this->assertTrue($idMail !== $idPublic);

		$instance->expects($this->once())->method('createShareObject')
			->willReturnCallback(
				function ($data) use ($idMail) {
					$this->assertSame($idMail, (int)$data['id']);
					return $this->share;
				}
			);

		$this->assertInstanceOf('OCP\Share\IShare',
			$instance->getShareByToken('token')
		);
	}

	/**
	 * @expectedException \OCP\Share\Exceptions\ShareNotFound
	 */
	public function testGetShareByTokenFailed() {

		$itemSource = 11;
		$itemType = 'file';
		$shareWith = 'user@server.com';
		$sharedBy = 'user1';
		$uidOwner = 'user2';
		$permissions = 1;
		$token = 'token';

		$instance = $this->getInstance(['createShareObject']);

		$idMail = $this->createDummyShare($itemType, $itemSource, $shareWith, $sharedBy, $uidOwner, $permissions, $token);
		$idPublic = $this->createDummyShare($itemType, $itemSource, $shareWith, $sharedBy, $uidOwner, $permissions, "token2", \OCP\Share::SHARE_TYPE_LINK);

		$this->assertTrue($idMail !== $idPublic);

		$this->assertInstanceOf('OCP\Share\IShare',
			$instance->getShareByToken('token2')
		);
	}

	public function testRemoveShareFromTable() {
		$itemSource = 11;
		$itemType = 'file';
		$shareWith = 'user@server.com';
		$sharedBy = 'user1';
		$uidOwner = 'user2';
		$permissions = 1;
		$token = 'token';

		$instance = $this->getInstance();

		$id = $this->createDummyShare($itemType, $itemSource, $shareWith, $sharedBy, $uidOwner, $permissions, $token);

		$query = $this->connection->getQueryBuilder();
		$query->select('*')->from('share')
			->where($query->expr()->eq('id', $query->createNamedParameter($id)));
		$before = $query->execute()->fetchAll();

		$this->assertTrue(is_array($before));
		$this->assertSame(1, count($before));

		$this->invokePrivate($instance, 'removeShareFromTable', [$id]);

		$query = $this->connection->getQueryBuilder();
		$query->select('*')->from('share')
			->where($query->expr()->eq('id', $query->createNamedParameter($id)));
		$after = $query->execute()->fetchAll();

		$this->assertTrue(is_array($after));
		$this->assertEmpty($after);
	}

	public function testUserDeleted() {

		$itemSource = 11;
		$itemType = 'file';
		$shareWith = 'user@server.com';
		$sharedBy = 'user1';
		$uidOwner = 'user2';
		$permissions = 1;
		$token = 'token';

		$this->createDummyShare($itemType, $itemSource, $shareWith, $sharedBy, $uidOwner, $permissions, $token);
		$id = $this->createDummyShare($itemType, $itemSource, $shareWith, $sharedBy, 'user2Wrong', $permissions, $token);

		$query = $this->connection->getQueryBuilder();
		$query->select('*')->from('share');
		$before = $query->execute()->fetchAll();

		$this->assertTrue(is_array($before));
		$this->assertSame(2, count($before));


		$instance = $this->getInstance();

		$instance->userDeleted($uidOwner, \OCP\Share::SHARE_TYPE_EMAIL);

		$query = $this->connection->getQueryBuilder();
		$query->select('*')->from('share');
		$after = $query->execute()->fetchAll();

		$this->assertTrue(is_array($after));
		$this->assertSame(1, count($after));
		$this->assertSame($id, (int)$after[0]['id']);

	}

	public function testGetRawShare() {
		$itemSource = 11;
		$itemType = 'file';
		$shareWith = 'user@server.com';
		$sharedBy = 'user1';
		$uidOwner = 'user2';
		$permissions = 1;
		$token = 'token';

		$instance = $this->getInstance();

		$id = $this->createDummyShare($itemType, $itemSource, $shareWith, $sharedBy, $uidOwner, $permissions, $token);

		$result = $this->invokePrivate($instance, 'getRawShare', [$id]);

		$this->assertTrue(is_array($result));
		$this->assertSame($itemSource, (int)$result['item_source']);
		$this->assertSame($itemType, $result['item_type']);
		$this->assertSame($shareWith, $result['share_with']);
		$this->assertSame($sharedBy, $result['uid_initiator']);
		$this->assertSame($uidOwner, $result['uid_owner']);
		$this->assertSame($permissions, (int)$result['permissions']);
		$this->assertSame($token, $result['token']);
	}

	/**
	 * @expectedException \OCP\Share\Exceptions\ShareNotFound
	 */
	public function testGetRawShareFailed() {
		$itemSource = 11;
		$itemType = 'file';
		$shareWith = 'user@server.com';
		$sharedBy = 'user1';
		$uidOwner = 'user2';
		$permissions = 1;
		$token = 'token';

		$instance = $this->getInstance();

		$id = $this->createDummyShare($itemType, $itemSource, $shareWith, $sharedBy, $uidOwner, $permissions, $token);

		$this->invokePrivate($instance, 'getRawShare', [$id+1]);
	}

	private function createDummyShare($itemType, $itemSource, $shareWith, $sharedBy, $uidOwner, $permissions, $token, $shareType = \OCP\Share::SHARE_TYPE_EMAIL) {
		$qb = $this->connection->getQueryBuilder();
		$qb->insert('share')
			->setValue('share_type', $qb->createNamedParameter($shareType))
			->setValue('item_type', $qb->createNamedParameter($itemType))
			->setValue('item_source', $qb->createNamedParameter($itemSource))
			->setValue('file_source', $qb->createNamedParameter($itemSource))
			->setValue('share_with', $qb->createNamedParameter($shareWith))
			->setValue('uid_owner', $qb->createNamedParameter($uidOwner))
			->setValue('uid_initiator', $qb->createNamedParameter($sharedBy))
			->setValue('permissions', $qb->createNamedParameter($permissions))
			->setValue('token', $qb->createNamedParameter($token))
			->setValue('stime', $qb->createNamedParameter(time()));

		/*
		 * Added to fix https://github.com/owncloud/core/issues/22215
		 * Can be removed once we get rid of ajax/share.php
		 */
		$qb->setValue('file_target', $qb->createNamedParameter(''));

		$qb->execute();
		$id = $qb->getLastInsertId();

		return (int)$id;
	}

	public function testGetSharesInFolder() {
		$userManager = \OC::$server->getUserManager();
		$rootFolder = \OC::$server->getRootFolder();

		$provider = $this->getInstance(['sendMailNotification', 'createActivity']);

		$u1 = $userManager->createUser('testFed', md5(time()));
		$u2 = $userManager->createUser('testFed2', md5(time()));

		$folder1 = $rootFolder->getUserFolder($u1->getUID())->newFolder('foo');
		$file1 = $folder1->newFile('bar1');
		$file2 = $folder1->newFile('bar2');

		$share1 = $this->shareManager->newShare();
		$share1->setSharedWith('user@server.com')
			->setSharedBy($u1->getUID())
			->setShareOwner($u1->getUID())
			->setPermissions(\OCP\Constants::PERMISSION_READ)
			->setNode($file1);
		$provider->create($share1);

		$share2 = $this->shareManager->newShare();
		$share2->setSharedWith('user@server.com')
			->setSharedBy($u2->getUID())
			->setShareOwner($u1->getUID())
			->setPermissions(\OCP\Constants::PERMISSION_READ)
			->setNode($file2);
		$provider->create($share2);

		$result = $provider->getSharesInFolder($u1->getUID(), $folder1, false);
		$this->assertCount(1, $result);
		$this->assertCount(1, $result[$file1->getId()]);

		$result = $provider->getSharesInFolder($u1->getUID(), $folder1, true);
		$this->assertCount(2, $result);
		$this->assertCount(1, $result[$file1->getId()]);
		$this->assertCount(1, $result[$file2->getId()]);

		$u1->delete();
		$u2->delete();
	}

}
