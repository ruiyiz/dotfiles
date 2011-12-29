# Copyright (C) 2010 Fog Creek Software.  All rights reserved.
#
# To enable the "kiln" extension put these lines in your ~/.hgrc:
#  [extensions]
#  kiln = /path/to/kiln.py
#
# For help on the usage of "hg kiln" use:
#  hg help kiln
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

'''provides command-line support for working with Kiln

This extension allows you to directly open up the Kiln page for your
repository, including the annotation, file view, outgoing, and other
pages.
'''

import os
import re

from mercurial import cmdutil, demandimport, hg, util
from mercurial import url as hgurl
from mercurial.i18n import _

demandimport.disable()
try:
    import webbrowser
    def browse(url):
        webbrowser.open(_fixreserved(url))
except ImportError:
    if os.name == 'nt':
        import win32api
        def browse(url):
            win32api.ShellExecute(0, 'open', _fixreserved(url), None, None, 0)
demandimport.enable()

def _urljoin(*components):
    url = components[0]
    for next in components[1:]:
        if not url.endswith('/'):
            url += '/'
        if next.startswith('/'):
            next = next[1:]
        url += next
    return url

def _baseurl(ui, path):
    remote = hg.repository(ui, path)
    url = hgurl.removeauth(remote.url())
    if url.lower().find('/kiln/') > 0 or url.lower().find('kilnhg.com/') > 0:
        return url
    else:
        return None

def _fixreserved(path):
    reserved = re.compile(
               r'^(((com[1-9]|lpt[1-9]|con|prn|aux)(\..*)?)|web\.config' +
               r'|clock\$|app_data|app_code|app_browsers' +
               r'|app_globalresources|app_localresources|app_themes' +
               r'|app_webreferences|bin)$', re.IGNORECASE)
    p = path.split('?')
    path = p[0]
    query = '?' + p[1] if len(p) > 1 else ''
    return '/'.join('$' + part
                    if reserved.match(part) or part.startswith('$')
                    else part
                    for part in path.split('/')) + query

def kiln(ui, repo, *pats, **opts):
    '''show the relevant page of the repository in Kiln

    This command allows you to navigate straight to a repository,
    including directly to settings, file annotation, and file viewing.

    Typing simply "hg kiln" by itself will take you directly to the
    repository history in kiln.  Specify any other options to override
    this default.
    '''

    url = _baseurl(ui, ui.expandpath(opts['path'] or 'default', opts['path'] or 'default-push'))
    if not url:
        raise util.Abort(_('this does not appear to be a Kiln-hosted repository\n'))
    needsfiles = ['annotate', 'file', 'filehistory']
    if util.any([opts[l] for l in needsfiles]) and not pats:
        raise util.Abort(_('no files or directories specified'))
    m = cmdutil.match(repo, pats, opts)
    files = [f for f in repo['.'].walk(m)]
    default = True

    if opts['annotate']:
        default = False
        for f in files:
            browse(_urljoin(url, 'File', f) + '?view=annotate')
    if opts['file']:
        default = False
        for f in files:
            browse(_urljoin(url, 'File', f))
    if opts['filehistory']:
        default = False
        for f in files:
            browse(_urljoin(url, 'FileHistory', f) + '?rev=tip')

    if opts['outgoing']:
        default = False
        browse(_urljoin(url, 'Outgoing'))
    if opts['settings']:
        default = False
        browse(_urljoin(url, 'Settings'))

    if opts['targets']:
	default = False
	ui.write('Hello World')

    if default or opts['changes']:
        browse(url)

cmdtable = {
    'kiln':
        (kiln,
         [('a', 'annotate', None, _('annotate the file provided')),
          ('c', 'changes', None, _('view the history of this repository; this is the default')),
          ('f', 'file', None, _('view the file contents')),
          ('l', 'filehistory', None, _('view the history of the file')),
          ('o', 'outgoing', None, _('view the repository\'s outgoing tab')),
          ('s', 'settings', None, _('view the repository\'s settings tab')),
          ('p', 'path', '', _('override the default URL to use for Kiln')),
          ('t', 'targets', '', _('veiw the repository\'s targets'))],
         _('hg kiln [-p url] [-a file|-f file|-o|-s|-c]'))
    }
