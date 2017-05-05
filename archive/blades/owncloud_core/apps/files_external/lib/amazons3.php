<?php

/**
 * ownCloud
 *
 * @author Michael Gapczynski
 * @author Christian Berendt
 * @copyright 2012 Michael Gapczynski mtgap@owncloud.com
 * @copyright 2013 Christian Berendt berendt@b1-systems.de
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
 */

namespace OC\Files\Storage;

set_include_path(get_include_path() . PATH_SEPARATOR .
	\OC_App::getAppPath('files_external') . '/3rdparty/aws-sdk-php');
require 'aws-autoloader.php';

use Aws\S3\S3Client;
use Aws\S3\Exception\S3Exception;

class AmazonS3 extends \OC\Files\Storage\Common {

	/**
	 * @var \Aws\S3\S3Client
	 */
	private $connection;
	/**
	 * @var string
	 */
	private $bucket;
	/**
	 * @var array
	 */
	private static $tmpFiles = array();
	/**
	 * @var bool
	 */
	private $test = false;
	/**
	 * @var int
	 */
	private $timeout = 15;

	/**
	 * @param string $path
	 * @return string correctly encoded path
	 */
	private function normalizePath($path) {
		$path = trim($path, '/');

		if (!$path) {
			$path = '.';
		}

		return $path;
	}

	private function testTimeout() {
		if ($this->test) {
			sleep($this->timeout);
		}
	}
	private function cleanKey($path) {
		if ($path === '.') {
			return '/';
		}
		return $path;
	}

	public function __construct($params) {
		if (!isset($params['key']) || !isset($params['secret']) || !isset($params['bucket'])) {
			throw new \Exception("Access Key, Secret and Bucket have to be configured.");
		}

		$this->id = 'amazon::' . $params['key'] . md5($params['secret']);

		$this->bucket = $params['bucket'];
		$scheme = ($params['use_ssl'] === 'false') ? 'http' : 'https';
		$this->test = isset($params['test']);
		$this->timeout = ( ! isset($params['timeout'])) ? 15 : $params['timeout'];
		$params['region'] = ( ! isset($params['region']) || $params['region'] === '' ) ? 'eu-west-1' : $params['region'];
		$params['hostname'] = ( !isset($params['hostname']) || $params['hostname'] === '' ) ? 's3.amazonaws.com' : $params['hostname'];
		if (!isset($params['port']) || $params['port'] === '') {
			$params['port'] = ($params['use_ssl'] === 'false') ? 80 : 443;
		}
		$base_url = $scheme.'://'.$params['hostname'].':'.$params['port'].'/';

		$this->connection = S3Client::factory(array(
			'key' => $params['key'],
			'secret' => $params['secret'],
			'base_url' => $base_url,
			'region' => $params['region']
		));

		if (!$this->connection->isValidBucketName($this->bucket)) {
			throw new \Exception("The configured bucket name is invalid.");
		}

		if (!$this->connection->doesBucketExist($this->bucket)) {
			try {
				$result = $this->connection->createBucket(array(
					'Bucket' => $this->bucket
				));
				$this->connection->waitUntilBucketExists(array(
					'Bucket' => $this->bucket,
					'waiter.interval' => 1,
					'waiter.max_attempts' => 15
				));
			$this->testTimeout();
			} catch (S3Exception $e) {
				\OCP\Util::writeLog('files_external', $e->getMessage(), \OCP\Util::ERROR);
				throw new \Exception("Creation of bucket failed.");
			}
		}
		if (!$this->file_exists('.')) {
			$result = $this->connection->putObject(array(
				'Bucket' => $this->bucket,
				'Key'    => $this->cleanKey('.'),
				'Body'   => '',
				'ContentType' => 'httpd/unix-directory',
				'ContentLength' => 0
			));
			$this->testTimeout();
		}
	}

	public function mkdir($path) {
		$path = $this->normalizePath($path);

		if ($this->is_dir($path)) {
			return false;
		}

		try {
			$result = $this->connection->putObject(array(
				'Bucket' => $this->bucket,
				'Key'    => $path . '/',
				'Body'   => '',
				'ContentType' => 'httpd/unix-directory',
				'ContentLength' => 0
			));
			$this->testTimeout();
		} catch (S3Exception $e) {
			\OCP\Util::writeLog('files_external', $e->getMessage(), \OCP\Util::ERROR);
			return false;
		}

		return true;
	}

	public function file_exists($path) {
		$path = $this->normalizePath($path);

		if (!$path) {
			$path = '.';
		} else if ($path != '.' && $this->is_dir($path)) {
			$path .= '/';
		}

		try {
			$result = $this->connection->doesObjectExist(
				$this->bucket,
				$this->cleanKey($path)
			);
		} catch (S3Exception $e) {
			\OCP\Util::writeLog('files_external', $e->getMessage(), \OCP\Util::ERROR);
			return false;
		}

		return $result;
	}


	public function rmdir($path) {
		$path = $this->normalizePath($path);

		if (!$this->file_exists($path)) {
			return false;
		}

		// Since there are no real directories on S3, we need
		// to delete all objects prefixed with the path.
		$objects = $this->connection->listObjects(array(
			'Bucket' => $this->bucket,
			'Prefix' => $path . '/'
		));

		try {
			$result = $this->connection->deleteObjects(array(
				'Bucket' => $this->bucket,
				'Objects' => $objects['Contents']
			));
			$this->testTimeout();
		} catch (S3Exception $e) {
			\OCP\Util::writeLog('files_external', $e->getMessage(), \OCP\Util::ERROR);
			return false;
		}

		return true;
	}

	public function opendir($path) {
		$path = $this->normalizePath($path);

		if ($path === '.') {
			$path = '';
		} else if ($path) {
			$path .= '/';
		}

		try {
			$files = array();
			$result = $this->connection->getIterator('ListObjects', array(
				'Bucket' => $this->bucket,
				'Delimiter' => '/',
				'Prefix' => $path
			), array('return_prefixes' => true));

			foreach ($result as $object) {
				$file = basename(
					isset($object['Key']) ? $object['Key'] : $object['Prefix']
				);

				if ($file != basename($path)) {
					$files[] = $file;
				}
			}

			\OC\Files\Stream\Dir::register('amazons3' . $path, $files);

			return opendir('fakedir://amazons3' . $path);
		} catch (S3Exception $e) {
			\OCP\Util::writeLog('files_external', $e->getMessage(), \OCP\Util::ERROR);
			return false;
		}
	}

	public function stat($path) {
		$path = $this->normalizePath($path);

		try {
			if ($this->is_dir($path) && $path != '.') {
				$path .= '/';
			}

			$result = $this->connection->headObject(array(
				'Bucket' => $this->bucket,
				'Key' => $this->cleanKey($path)
			));

			$stat = array();
			$stat['size'] = $result['ContentLength'] ? $result['ContentLength'] : 0;
			if ($result['Metadata']['lastmodified']) {
				$stat['mtime'] = strtotime($result['Metadata']['lastmodified']);
			} else {
				$stat['mtime'] = strtotime($result['LastModified']);
			}
			$stat['atime'] = time();

			return $stat;
		} catch(S3Exception $e) {
			\OCP\Util::writeLog('files_external', $e->getMessage(), \OCP\Util::ERROR);
			return false;
		}
	}

	public function filetype($path) {
		$path = $this->normalizePath($path);

		try {
			if ($path != '.' && $this->connection->doesObjectExist($this->bucket, $path)) {
				return 'file';
			}

			if ($path != '.') {
				$path .= '/';
			}
			if ($this->connection->doesObjectExist($this->bucket, $this->cleanKey($path))) {
				return 'dir';
			}
		} catch (S3Exception $e) {
			\OCP\Util::writeLog('files_external', $e->getMessage(), \OCP\Util::ERROR);
			return false;
		}

		return false;
	}

	public function unlink($path) {
		$path = $this->normalizePath($path);

		if ( $this->is_dir($path) ) {
			return $this->rmdir($path);
		}

		try {
			$result = $this->connection->deleteObject(array(
				'Bucket' => $this->bucket,
				'Key' => $this->cleanKey($path)
			));
			$this->testTimeout();
		} catch (S3Exception $e) {
			\OCP\Util::writeLog('files_external', $e->getMessage(), \OCP\Util::ERROR);
			return false;
		}

		return true;
	}

	public function fopen($path, $mode) {
		$path = $this->normalizePath($path);

		switch ($mode) {
			case 'r':
			case 'rb':
				$tmpFile = \OC_Helper::tmpFile();
				self::$tmpFiles[$tmpFile] = $path;

				try {
					$result = $this->connection->getObject(array(
						'Bucket' => $this->bucket,
						'Key' => $this->cleanKey($path),
						'SaveAs' => $tmpFile
					));
				} catch (S3Exception $e) {
					\OCP\Util::writeLog('files_external', $e->getMessage(), \OCP\Util::ERROR);
					return false;
				}

				return fopen($tmpFile, 'r');
			case 'w':
			case 'wb':
			case 'a':
			case 'ab':
			case 'r+':
			case 'w+':
			case 'wb+':
			case 'a+':
			case 'x':
			case 'x+':
			case 'c':
			case 'c+':
				if (strrpos($path, '.') !== false) {
					$ext = substr($path, strrpos($path, '.'));
				} else {
					$ext = '';
				}
				$tmpFile = \OC_Helper::tmpFile($ext);
				\OC\Files\Stream\Close::registerCallback($tmpFile, array($this, 'writeBack'));
				if ($this->file_exists($path)) {
					$source = $this->fopen($path, 'r');
					file_put_contents($tmpFile, $source);
				}
				self::$tmpFiles[$tmpFile] = $path;

				return fopen('close://' . $tmpFile, $mode);
		}
		return false;
	}

	public function getMimeType($path) {
		$path = $this->normalizePath($path);

		if ($this->is_dir($path)) {
			return 'httpd/unix-directory';
		} else if ($this->file_exists($path)) {
			try {
				$result = $this->connection->headObject(array(
					'Bucket' => $this->bucket,
					'Key' => $this->cleanKey($path)
				));
			} catch (S3Exception $e) {
				\OCP\Util::writeLog('files_external', $e->getMessage(), \OCP\Util::ERROR);
				return false;
			}

			return $result['ContentType'];
		}
		return false;
	}

	public function touch($path, $mtime = null) {
		$path = $this->normalizePath($path);

		$metadata = array();
		if (!is_null($mtime)) {
			$metadata = array('lastmodified' => $mtime);
		}

		try {
			if ($this->file_exists($path)) {
				if ($this->is_dir($path) && $path != '.') {
					$path .= '/';
				}
				$result = $this->connection->copyObject(array(
					'Bucket' => $this->bucket,
					'Key' => $this->cleanKey($path),
					'Metadata' => $metadata,
					'CopySource' => $this->bucket . '/' . $path
				));
				$this->testTimeout();
			} else {
				$result = $this->connection->putObject(array(
					'Bucket' => $this->bucket,
					'Key' => $this->cleanKey($path),
					'Metadata' => $metadata
				));
				$this->testTimeout();
			}
		} catch (S3Exception $e) {
			\OCP\Util::writeLog('files_external', $e->getMessage(), \OCP\Util::ERROR);
			return false;
		}

		return true;
	}

	public function copy($path1, $path2) {
		$path1 = $this->normalizePath($path1);
		$path2 = $this->normalizePath($path2);

		if ($this->is_file($path1)) {
			try {
				$result = $this->connection->copyObject(array(
					'Bucket' => $this->bucket,
					'Key' => $this->cleanKey($path2),
					'CopySource' => S3Client::encodeKey($this->bucket . '/' . $path1)
				));
				$this->testTimeout();
			} catch (S3Exception $e) {
				\OCP\Util::writeLog('files_external', $e->getMessage(), \OCP\Util::ERROR);
				return false;
			}
		} else {
			if ($this->file_exists($path2)) {
				return false;
			}

			try {
				$result = $this->connection->copyObject(array(
					'Bucket' => $this->bucket,
					'Key' => $path2 . '/',
					'CopySource' => S3Client::encodeKey($this->bucket . '/' . $path1 . '/')
				));
				$this->testTimeout();
			} catch (S3Exception $e) {
				\OCP\Util::writeLog('files_external', $e->getMessage(), \OCP\Util::ERROR);
				return false;
			}

			$dh = $this->opendir($path1);
			if(is_resource($dh)) {
				while (($file = readdir($dh)) !== false) {
					if ($file === '.' || $file === '..') {
						continue;
					}

					$source = $path1 . '/' . $file;
					$target = $path2 . '/' . $file;
					$this->copy($source, $target);
				}
			}
		}

		return true;
	}

	public function rename($path1, $path2) {
		$path1 = $this->normalizePath($path1);
		$path2 = $this->normalizePath($path2);

		if ($this->is_file($path1)) {
			if ($this->copy($path1, $path2) === false) {
				return false;
			}

			if ($this->unlink($path1) === false) {
				$this->unlink($path2);
				return false;
			}
		} else {
			if ($this->file_exists($path2)) {
				return false;
			}

			if ($this->copy($path1, $path2) === false) {
				return false;
			}

			if ($this->rmdir($path1) === false) {
				$this->rmdir($path2);
				return false;
			}
		}

		return true;
	}

	public function test() {
		$test = $this->connection->getBucketAcl(array(
			'Bucket' => $this->bucket,
		));
		if (isset($test) && !is_null($test->getPath('Owner/ID'))) {
			return true;
		}
		return false;
	}

	public function getId() {
		return $this->id;
	}

	public function getConnection() {
		return $this->connection;
	}

	public function writeBack($tmpFile) {
		if (!isset(self::$tmpFiles[$tmpFile])) {
			return false;
		}

		try {
			$result= $this->connection->putObject(array(
				'Bucket' => $this->bucket,
				'Key' => $this->cleanKey(self::$tmpFiles[$tmpFile]),
				'SourceFile' => $tmpFile,
				'ContentType' => \OC_Helper::getMimeType($tmpFile),
				'ContentLength' => filesize($tmpFile)
			));
			$this->testTimeout();

			unlink($tmpFile);
		} catch (S3Exception $e) {
			\OCP\Util::writeLog('files_external', $e->getMessage(), \OCP\Util::ERROR);
			return false;
		}
	}

	/**
	 * check if curl is installed
	 */
	public static function checkDependencies() {
		if (function_exists('curl_init')) {
			return true;
		} else {
			return array('curl');
		}
	}

}
