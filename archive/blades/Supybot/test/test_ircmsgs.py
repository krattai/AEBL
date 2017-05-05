###
# Copyright (c) 2002-2005, Jeremiah Fincher
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#   * Redistributions of source code must retain the above copyright notice,
#     this list of conditions, and the following disclaimer.
#   * Redistributions in binary form must reproduce the above copyright notice,
#     this list of conditions, and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#   * Neither the name of the author of this software nor the name of
#     contributors to this software may be used to endorse or promote products
#     derived from this software without specific prior written consent.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
###

from supybot.test import *

import copy
import pickle

import supybot.ircmsgs as ircmsgs
import supybot.ircutils as ircutils

# The test framework used to provide these, but not it doesn't.  We'll add
# messages to as we find bugs (if indeed we find bugs).
msgs = []
rawmsgs = []

class IrcMsgTestCase(SupyTestCase):
    def testLen(self):
        for msg in msgs:
            if msg.prefix:
                strmsg = str(msg)
                self.failIf(len(msg) != len(strmsg) and \
                            strmsg.replace(':', '') == strmsg)

    def testRepr(self):
        IrcMsg = ircmsgs.IrcMsg
        for msg in msgs:
            self.assertEqual(msg, eval(repr(msg)))

    def testStr(self):
        for (rawmsg, msg) in zip(rawmsgs, msgs):
            strmsg = str(msg).strip()
            self.failIf(rawmsg != strmsg and \
                        strmsg.replace(':', '') == strmsg)

    def testEq(self):
        for msg in msgs:
            self.assertEqual(msg, msg)
        self.failIf(msgs and msgs[0] == []) # Comparison to unhashable type.

    def testNe(self):
        for msg in msgs:
            self.failIf(msg != msg)

##     def testImmutability(self):
##         s = 'something else'
##         t = ('foo', 'bar', 'baz')
##         for msg in msgs:
##             self.assertRaises(AttributeError, setattr, msg, 'prefix', s)
##             self.assertRaises(AttributeError, setattr, msg, 'nick', s)
##             self.assertRaises(AttributeError, setattr, msg, 'user', s)
##             self.assertRaises(AttributeError, setattr, msg, 'host', s)
##             self.assertRaises(AttributeError, setattr, msg, 'command', s)
##             self.assertRaises(AttributeError, setattr, msg, 'args', t)
##             if msg.args:
##                 def setArgs(msg):
##                     msg.args[0] = s
##                 self.assertRaises(TypeError, setArgs, msg)

    def testInit(self):
        for msg in msgs:
            self.assertEqual(msg, ircmsgs.IrcMsg(prefix=msg.prefix,
                                                 command=msg.command,
                                                 args=msg.args))
            self.assertEqual(msg, ircmsgs.IrcMsg(msg=msg))
        self.assertRaises(ValueError,
                          ircmsgs.IrcMsg,
                          args=('foo', 'bar'),
                          prefix='foo!bar@baz')

    def testPickleCopy(self):
        for msg in msgs:
            self.assertEqual(msg, pickle.loads(pickle.dumps(msg)))
            self.assertEqual(msg, copy.copy(msg))

    def testHashNotZero(self):
        zeroes = 0
        for msg in msgs:
            if hash(msg) == 0:
                zeroes += 1
        self.failIf(zeroes > (len(msgs)/10), 'Too many zero hashes.')

    def testMsgKeywordHandledProperly(self):
        msg = ircmsgs.notice('foo', 'bar')
        msg2 = ircmsgs.IrcMsg(msg=msg, command='PRIVMSG')
        self.assertEqual(msg2.command, 'PRIVMSG')
        self.assertEqual(msg2.args, msg.args)

    def testMalformedIrcMsgRaised(self):
        self.assertRaises(ircmsgs.MalformedIrcMsg, ircmsgs.IrcMsg, ':foo')
        self.assertRaises(ircmsgs.MalformedIrcMsg, ircmsgs.IrcMsg,
                          args=('biff',), prefix='foo!bar@baz')

    def testTags(self):
        m = ircmsgs.privmsg('foo', 'bar')
        self.failIf(m.repliedTo)
        m.tag('repliedTo')
        self.failUnless(m.repliedTo)
        m.tag('repliedTo')
        self.failUnless(m.repliedTo)
        m.tag('repliedTo', 12)
        self.assertEqual(m.repliedTo, 12)

