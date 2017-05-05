<?php
/**
 * @author Lukas Reschke <lukas@owncloud.com>
 *
 * @copyright Copyright (c) 2016, Lukas Reschke <lukas@statuscode.ch>
 * @copyright Copyright (c) 2015, ownCloud, Inc.
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

namespace Tests\Settings\Controller;

use OC\App\AppStore\Fetcher\AppFetcher;
use OC\App\AppStore\Fetcher\CategoryFetcher;
use OC\Settings\Controller\AppSettingsController;
use OCP\AppFramework\Http\ContentSecurityPolicy;
use OCP\AppFramework\Http\JSONResponse;
use OCP\AppFramework\Http\TemplateResponse;
use OCP\L10N\IFactory;
use Test\TestCase;
use OCP\IRequest;
use OCP\IL10N;
use OCP\IConfig;
use OCP\INavigationManager;
use OCP\App\IAppManager;

/**
 * Class AppSettingsControllerTest
 *
 * @package Tests\Settings\Controller
 */
class AppSettingsControllerTest extends TestCase {
	/** @var AppSettingsController */
	private $appSettingsController;
	/** @var IRequest|\PHPUnit_Framework_MockObject_MockObject */
	private $request;
	/** @var IL10N|\PHPUnit_Framework_MockObject_MockObject */
	private $l10n;
	/** @var IConfig|\PHPUnit_Framework_MockObject_MockObject */
	private $config;
	/** @var INavigationManager|\PHPUnit_Framework_MockObject_MockObject */
	private $navigationManager;
	/** @var IAppManager|\PHPUnit_Framework_MockObject_MockObject */
	private $appManager;
	/** @var CategoryFetcher|\PHPUnit_Framework_MockObject_MockObject */
	private $categoryFetcher;
	/** @var AppFetcher|\PHPUnit_Framework_MockObject_MockObject */
	private $appFetcher;
	/** @var IFactory|\PHPUnit_Framework_MockObject_MockObject */
	private $l10nFactory;

	public function setUp() {
		parent::setUp();

		$this->request = $this->createMock(IRequest::class);
		$this->l10n = $this->createMock(IL10N::class);
		$this->l10n->expects($this->any())
			->method('t')
			->will($this->returnArgument(0));
		$this->config = $this->createMock(IConfig::class);
		$this->navigationManager = $this->createMock(INavigationManager::class);
		$this->appManager = $this->createMock(IAppManager::class);
		$this->categoryFetcher = $this->createMock(CategoryFetcher::class);
		$this->appFetcher = $this->createMock(AppFetcher::class);
		$this->l10nFactory = $this->createMock(IFactory::class);

		$this->appSettingsController = new AppSettingsController(
			'settings',
			$this->request,
			$this->l10n,
			$this->config,
			$this->navigationManager,
			$this->appManager,
			$this->categoryFetcher,
			$this->appFetcher,
			$this->l10nFactory
		);
	}

