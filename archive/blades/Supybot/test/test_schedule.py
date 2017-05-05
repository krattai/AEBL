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

import time

import supybot.schedule as schedule

class TestSchedule(SupyTestCase):
    def testSchedule(self):
        sched = schedule.Schedule()
        i = [0]
        def add10():
            i[0] = i[0] + 10
        def add1():
            i[0] = i[0] + 1

        sched.addEvent(add10, time.time() + 3)
        sched.addEvent(add1, time.time() + 1)
        time.sleep(1.2)
        sched.run()
        self.assertEqual(i[0], 1)
        time.sleep(1.9)
        sched.run()
        self.assertEqual(i[0], 11)

        sched.addEvent(add10, time.time() + 3, 'test')
        sched.run()
        self.assertEqual(i[0], 11)
        sched.removeEvent('test')
        self.assertEqual(i[0], 11)
        time.sleep(3)
        self.assertEqual(i[0], 11)

    def testReschedule(self):
        sched = schedule.Schedule()
        i = [0]
        def inc():
            i[0] += 1
        n = sched.addEvent(inc, time.time() + 1)
        sched.rescheduleEvent(n, time.time() + 3)
        time.sleep(1.2)
        sched.run()
        self.assertEqual(i[0], 0)
        time.sleep(2)
        sched.run()
        self.assertEqual(i[0], 1)


# vim:set shiftwidth=4 softtabstop=4 expandtab textwidth=79:

