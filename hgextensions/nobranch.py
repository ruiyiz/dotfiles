# Copyright (C) 2009-2010 Fog Creek Software.  All rights reserved.
#
# This is a small extension for Mercurial (http://www.selenic.com/mercurial)
# that discourages you from using the ``hg branch'' command.
#
# To enable the "nobranch" extension put these lines in your ~/.hgrc:
#  [extensions]
#  nobranch = /path/to/nobranch.py
#
# For help on the usage of "hg nobranch" use:
#  hg help nobranch
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

'''discourages using the branch command

This extension discourages users from using hg branch by asking them
to confirm that doing so is truly what they want to do.
'''

from mercurial import commands, extensions
from mercurial.i18n import _

warning = _("""
      Fog Creek recommends using Kiln branches instead of the
      named branch you are about to create.  Read more at
      http://kiln.stackexchange.com/questions/127 .

      If you'd like to create a named branch anyway, use the
      --override option.

""")

def uisetup(ui):
    def reallybranch(orig, ui, repo, label=None, override=False, **opts):
        if not override and label:
            ui.warn(warning)
        else:
            return orig(ui, repo, label=label, **opts)

    entry = extensions.wrapcommand(commands.table, 'branch', reallybranch)
    entry[1].append(('', 'override', False,
                     _('allow the creation of a named branch')))