	public function testListCategories() {
		$expected = new JSONResponse([
			[
				'id' => 0,
				'ident' => 'enabled',
				'displayName' => 'Enabled',
			],
			[
				'id' => 1,
				'ident' => 'disabled',
				'displayName' => 'Not enabled',
			],
			[
				'id' => 'auth',
				'ident' => 'auth',
				'displayName' => 'Authentication & authorization',
			],
			[
				'id' => 'customization',
				'ident' => 'customization',
				'displayName' => 'Customization',
			],
			[
				'id' => 'files',
				'ident' => 'files',
				'displayName' => 'Files',
			],
			[
				'id' => 'integration',
				'ident' => 'integration',
				'displayName' => 'Integration',
			],
			[
				'id' => 'monitoring',
				'ident' => 'monitoring',
				'displayName' => 'Monitoring',
			],
			[
				'id' => 'multimedia',
				'ident' => 'multimedia',
				'displayName' => 'Multimedia',
			],
			[
				'id' => 'office',
				'ident' => 'office',
				'displayName' => 'Office & text',
			],
			[
				'id' => 'organization',
				'ident' => 'organization',
				'displayName' => 'Organization',
			],
			[
				'id' => 'social',
				'ident' => 'social',
				'displayName' => 'Social & communication',
			],
			[
				'id' => 'tools',
				'ident' => 'tools',
				'displayName' => 'Tools',
			],
		]);

		$this->categoryFetcher
			->expects($this->once())
			->method('get')
			->willReturn(json_decode('[{"id":"auth","translations":{"cs":{"name":"Autentizace & autorizace","description":"Aplikace poskytující služby dodatečného ověření nebo přihlášení"},"hu":{"name":"Azonosítás és hitelesítés","description":"Apps that provide additional authentication or authorization services"},"de":{"name":"Authentifizierung & Authorisierung","description":"Apps die zusätzliche Autentifizierungs- oder Autorisierungsdienste bereitstellen"},"nl":{"name":"Authenticatie & authorisatie","description":"Apps die aanvullende authenticatie- en autorisatiediensten bieden"},"nb":{"name":"Pålogging og tilgangsstyring","description":"Apper for å tilby ekstra pålogging eller tilgangsstyring"},"it":{"name":"Autenticazione e autorizzazione","description":"Apps that provide additional authentication or authorization services"},"fr":{"name":"Authentification et autorisations","description":"Applications qui fournissent des services d\'authentification ou d\'autorisations additionnels."},"ru":{"name":"Аутентификация и авторизация","description":"Apps that provide additional authentication or authorization services"},"en":{"name":"Authentication & authorization","description":"Apps that provide additional authentication or authorization services"}}},{"id":"customization","translations":{"cs":{"name":"Přizpůsobení","description":"Motivy a aplikace měnící rozvržení a uživatelské rozhraní"},"it":{"name":"Personalizzazione","description":"Applicazioni di temi, modifiche della disposizione e UX"},"de":{"name":"Anpassung","description":"Apps zur Änderung von Themen, Layout und Benutzererfahrung"},"hu":{"name":"Személyre szabás","description":"Témák, elrendezések felhasználói felület módosító alkalmazások"},"nl":{"name":"Maatwerk","description":"Thema\'s, layout en UX aanpassingsapps"},"nb":{"name":"Tilpasning","description":"Apper for å endre Tema, utseende og brukeropplevelse"},"fr":{"name":"Personalisation","description":"Thèmes, apparence et applications modifiant l\'expérience utilisateur"},"ru":{"name":"Настройка","description":"Themes, layout and UX change apps"},"en":{"name":"Customization","description":"Themes, layout and UX change apps"}}},{"id":"files","translations":{"cs":{"name":"Soubory","description":"Aplikace rozšiřující správu souborů nebo aplikaci Soubory"},"it":{"name":"File","description":"Applicazioni di gestione dei file ed estensione dell\'applicazione FIle"},"de":{"name":"Dateien","description":"Dateimanagement sowie Erweiterungs-Apps für die Dateien-App"},"hu":{"name":"Fájlok","description":"Fájl kezelő és kiegészítő alkalmazások"},"nl":{"name":"Bestanden","description":"Bestandebeheer en uitbreidingen van bestand apps"},"nb":{"name":"Filer","description":"Apper for filhåndtering og filer"},"fr":{"name":"Fichiers","description":"Applications de gestion de fichiers et extensions à l\'application Fichiers"},"ru":{"name":"Файлы","description":"Расширение: файлы и управление файлами"},"en":{"name":"Files","description":"File management and Files app extension apps"}}},{"id":"integration","translations":{"it":{"name":"Integrazione","description":"Applicazioni che collegano Nextcloud con altri servizi e piattaforme"},"hu":{"name":"Integráció","description":"Apps that connect Nextcloud with other services and platforms"},"nl":{"name":"Integratie","description":"Apps die Nextcloud verbinden met andere services en platformen"},"nb":{"name":"Integrasjon","description":"Apper som kobler Nextcloud med andre tjenester og plattformer"},"de":{"name":"Integration","description":"Apps die Nextcloud mit anderen Diensten und Plattformen verbinden"},"cs":{"name":"Propojení","description":"Aplikace propojující NextCloud s dalšími službami a platformami"},"fr":{"name":"Intégration","description":"Applications qui connectent Nextcloud avec d\'autres services et plateformes"},"ru":{"name":"Интеграция","description":"Приложения, соединяющие Nextcloud с другими службами и платформами"},"en":{"name":"Integration","description":"Apps that connect Nextcloud with other services and platforms"}}},{"id":"monitoring","translations":{"nb":{"name":"Overvåking","description":"Apper for statistikk, systemdiagnose og aktivitet"},"it":{"name":"Monitoraggio","description":"Applicazioni di statistiche, diagnostica di sistema e attività"},"de":{"name":"Überwachung","description":"Datenstatistiken-, Systemdiagnose- und Aktivitäten-Apps"},"hu":{"name":"Megfigyelés","description":"Data statistics, system diagnostics and activity apps"},"nl":{"name":"Monitoren","description":"Gegevensstatistiek, systeem diagnose en activiteit apps"},"cs":{"name":"Kontrola","description":"Datové statistiky, diagnózy systému a aktivity aplikací"},"fr":{"name":"Surveillance","description":"Applications de statistiques sur les données, de diagnostics systèmes et d\'activité."},"ru":{"name":"Мониторинг","description":"Статистика данных, диагностика системы и активность приложений"},"en":{"name":"Monitoring","description":"Data statistics, system diagnostics and activity apps"}}},{"id":"multimedia","translations":{"nb":{"name":"Multimedia","description":"Apper for lyd, film og bilde"},"it":{"name":"Multimedia","description":"Applicazioni per audio, video e immagini"},"de":{"name":"Multimedia","description":"Audio-, Video- und Bilder-Apps"},"hu":{"name":"Multimédia","description":"Hang, videó és kép alkalmazások"},"nl":{"name":"Multimedia","description":"Audio, video en afbeelding apps"},"en":{"name":"Multimedia","description":"Audio, video and picture apps"},"cs":{"name":"Multimédia","description":"Aplikace audia, videa a obrázků"},"fr":{"name":"Multimédia","description":"Applications audio, vidéo et image"},"ru":{"name":"Мультимедиа","description":"Приложение аудио, видео и изображения"}}},{"id":"office","translations":{"nb":{"name":"Kontorstøtte og tekst","description":"Apper for Kontorstøtte og tekstbehandling"},"it":{"name":"Ufficio e testo","description":"Applicazione per ufficio ed elaborazione di testi"},"de":{"name":"Büro & Text","description":"Büro- und Textverarbeitungs-Apps"},"hu":{"name":"Iroda és szöveg","description":"Irodai és szöveg feldolgozó alkalmazások"},"nl":{"name":"Office & tekst","description":"Office en tekstverwerkingsapps"},"cs":{"name":"Kancelář a text","description":"Aplikace pro kancelář a zpracování textu"},"fr":{"name":"Bureautique & texte","description":"Applications de bureautique et de traitement de texte"},"en":{"name":"Office & text","description":"Office and text processing apps"}}},{"id":"organization","translations":{"nb":{"name":"Organisering","description":"Apper for tidsstyring, oppgaveliste og kalender"},"it":{"name":"Organizzazione","description":"Applicazioni di gestione del tempo, elenco delle cose da fare e calendario"},"hu":{"name":"Szervezet","description":"Időbeosztás, teendő lista és naptár alkalmazások"},"nl":{"name":"Organisatie","description":"Tijdmanagement, takenlijsten en agenda apps"},"cs":{"name":"Organizace","description":"Aplikace pro správu času, plánování a kalendáře"},"de":{"name":"Organisation","description":"Time management, Todo list and calendar apps"},"fr":{"name":"Organisation","description":"Applications de gestion du temps, de listes de tâches et d\'agendas"},"ru":{"name":"Организация","description":"Приложения по управлению временем, список задач и календарь"},"en":{"name":"Organization","description":"Time management, Todo list and calendar apps"}}},{"id":"social","translations":{"nb":{"name":"Sosialt og kommunikasjon","description":"Apper for meldinger, kontakthåndtering og sosiale medier"},"it":{"name":"Sociale e comunicazione","description":"Applicazioni di messaggistica, gestione dei contatti e reti sociali"},"de":{"name":"Kommunikation","description":"Nachrichten-, Kontaktverwaltungs- und Social-Media-Apps"},"hu":{"name":"Közösségi és kommunikáció","description":"Üzenetküldő, kapcsolat kezelő és közösségi média alkalmazások"},"nl":{"name":"Sociaal & communicatie","description":"Messaging, contactbeheer en social media apps"},"cs":{"name":"Sociální sítě a komunikace","description":"Aplikace pro zasílání zpráv, správu kontaktů a sociální sítě"},"fr":{"name":"Social & communication","description":"Applications de messagerie, de gestion de contacts et de réseaux sociaux"},"ru":{"name":"Социальное и связь","description":"Общение, управление контактами и социальное медиа-приложение"},"en":{"name":"Social & communication","description":"Messaging, contact management and social media apps"}}},{"id":"tools","translations":{"nb":{"name":"Verktøy","description":"Alt annet"},"it":{"name":"Strumenti","description":"Tutto il resto"},"hu":{"name":"Eszközök","description":"Minden más"},"nl":{"name":"Tools","description":"De rest"},"de":{"name":"Werkzeuge","description":"Alles Andere"},"en":{"name":"Tools","description":"Everything else"},"cs":{"name":"Nástroje","description":"Vše ostatní"},"fr":{"name":"Outils","description":"Tout le reste"},"ru":{"name":"Приложения","description":"Что-то еще"}}}]', true));

		$this->assertEquals($expected, $this->appSettingsController->listCategories());
	}

