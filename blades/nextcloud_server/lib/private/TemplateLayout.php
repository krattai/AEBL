<?php
/**
 * @copyright Copyright (c) 2016, ownCloud, Inc.
 *
 * @author Bart Visscher <bartv@thisnet.nl>
 * @author Christopher Schäpers <kondou@ts.unde.re>
 * @author Clark Tomlinson <fallen013@gmail.com>
 * @author Hendrik Leppelsack <hendrik@leppelsack.de>
 * @author Joas Schilling <coding@schilljs.com>
 * @author Jörn Friedrich Dreyer <jfd@butonic.de>
 * @author Lukas Reschke <lukas@statuscode.ch>
 * @author Michael Gapczynski <GapczynskiM@gmail.com>
 * @author Morris Jobke <hey@morrisjobke.de>
 * @author Remco Brenninkmeijer <requist1@starmail.nl>
 * @author Robin Appelman <robin@icewind.nl>
 * @author Robin McCorkell <robin@mccorkell.me.uk>
 * @author Roeland Jago Douma <roeland@famdouma.nl>
 * @author Thomas Müller <thomas.mueller@tmit.eu>
 * @author Victor Dubiniuk <dubiniuk@owncloud.com>
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
namespace OC;

use OC\Template\JSConfigHelper;
use OC\Template\SCSSCacher;

class TemplateLayout extends \OC_Template {

	private static $versionHash = '';

	/**
	 * @var \OCP\IConfig
	 */
	private $config;

	/**
	 * @param string $renderAs
	 * @param string $appId application id
	 */
	public function __construct( $renderAs, $appId = '' ) {

		// yes - should be injected ....
		$this->config = \OC::$server->getConfig();

		// Decide which page we show
		if($renderAs == 'user') {
			parent::__construct( 'core', 'layout.user' );
			if(in_array(\OC_App::getCurrentApp(), ['settings','admin', 'help']) !== false) {
				$this->assign('bodyid', 'body-settings');
			}else{
				$this->assign('bodyid', 'body-user');
			}

			// Code integrity notification
			$integrityChecker = \OC::$server->getIntegrityCodeChecker();
			if(\OC_User::isAdminUser(\OC_User::getUser()) && $integrityChecker->isCodeCheckEnforced() && !$integrityChecker->hasPassedCheck()) {
				\OCP\Util::addScript('core', 'integritycheck-failed-notification');
			}

			// Add navigation entry
			$this->assign( 'application', '');
			$this->assign( 'appid', $appId );
			$navigation = \OC_App::getNavigation();
			$this->assign( 'navigation', $navigation);
			$settingsNavigation = \OC_App::getSettingsNavigation();
			$this->assign( 'settingsnavigation', $settingsNavigation);
			foreach($navigation as $entry) {
				if ($entry['active']) {
					$this->assign( 'application', $entry['name'] );
					break;
				}
			}
			
			foreach($settingsNavigation as $entry) {
				if ($entry['active']) {
					$this->assign( 'application', $entry['name'] );
					break;
				}
			}
			$userDisplayName = \OC_User::getDisplayName();
			$appsMgmtActive = strpos(\OC::$server->getRequest()->getRequestUri(), \OC::$server->getURLGenerator()->linkToRoute('settings.AppSettings.viewApps')) === 0;
			if ($appsMgmtActive) {
				$l = \OC::$server->getL10N('lib');
				$this->assign('application', $l->t('Apps'));
			}
			$this->assign('user_displayname', $userDisplayName);
			$this->assign('user_uid', \OC_User::getUser());
			$this->assign('appsmanagement_active', $appsMgmtActive);
			$this->assign('enableAvatars', $this->config->getSystemValue('enable_avatars', true) === true);

			if (\OC_User::getUser() === false) {
				$this->assign('userAvatarSet', false);
			} else {
				$this->assign('userAvatarSet', \OC::$server->getAvatarManager()->getAvatar(\OC_User::getUser())->exists());
				$this->assign('userAvatarVersion', \OC::$server->getConfig()->getUserValue(\OC_User::getUser(), 'avatar', 'version', 0));
			}

		} else if ($renderAs == 'error') {
			parent::__construct('core', 'layout.guest', '', false);
			$this->assign('bodyid', 'body-login');
		} else if ($renderAs == 'guest') {
			parent::__construct('core', 'layout.guest');
			$this->assign('bodyid', 'body-login');
		} else {
			parent::__construct('core', 'layout.base');

		}
		// Send the language to our layouts
		$this->assign('language', \OC::$server->getL10NFactory()->findLanguage());

		if(\OC::$server->getSystemConfig()->getValue('installed', false)) {
			if (empty(self::$versionHash)) {
				$v = \OC_App::getAppVersions();
				$v['core'] = implode('.', \OCP\Util::getVersion());
				self::$versionHash = md5(implode(',', $v));
			}
		} else {
			self::$versionHash = md5('not installed');
		}

		// Add the js files
		$jsFiles = self::findJavascriptFiles(\OC_Util::$scripts);
		$this->assign('jsfiles', array());
		if ($this->config->getSystemValue('installed', false) && $renderAs != 'error') {
			if (\OC::$server->getContentSecurityPolicyNonceManager()->browserSupportsCspV3()) {
				$jsConfigHelper = new JSConfigHelper(
					\OC::$server->getL10N('core'),
					\OC::$server->getThemingDefaults(),
					\OC::$server->getAppManager(),
					\OC::$server->getSession(),
					\OC::$server->getUserSession()->getUser(),
					\OC::$server->getConfig(),
					\OC::$server->getGroupManager(),
					\OC::$server->getIniWrapper(),
					\OC::$server->getURLGenerator()
				);
				$this->assign('inline_ocjs', $jsConfigHelper->getConfig());
				$this->assign('foo', 'bar');
			} else {
				$this->append('jsfiles', \OC::$server->getURLGenerator()->linkToRoute('core.OCJS.getConfig', ['v' => self::$versionHash]));
			}
		}
		foreach($jsFiles as $info) {
			$web = $info[1];
			$file = $info[2];
			$this->append( 'jsfiles', $web.'/'.$file . $this->getVersionHashSuffix() );
		}

		// Do not initialise scss appdata until we have a fully installed instance
		// Do not load scss for update, errors, installation or login page
		if(\OC::$server->getSystemConfig()->getValue('installed', false)
			&& !\OCP\Util::needUpgrade()
			&& strpos(\OC::$server->getRequest()->getRequestUri(), \OC::$server->getURLGenerator()->linkToRoute('core.login.tryLogin')) !== 0) {
			$cssFiles = self::findStylesheetFiles(\OC_Util::$styles);
		} else {
			$cssFiles = self::findStylesheetFiles(\OC_Util::$styles, false);
		}
		$this->assign('cssfiles', array());
		$this->assign('printcssfiles', []);
		$this->assign('versionHash', self::$versionHash);
		foreach($cssFiles as $info) {
			$web = $info[1];
			$file = $info[2];

			if (substr($file, -strlen('print.css')) === 'print.css') {
				$this->append( 'printcssfiles', $web.'/'.$file . $this->getVersionHashSuffix() );
			} else {
				$this->append( 'cssfiles', $web.'/'.$file . $this->getVersionHashSuffix()  );
			}
		}
	}

	protected function getVersionHashSuffix() {
		if(\OC::$server->getConfig()->getSystemValue('debug', false)) {
			// allows chrome workspace mapping in debug mode
			return "";
		}

		return '?v=' . self::$versionHash;
	}

	/**
	 * @param array $styles
	 * @return array
	 */
	static public function findStylesheetFiles($styles, $compileScss = true) {
		// Read the selected theme from the config file
		$theme = \OC_Util::getTheme();

		if($compileScss) {
			$SCSSCacher = new SCSSCacher(
				\OC::$server->getLogger(),
				\OC::$server->getAppDataDir('css'),
				\OC::$server->getURLGenerator(),
				\OC::$server->getSystemConfig()
			);
		} else {
			$SCSSCacher = null;
		}

		$locator = new \OC\Template\CSSResourceLocator(
			\OC::$server->getLogger(),
			$theme,
			array( \OC::$SERVERROOT => \OC::$WEBROOT ),
			array( \OC::$SERVERROOT => \OC::$WEBROOT ),
			$SCSSCacher);
		$locator->find($styles);
		return $locator->getResources();
	}

	/**
	 * @param array $scripts
	 * @return array
	 */
	static public function findJavascriptFiles($scripts) {
		// Read the selected theme from the config file
		$theme = \OC_Util::getTheme();

		$locator = new \OC\Template\JSResourceLocator(
			\OC::$server->getLogger(),
			$theme,
			array( \OC::$SERVERROOT => \OC::$WEBROOT ),
			array( \OC::$SERVERROOT => \OC::$WEBROOT ));
		$locator->find($scripts);
		return $locator->getResources();
	}

	/**
	 * Converts the absolute file path to a relative path from \OC::$SERVERROOT
	 * @param string $filePath Absolute path
	 * @return string Relative path
	 * @throws \Exception If $filePath is not under \OC::$SERVERROOT
	 */
	public static function convertToRelativePath($filePath) {
		$relativePath = explode(\OC::$SERVERROOT, $filePath);
		if(count($relativePath) !== 2) {
			throw new \Exception('$filePath is not under the \OC::$SERVERROOT');
		}

		return $relativePath[1];
	}
}
