AEBL
====

AEBL is a mobile multimedia distribution and playback platform.

For more information, read the wiki:  https://github.com/krattai/AEBL/wiki

Related video:  https://www.youtube.com/embed/_NEA02NtI4E?rel=0

Features
+ Video or Audio kiosk (standalone or network)
+ Personal, portable audio and video player
+ Streaming content video and audio player
+ Social media aware and interactive
+ Zeroconf / bonjour device
+ Channel content playing and sharing
+ Integrated Emergency Broadcast. 411 info, and other features
+ and Much, much more, doesn't even begin to explain it! :)

AEBL Mobile Media Player, changing how we consume media.

AEBL is foremost a mobile media distribution and playback framework.  It was created to be the core technology that is used in a television ad insertion and digital sign, and further development has opened up many more applications.  It currently is designed to run on a raspberry Pi, although it is being ported to other systems.

The AEBL blog is located here:
http://aeblm2.blogspot.ca/

For those interested in trying it out, you will need a Raspberry Pi (should be the B series with 512MB) and a SD card (4GB or higher, recommend base 8GB but the larger, the better, for content storage).

The current image is a ~710MB 7zip compressed file of it's original 2.9GB size, located on dropbox, here:
https://www.dropbox.com/s/sxm3oirk800m7d4/170420-aebl_p1.img.7z?dl=0

AEBL uses IPv6 to a great extent.  Many Internet Service Providers still do not provide IPv6.  As a result, in order to access certain information for AEBL, obtaining an IPv6 internet connection will be helpful.  The following providers offer free IPv6 tunnels:

(This needs to be updated, as gogo6 is defunct and sixxs is not accepting new accounts)
gogo6:
http://www.gogo6.com/profile/gogoCLIENT

sixxs:
https://www.sixxs.net/faq/account/?faq=10steps

Hurricane Electric also provides IPv6:
https://tunnelbroker.net/

There is more and more information for IPv6 on the internet and HE.net provides a decent certifiation course for learning about IPv6 from simple to extensive:
https://ipv6.he.net/certification/

Generally gogo6 is the simplest path to IPv6 without native or dual stack configurations, followed by sixxs (a more stringent process), and finally HE.net (which requires a significant amount to networking skills).

AEBL is tightly linked to the Open Information (Op_In) project:
https://github.com/krattai/Op_In

Especially in the AEBL Anarchy edition, much, if not all of the Op_In knowledge base will be accessible.
