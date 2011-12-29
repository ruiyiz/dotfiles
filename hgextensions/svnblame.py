# Copyright (C) 2009-2010 Fog Creek Software.  All rights reserved.
#
# This is a small extension for Mercurial (http://www.selenic.com/mercurial)
# that provides Subversion's blame command, with identical output
#
# To enable the "blame" extension put these lines in your ~/.hgrc:
#  [extensions]
#  svnblame = /path/to/svnblame.py
#
# For help on the usage of "hg svnblame" use:
#  hg help svnblame
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

'''provides a Subversion-compatible blame command

This extension provides a blame command that produces identical output
to Subversion's blame command.
'''

from mercurial import commands
from mercurial.i18n import _

def blame(ui, repo, *files, **opts):
    '''provides a Subversion-compatible blame

    This command shows you who modified which lines of a file at given
    revisions, and does so in a Subversion-compatible manner.  It should
    be a drop-in replacement for Subversion\'s blame command in your
    scripts.
    '''
    commands.annotate(ui, repo, rev='tip', user=True, number=True, *files)

cmdtable = {
    'svnblame':
        (blame,
         [],
         _('hg svnblame FILE...')),
    }
