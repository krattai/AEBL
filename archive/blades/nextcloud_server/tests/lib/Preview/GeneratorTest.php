<?php
/**
 * @copyright Copyright (c) 2016, Roeland Jago Douma <roeland@famdouma.nl>
 *
 * @author Roeland Jago Douma <roeland@famdouma.nl>
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
namespace Test\Preview;

use OC\Preview\Generator;
use OC\Preview\GeneratorHelper;
use OCP\Files\File;
use OCP\Files\IAppData;
use OCP\Files\NotFoundException;
use OCP\Files\SimpleFS\ISimpleFile;
use OCP\Files\SimpleFS\ISimpleFolder;
use OCP\IConfig;
use OCP\IImage;
use OCP\IPreview;
use OCP\Preview\IProvider;
use Symfony\Component\EventDispatcher\EventDispatcherInterface;
use Symfony\Component\EventDispatcher\GenericEvent;

class GeneratorTest extends \Test\TestCase {

	/** @var IConfig|\PHPUnit_Framework_MockObject_MockObject */
	private $config;

	/** @var IPreview|\PHPUnit_Framework_MockObject_MockObject */
	private $previewManager;

	/** @var IAppData|\PHPUnit_Framework_MockObject_MockObject */
	private $appData;

	/** @var GeneratorHelper|\PHPUnit_Framework_MockObject_MockObject */
	private $helper;

	/** @var EventDispatcherInterface|\PHPUnit_Framework_MockObject_MockObject */
	private $eventDispatcher;

	/** @var Generator */
	private $generator;

	public function setUp() {
		parent::setUp();

		$this->config = $this->createMock(IConfig::class);
		$this->previewManager = $this->createMock(IPreview::class);
		$this->appData = $this->createMock(IAppData::class);
		$this->helper = $this->createMock(GeneratorHelper::class);
		$this->eventDispatcher = $this->createMock(EventDispatcherInterface::class);

		$this->generator = new Generator(
			$this->config,
			$this->previewManager,
			$this->appData,
			$this->helper,
			$this->eventDispatcher
		);
	}

	public function testGetCachedPreview() {
		$file = $this->createMock(File::class);
		$file->method('getMimeType')
			->willReturn('myMimeType');
		$file->method('getId')
			->willReturn(42);

		$this->previewManager->method('isMimeSupported')
			->with($this->equalTo('myMimeType'))
			->willReturn(true);

		$previewFolder = $this->createMock(ISimpleFolder::class);
		$this->appData->method('getFolder')
			->with($this->equalTo(42))
			->willReturn($previewFolder);

		$maxPreview = $this->createMock(ISimpleFile::class);
		$maxPreview->method('getName')
			->willReturn('1000-1000-max.png');

		$previewFolder->method('getDirectoryListing')
			->willReturn([$maxPreview]);

		$previewFile = $this->createMock(ISimpleFile::class);

		$previewFolder->method('getFile')
			->with($this->equalTo('128-128.png'))
			->willReturn($previewFile);

		$this->eventDispatcher->expects($this->once())
			->method('dispatch')
			->with(
				$this->equalTo(IPreview::EVENT),
				$this->callback(function(GenericEvent $event) use ($file) {
					return $event->getSubject() === $file &&
						$event->getArgument('width') === 100 &&
						$event->getArgument('height') === 100;
				})
			);

		$result = $this->generator->getPreview($file, 100, 100);
		$this->assertSame($previewFile, $result);
	}

	public function testGetNewPreview() {
		$file = $this->createMock(File::class);
		$file->method('getMimeType')
			->willReturn('myMimeType');
		$file->method('getId')
			->willReturn(42);

		$this->previewManager->method('isMimeSupported')
			->with($this->equalTo('myMimeType'))
			->willReturn(true);

		$previewFolder = $this->createMock(ISimpleFolder::class);
		$this->appData->method('getFolder')
			->with($this->equalTo(42))
			->willThrowException(new NotFoundException());

		$this->appData->method('newFolder')
			->with($this->equalTo(42))
			->willReturn($previewFolder);

		$this->config->method('getSystemValue')
			->will($this->returnCallback(function($key, $defult) {
				return $defult;
			}));

		$invalidProvider = $this->createMock(IProvider::class);
		$validProvider = $this->createMock(IProvider::class);

		$this->previewManager->method('getProviders')
			->willReturn([
				'/image\/png/' => ['wrongProvider'],
				'/myMimeType/' => ['brokenProvider', 'invalidProvider', 'validProvider'],
			]);

		$this->helper->method('getProvider')
			->will($this->returnCallback(function($provider) use ($invalidProvider, $validProvider) {
				if ($provider === 'wrongProvider') {
					$this->fail('Wrongprovider should not be constructed!');
				} else if ($provider === 'brokenProvider') {
					return false;
				} else if ($provider === 'invalidProvider') {
					return $invalidProvider;
				} else if ($provider === 'validProvider') {
					return $validProvider;
				}
				$this->fail('Unexpected provider requested');
			}));

		$image = $this->createMock(IImage::class);
		$image->method('width')->willReturn(2048);
		$image->method('height')->willReturn(2048);

		$this->helper->method('getThumbnail')
			->will($this->returnCallback(function ($provider, $file, $x, $y) use ($invalidProvider, $validProvider, $image) {
				if ($provider === $validProvider) {
					return $image;
				} else {
					return false;
				}
			}));

		$image->method('data')
			->willReturn('my data');

		$maxPreview = $this->createMock(ISimpleFile::class);
		$maxPreview->method('getName')->willReturn('2048-2048-max.png');

		$previewFile = $this->createMock(ISimpleFile::class);

		$previewFolder->method('getDirectoryListing')
			->willReturn([]);
		$previewFolder->method('newFile')
			->will($this->returnCallback(function($filename) use ($maxPreview, $previewFile) {
				if ($filename === '2048-2048-max.png') {
					return $maxPreview;
				} else if ($filename === '128-128.png') {
					return $previewFile;
				}
				$this->fail('Unexpected file');
			}));

		$maxPreview->expects($this->once())
			->method('putContent')
			->with($this->equalTo('my data'));

		$previewFolder->method('getFile')
			->with($this->equalTo('128-128.png'))
			->willThrowException(new NotFoundException());

		$image = $this->createMock(IImage::class);
		$this->helper->method('getImage')
			->with($this->equalTo($maxPreview))
			->willReturn($image);

		$image->expects($this->once())
			->method('resize')
			->with(128);
		$image->method('data')
			->willReturn('my resized data');

		$previewFile->expects($this->once())
			->method('putContent')
			->with('my resized data');

		$this->eventDispatcher->expects($this->once())
			->method('dispatch')
			->with(
				$this->equalTo(IPreview::EVENT),
				$this->callback(function(GenericEvent $event) use ($file) {
					return $event->getSubject() === $file &&
					$event->getArgument('width') === 100 &&
					$event->getArgument('height') === 100;
				})
			);

		$result = $this->generator->getPreview($file, 100, 100);
		$this->assertSame($previewFile, $result);
	}

	public function testInvalidMimeType() {
		$this->expectException(NotFoundException::class);

		$file = $this->createMock(File::class);

		$this->previewManager->method('isMimeSupported')
			->with('invalidType')
			->willReturn(false);

		$this->eventDispatcher->expects($this->once())
			->method('dispatch')
			->with(
				$this->equalTo(IPreview::EVENT),
				$this->callback(function(GenericEvent $event) use ($file) {
					return $event->getSubject() === $file &&
					$event->getArgument('width') === 0 &&
					$event->getArgument('height') === 0 &&
					$event->getArgument('crop') === true &&
					$event->getArgument('mode') === IPreview::MODE_COVER;
				})
			);

		$this->generator->getPreview($file, 0, 0, true, IPreview::MODE_COVER, 'invalidType');
	}

	public function testNoProvider() {
		$file = $this->createMock(File::class);
		$file->method('getMimeType')
			->willReturn('myMimeType');
		$file->method('getId')
			->willReturn(42);

		$this->previewManager->method('isMimeSupported')
			->with($this->equalTo('myMimeType'))
			->willReturn(true);

		$previewFolder = $this->createMock(ISimpleFolder::class);
		$this->appData->method('getFolder')
			->with($this->equalTo(42))
			->willReturn($previewFolder);

		$previewFolder->method('getDirectoryListing')
			->willReturn([]);

		$this->previewManager->method('getProviders')
			->willReturn([]);

		$this->eventDispatcher->expects($this->once())
			->method('dispatch')
			->with(
				$this->equalTo(IPreview::EVENT),
				$this->callback(function(GenericEvent $event) use ($file) {
					return $event->getSubject() === $file &&
					$event->getArgument('width') === 100 &&
					$event->getArgument('height') === 100;
				})
			);

		$this->expectException(NotFoundException::class);
		$this->generator->getPreview($file, 100, 100);
	}

	public function dataSize() {
		return [
			[1024, 2048, 512, 512, false, IPreview::MODE_FILL, 256, 512],
			[1024, 2048, 512, 512, false, IPreview::MODE_COVER, 512, 1024],
			[1024, 2048, 512, 512, true, IPreview::MODE_FILL, 512, 512],
			[1024, 2048, 512, 512, true, IPreview::MODE_COVER, 512, 512],

			[1024, 2048, -1, 512, false, IPreview::MODE_COVER, 256, 512],
			[1024, 2048, 512, -1, false, IPreview::MODE_FILL, 512, 1024],

			[1024, 2048, 250, 1100, true, IPreview::MODE_COVER, 256, 1126],
			[1024, 1100, 250, 1100, true, IPreview::MODE_COVER, 250, 1100],

			[1024, 2048, 4096, 2048, false, IPreview::MODE_FILL, 1024, 2048],
			[1024, 2048, 4096, 2048, false, IPreview::MODE_COVER, 1024, 2048],


			[2048, 1024, 512, 512, false, IPreview::MODE_FILL, 512, 256],
			[2048, 1024, 512, 512, false, IPreview::MODE_COVER, 1024, 512],
			[2048, 1024, 512, 512, true, IPreview::MODE_FILL, 512, 512],
			[2048, 1024, 512, 512, true, IPreview::MODE_COVER, 512, 512],

			[2048, 1024, -1, 512, false, IPreview::MODE_FILL, 1024, 512],
			[2048, 1024, 512, -1, false, IPreview::MODE_COVER, 512, 256],

			[2048, 1024, 4096, 1024, true, IPreview::MODE_FILL, 2048, 512],
			[2048, 1024, 4096, 1024, true, IPreview::MODE_COVER, 2048, 512],
		];
	}

	/**
	 * @dataProvider dataSize
	 *
	 * @param int $maxX
	 * @param int $maxY
	 * @param int $reqX
	 * @param int $reqY
	 * @param bool $crop
	 * @param string $mode
	 * @param int $expectedX
	 * @param int $expectedY
	 */
	public function testCorrectSize($maxX, $maxY, $reqX, $reqY, $crop, $mode, $expectedX, $expectedY) {
		$file = $this->createMock(File::class);
		$file->method('getMimeType')
			->willReturn('myMimeType');
		$file->method('getId')
			->willReturn(42);

		$this->previewManager->method('isMimeSupported')
			->with($this->equalTo('myMimeType'))
			->willReturn(true);

		$previewFolder = $this->createMock(ISimpleFolder::class);
		$this->appData->method('getFolder')
			->with($this->equalTo(42))
			->willReturn($previewFolder);

		$maxPreview = $this->createMock(ISimpleFile::class);
		$maxPreview->method('getName')
			->willReturn($maxX . '-' . $maxY . '-max.png');

		$previewFolder->method('getDirectoryListing')
			->willReturn([$maxPreview]);

		$filename = $expectedX . '-' . $expectedY;
		if ($crop) {
			$filename .= '-crop';
		}
		$filename .= '.png';
		$previewFolder->method('getFile')
			->with($this->equalTo($filename))
			->willThrowException(new NotFoundException());

		$image = $this->createMock(IImage::class);
		$this->helper->method('getImage')
			->with($this->equalTo($maxPreview))
			->willReturn($image);
		$image->method('height')->willReturn($maxY);
		$image->method('width')->willReturn($maxX);

		$preview = $this->createMock(ISimpleFile::class);
		$previewFolder->method('newFile')
			->with($this->equalTo($filename))
			->willReturn($preview);

		$this->eventDispatcher->expects($this->once())
			->method('dispatch')
			->with(
				$this->equalTo(IPreview::EVENT),
				$this->callback(function(GenericEvent $event) use ($file, $reqX, $reqY, $crop, $mode) {
					return $event->getSubject() === $file &&
					$event->getArgument('width') === $reqX &&
					$event->getArgument('height') === $reqY &&
					$event->getArgument('crop') === $crop &&
					$event->getArgument('mode') === $mode;
				})
			);

		$result = $this->generator->getPreview($file, $reqX, $reqY, $crop, $mode);
		$this->assertSame($preview, $result);
	}
}
