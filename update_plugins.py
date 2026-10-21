try:
    import concurrent.futures as futures
except ImportError:
    try:
        import futures
    except ImportError:
        futures = None

import zipfile
import shutil
import tempfile
import requests

from os import path


#--- Globals ----------------------------------------------
PLUGINS = """
ack.vim https://github.com/mileszs/ack.vim
ale https://github.com/dense-analysis/ale
auto-pairs https://github.com/jiangmiao/auto-pairs
ctrlp.vim https://github.com/ctrlpvim/ctrlp.vim
gruvbox https://github.com/morhetz/gruvbox
lightline.vim https://github.com/itchyny/lightline.vim
nerdtree https://github.com/preservim/nerdtree
tabular https://github.com/godlygeek/tabular
taglist https://github.com/yegappan/taglist
vim-commentary https://github.com/tpope/vim-commentary
vim-fugitive https://github.com/tpope/vim-fugitive
vim-gitgutter https://github.com/airblade/vim-gitgutter
vim-indent-object https://github.com/michaeljsmith/vim-indent-object
vim-markdown https://github.com/preservim/vim-markdown
vim-repeat https://github.com/tpope/vim-repeat
vim-surround https://github.com/tpope/vim-surround
""".strip()

GITHUB_ZIP = '%s/archive/HEAD.zip'

SOURCE_DIR = path.join(path.dirname(__file__), 'sources_non_forked')


def download_extract_replace(plugin_name, zip_path, temp_dir, source_dir):
    temp_zip_path = path.join(temp_dir, plugin_name)

    # Download and extract file in temp dir
    req = requests.get(zip_path)
    req.raise_for_status()
    open(temp_zip_path, 'wb').write(req.content)

    zip_f = zipfile.ZipFile(temp_zip_path)
    zip_f.extractall(temp_dir)

    # The archive's top directory is named <repo>-<branch>
    top_dir = zip_f.namelist()[0].split('/')[0]
    plugin_temp_path = path.join(temp_dir, top_dir)

    # Remove the current plugin and replace it with the extracted
    plugin_dest_path = path.join(source_dir, plugin_name)

    try:
        shutil.rmtree(plugin_dest_path)
    except OSError:
        pass

    shutil.move(plugin_temp_path, plugin_dest_path)
    print('Updated {0}'.format(plugin_name))


def update(plugin):
    name, github_url = plugin.split(' ')
    zip_path = GITHUB_ZIP % github_url
    download_extract_replace(name, zip_path,
                             temp_directory, SOURCE_DIR)


if __name__ == '__main__':
    temp_directory = tempfile.mkdtemp()

    try:
        if futures:
            with futures.ThreadPoolExecutor(16) as executor:
                list(executor.map(update, PLUGINS.splitlines()))
        else:
            [update(x) for x in PLUGINS.splitlines()]
    finally:
        shutil.rmtree(temp_directory)
