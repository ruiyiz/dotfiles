# Copyright (C) 2009-2010 Fog Creek Software. All rights reserved.
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

'''automatically push large repositories in chunks'''

from mercurial import cmdutil, commands, hg, url, extensions
from mercurial.i18n import _

max_push_size = 1000

def bigpush(push_fn, ui, repo, dest=None, *files, **opts):
    '''Pushes this repository to a target repository.

    If this repository is small, behaves as the native push command.
    For large, remote repositories, the repository is pushed in chunks of 1000 changesets.'''
    if not opts.get('chunked'):
        return push_fn(ui, repo, dest, **opts)

    source, revs = parseurl(ui.expandpath(dest or 'default-push', dest or 'default'))
    other = hg.repository(cmdutil.remoteui(repo, opts), source)
    if hasattr(hg, 'addbranchrevs'):
        revs = hg.addbranchrevs(repo, other, revs, opts.get('rev'))[0]
    if revs:
        revs = [repo.lookup(rev) for rev in revs]
    if other.local():
        return push_fn(ui, repo, dest, **opts)

    ui.status(_('pushing to %s\n') % other.path)

    outgoing = repo.findoutgoing(other, force=False)
    if outgoing:
        outgoing = repo.changelog.nodesbetween(outgoing, revs)[0]

    # if the push will create multiple heads and isn't forced, fail now
    # (prepush prints an error message, so we can just exit)
    if not opts.get('force') and None == repo.prepush(other, False, revs)[0]:
        return
    try:
        while len(outgoing) > 0:
            ui.debug('start: %d to push\n' % len(outgoing))
            current_push_size = min(max_push_size, len(outgoing))
            ui.debug('pushing: %d\n' % current_push_size)
            # force the push, because we checked above that by the time the whole push is done, we'll have merged back to one head
            remote_heads = repo.push(other, force=True, revs=outgoing[:current_push_size])
            if remote_heads: # push succeeded
                outgoing = outgoing[current_push_size:]
                current_push_size = max_push_size
                ui.debug('pushed %d ok\n' % current_push_size)
            else: # push failed; try again with a smaller size
                current_push_size /= 10
                ui.debug('failed, trying %d\n' % current_push_size)
                if current_push_size == 0:
                    raise UnpushableChangesetError
    except UnpushableChangesetError:
        ui.status(_('unable to push changeset %s\n') % outgoing[0])
    ui.debug('done\n')

def parseurl(source):
    '''wrap hg.parseurl to work on 1.3 -> 1.5'''
    return hg.parseurl(source, None)[:2]

def uisetup(ui):
    push_cmd = extensions.wrapcommand(commands.table, 'push', bigpush)
    push_cmd[1].extend([('', 'chunked', None, 'push large repository in chunks')])

class UnpushableChangesetError(Exception):
    pass
