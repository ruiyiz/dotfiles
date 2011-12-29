# Copyright (C) 2009-2010 Fog Creek Software.  All rights reserved.
#
# To enable the "gestalt" extension put these lines in your ~/.hgrc:
#  [extensions]
#  gestalt = /path/to/gestalt.py
#
# For help on the usage of "hg gestalt" use:
#  hg help gestalt
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

'''provides a general overview of your repository state

This extension attempts to help new Mercurial users by providing
several commands to help learn how Mercurial works.  The primary
command provided is "hg next", which shows an overview of your
local repository, its relationship and status to its parent,
and what next actions you may wish to consider performing.
'''

from mercurial import bundlerepo, changegroup, cmdutil, commands, hg, \
        node, url
from mercurial.i18n import _

##
# Private utility functions for determining advice output
def _isrepo(ui, repo, files, opts):
    if not repo:
        ui.status(_("""You need to create a Mercurial repository.

Run -> hg init
"""))
        return True
    return False

def _ismerging(ui, repo, files, opts):
    if repo.dirstate.parents()[1] != node.nullid:
        ui.status(_('It appears there is a merge in progress.\n'))
        return True
    return False

def _haschanges(ui, repo, files, opts):
    changed = any(repo.status())
    if changed:
        ui.status(_('''You have changes in your working copy that should be committed
before updating your local or remote repositories:

Run -> hg commit
'''))
        return True
    return False

def _shouldmerge(ui, repo, files, opts):
    heads = repo.branchheads(closed=False)
    if len(heads) > 1:
        ui.status(_('''You have two heads in your local repository. To resolve this,
you should merge:

Run -> hg merge
'''))
        return True
    return False

def _shouldsync(ui, repo, files, opts):
    source, revs = parseurl(ui.expandpath('default'))

    # grab incoming and outgoing changesets
    other = hg.repository(cmdutil.remoteui(repo, opts), source)
    if hasattr(hg, 'addbranchrevs'):
        revs, checkout = hg.addbranchrevs(repo, other, revs, None)
    ui.pushbuffer()
    common, incoming, rheads = repo.findcommonincoming(other, heads=revs, force=False)
    ui.popbuffer()

    if incoming:
        ui.status(_('''There are changes in your remote repository that haven't been
included in your local repository. To get your copy up-to-date you should:

Run -> hg pull
'''))
        return True

    ui.pushbuffer()
    outgoing = repo.findoutgoing(other, force=False)
    if outgoing:
        outgoing = repo.changelog.nodesbetween(outgoing, revs)[0]
    ui.popbuffer()

    if outgoing:
        ui.status(_('''You have changes in your local repository that aren't in your
remote repository. If you want to share your changes, you should:

Run -> hg push
'''))
        return True
    return False

def _istip(ui, repo, files, opts):
    tip = repo['tip']
    cwd = repo['.']
    if tip != cwd:
        ui.status(_('''You are not at a head.  You probably want to update to tip
before making any changes:

Run -> hg up
'''))
        return True
    return False

def _shouldwritemorecode(ui, *ignored):
    ui.status(_('Everything is up-to-date.  Write more code!\n'))
    return True

##
# General utility methods
def outgoing(repo, origin, revs):
    '''return a list of outgoing changesets'''
    out = repo.findoutgoing(origin)
    if out:
        out = repo.changelog.nodesbetween(out, None)[0]
    return out

def incoming(repo, origin, revs):
    '''return a list of incoming changesets'''
    if revs:
        revs = [origin.lookup(rev) for rev in revs]
    common, incoming, rheads = repo.findcommonincoming(origin, heads=revs, force=False)
    if not incoming:
        return incoming
    if not origin.local():
        # create a bundle (uncompressed if other repo is not local)
        if not revs and origin.capable('changegroupsubset'):
            revs = rheads

        if not revs:
            cg = origin.changegroup(incoming, 'incoming')
        else:
            cg = origin.changegroupsubset(incoming, revs, 'incoming')
        fname  = changegroup.writebundle(cg, None, "HG10UN")
        origin = bundlerepo.bundlerepository(repo.ui, repo.root, fname)
    incoming = origin.changelog.nodesbetween(incoming, revs)[0]
    if hasattr(origin, 'close'):
        origin.close()
    return incoming

def parseurl(source):
    '''wrap hg.parseurl to work on 1.3 -> 1.5'''
    return hg.parseurl(source, None)[:2]

##
# commands
def overview(ui, repo, source='default', **opts):
    '''provides a general overview of your repository state

    This command combines the output of the hg incomng, hg outgoing,
    hg status, and hg id commands into an easily human-readable explanation
    of the entire state of your current working repository.
    '''
    if not repo:
        return
    origin, revs = parseurl(ui.expandpath(source))
    origin = hg.repository(cmdutil.remoteui(repo, opts), origin)
    ui.status(_('parent repository: %s\n') % url.hidepassword(source))

    ui.pushbuffer()
    out = outgoing(repo, origin, revs)
    inc = incoming(repo, origin, revs)
    ui.popbuffer()

    changed = any(repo.status())
    if changed:
        status = _('uncommitted changes')
    else:
        status = _('working copy up-to-date')

    # grab heads
    heads = repo.branchheads(None, closed=False)
    if len(heads) > 1:
        merge = 'merge required'
    else:
        merge = ''

    ui.status(_('|   Remote   | << %s    |   Local    | %s\n') % (str(len(out)).center(5), merge))
    ui.status(_('| Repository |    %s >> | Repository | %s\n') % (str(len(inc)).center(5), status))

    if opts['detail']:
        if len(out) > 0:
            ui.status(_('\noutgoing changes:\n'))
            for rev in out:
                ui.status('%s %s\n' % (repo[rev],
                                       repo[rev].description().strip().split('\n')[0]))
        if len(inc) > 0:
            ui.status(_('\nincoming changes:\n'))
            for rev in inc:
                ui.status('%s %s\n' % (repo[rev],
                                       repo[rev].description().strip().split('\n')[0]))
        if changed:
            ui.status(_('\nlocal files:\n'))
            ui.pushbuffer()
            commands.status(ui, repo, '', **opts)
            status = ui.popbuffer()
            for l in status.splitlines():
                print '    %s' % l

def advice(ui, repo, *files, **opts):
    '''provides a suggestion of your next step

    This command attempts to help new Mercurial users by suggesting
    what your next step should be.  These steps are suggestions only,
    and do not provide an exhaustive list of all possible actions that
    may be appropriate, but should nevertheless help you if you are
    unsure how to proceed.
    '''
    checks = [_isrepo,
              _ismerging,
              _haschanges,
              _shouldmerge,
              _shouldsync,
              _istip,
              _shouldwritemorecode]
    for fun in checks:
        if fun(ui, repo, files, opts):
            return

def next(ui, repo, *files, **opts):
    '''provides an overview and explanation of what to do next

    This command shows you a graphical representation of the
    current state of your repository and its parent, and suggests
    what your next step should be based on the picture.'''
    overview(ui, repo, *files, **opts)
    advice(ui, repo, *files, **opts)


cmdtable = {
    'overview':
        (overview,
         [('d', 'detail', None, _('provide verbose output'))],
         _('hg gestalt [OPTION] [REMOTE REPOSITORY]')),
    'advice':
        (advice, [], _('hg next')),
    'next|wtf':
        (next,
         [('d', 'detail', None, _('provide verbose output'))],
         _('hg next [OPTION] [REMOTE REPOSITORY]')),
    }

commands.optionalrepo += 'wtf advice overview next'
