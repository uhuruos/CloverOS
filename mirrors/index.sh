cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
git=https://gitgud.io/cloveros/cloveros/raw/master
site=cloveros.ga
isoname=`basename /var/cache/binpkgs/s/CloverOS-x86_64-*.iso`
libreisoname=`basename /var/cache/binpkgs/s/CloverOS_Libre-x86_64-*.iso`
minimalisoname=`basename /var/cache/binpkgs/s/CloverOS_Minimal-x86_64-*.iso`
packageuse=`cat ../binhost_settings/etc/portage/package.use`
packageenv=`cat ../binhost_settings/etc/portage/package.env`
packagekeywords=`cat ../binhost_settings/etc/portage/package.accept_keywords`
makeconf=`cat ../binhost_settings/etc/portage/make.conf`
reposconf=`cat ../binhost_settings/etc/portage/repos.conf/eselect-repo.conf`
worldtxt=`cat ../binhost_settings/var/lib/portage/world`
usermake=`cat ../home/user/make.conf`
quickpkg=`cat /var/cache/binpkgs/s/quickpkg.html`
quickpkg=`grep span /var/cache/binpkgs/s/quickpkg.html`
packagecount=`echo /var/db/pkg/*/* | wc -w`
cflags=`grep ^CFLAGS=\"- ../binhost_settings/etc/portage/make.conf`
use=`grep ^USE= ../binhost_settings/etc/portage/make.conf`
mirrors=`grep binhost_mirrors= ../home/user/make.conf | tr "," "\n" | sed 's@\(.*\)@<a href="\1">\1</a>@g; 1d;$d;' | tr "\n" " "`
files="<h1>Index of /</h1><hr><pre><a href=\"../\">../</a>		-"$'\n'"$(for line in `ls -1p /var/cache/binpkgs/`; do echo "<a href=\"$line\">$line</a>						$(date -r /var/cache/binpkgs/$line "+%d-%b-%Y %H:%M")       -"; done)"
echo '<!DOCTYPE html>
<html>
<link rel="icon" href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAgMAAABinRfyAAAACVBMVEXKbt4AmQAAzAArTnekAAAAAXRSTlMAQObYZgAAADdJREFUeAFjYGARYGBgEA0BEqGhUIJLNGQBg1Zr0AqGVQu9VjFordBaASIgXLAEWAlcB8QAsFEAnzYQ4QKPcGQAAAAASUVORK5CYII=" type="image/x-ico" />
<title>CloverOS GNU/Linux</title>
<style>
	body { color: black; background: white; }
	a { text-decoration: none; }
	a:visited { color: blue; }
	.mono { font-family: monospace; }
	.pre { white-space: pre; }
	.fileinfo { height: 150px; width: 550px; margin: 0; overflow: auto; resize: both; border: 1px solid black; }
	.ansi1 { font-weight: bold; }
	.ansi32 { color: #00aa00; }
	.ansi34 { color: #0000aa; }
</style>
CloverOS GNU/Linux
<br><br>
Git: <a target="_blank" href="https://gitgud.io/cloveros/cloveros">https://gitgud.io/cloveros/cloveros</a><br>
ISO: <a href="s/'"$isoname"'">https://'"$site"'/s/'"$isoname"'</a><br>
Libre ISO: <a href="https://nl.cloveros.ga/s/'"$libreisoname"'">https://nl.cloveros.ga/s/'"$libreisoname"'</a><br>
Minimal ISO: <a href="https://nl.cloveros.ga/s/'"$minimalisoname"'">https://nl.cloveros.ga/s/'"$minimalisoname"'</a><br>
GPG: <a target="_blank" href="s/cloveros.gpg">78F5 AC55 A120 07F2 2DF9  A28A 78B9 3F76 B8E4 2805</a><br>
IRC: <a target="_blank" href="irc://irc.rizon.net/cloveros">#cloveros</a> on irc.rizon.net<br>
Twitter: <a target="_blank" href="https://twitter.com/cloveros_ga">https://twitter.com/cloveros_ga</a><br>
Rsync: rsync://nl.cloveros.ga/cloveros<br>
License: WTFPL<br>
Mirrors: '"$mirrors"'<br>
Packages: <a target="_blank" href="s/packages.html">'"$packagecount"' https://'"$site"'/s/packages.html</a><br>
CFLAGS: <span class="mono">'"$cflags"'</span><br>
USE flags: <span class="mono">'"$use"'</span><br>
DL & Validate ISO: <span class="mono pre">gpg --keyserver hkp://pool.sks-keyservers.net --recv-key "78F5 AC55 A120 07F2 2DF9 A28A 78B9 3F76 B8E4 2805"
wget https://'"$site"'/s/'"$isoname"' https://'"$site"'/s/signatures/s/'"$isoname"'.asc
gpg --verify '"$isoname"'.asc '"$isoname"'</span>
<br>
<a target="_blank" href="s/quickpkg.html"><span class="mono">$ sudo quickpkg --include-unmodified-config=y "*/*"</div></a>
<div class="mono pre fileinfo">'"$quickpkg"'</div>
<a href="'"$git"'/binhost_settings/etc/portage/make.conf" target="_blank">/etc/portage/make.conf</a>
<div class="mono pre fileinfo">'"$makeconf"'</div>
<a href="'"$git"'/binhost_settings/etc/portage/package.use" target="_blank">/etc/portage/package.use</a>
<div class="mono pre fileinfo">'"$packageuse"'</div>
<a href="'"$git"'/binhost_settings/etc/portage/package.env" target="_blank">/etc/portage/package.env</a>
<div class="mono pre fileinfo">'"$packageenv"'</div>
<a href="'"$git"'/binhost_settings/etc/portage/repos.conf/eselect-repo.conf" target="_blank">/etc/portage/repos.conf/eselect-repo.conf</a>
<div class="mono pre fileinfo">'"$reposconf"'</div>
<a href="'"$git"'/binhost_settings/var/lib/portage/world" target="_blank">/var/lib/portage/world</a>
<div class="mono pre fileinfo">'"$worldtxt"'</div>
'"$files"'
</html>'
