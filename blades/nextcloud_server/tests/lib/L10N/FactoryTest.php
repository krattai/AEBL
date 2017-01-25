<?php
/**
 * Copyright (c) 2016 Joas Schilling <nickvergessen@owncloud.com>
 * This file is licensed under the Affero General Public License version 3 or
 * later.
 * See the COPYING-README file.
 */

namespace Test\L10N;

use OC\L10N\Factory;
use OCP\IConfig;
use OCP\IRequest;
use OCP\IUser;
use OCP\IUserSession;
use Test\TestCase;

/**
 * Class FactoryTest
 *
 * @package Test\L10N
 */
class FactoryTest extends TestCase {

	/** @var IConfig|\PHPUnit_Framework_MockObject_MockObject */
	protected $config;

	/** @var IRequest|\PHPUnit_Framework_MockObject_MockObject */
	protected $request;

	/** @var IUserSession|\PHPUnit_Framework_MockObject_MockObject */
	protected $userSession;

	/** @var string */
	protected $serverRoot;

	public function setUp() {
		parent::setUp();

		$this->config = $this->getMockBuilder(IConfig::class)
			->disableOriginalConstructor()
			->getMock();

		$this->request = $this->getMockBuilder(IRequest::class)
			->disableOriginalConstructor()
			->getMock();

		$this->userSession = $this->getMockBuilder(IUserSession::class)
			->disableOriginalConstructor()
			->getMock();

		$this->serverRoot = \OC::$SERVERROOT;
	}

	/**
	 * @param array $methods
	 * @return Factory|\PHPUnit_Framework_MockObject_MockObject
	 */
	protected function getFactory(array $methods = []) {
		if (!empty($methods)) {
			return $this->getMockBuilder(Factory::class)
				->setConstructorArgs([
					$this->config,
					$this->request,
					$this->userSession,
					$this->serverRoot,
				])
				->setMethods($methods)
				->getMock();
		} else {
			return new Factory($this->config, $this->request, $this->userSession, $this->serverRoot);
		}
	}

	public function dataFindAvailableLanguages() {
		return [
			[null],
			['files'],
		];
	}

	public function testFindLanguageWithExistingRequestLanguageAndNoApp() {
		$factory = $this->getFactory(['languageExists']);
		$this->invokePrivate($factory, 'requestLanguage', ['de']);
		$factory->expects($this->once())
			->method('languageExists')
			->with(null, 'de')
			->willReturn(true);

		$this->assertSame('de', $factory->findLanguage());
	}

	public function testFindLanguageWithExistingRequestLanguageAndApp() {
		$factory = $this->getFactory(['languageExists']);
		$this->invokePrivate($factory, 'requestLanguage', ['de']);
		$factory->expects($this->once())
				->method('languageExists')
				->with('MyApp', 'de')
				->willReturn(true);

		$this->assertSame('de', $factory->findLanguage('MyApp'));
	}

	public function testFindLanguageWithNotExistingRequestLanguageAndExistingStoredUserLanguage() {
		$factory = $this->getFactory(['languageExists']);
		$this->invokePrivate($factory, 'requestLanguage', ['de']);
		$factory->expects($this->at(0))
				->method('languageExists')
				->with('MyApp', 'de')
				->willReturn(false);
		$this->config
			->expects($this->once())
			->method('getSystemValue')
			->with('installed', false)
			->willReturn(true);
		$user = $this->getMockBuilder(IUser::class)
			->getMock();
		$user->expects($this->once())
			->method('getUID')
			->willReturn('MyUserUid');
		$this->userSession
			->expects($this->exactly(2))
			->method('getUser')
			->willReturn($user);
		$this->config
				->expects($this->once())
				->method('getUserValue')
				->with('MyUserUid', 'core', 'lang', null)
				->willReturn('jp');
		$factory->expects($this->at(1))
				->method('languageExists')
				->with('MyApp', 'jp')
				->willReturn(true);

		$this->assertSame('jp', $factory->findLanguage('MyApp'));
	}

	public function testFindLanguageWithNotExistingRequestLanguageAndNotExistingStoredUserLanguage() {
		$factory = $this->getFactory(['languageExists']);
		$this->invokePrivate($factory, 'requestLanguage', ['de']);
		$factory->expects($this->at(0))
				->method('languageExists')
				->with('MyApp', 'de')
				->willReturn(false);
		$this->config
				->expects($this->at(0))
				->method('getSystemValue')
				->with('installed', false)
				->willReturn(true);
		$user = $this->getMockBuilder(IUser::class)
			->getMock();
		$user->expects($this->once())
				->method('getUID')
				->willReturn('MyUserUid');
		$this->userSession
				->expects($this->exactly(2))
				->method('getUser')
				->willReturn($user);
		$this->config
				->expects($this->once())
				->method('getUserValue')
				->with('MyUserUid', 'core', 'lang', null)
				->willReturn('jp');
		$factory->expects($this->at(1))
				->method('languageExists')
				->with('MyApp', 'jp')
				->willReturn(false);
		$this->config
				->expects($this->at(2))
				->method('getSystemValue')
				->with('default_language', false)
				->willReturn('es');
		$factory->expects($this->at(2))
				->method('languageExists')
				->with('MyApp', 'es')
				->willReturn(true);

		$this->assertSame('es', $factory->findLanguage('MyApp'));
	}