	public function testViewApps() {
		$this->config
			->expects($this->once())
			->method('getSystemValue')
			->with('appstoreenabled', true)
			->will($this->returnValue(true));
		$this->navigationManager
			->expects($this->once())
			->method('setActiveEntry')
			->with('core_apps');

		$policy = new ContentSecurityPolicy();
		$policy->addAllowedImageDomain('https://usercontent.apps.nextcloud.com');

		$expected = new TemplateResponse('settings', 'apps', ['category' => 'enabled', 'appstoreEnabled' => true], 'user');
		$expected->setContentSecurityPolicy($policy);

		$this->assertEquals($expected, $this->appSettingsController->viewApps());
	}

	public function testViewAppsAppstoreNotEnabled() {
		$this->config
			->expects($this->once())
			->method('getSystemValue')
			->with('appstoreenabled', true)
			->will($this->returnValue(false));
		$this->navigationManager
			->expects($this->once())
			->method('setActiveEntry')
			->with('core_apps');

		$policy = new ContentSecurityPolicy();
		$policy->addAllowedImageDomain('https://usercontent.apps.nextcloud.com');

		$expected = new TemplateResponse('settings', 'apps', ['category' => 'enabled', 'appstoreEnabled' => false], 'user');
		$expected->setContentSecurityPolicy($policy);

		$this->assertEquals($expected, $this->appSettingsController->viewApps());
	}
}
