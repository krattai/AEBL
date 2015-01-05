<map version="freeplane 1.2.0">
<!--To view this file, download free mind mapping software Freeplane from http://freeplane.sourceforge.net -->
<node TEXT="AEBL system" ID="Freemind_Link_1043402355" CREATED="1269462110846" MODIFIED="1414923521684">
<icon BUILTIN="gohome"/>
<hook NAME="MapStyle">

<map_styles>
<stylenode LOCALIZED_TEXT="styles.root_node">
<stylenode LOCALIZED_TEXT="styles.predefined" POSITION="right">
<stylenode LOCALIZED_TEXT="default" MAX_WIDTH="600" COLOR="#000000" STYLE="as_parent">
<font NAME="SansSerif" SIZE="10" BOLD="false" ITALIC="false"/>
</stylenode>
<stylenode LOCALIZED_TEXT="defaultstyle.details"/>
<stylenode LOCALIZED_TEXT="defaultstyle.note"/>
<stylenode LOCALIZED_TEXT="defaultstyle.floating">
<edge STYLE="hide_edge"/>
<cloud COLOR="#f0f0f0" SHAPE="ROUND_RECT"/>
</stylenode>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.user-defined" POSITION="right">
<stylenode LOCALIZED_TEXT="styles.topic" COLOR="#18898b" STYLE="fork">
<font NAME="Liberation Sans" SIZE="10" BOLD="true"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.subtopic" COLOR="#cc3300" STYLE="fork">
<font NAME="Liberation Sans" SIZE="10" BOLD="true"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.subsubtopic" COLOR="#669900">
<font NAME="Liberation Sans" SIZE="10" BOLD="true"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.important">
<icon BUILTIN="yes"/>
</stylenode>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.AutomaticLayout" POSITION="right">
<stylenode LOCALIZED_TEXT="AutomaticLayout.level.root" COLOR="#000000">
<font SIZE="18"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,1" COLOR="#0033ff">
<font SIZE="16"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,2" COLOR="#00b439">
<font SIZE="14"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,3" COLOR="#990000">
<font SIZE="12"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,4" COLOR="#111111">
<font SIZE="10"/>
</stylenode>
</stylenode>
</stylenode>
</map_styles>
</hook>
<node TEXT="AEBL core" POSITION="right" ID="_" CREATED="1269462169926" MODIFIED="1419460450429" HGAP="50" VSHIFT="-21">
<node TEXT="Prototype Development" ID="Freemind_Link_1948237358" CREATED="1269462283400" MODIFIED="1269462296310">
<node TEXT="specific to any new functions not already part of the core" ID="ID_1064129376" CREATED="1416163700225" MODIFIED="1416163749904"/>
<node TEXT="includes major updates to core" ID="ID_511280160" CREATED="1420402268957" MODIFIED="1420402301467"/>
<node TEXT="config file" ID="ID_481148730" CREATED="1417693184022" MODIFIED="1417693192228">
<node TEXT="include network config" ID="ID_863184324" CREATED="1417693307702" MODIFIED="1417693317647"/>
<node TEXT="include server IP if relevant" ID="ID_1712947505" CREATED="1417697064537" MODIFIED="1417697087479"/>
</node>
<node TEXT="configuration manager tool" ID="ID_1709308848" CREATED="1417779944197" MODIFIED="1417780010739">
<node TEXT="raspCTL performs this function" ID="ID_424310803" CREATED="1417780057991" MODIFIED="1417780080850">
<node TEXT="if raspCTL, then trim down to just configure and install blades" ID="ID_1781409653" CREATED="1417780137760" MODIFIED="1417780167298"/>
<node TEXT="default raspCTL features" ID="ID_20353327" CREATED="1418076501892" MODIFIED="1418076527770"/>
<node TEXT="should install as core" ID="ID_1413625358" CREATED="1418190661790" MODIFIED="1418190679608"/>
</node>
<node TEXT="include network config" ID="ID_495836027" CREATED="1418275798497" MODIFIED="1418275853784">
<node TEXT="wifi and cable" ID="ID_963767718" CREATED="1418421555802" MODIFIED="1418421568016">
<node TEXT="cable connection auto configure" ID="ID_1463283354" CREATED="1418495791735" MODIFIED="1418495805311"/>
<node TEXT="wifi config unique" ID="ID_872021162" CREATED="1418496087428" MODIFIED="1418496116722">
<node TEXT="flag for on / off" ID="ID_850266048" CREATED="1418496153508" MODIFIED="1418496167543"/>
<node TEXT="default settings" ID="ID_1974209834" CREATED="1418496232487" MODIFIED="1418496237411">
<node TEXT="wifi flag off" ID="ID_569295448" CREATED="1418496292412" MODIFIED="1418496301059"/>
<node TEXT="generic values for wifi" ID="ID_1278297705" CREATED="1418496336604" MODIFIED="1418496379254"/>
</node>
<node TEXT="Allow for open and encrypted" ID="ID_396991568" CREATED="1418496428245" MODIFIED="1418496447509"/>
<node TEXT="network scan feature" ID="ID_183649141" CREATED="1418496640845" MODIFIED="1418496658767"/>
</node>
</node>
</node>
<node TEXT="blades" ID="ID_389725559" CREATED="1418622291094" MODIFIED="1418622322108">
<node TEXT="installed" ID="ID_664522300" CREATED="1418707412289" MODIFIED="1418707428862">
<node TEXT="(in)active" ID="ID_172712540" CREATED="1418792113914" MODIFIED="1418792124419"/>
</node>
</node>
</node>
<node TEXT="determine hardware type" ID="ID_1454235360" CREATED="1419697829897" MODIFIED="1419697843407"/>
<node TEXT="AEBL VM" ID="ID_1266306378" CREATED="1419829742817" MODIFIED="1419918421527">
<node TEXT="video playback" ID="ID_126396039" CREATED="1418967951361" MODIFIED="1418967960322"/>
<node TEXT="audio playback" ID="ID_8691685" CREATED="1419010492028" MODIFIED="1419010498857"/>
</node>
<node TEXT="content crawler" ID="ID_1491521412" CREATED="1419981944717" MODIFIED="1419982008945">
<node TEXT="this is a working name" ID="ID_220955467" CREATED="1419982088342" MODIFIED="1419982097012"/>
<node TEXT="able to browse and collect content" ID="ID_633710779" CREATED="1419982105841" MODIFIED="1419982124654">
<node TEXT="local and remote" ID="ID_1459930657" CREATED="1420045435732" MODIFIED="1420045442227"/>
</node>
<node TEXT="see content_crawler.txt" ID="ID_1898195803" CREATED="1420182798091" MODIFIED="1420182810362"/>
<node TEXT="flexget" ID="ID_1947180018" CREATED="1420182883133" MODIFIED="1420183008976" LINK="http://flexget.com/"/>
<node TEXT="sick-beard" ID="ID_196389961" CREATED="1420183355437" MODIFIED="1420183371454" LINK="https://github.com/midgetspy/Sick-Beard"/>
<node TEXT="CouchPotato" ID="ID_603714376" CREATED="1420183403346" MODIFIED="1420183422662" LINK="https://couchpota.to/"/>
<node TEXT="Deluge" ID="ID_1044517846" CREATED="1420183454509" MODIFIED="1420183474017" LINK="http://deluge-torrent.org/"/>
<node TEXT="Plex" ID="ID_881687366" CREATED="1420183509093" MODIFIED="1420183523356" LINK="https://plex.tv/"/>
<node TEXT="OpenMediaVault" ID="ID_1980236207" CREATED="1420183580533" MODIFIED="1420183593071" LINK="http://www.openmediavault.org/"/>
</node>
<node TEXT="NAS" ID="ID_973833354" CREATED="1420054047585" MODIFIED="1420054062836"/>
<node TEXT="auto thumbdrive content" ID="ID_228740941" CREATED="1420054092886" MODIFIED="1420054140398"/>
<node TEXT="tweetbot" ID="ID_1208960364" CREATED="1420227796857" MODIFIED="1420227800073">
<node TEXT="OAuth tweeting" ID="ID_175107668" CREATED="1420223500616" MODIFIED="1420223523831" LINK="https://www.bentasker.co.uk/documentation/20-developmentprogramming/23-howto-tweet-from-bash-scripts-using-oauth">
<node TEXT="bash ready" ID="ID_589979534" CREATED="1420227641286" MODIFIED="1420227653411"/>
<node TEXT="tcli.zip contains files" ID="ID_1282589937" CREATED="1420227694641" MODIFIED="1420227705798"/>
</node>
<node TEXT="twython" ID="ID_1318675621" CREATED="1420228047593" MODIFIED="1420228064620" LINK="https://github.com/ryanmcgrath/twython"/>
<node TEXT="twitterbot instructable" ID="ID_1079604422" CREATED="1420228110753" MODIFIED="1420228134495" LINK="http://www.instructables.com/id/Raspberry-Pi-Twitterbot/?ALLSTEPS"/>
<node TEXT="twitter monitor" ID="ID_1502800099" CREATED="1420228183097" MODIFIED="1420228195504" LINK="https://learn.sparkfun.com/tutorials/raspberry-pi-twitter-monitor"/>
<node TEXT="should convert to C" ID="ID_1531200645" CREATED="1420228228457" MODIFIED="1420228241652"/>
</node>
<node TEXT="patch system upgrade" ID="ID_333515691" CREATED="1420401954862" MODIFIED="1420401963996">
<node TEXT="get patches from github" ID="ID_1941548697" CREATED="1420402000609" MODIFIED="1420402023981"/>
<node TEXT="honour old patch system and files" ID="ID_911120548" CREATED="1420402080741" MODIFIED="1420402103764"/>
</node>
<node TEXT="mediatomb blade" ID="ID_243844233" CREATED="1420416284446" MODIFIED="1420416332604">
<node TEXT="notes on mediatomb" ID="ID_832763002" CREATED="1420416345134" MODIFIED="1420416357157" LINK="http://mediatomb.cc/pages/documentation"/>
</node>
<node TEXT="AirTime blade" ID="ID_1411054759" CREATED="1420484460487" MODIFIED="1420484671747" LINK="https://www.sourcefabric.org/en/airtime/">
<node TEXT="apparently webmin can cause problem" ID="ID_1606606865" CREATED="1420484654643" MODIFIED="1420484679629" LINK="http://sourcefabric.booktype.pro/airtime-25-for-broadcasters/preparing-the-server/"/>
<node TEXT="manual installation" ID="ID_4133178" CREATED="1420484775868" MODIFIED="1420484786068" LINK="http://sourcefabric.booktype.pro/airtime-25-for-broadcasters/manual-installation/"/>
<node TEXT="automated installation" ID="ID_315724991" CREATED="1420496058461" MODIFIED="1420496080889" LINK="http://sourcefabric.booktype.pro/airtime-25-for-broadcasters/automated-installation/"/>
</node>
<node TEXT="compression blade" ID="ID_758771392" CREATED="1420496151303" MODIFIED="1420496157544">
<node TEXT="related to NAS" ID="ID_626429105" CREATED="1420496185077" MODIFIED="1420496199436"/>
<node TEXT="long term storage archive" ID="ID_808640446" CREATED="1420496226107" MODIFIED="1420496234420"/>
</node>
</node>
<node TEXT="Prototype Showcasing" ID="Freemind_Link_196559201" CREATED="1269462299880" MODIFIED="1269462316023">
<node TEXT="to be conducted via alpha and beta releases" ID="ID_1607155208" CREATED="1416163797345" MODIFIED="1416163811358"/>
</node>
<node TEXT="Develop production units" ID="Freemind_Link_708908499" CREATED="1269462320545" MODIFIED="1269462346329">
<node TEXT="integration of prototypes to core releases" ID="ID_944038600" CREATED="1416163874561" MODIFIED="1416163896554"/>
</node>
<node TEXT="Distribute units" ID="Freemind_Link_1715343041" CREATED="1269462359555" MODIFIED="1269462366089">
<node TEXT="making core release available to public" ID="ID_631516179" CREATED="1416164024105" MODIFIED="1416164051519"/>
</node>
<node TEXT="Document AEBL" ID="Freemind_Link_1252698133" CREATED="1269623451636" MODIFIED="1414923667622">
<node TEXT="core code flowcharts" ID="ID_1206235571" CREATED="1414927030668" MODIFIED="1414927085993"/>
<node TEXT="administration guide" ID="ID_304867297" CREATED="1414927095479" MODIFIED="1414927105226"/>
<node TEXT="user manual" ID="ID_1781367384" CREATED="1414927109026" MODIFIED="1414927114227"/>
</node>
<node TEXT="Development Toolset" ID="ID_242172053" CREATED="1419364187887" MODIFIED="1419364195273">
<node TEXT="examine possible toolsets" ID="ID_59190645" CREATED="1419441472331" MODIFIED="1419441503572"/>
<node TEXT="programming languages" ID="ID_1450752653" CREATED="1419500057180" MODIFIED="1419500068346">
<node TEXT="C" ID="ID_107925574" CREATED="1419500129659" MODIFIED="1419500134094">
<node TEXT="for realtime functions" ID="ID_7835576" CREATED="1420046880212" MODIFIED="1420046890098"/>
<node TEXT="for low level function" ID="ID_1956976764" CREATED="1420046931844" MODIFIED="1420046940194"/>
</node>
<node TEXT="bash" ID="ID_677103561" CREATED="1419500195273" MODIFIED="1419500207447">
<node TEXT="for prototyping" ID="ID_644474872" CREATED="1420046768883" MODIFIED="1420046774581"/>
<node TEXT="for system job control" ID="ID_1980728255" CREATED="1420046814932" MODIFIED="1420046824490"/>
</node>
<node TEXT="Assembly" ID="ID_36797270" CREATED="1419500268265" MODIFIED="1419500272684">
<node TEXT="for fine control" ID="ID_1592579071" CREATED="1420047002987" MODIFIED="1420047009066"/>
<node TEXT="for speed" ID="ID_1936032004" CREATED="1420047043331" MODIFIED="1420047062282"/>
</node>
<node TEXT="Go" ID="ID_877222892" CREATED="1419500306497" MODIFIED="1419500309393">
<node TEXT="no need to set GOROOT" ID="ID_1965390109" CREATED="1419545104432" MODIFIED="1419545119031"/>
<node TEXT="cross compile" ID="ID_795131357" CREATED="1419548027253" MODIFIED="1419548032026">
<node TEXT="goxc tool" ID="ID_634244686" CREATED="1419593820944" MODIFIED="1419593834947"/>
</node>
<node TEXT="for parallel processes" ID="ID_1309231942" CREATED="1420047097132" MODIFIED="1420047150042"/>
</node>
<node TEXT="other" ID="ID_1259013229" CREATED="1420046263444" MODIFIED="1420046271770">
<node TEXT="secondary" ID="ID_1232660087" CREATED="1420046302587" MODIFIED="1420046309474"/>
<node TEXT="for support of core code" ID="ID_1587028601" CREATED="1420046353996" MODIFIED="1420046366553"/>
<node TEXT="php, perl, python, java, js" ID="ID_1053189831" CREATED="1420046405613" MODIFIED="1420046424971"/>
</node>
</node>
<node TEXT="working OS" ID="ID_1234181298" CREATED="1419543390407" MODIFIED="1419543413658">
<node TEXT="ubuntu 14.04 64bit" ID="ID_1871027092" CREATED="1419543556655" MODIFIED="1419543581050"/>
</node>
<node TEXT="git / github" ID="ID_1746256255" CREATED="1420046515299" MODIFIED="1420046536436"/>
<node TEXT="eclipse" ID="ID_1497300094" CREATED="1420046569870" MODIFIED="1420046575902"/>
<node TEXT="dia" ID="ID_1138087280" CREATED="1420046615467" MODIFIED="1420046618705"/>
<node TEXT="freeplane" ID="ID_1357512479" CREATED="1420046646059" MODIFIED="1420046652963"/>
</node>
</node>
<node TEXT="Network" POSITION="left" ID="Freemind_Link_809364370" CREATED="1269462184478" MODIFIED="1269462534971" HGAP="21" VSHIFT="-39">
<node TEXT="Establish initial server" ID="Freemind_Link_1907216706" CREATED="1269462370428" MODIFIED="1269462383029">
<node TEXT="Created and delivered LAMP server" ID="Freemind_Link_45362831" CREATED="1269623333309" MODIFIED="1269623351412"/>
</node>
<node TEXT="Create failover servers" ID="Freemind_Link_299699653" CREATED="1269462387789" MODIFIED="1269462396883">
<node TEXT="R&amp;D failover server solution" ID="Freemind_Link_730764016" CREATED="1269623374839" MODIFIED="1269623386673"/>
</node>
<node TEXT="Establish streaming server" ID="Freemind_Link_1877115724" CREATED="1269462403102" MODIFIED="1269462411102">
<node TEXT="R&amp;D streaming server" ID="Freemind_Link_709334703" CREATED="1269623392800" MODIFIED="1269623399787"/>
</node>
<node TEXT="Document network" ID="Freemind_Link_255179581" CREATED="1269623464453" MODIFIED="1269623470263"/>
</node>
<node TEXT="AEBL blades" POSITION="right" ID="ID_830569553" CREATED="1414926214172" MODIFIED="1416174341351" VSHIFT="-20">
<node TEXT="core integration" ID="ID_196219513" CREATED="1414926269327" MODIFIED="1414926279549"/>
<node TEXT="blades" ID="ID_32077376" CREATED="1414926286103" MODIFIED="1414926289727">
<node TEXT="raspCTL" ID="ID_536154426" CREATED="1414926707654" MODIFIED="1414926713398">
<node TEXT="Prototype unmodified" ID="ID_302049388" CREATED="1416158773616" MODIFIED="1416158887651"/>
<node TEXT="Make changes for AEBL specific function" ID="ID_612489054" CREATED="1416158909545" MODIFIED="1416158953655"/>
</node>
<node TEXT="mediatomb" ID="ID_1034126241" CREATED="1416160059688" MODIFIED="1416160068613"/>
<node TEXT="icecast2" ID="ID_349004900" CREATED="1416160119505" MODIFIED="1416160133751"/>
<node TEXT="piui" ID="ID_704176070" CREATED="1416162144257" MODIFIED="1416162150847"/>
<node TEXT="owncloud" ID="ID_1686142785" CREATED="1416162220265" MODIFIED="1416162227231">
<node TEXT="owncloud notes" ID="ID_972549851" CREATED="1420416204687" MODIFIED="1420416217357" LINK="https://www.howtoforge.com/how-to-install-owncloud-7-on-ubuntu-14.04"/>
<node TEXT="first run" ID="ID_1137224168" CREATED="1420467129587" MODIFIED="1420467137958">
<node TEXT="create user pi password password" ID="ID_1061837574" CREATED="1420467170812" MODIFIED="1420467179592"/>
<node TEXT="database user root password password" ID="ID_543469846" CREATED="1420467217914" MODIFIED="1420467235986"/>
</node>
<node TEXT="create usage notes" ID="ID_1108347928" CREATED="1420481579447" MODIFIED="1420481591207"/>
</node>
<node TEXT="seafile" ID="ID_121833645" CREATED="1416162353161" MODIFIED="1416162356558"/>
<node TEXT="xtreemfs" ID="ID_325003429" CREATED="1416162390577" MODIFIED="1416162420952"/>
<node TEXT="Terra Vista" ID="ID_1669515084" CREATED="1416162478521" MODIFIED="1416162483959"/>
<node TEXT="noo-ebs" ID="ID_346129573" CREATED="1416187485572" MODIFIED="1416187493241"/>
<node TEXT="webmin blade" ID="ID_1493368120" CREATED="1420416026228" MODIFIED="1420416029895">
<node TEXT="notes for ubuntu" ID="ID_1587702566" CREATED="1420416077030" MODIFIED="1420416095574" LINK="http://ubuntuhandbook.org/index.php/2013/12/install-webmin-official-repository-ubuntu/"/>
</node>
</node>
</node>
<node TEXT="AEBL interfaces" POSITION="right" ID="ID_43537905" CREATED="1416159240121" MODIFIED="1416159305836" HGAP="40" VSHIFT="-40">
<node TEXT="AEBL Navigator" ID="ID_1406757722" CREATED="1416159343720" MODIFIED="1420257841870">
<node TEXT="need delete files doc function if not in place" ID="ID_1796691920" CREATED="1417693388126" MODIFIED="1417693447704"/>
<node TEXT="files to modify configuration / functionality" ID="ID_1210994575" CREATED="1417693495486" MODIFIED="1417693556766"/>
</node>
<node TEXT="AEBL Airtime" ID="ID_1807319122" CREATED="1416159434617" MODIFIED="1416159442107">
<node TEXT="curremtly running as virtual machine" ID="ID_1875474111" CREATED="1420257950067" MODIFIED="1420257966559"/>
<node TEXT="requires custom configuration" ID="ID_572695373" CREATED="1420257981859" MODIFIED="1420257997464"/>
<node TEXT="possibly a blade, eventually" ID="ID_969803629" CREATED="1420258001169" MODIFIED="1420258009193"/>
</node>
</node>
<node TEXT="Streaming" POSITION="right" ID="Freemind_Link_1631455944" CREATED="1269462208469" MODIFIED="1419460440629" HGAP="51" VSHIFT="-61">
<node TEXT="Prototype Development" ID="Freemind_Link_1676396090" CREATED="1269462453360" MODIFIED="1269462459716">
<node TEXT="Develop 1.0 prototype" ID="Freemind_Link_765523027" CREATED="1269622478219" MODIFIED="1269622488005"/>
</node>
<node TEXT="Prototype Showcasing" ID="Freemind_Link_1973894088" CREATED="1269462463298" MODIFIED="1269462469942"/>
<node TEXT="Develop production units" ID="Freemind_Link_627391337" CREATED="1269462472707" MODIFIED="1269462478302"/>
<node TEXT="Produce units" ID="Freemind_Link_1917493285" CREATED="1269462481154" MODIFIED="1269462484358"/>
<node TEXT="Distribute units" ID="Freemind_Link_370975554" CREATED="1269462487059" MODIFIED="1269462491952"/>
<node TEXT="Integrate with AEBL" ID="Freemind_Link_18800446" CREATED="1269622497279" MODIFIED="1414923571878"/>
<node TEXT="Document streaming system" ID="Freemind_Link_1629211406" CREATED="1269623475575" MODIFIED="1269623483257"/>
</node>
<node TEXT="Web Site" POSITION="left" ID="Freemind_Link_652055776" CREATED="1269462222165" MODIFIED="1269462539051" VSHIFT="-50">
<node TEXT="AEBL github project" ID="ID_1047986739" CREATED="1414925595972" MODIFIED="1414925735260" LINK="https://github.com/krattai/AEBL"/>
<node TEXT="AEBL blog" ID="ID_1791992662" CREATED="1414925788574" MODIFIED="1414925811103" LINK="http://aeblm2.blogspot.ca/"/>
<node TEXT="AEBL Twitter feed" ID="ID_1710510696" CREATED="1414925840608" MODIFIED="1414925894801" LINK="https://twitter.com/aeblm2"/>
</node>
<node TEXT="Standard Installations" POSITION="left" ID="Freemind_Link_1871331892" CREATED="1269462240317" MODIFIED="1416174304899" HGAP="40" VSHIFT="-20"/>
<node TEXT="Marketing / promotion" POSITION="left" ID="Freemind_Link_578657518" CREATED="1269545354524" MODIFIED="1416796948825" HGAP="80" VSHIFT="40"/>
<node TEXT="AEBL installer" POSITION="right" ID="ID_1003427674" CREATED="1414926366947" MODIFIED="1416796865648" HGAP="70" VSHIFT="-20">
<node TEXT="reliable host required" ID="ID_1836542380" CREATED="1416887064009" MODIFIED="1416887119429"/>
</node>
<node TEXT="Custom / corporate" POSITION="right" ID="ID_836554520" CREATED="1414923790930" MODIFIED="1416796871312" HGAP="40">
<node TEXT="IHDN" ID="ID_744033792" CREATED="1416162632417" MODIFIED="1416162636031">
<node TEXT="utilizes AEBL with GPIO plugin device" ID="ID_1715623668" CREATED="1416162726401" MODIFIED="1416162746087"/>
</node>
</node>
<node TEXT="Custom cases" POSITION="left" ID="ID_16724359" CREATED="1416445257257" MODIFIED="1416796952050" HGAP="60" VSHIFT="50">
<node TEXT="IHDN Detector" ID="ID_1701913390" CREATED="1416445348154" MODIFIED="1416796967054" HGAP="90" VSHIFT="-10"/>
<node TEXT="Case that exposes GPIO" ID="ID_1895391949" CREATED="1416445381594" MODIFIED="1416796927774" HGAP="80" VSHIFT="10"/>
</node>
<node TEXT="AEBL Digital Sign" POSITION="left" ID="ID_1925312428" CREATED="1416663069969" MODIFIED="1416796954274" HGAP="50" VSHIFT="40">
<node TEXT="AEBL works as digital sign, but create version that specifically is configured as such" ID="ID_352489980" CREATED="1416797018813" MODIFIED="1416797062199"/>
</node>
<node TEXT="AEBL Virtual Machine" POSITION="right" ID="ID_1829776084" CREATED="1416310340324" MODIFIED="1416310352564">
<node TEXT="Base being current ubuntu 32bit" ID="ID_708375404" CREATED="1416980723247" MODIFIED="1419548136529"/>
<node TEXT="no X installed" ID="ID_890541301" CREATED="1418879598626" MODIFIED="1418879633332"/>
<node TEXT="blade functions" ID="ID_1433702765" CREATED="1419132164119" MODIFIED="1419132172301">
<node TEXT="messaging" ID="ID_1748953683" CREATED="1419279766833" MODIFIED="1419279801728"/>
</node>
<node TEXT="backend interfaces" ID="ID_608698720" CREATED="1419218170970" MODIFIED="1419218178837"/>
</node>
</node>
</map>