	public function testFindLanguageWithNotExistingRequestLanguageAndNotExistingStoredUserLanguageAndNotExistingDefault() {
		$factory = $this->getFactory(['languageExists']);
		$this->invokePrivate($factory, 'requestLanguage', ['de']);
		$factory->expects($this->at(0))
				->method('languageExists')
				->with('MyApp', 'de')
				->willReturn(false);
		$this->config
				->expects($this->at(0))
				->method('getSystemValue')
				->with('installed', false)
				->willReturn(true);
		$user = $this->getMockBuilder(IUser::class)
			->getMock();
		$user->expects($this->once())
				->method('getUID')
				->willReturn('MyUserUid');
		$this->userSession
				->expects($this->exactly(2))
				->method('getUser')
				->willReturn($user);
		$this->config
				->expects($this->once())
				->method('getUserValue')
				->with('MyUserUid', 'core', 'lang', null)
				->willReturn('jp');
		$factory->expects($this->at(1))
				->method('languageExists')
				->with('MyApp', 'jp')
				->willReturn(false);
		$this->config
				->expects($this->at(2))
				->method('getSystemValue')
				->with('default_language', false)
				->willReturn('es');
		$factory->expects($this->at(2))
				->method('languageExists')
				->with('MyApp', 'es')
				->willReturn(false);
		$this->config
			->expects($this->never())
			->method('setUserValue');

		$this->assertSame('en', $factory->findLanguage('MyApp'));
	}

	public function testFindLanguageWithNotExistingRequestLanguageAndNotExistingStoredUserLanguageAndNotExistingDefaultAndNoAppInScope() {
		$factory = $this->getFactory(['languageExists']);
		$this->invokePrivate($factory, 'requestLanguage', ['de']);
		$factory->expects($this->at(0))
				->method('languageExists')
				->with('MyApp', 'de')
				->willReturn(false);
		$this->config
				->expects($this->at(0))
				->method('getSystemValue')
				->with('installed', false)
				->willReturn(true);
		$user = $this->getMockBuilder(IUser::class)
			->getMock();
		$user->expects($this->once())
				->method('getUID')
				->willReturn('MyUserUid');
		$this->userSession
				->expects($this->exactly(2))
				->method('getUser')
				->willReturn($user);
		$this->config
				->expects($this->once())
				->method('getUserValue')
				->with('MyUserUid', 'core', 'lang', null)
				->willReturn('jp');
		$factory->expects($this->at(1))
				->method('languageExists')
				->with('MyApp', 'jp')
				->willReturn(false);
		$this->config
				->expects($this->at(2))
				->method('getSystemValue')
				->with('default_language', false)
				->willReturn('es');
		$factory->expects($this->at(2))
				->method('languageExists')
				->with('MyApp', 'es')
				->willReturn(false);
		$this->config
				->expects($this->never())
				->method('setUserValue')
				->with('MyUserUid', 'core', 'lang', 'en');


		$this->assertSame('en', $factory->findLanguage('MyApp'));
	}

	/**
	 * @dataProvider dataFindAvailableLanguages
	 *
	 * @param string|null $app
	 */
	public function testFindAvailableLanguages($app) {
		$factory = $this->getFactory(['findL10nDir']);
		$factory->expects($this->once())
			->method('findL10nDir')
			->with($app)
			->willReturn(\OC::$SERVERROOT . '/tests/data/l10n/');

		$this->assertEquals(['cs', 'de', 'en', 'ru'], $factory->findAvailableLanguages($app), '', 0.0, 10, true);
	}

	public function dataLanguageExists() {
		return [
			[null, 'en', [], true],
			[null, 'de', [], false],
			[null, 'de', ['ru'], false],
			[null, 'de', ['ru', 'de'], true],
			['files', 'en', [], true],
			['files', 'de', [], false],
			['files', 'de', ['ru'], false],
			['files', 'de', ['de', 'ru'], true],
		];
	}

	public function testFindAvailableLanguagesWithThemes() {
		$this->serverRoot .= '/tests/data';
		$app = 'files';

		$factory = $this->getFactory(['findL10nDir']);
		$factory->expects($this->once())
			->method('findL10nDir')
			->with($app)
			->willReturn($this->serverRoot . '/apps/files/l10n/');
		$this->config
			->expects($this->once())
			->method('getSystemValue')
			->with('theme')
			->willReturn('abc');

		$this->assertEquals(['en', 'zz'], $factory->findAvailableLanguages($app), '', 0.0, 10, true);
	}

	/**
	 * @dataProvider dataLanguageExists
	 *
	 * @param string|null $app
	 * @param string $lang
	 * @param string[] $availableLanguages
	 * @param string $expected
	 */
	public function testLanguageExists($app, $lang, array $availableLanguages, $expected) {
		$factory = $this->getFactory(['findAvailableLanguages']);
		$factory->expects(($lang === 'en') ? $this->never() : $this->once())
			->method('findAvailableLanguages')
			->with($app)
			->willReturn($availableLanguages);

		$this->assertSame($expected, $factory->languageExists($app, $lang));
	}

	public function dataSetLanguageFromRequest() {
		return [
			// Language is available
			[null, 'de', null, ['de'], 'de', 'de'],
			[null, 'de,en', null, ['de'], 'de', 'de'],
			[null, 'de-DE,en-US;q=0.8,en;q=0.6', null, ['de'], 'de', 'de'],
			// Language is not available
			[null, 'de', null, ['ru'], 'en', 'en'],
			[null, 'de,en', null, ['ru', 'en'], 'en', 'en'],
			[null, 'de-DE,en-US;q=0.8,en;q=0.6', null, ['ru', 'en'], 'en', 'en'],
			// Language is available, but request language is set
			[null, 'de', 'ru', ['de'], 'de', 'ru'],
			[null, 'de,en', 'ru', ['de'], 'de', 'ru'],
			[null, 'de-DE,en-US;q=0.8,en;q=0.6', 'ru', ['de'], 'de', 'ru'],

			// Request lang should not be set for apps: Language is available
			['files_pdfviewer', 'de', null, ['de'], 'de', ''],
			['files_pdfviewer', 'de,en', null, ['de'], 'de', ''],
			['files_pdfviewer', 'de-DE,en-US;q=0.8,en;q=0.6', null, ['de'], 'de', ''],
			// Request lang should not be set for apps: Language is not available
			['files_pdfviewer', 'de', null, ['ru'], 'en', ''],
			['files_pdfviewer', 'de,en', null, ['ru', 'en'], 'en', ''],
			['files_pdfviewer', 'de-DE,en-US;q=0.8,en;q=0.6', null, ['ru', 'en'], 'en', ''],
		];
	}

	/**
	 * @dataProvider dataSetLanguageFromRequest
	 *
	 * @param string|null $app
	 * @param string $header
	 * @param string|null $requestLanguage
	 * @param string[] $availableLanguages
	 * @param string $expected
	 * @param string $expectedLang
	 */
	public function testSetLanguageFromRequest($app, $header, $requestLanguage, array $availableLanguages, $expected, $expectedLang) {
		$factory = $this->getFactory(['findAvailableLanguages']);
		$factory->expects($this->once())
			->method('findAvailableLanguages')
			->with($app)
			->willReturn($availableLanguages);

		$this->request->expects($this->once())
			->method('getHeader')
			->with('ACCEPT_LANGUAGE')
			->willReturn($header);

		if ($requestLanguage !== null) {
			$this->invokePrivate($factory, 'requestLanguage', [$requestLanguage]);
		}
		$this->assertSame($expected, $factory->setLanguageFromRequest($app), 'Asserting returned language');
		$this->assertSame($expectedLang, $this->invokePrivate($factory, 'requestLanguage'), 'Asserting stored language');
	}

	public function dataGetL10nFilesForApp() {
		return [
			[null, 'de', [\OC::$SERVERROOT . '/core/l10n/de.json']],
			['core', 'ru', [\OC::$SERVERROOT . '/core/l10n/ru.json']],
			['lib', 'ru', [\OC::$SERVERROOT . '/lib/l10n/ru.json']],
			['settings', 'de', [\OC::$SERVERROOT . '/settings/l10n/de.json']],
			['files', 'de', [\OC::$SERVERROOT . '/apps/files/l10n/de.json']],
			['files', '_lang_never_exists_', []],
			['_app_never_exists_', 'de', [\OC::$SERVERROOT . '/core/l10n/de.json']],
		];
	}

	/**
	 * @dataProvider dataGetL10nFilesForApp
	 *
	 * @param string|null $app
	 * @param string $expected
	 */
	public function testGetL10nFilesForApp($app, $lang, $expected) {
		$factory = $this->getFactory();
		$this->assertSame($expected, $this->invokePrivate($factory, 'getL10nFilesForApp', [$app, $lang]));
	}

	public function dataFindL10NDir() {
		return [
			[null, \OC::$SERVERROOT . '/core/l10n/'],
			['core', \OC::$SERVERROOT . '/core/l10n/'],
			['lib', \OC::$SERVERROOT . '/lib/l10n/'],
			['settings', \OC::$SERVERROOT . '/settings/l10n/'],
			['files', \OC::$SERVERROOT . '/apps/files/l10n/'],
			['_app_never_exists_', \OC::$SERVERROOT . '/core/l10n/'],
		];
	}

	/**
	 * @dataProvider dataFindL10NDir
	 *
	 * @param string|null $app
	 * @param string $expected
	 */
	public function testFindL10NDir($app, $expected) {
		$factory = $this->getFactory();
		$this->assertSame($expected, $this->invokePrivate($factory, 'findL10nDir', [$app]));
	}

	public function dataCreatePluralFunction() {
		return [
			['nplurals=2; plural=(n != 1);', 0, 1],
			['nplurals=2; plural=(n != 1);', 1, 0],
			['nplurals=2; plural=(n != 1);', 2, 1],
			['nplurals=3; plural=(n==1) ? 0 : (n>=2 && n<=4) ? 1 : 2;', 0, 2],
			['nplurals=3; plural=(n==1) ? 0 : (n>=2 && n<=4) ? 1 : 2;', 1, 0],
			['nplurals=3; plural=(n==1) ? 0 : (n>=2 && n<=4) ? 1 : 2;', 2, 1],
			['nplurals=3; plural=(n==1) ? 0 : (n>=2 && n<=4) ? 1 : 2;', 3, 1],
			['nplurals=3; plural=(n==1) ? 0 : (n>=2 && n<=4) ? 1 : 2;', 4, 1],
			['nplurals=3; plural=(n==1) ? 0 : (n>=2 && n<=4) ? 1 : 2;', 5, 2],
		];
	}

	/**
	 * @dataProvider dataCreatePluralFunction
	 *
	 * @param string $function
	 * @param int $count
	 * @param int $expected
	 */
	public function testCreatePluralFunction($function, $count, $expected) {
		$factory = $this->getFactory();
		$fn = $factory->createPluralFunction($function);
		$this->assertEquals($expected, $fn($count));
	}

	public function dataFindLanguage() {
		return [
			// Not logged in
			[false, [], 'en'],
			[false, ['fr'], 'fr'],
			[false, ['de', 'fr'], 'de'],
			[false, ['nl', 'de', 'fr'], 'de'],

			[true, [], 'en'],
			[true, ['fr'], 'fr'],
			[true, ['de', 'fr'], 'de'],
			[true, ['nl', 'de', 'fr'], 'nl'],
		];
	}

	/**
	 * @dataProvider dataFindLanguage
	 *
	 * @param bool $loggedIn
	 * @param array $availableLang
	 * @param string $expected
	 */
	public function testFindLanguage($loggedIn, $availableLang, $expected) {
		$userLang = 'nl';
		$browserLang = 'de';
		$defaultLang = 'fr';

		$this->config->expects($this->any())
			->method('getSystemValue')
			->will($this->returnCallback(function($var, $default) use ($defaultLang) {
				if ($var === 'installed') {
					return true;
				} else if ($var === 'default_language') {
					return $defaultLang;
				} else {
					return $default;
				}
			}));

		if ($loggedIn) {
			$user = $this->getMockBuilder(IUser::class)
				->getMock();
			$user->expects($this->any())
				->method('getUID')
				->willReturn('MyUserUid');
			$this->userSession
				->expects($this->any())
				->method('getUser')
				->willReturn($user);
			$this->config->expects($this->any())
				->method('getUserValue')
				->with('MyUserUid', 'core', 'lang', null)
				->willReturn($userLang);
		} else {
			$this->userSession
				->expects($this->any())
				->method('getUser')
				->willReturn(null);
		}

		$this->request->expects($this->any())
			->method('getHeader')
			->with($this->equalTo('ACCEPT_LANGUAGE'))
			->willReturn($browserLang);

		$factory = $this->getFactory(['languageExists', 'findAvailableLanguages']);
		$factory->expects($this->any())
			->method('languageExists')
			->will($this->returnCallback(function ($app, $lang) use ($availableLang) {
				return in_array($lang, $availableLang);
			}));
		$factory->expects($this->any())
			->method('findAvailableLanguages')
			->will($this->returnCallback(function ($app) use ($availableLang) {
				return $availableLang;
			}));

		$lang = $factory->findLanguage(null);
		$this->assertSame($expected, $lang);

	}
}
