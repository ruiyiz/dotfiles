# Copyright (C) 2009-2010 Fog Creek Software.  All rights reserved.
#
# To enable the "kilnpath" extension put these lines in your ~/.hgrc:
#    [extensions]
#    kilnpath = /path/to/kilnpath.py
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

'''Lets users identify repository paths by custom schemes like kiln://Project/Group/Repository.

This extensions knows how to expand Kiln repository paths from
kiln://Project/Group/Repository to
the full http://your.fogbugz.com/kiln/Repo/Project/Group/Repository,
so you only have to type
"hg pull kiln://Project/Group/Repository" at the command line.

This extensions works for pull, push, incoming, outgoing, and clone.

To specify the Kiln path prefix, add a [kiln_scheme] section to your hg config like so:
[kiln_scheme]
kiln = https://your.fogbugz.com/kiln/Repo
'''

import os
from mercurial import extensions, commands, hg, ui

def urlcombine(pre, suff):
    if pre.endswith("/"):
        pre = pre[0:len(pre) - 1]
    if not suff.startswith("/"):
        suff = "/" + suff
    return pre + suff

def kilnpath_info(orig, ui, repo, dest=None, **opts):

    # If either repo or dest can be replaced w/ a preferred scheme prefix, let the user know
    scheme_path = known_scheme(ui, repo) or known_scheme(ui, dest)
    if scheme_path:
        print_shortcut_scheme(ui, scheme_path[0], scheme_path[1])

    if not dest:
        return orig(ui, repo, **opts)

    return orig(ui, repo, dest, **opts)

def known_scheme(ui, path):
    if not isinstance(path, basestring):
        return None

    schemes = ui.configitems('kiln_scheme')
    for scheme, prefix in schemes:
        if path.lower().startswith(prefix.lower()):
            return (scheme, path)

    return None

def print_shortcut_scheme(ui, scheme, path):
    ui.status("You can use " + get_shortcut(ui, scheme, path) + " as a shortcut for " + path + ".\n")

def get_shortcut(ui, scheme, path):
    prefix = ui.config('kiln_scheme', scheme)
    suffix = path[len(prefix):]
    return urlcombine(scheme + "://", suffix)

def add_schemes(ui):
    schemes = ui.configitems('kiln_scheme')
    for scheme, prefix in schemes:
        hg.schemes[scheme] = KilnRepo(scheme, prefix)

class KilnRepo(object):
    def __init__(self, scheme, prefix):
        self.scheme = scheme
        self.prefix = prefix

    def instance(self, ui, path, create):
        path_pieces = path.split(":", 1)
        if len(path_pieces) <= 1:
            return None

        suffix = path_pieces[1]
        if suffix.startswith("//"):
            suffix = suffix[2:]

        path_full = urlcombine(self.prefix, suffix)
        return hg._lookup(path_full).instance(ui, path_full, create)

def uisetup(ui):
    # Wrap a bunch of common commands so we can let the user know
    # if there's a preferred custom scheme to use for the current path
    extensions.wrapcommand(commands.table, 'outgoing', kilnpath_info)
    extensions.wrapcommand(commands.table, 'incoming', kilnpath_info)
    extensions.wrapcommand(commands.table, 'push', kilnpath_info)
    extensions.wrapcommand(commands.table, 'pull', kilnpath_info)
    extensions.wrapcommand(commands.table, 'clone', kilnpath_info)

def extsetup(*args):
    if len(args) > 0:
        add_schemes(args[0])
    else:
        add_schemes(ui.ui())