class FunctionsTestCase(SupyTestCase):
    def testIsAction(self):
        L = [':jemfinch!~jfincher@ts26-2.homenet.ohio-state.edu PRIVMSG'
             ' #sourcereview :ACTION does something',
             ':supybot!~supybot@underthemain.net PRIVMSG #sourcereview '
             ':ACTION beats angryman senseless with a Unix manual (#2)',
             ':supybot!~supybot@underthemain.net PRIVMSG #sourcereview '
             ':ACTION beats ang senseless with a 50lb Unix manual (#2)',
             ':supybot!~supybot@underthemain.net PRIVMSG #sourcereview '
             ':ACTION resizes angryman\'s terminal to 40x24 (#16)']
        msgs = map(ircmsgs.IrcMsg, L)
        for msg in msgs:
            self.failUnless(ircmsgs.isAction(msg))

    def testIsActionIsntStupid(self):
        m = ircmsgs.privmsg('#x', '\x01NOTANACTION foo\x01')
        self.failIf(ircmsgs.isAction(m))
        m = ircmsgs.privmsg('#x', '\x01ACTION foo bar\x01')
        self.failUnless(ircmsgs.isAction(m))

    def testIsCtcp(self):
        self.failUnless(ircmsgs.isCtcp(ircmsgs.privmsg('foo',
                                                       '\x01VERSION\x01')))
        self.failIf(ircmsgs.isCtcp(ircmsgs.privmsg('foo', '\x01')))

    def testIsActionFalseWhenNoSpaces(self):
        msg = ircmsgs.IrcMsg('PRIVMSG #foo :\x01ACTIONfoobar\x01')
        self.failIf(ircmsgs.isAction(msg))

    def testUnAction(self):
        s = 'foo bar baz'
        msg = ircmsgs.action('#foo', s)
        self.assertEqual(ircmsgs.unAction(msg), s)

    def testBan(self):
        channel = '#osu'
        ban = '*!*@*.edu'
        exception = '*!*@*ohio-state.edu'
        noException = ircmsgs.ban(channel, ban)
        self.assertEqual(ircutils.separateModes(noException.args[1:]),
                         [('+b', ban)])
        withException = ircmsgs.ban(channel, ban, exception)
        self.assertEqual(ircutils.separateModes(withException.args[1:]),
                         [('+b', ban), ('+e', exception)])

    def testBans(self):
        channel = '#osu'
        bans = ['*!*@*', 'jemfinch!*@*']
        exceptions = ['*!*@*ohio-state.edu']
        noException = ircmsgs.bans(channel, bans)
        self.assertEqual(ircutils.separateModes(noException.args[1:]),
                         [('+b', bans[0]), ('+b', bans[1])])
        withExceptions = ircmsgs.bans(channel, bans, exceptions)
        self.assertEqual(ircutils.separateModes(withExceptions.args[1:]),
                         [('+b', bans[0]), ('+b', bans[1]),
                          ('+e', exceptions[0])])

    def testUnban(self):
        channel = '#supybot'
        ban = 'foo!bar@baz'
        self.assertEqual(str(ircmsgs.unban(channel, ban)),
                         'MODE %s -b :%s\r\n' % (channel, ban))

    def testJoin(self):
        channel = '#osu'
        key = 'michiganSucks'
        self.assertEqual(ircmsgs.join(channel).args, ('#osu',))
        self.assertEqual(ircmsgs.join(channel, key).args,
                         ('#osu', 'michiganSucks'))

    def testJoins(self):
        channels = ['#osu', '#umich']
        keys = ['michiganSucks', 'osuSucks']
        self.assertEqual(ircmsgs.joins(channels).args, ('#osu,#umich',))
        self.assertEqual(ircmsgs.joins(channels, keys).args,
                         ('#osu,#umich', 'michiganSucks,osuSucks'))
        keys.pop()
        self.assertEqual(ircmsgs.joins(channels, keys).args,
                         ('#osu,#umich', 'michiganSucks'))

    def testQuit(self):
        self.failUnless(ircmsgs.quit(prefix='foo!bar@baz'))

    def testOps(self):
        m = ircmsgs.ops('#foo', ['foo', 'bar', 'baz'])
        self.assertEqual(str(m), 'MODE #foo +ooo foo bar :baz\r\n')

    def testDeops(self):
        m = ircmsgs.deops('#foo', ['foo', 'bar', 'baz'])
        self.assertEqual(str(m), 'MODE #foo -ooo foo bar :baz\r\n')

    def testVoices(self):
        m = ircmsgs.voices('#foo', ['foo', 'bar', 'baz'])
        self.assertEqual(str(m), 'MODE #foo +vvv foo bar :baz\r\n')

    def testDevoices(self):
        m = ircmsgs.devoices('#foo', ['foo', 'bar', 'baz'])
        self.assertEqual(str(m), 'MODE #foo -vvv foo bar :baz\r\n')

    def testHalfops(self):
        m = ircmsgs.halfops('#foo', ['foo', 'bar', 'baz'])
        self.assertEqual(str(m), 'MODE #foo +hhh foo bar :baz\r\n')

    def testDehalfops(self):
        m = ircmsgs.dehalfops('#foo', ['foo', 'bar', 'baz'])
        self.assertEqual(str(m), 'MODE #foo -hhh foo bar :baz\r\n')

    def testMode(self):
        m = ircmsgs.mode('#foo', ('-b', 'foo!bar@baz'))
        s = str(m)
        self.assertEqual(s, 'MODE #foo -b :foo!bar@baz\r\n')

    def testIsSplit(self):
        m = ircmsgs.IrcMsg(prefix="caker!~caker@ns.theshore.net",
                           command="QUIT",
                           args=('jupiter.oftc.net quasar.oftc.net',))
        self.failUnless(ircmsgs.isSplit(m))
        m = ircmsgs.IrcMsg(prefix="bzbot!Brad2901@ACC87473.ipt.aol.com",
                           command="QUIT",
                           args=('Read error: 110 (Connection timed out)',))
        self.failIf(ircmsgs.isSplit(m))
        m = ircmsgs.IrcMsg(prefix="JibberJim!~none@8212cl.b0nwbeoe.co.uk",
                           command="QUIT",
                           args=('"Bye!"',))
        self.failIf(ircmsgs.isSplit(m))


# vim:set shiftwidth=4 softtabstop=4 expandtab textwidth=79:
