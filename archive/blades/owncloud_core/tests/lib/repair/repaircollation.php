<?php
/**
 * Copyright (c) 2014 Thomas Müller <deepdiver@owncloud.com>
 * This file is licensed under the Affero General Public License version 3 or
 * later.
 * See the COPYING-README file.
 */

class TestCollationRepair extends \OC\Repair\Collation {
	/**
	 * @param \Doctrine\DBAL\Connection $connection
	 * @return string[]
	 */
	public function getAllNonUTF8BinTables($connection) {
		return parent::getAllNonUTF8BinTables($connection);
	}
}

/**
 * Tests for the converting of MySQL tables to InnoDB engine
 *
 * @see \OC\Repair\RepairMimeTypes
 */
class TestRepairCollation extends PHPUnit_Framework_TestCase {

	/**
	 * @var TestCollationRepair
	 */
	private $repair;

	/**
	 * @var \Doctrine\DBAL\Connection
	 */
	private $connection;

	/**
	 * @var string
	 */
	private $tableName;

	/**
	 * @var \OCP\IConfig
	 */
	private $config;

	public function setUp() {
		$this->connection = \OC_DB::getConnection();
		$this->config = \OC::$server->getConfig();
		if (!$this->connection->getDatabasePlatform() instanceof \Doctrine\DBAL\Platforms\MySqlPlatform) {
			$this->markTestSkipped("Test only relevant on MySql");
		}

		$dbPrefix = $this->config->getSystemValue("dbtableprefix");
		$this->tableName = uniqid($dbPrefix . "_collation_test");
		$this->connection->exec("CREATE TABLE $this->tableName(text VARCHAR(16)) COLLATE utf8_unicode_ci");

		$this->repair = new TestCollationRepair($this->config, $this->connection);
	}

	public function tearDown() {
		$this->connection->getSchemaManager()->dropTable($this->tableName);
	}

	public function testCollationConvert() {
		$tables = $this->repair->getAllNonUTF8BinTables($this->connection);
		$this->assertGreaterThanOrEqual(1, count($tables));

		$this->repair->run();

		$tables = $this->repair->getAllNonUTF8BinTables($this->connection);
		$this->assertCount(0, $tables);
	}
}
