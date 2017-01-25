<?php
/**
 * @copyright Copyright (c) 2016 Joas Schilling <coding@schilljs.com>
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

namespace OCA\DAV\Tests\unit\CalDAV\Activity\Provider;

use OCA\DAV\CalDAV\Activity\Provider\Base;
use OCP\Activity\IEvent;
use OCP\Activity\IProvider;
use OCP\IUser;
use OCP\IUserManager;
use Test\TestCase;

class BaseTest extends TestCase {

	/** @var IUserManager|\PHPUnit_Framework_MockObject_MockObject */
	protected $userManager;

	/** @var IProvider|Base|\PHPUnit_Framework_MockObject_MockObject */
	protected $provider;

	protected function setUp() {
		parent::setUp();
		$this->userManager = $this->createMock(IUserManager::class);
		$this->provider = $this->getMockBuilder(Base::class)
			->setConstructorArgs([
				$this->userManager
			])
			->setMethods(['parse'])
			->getMock();
	}

	public function dataSetSubjects() {
		return [
			['abc', [], 'abc'],
			['{actor} created {calendar}', ['actor' => ['name' => 'abc'], 'calendar' => ['name' => 'xyz']], 'abc created xyz'],
		];
	}

	/**
	 * @dataProvider dataSetSubjects
	 * @param string $subject
	 * @param array $parameters
	 * @param string $parsedSubject
	 */
	public function testSetSubjects($subject, array $parameters, $parsedSubject) {
		$event = $this->createMock(IEvent::class);
		$event->expects($this->once())
			->method('setRichSubject')
			->with($subject, $parameters)
			->willReturnSelf();
		$event->expects($this->once())
			->method('setParsedSubject')
			->with($parsedSubject)
			->willReturnSelf();

		$this->invokePrivate($this->provider, 'setSubjects', [$event, $subject, $parameters]);
	}

	public function dataGenerateObjectParameter() {
		return [
			[23, 'c1'],
			[42, 'c2'],
		];
	}

	/**
	 * @dataProvider dataGenerateObjectParameter
	 * @param int $id
	 * @param string $name
	 */
	public function testGenerateObjectParameter($id, $name) {
		$this->assertEquals([
			'type' => 'calendar-event',
			'id' => $id,
			'name' => $name,
		], $this->invokePrivate($this->provider, 'generateObjectParameter', [['id' => $id, 'name' => $name]]));
	}

	public function dataGenerateObjectParameterThrows() {
		return [
			['event'],
			[['name' => 'event']],
			[['id' => 42]],
		];
	}

	/**
	 * @dataProvider dataGenerateObjectParameterThrows
	 * @expectedException \InvalidArgumentException
	 * @param mixed $eventData
	 */
	public function testGenerateObjectParameterThrows($eventData) {
		$this->invokePrivate($this->provider, 'generateObjectParameter', [$eventData]);
	}

	public function dataGenerateCalendarParameter() {
		return [
			[23, 'c1'],
			[42, 'c2'],
		];
	}

	/**
	 * @dataProvider dataGenerateCalendarParameter
	 * @param int $id
	 * @param string $name
	 */
	public function testGenerateCalendarParameter($id, $name) {
		$this->assertEquals([
			'type' => 'calendar',
			'id' => $id,
			'name' => $name,
		], $this->invokePrivate($this->provider, 'generateCalendarParameter', [$id, $name]));
	}

	public function dataGenerateGroupParameter() {
		return [
			['g1'],
			['g2'],
		];
	}

	/**
	 * @dataProvider dataGenerateGroupParameter
	 * @param string $gid
	 */
	public function testGenerateGroupParameter($gid) {
		$this->assertEquals([
			'type' => 'group',
			'id' => $gid,
			'name' => $gid,
		], $this->invokePrivate($this->provider, 'generateGroupParameter', [$gid]));
	}

	public function dataGenerateUserParameter() {
		$u1 = $this->createMock(IUser::class);
		$u1->expects($this->any())
			->method('getDisplayName')
			->willReturn('User 1');
		return [
			['u1', 'User 1', $u1],
			['u2', 'u2', null],
		];
	}

	/**
	 * @dataProvider dataGenerateUserParameter
	 * @param string $uid
	 * @param string $displayName
	 * @param IUser|null $user
	 */
	public function testGenerateUserParameter($uid, $displayName, $user) {
		$this->userManager->expects($this->once())
			->method('get')
			->with($uid)
			->willReturn($user);

		$this->assertEquals([
			'type' => 'user',
			'id' => $uid,
			'name' => $displayName,
		], $this->invokePrivate($this->provider, 'generateUserParameter', [$uid]));

		// Test caching (only 1 user manager invocation allowed)
		$this->assertEquals([
			'type' => 'user',
			'id' => $uid,
			'name' => $displayName,
		], $this->invokePrivate($this->provider, 'generateUserParameter', [$uid]));
	}
}
