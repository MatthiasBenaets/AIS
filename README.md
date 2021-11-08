# AIS

### AKA Automated Installation Script

Created to automate the installation process of my personal window manager and needed packages and dependencies.

---
### Current status

- Suckless-installer.sh should work as intended for Debian, Arch and Void. It will probably also work any other distribution using the same package manager.
- Gentoo scripts should work. Last time I tried, dwm swallow patch broke the window manager. Will probably need some tinkering to get working. Partially abandoned since some essential patches won't work correctly. Might fix later. Correct order: part1 - part2 - dwm
- Archive: old script that are out of date or are full implemented in "suckless-installer.sh"

### General use

Either:
<pre>
git clone https://www.github.com/matthiasbenaets/ais
</pre>

or
<pre>
wget https://raw.githubusercontent.com/matthiasbenaets/ais/main/[script name]
</pre>

If script does not run, give permission:
<pre>
chmod +x [script name].sh
./[script name].sh
</pre>
