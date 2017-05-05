<?php
/**
 * ownCloud
 *
 * @author Sam Tuke
 * @copyright 2012 Sam Tuke samtuke@owncloud.com
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU AFFERO GENERAL PUBLIC LICENSE
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU AFFERO GENERAL PUBLIC LICENSE for more details.
 *
 * You should have received a copy of the GNU Affero General Public
 * License along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

namespace OCA\Encryption;

/**
 * Class for handling encryption related session data
 */

class Session {

	private $view;

	const NOT_INITIALIZED = '0';
	const INIT_EXECUTED = '1';
	const INIT_SUCCESSFUL = '2';


	/**
	 * if session is started, check if ownCloud key pair is set up, if not create it
	 * @param \OC\Files\View $view
	 *
	 * @note The ownCloud key pair is used to allow public link sharing even if encryption is enabled
	 */
	public function __construct($view) {

		$this->view = $view;

		if (!$this->view->is_dir('owncloud_private_key')) {

			$this->view->mkdir('owncloud_private_key');

		}

		$appConfig = \OC::$server->getAppConfig();

		$publicShareKeyId = $appConfig->getValue('files_encryption', 'publicShareKeyId');

		if ($publicShareKeyId === null) {
			$publicShareKeyId = 'pubShare_' . substr(md5(time()), 0, 8);
			$appConfig->setValue('files_encryption', 'publicShareKeyId', $publicShareKeyId);
		}

		if (
			!$this->view->file_exists("/public-keys/" . $publicShareKeyId . ".public.key")
			|| !$this->view->file_exists("/owncloud_private_key/" . $publicShareKeyId . ".private.key")
		) {

			$keypair = Crypt::createKeypair();

			// Disable encryption proxy to prevent recursive calls
			$proxyStatus = \OC_FileProxy::$enabled;
			\OC_FileProxy::$enabled = false;

			// Save public key

			if (!$view->is_dir('/public-keys')) {
				$view->mkdir('/public-keys');
			}

			$this->view->file_put_contents('/public-keys/' . $publicShareKeyId . '.public.key', $keypair['publicKey']);

			// Encrypt private key empty passphrase
			$cipher = \OCA\Encryption\Helper::getCipher();
			$encryptedKey = \OCA\Encryption\Crypt::symmetricEncryptFileContent($keypair['privateKey'], '', $cipher);
			if ($encryptedKey) {
				Keymanager::setPrivateSystemKey($encryptedKey, $publicShareKeyId . '.private.key');
			} else {
				\OCP\Util::writeLog('files_encryption', 'Could not create public share keys', \OCP\Util::ERROR);
			}

			\OC_FileProxy::$enabled = $proxyStatus;

		}

		if (\OCA\Encryption\Helper::isPublicAccess()) {
			// Disable encryption proxy to prevent recursive calls
			$proxyStatus = \OC_FileProxy::$enabled;
			\OC_FileProxy::$enabled = false;

			$encryptedKey = $this->view->file_get_contents(
				'/owncloud_private_key/' . $publicShareKeyId . '.private.key');
			$privateKey = Crypt::decryptPrivateKey($encryptedKey, '');
			$this->setPublicSharePrivateKey($privateKey);

			$this->setInitialized(\OCA\Encryption\Session::INIT_SUCCESSFUL);

			\OC_FileProxy::$enabled = $proxyStatus;
		}
	}

	/**
	 * Sets user private key to session
	 * @param string $privateKey
	 * @return bool
	 *
	 * @note this should only be set on login
	 */
	public function setPrivateKey($privateKey) {

		\OC::$server->getSession()->set('privateKey', $privateKey);

		return true;

	}

	/**
	 * remove keys from session
	 */
	public function removeKeys() {
		\OC::$session->remove('publicSharePrivateKey');
		\OC::$session->remove('privateKey');
	}

	/**
	 * Sets status of encryption app
	 * @param string $init INIT_SUCCESSFUL, INIT_EXECUTED, NOT_INITIALIZED
	 * @return bool
	 *
	 * @note this doesn not indicate of the init was successful, we just remeber the try!
	 */
	public function setInitialized($init) {

		\OC::$server->getSession()->set('encryptionInitialized', $init);

		return true;

	}

	/**
	 * remove encryption keys and init status from session
	 */
	public function closeSession() {
		\OC::$server->getSession()->remove('encryptionInitialized');
		\OC::$server->getSession()->remove('privateKey');
	}


	/**
	 * Gets status if we already tried to initialize the encryption app
	 * @return string init status INIT_SUCCESSFUL, INIT_EXECUTED, NOT_INITIALIZED
	 *
	 * @note this doesn not indicate of the init was successful, we just remeber the try!
	 */
	public function getInitialized() {
		if (!is_null(\OC::$server->getSession()->get('encryptionInitialized'))) {
			return \OC::$server->getSession()->get('encryptionInitialized');
		} else {
			return self::NOT_INITIALIZED;
		}
	}

	/**
	 * Gets user or public share private key from session
	 * @return string $privateKey The user's plaintext private key
	 *
	 */
	public function getPrivateKey() {
		// return the public share private key if this is a public access
		if (\OCA\Encryption\Helper::isPublicAccess()) {
			return $this->getPublicSharePrivateKey();
		} else {
			if (!is_null(\OC::$server->getSession()->get('privateKey'))) {
				return \OC::$server->getSession()->get('privateKey');
			} else {
				return false;
			}
		}
	}

	/**
	 * Sets public user private key to session
	 * @param string $privateKey
	 * @return bool
	 */
	public function setPublicSharePrivateKey($privateKey) {

		\OC::$server->getSession()->set('publicSharePrivateKey', $privateKey);

		return true;

	}

	/**
	 * Gets public share private key from session
	 * @return string $privateKey
	 *
	 */
	public function getPublicSharePrivateKey() {

		if (!is_null(\OC::$server->getSession()->get('publicSharePrivateKey'))) {
			return \OC::$server->getSession()->get('publicSharePrivateKey');
		} else {
			return false;
		}
	}

}
