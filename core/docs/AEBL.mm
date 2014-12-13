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
<node TEXT="AEBL core" POSITION="right" ID="_" CREATED="1269462169926" MODIFIED="1414923607537" VSHIFT="-81">
<node TEXT="Prototype Development" ID="Freemind_Link_1948237358" CREATED="1269462283400" MODIFIED="1269462296310">
<node TEXT="specific to any new functions not already part of the core" ID="ID_1064129376" CREATED="1416163700225" MODIFIED="1416163749904"/>
<node TEXT="config file" ID="ID_481148730" CREATED="1417693184022" MODIFIED="1417693192228">
<node TEXT="include network config" ID="ID_863184324" CREATED="1417693307702" MODIFIED="1417693317647"/>
<node TEXT="include server IP if relevant" ID="ID_1712947505" CREATED="1417697064537" MODIFIED="1417697087479"/>
</node>
<node TEXT="configuration manager tool" ID="ID_1709308848" CREATED="1417779944197" MODIFIED="1417780010739">
<node TEXT="raspCTL performs this function" ID="ID_424310803" CREATED="1417780057991" MODIFIED="1417780080850">
<node TEXT="if raspCTL, then trim down to just configure and install blades" ID="ID_1781409653" CREATED="1417780137760" MODIFIED="1417780167298"/>
<node TEXT="default raspCTL features" ID="ID_20353327" CREATED="1418076501892" MODIFIED="1418076527770"/>
<node TEXT="should install as core" ID="ID_1413625358" CREATED="1418190661790" MODIFIED="1418190679608"/>
<node TEXT="include network config" ID="ID_495836027" CREATED="1418275798497" MODIFIED="1418275853784">
<node TEXT="wifi and cable" ID="ID_963767718" CREATED="1418421555802" MODIFIED="1418421568016">
<node TEXT="cable connection auto configure" ID="ID_1463283354" CREATED="1418495791735" MODIFIED="1418495805311"/>
</node>
</node>
</node>
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
<node TEXT="AEBL Virtual Machine" ID="ID_1829776084" CREATED="1416310340324" MODIFIED="1416310352564">
<node TEXT="Base being current ubuntu" ID="ID_708375404" CREATED="1416980723247" MODIFIED="1416980826568"/>
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
<node TEXT="owncloud" ID="ID_1686142785" CREATED="1416162220265" MODIFIED="1416162227231"/>
<node TEXT="seafile" ID="ID_121833645" CREATED="1416162353161" MODIFIED="1416162356558"/>
<node TEXT="xtreemfs" ID="ID_325003429" CREATED="1416162390577" MODIFIED="1416162420952"/>
<node TEXT="Terra Vista" ID="ID_1669515084" CREATED="1416162478521" MODIFIED="1416162483959"/>
<node TEXT="noo-ebs" ID="ID_346129573" CREATED="1416187485572" MODIFIED="1416187493241"/>
</node>
</node>
<node TEXT="AEBL interfaces" POSITION="right" ID="ID_43537905" CREATED="1416159240121" MODIFIED="1416159305836" HGAP="40" VSHIFT="-40">
<node TEXT="AEBL Navigator" ID="ID_1406757722" CREATED="1416159343720" MODIFIED="1416159385527">
<node TEXT="need delete files doc function if not in place" ID="ID_1796691920" CREATED="1417693388126" MODIFIED="1417693447704"/>
<node TEXT="files to modify configuration / functionality" ID="ID_1210994575" CREATED="1417693495486" MODIFIED="1417693556766"/>
</node>
<node TEXT="AEBL Airtime" ID="ID_1807319122" CREATED="1416159434617" MODIFIED="1416159442107"/>
</node>
<node TEXT="Streaming" POSITION="right" ID="Freemind_Link_1631455944" CREATED="1269462208469" MODIFIED="1416796860928" HGAP="51" VSHIFT="-21">
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
</node>
</map>
