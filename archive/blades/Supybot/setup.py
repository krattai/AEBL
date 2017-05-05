#!/usr/bin/env python

###
# Copyright (c) 2002-2005, Jeremiah Fincher
# Copyright (c) 2009, James McCoy
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

import os
import sys

if sys.version_info < (2, 6, 0):
    sys.stderr.write("Supybot requires Python 2.6 or newer.")
    sys.stderr.write(os.linesep)
    sys.exit(-1)

import os.path
import textwrap

from src.version import version
from setuptools import setup

def normalizeWhitespace(s):
    return ' '.join(s.split())

plugins = [s for s in os.listdir('plugins') if
           os.path.exists(os.path.join('plugins', s, 'plugin.py'))]

packages = ['supybot',
            'supybot.utils',
            'supybot.drivers',
            'supybot.plugins',] + \
            ['supybot.plugins.'+s for s in plugins] + \
            [
             'supybot.plugins.Dict.local',
             'supybot.plugins.Math.local',
            ]

package_dir = {'supybot': 'src',
               'supybot.utils': 'src/utils',
               'supybot.plugins': 'plugins',
               'supybot.drivers': 'src/drivers',
               'supybot.plugins.Dict.local': 'plugins/Dict/local',
               'supybot.plugins.Math.local': 'plugins/Math/local',
              }

for plugin in plugins:
    package_dir['supybot.plugins.' + plugin] = 'plugins/' + plugin

setup(
    # Metadata
    name='supybot',
    version=version,
    author='Jeremy Fincher',
    author_email='jemfinch@supybot.com',
    maintainer='James McCoy',
    maintainer_email='vega.james@gmail.com',
    url='https://github.com/Supybot/Supybot',
    download_url='https://github.com/Supybot/Supybot/releases',
    platforms=['linux', 'linux2', 'win32', 'cygwin', 'darwin'],
    description='A flexible and extensible Python IRC bot and framework.',
    long_description=normalizeWhitespace("""A robust, full-featured Python IRC
    bot with a clean and flexible plugin API.  Equipped with a complete ACL
    system for specifying user permissions with as much as per-command
    granularity.  Batteries are included in the form of numerous plugins
    already written."""),
    classifiers = [
        'Development Status :: 4 - Beta',
        'Environment :: Console',
        'Environment :: No Input/Output (Daemon)',
        'Intended Audience :: End Users/Desktop',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: BSD License',
        'Topic :: Communications :: Chat :: Internet Relay Chat',
        'Natural Language :: English',
        'Operating System :: OS Independent',
        'Operating System :: POSIX',
        'Operating System :: Microsoft :: Windows',
        'Programming Language :: Python :: 2.6',
        'Programming Language :: Python :: 2.7',
        ],

    # Installation data
    packages=packages,

    package_dir=package_dir,

    scripts=['scripts/supybot',
             'scripts/supybot-test',
             'scripts/supybot-botchk',
             'scripts/supybot-wizard',
             'scripts/supybot-adduser',
             'scripts/supybot-plugin-doc',
             'scripts/supybot-plugin-create',
             ],

    install_requires=[
        # Time plugin
        'python-dateutil !=2.0,>=1.3',
        'feedparser',
        ],

    tests_require=[
        'mock',
    ]
    )


# vim:set shiftwidth=4 softtabstop=4 expandtab textwidth=79:
