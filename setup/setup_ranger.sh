#!/usr/bin/env bash

my_custom() {
    sed -i 's/set show_hidden false/set show_hidden true/' ~/.config/ranger/rc.conf
    sed -i 's/set draw_borders none/set draw_borders both/' ~/.config/ranger/rc.conf
    sed -i 's/set preview_directories true/set preview_directories false/' ~/.config/ranger/rc.conf
    sed -i 's/set line_numbers false/set line_numbers true/' ~/.config/ranger/rc.conf
    sed -i 's/set dirname_in_tabs false/set dirname_in_tabs true/' ~/.config/ranger/rc.conf
    sed -i 's/set one_indexed false/set one_indexed true/' ~/.config/ranger/rc.conf
}

add_ranger_cd() {
	tee -a ~/.bashrc <<- "EOF" > /dev/null
	# ranger settings
	[ -n "$RANGER_LEVEL" ] && PS1="$PS1"'(in ranger) '

	# ranger_cd
	ranger_cd() {
	    temp_file="$(mktemp -t "ranger_cd.XXXXXXXXXX")"
	    ranger --choosedir="$temp_file" -- "${@:-$PWD}"
	    if chosen_dir="$(cat -- "$temp_file")" && [ -n "$chosen_dir" ] && [ "$chosen_dir" != "$PWD" ]; then
	        cd -- "$chosen_dir"
	    fi
	    rm -f -- "$temp_file"
	}

	# This binds Ctrl-O to ranger_cd:
	if which ranger >& /dev/null && [[ -t 1 ]]; then
	    bind '"\C-o":"ranger_cd\C-m"'
	fi
	EOF
}

add_compress_cmd_in_ranger() {
	tee -a ~/.config/ranger/commands.py <<- EOF > /dev/null

	from ranger.core.loader import CommandLoader

	class compress(Command):
	    def execute(self):
	        """ Compress marked files to current directory """
	        cwd = self.fm.thisdir
	        marked_files = cwd.get_selection()

	        if not marked_files:
	            return

	    def refresh(_):
	        cwd = self.fm.get_directory(original_path)
	        cwd.load_content()

	        original_path = cwd.path
	        parts = self.line.split()
	        au_flags = parts[1:]

	        descr = "compressing files in: " + os.path.basename(parts[1])
	        obj = CommandLoader(args=['apack'] + au_flags + \
	                [os.path.relpath(f.path, cwd.path) for f in marked_files], descr=descr, read=True)

	        obj.signal_bind('after', refresh)
	        self.fm.loader.add(obj)

	    def tab(self, tabnum):
	        """ Complete with current folder name """

	        extension = ['.zip', '.tar.gz', '.rar', '.7z']
	        return ['compress ' + os.path.basename(self.fm.thisdir.path) + ext for ext in extension]

	EOF
}

add_fzf_select_cmd_in_ranger() {
	tee -a ~/.config/ranger/commands.py <<- EOF > /dev/null

	class fzf_select(Command):
	    """
	    :fzf_select
	    Find a file using fzf.
	    With a prefix argument to select only directories.

	    See: https://github.com/junegunn/fzf
	    """

	    def execute(self):
	        import subprocess
	        import os
	        from ranger.ext.get_executables import get_executables

	        if 'fzf' not in get_executables():
	            self.fm.notify('Could not find fzf in the PATH.', bad=True)
	            return

	        fd = None
	        if 'fdfind' in get_executables():
	            fd = 'fdfind'
	        elif 'fd' in get_executables():
	            fd = 'fd'

	        if fd is not None:
	            hidden = ('--hidden' if self.fm.settings.show_hidden else '')
	            exclude = "--no-ignore-vcs --exclude '.git' --exclude '*.py[co]' --exclude '__pycache__'"
	            only_directories = ('--type directory' if self.quantifier else '')
	            fzf_default_command = '{} --follow {} {} {} --color=always'.format(
	                fd, hidden, exclude, only_directories
	            )
	        else:
	            hidden = ('-false' if self.fm.settings.show_hidden else r"-path '*/\.*' -prune")
	            exclude = r"\( -name '\.git' -o -name '*.py[co]' -o -fstype 'dev' -o -fstype 'proc' \) -prune"
	            only_directories = ('-type d' if self.quantifier else '')
	            fzf_default_command = 'find -L . -mindepth 1 {} -o {} -o {} -print | cut -b3-'.format(
	                hidden, exclude, only_directories
	            )

	        env = os.environ.copy()
	        env['FZF_DEFAULT_COMMAND'] = fzf_default_command
	        env['FZF_DEFAULT_OPTS'] = '--height=40% --layout=reverse --ansi --preview="{}"'.format('''
	            (
	                batcat --color=always {} ||
	                bat --color=always {} ||
	                cat {} ||
	                tree -ahpCL 3 -I '.git' -I '*.py[co]' -I '__pycache__' {}
	            ) 2>/dev/null | head -n 100
	        ''')

	        fzf = self.fm.execute_command('fzf --no-multi', env=env,
	                                    universal_newlines=True, stdout=subprocess.PIPE)
	        stdout, _ = fzf.communicate()
	        if fzf.returncode == 0:
	            selected = os.path.abspath(stdout.strip())
	            if os.path.isdir(selected):
	                self.fm.cd(selected)
	            else:
	                self.fm.select_file(selected)

	EOF
    echo 'map <A-f> fzf_select' >> ~/.config/ranger/rc.conf
}

# main
sudo apt-get install -y ranger w3m lynx highlight atool mediainfo xpdf caca-utils
ranger --copy-config=all
my_custom
add_ranger_cd
add_compress_cmd_in_ranger
add_fzf_select_cmd_in_ranger
