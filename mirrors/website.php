<?php
unlink('../index.html');
unlink('../indexalt.html');

$git = 'https://gitgud.io/cloveros/cloveros/raw/master';

$packageuse = file_get_contents("$git/binhost_settings/etc/portage/package.use");
$packageenv = file_get_contents("$git/binhost_settings/etc/portage/package.env");
$packagekeywords = file_get_contents("$git/binhost_settings/etc/portage/package.keywords");
$makeconf = file_get_contents("$git/binhost_settings/etc/portage/make.conf");
$worldtxt = file_get_contents("$git/binhost_settings/var/lib/portage/world");
$installscriptsh = file_get_contents("$git/installscript.sh");
$usermake = file_get_contents("$git/home/user/make.conf");
$quickpkg = file_get_contents('quickpkg.txt');

$mirrors = substr($usermake, strpos($usermake, 'binhost_mirrors="$PORTAGE_BINHOST,') + 34);
$mirrors = substr($mirrors, 0, strpos($mirrors, ',"'));
$mirrors = explode(',', $mirrors);
$mirrorlinks = '';
foreach ( $mirrors as $line ) {
	$mirrorlinks .= '<a target="_blank" href="'.$line.'">'.$line.'</a> ';
}

$isoname = glob('CloverOS-x86_64-*.iso')[0];
$libreisoname = glob('CloverOS_Libre-x86_64-*.iso')[0];

$files = file_get_contents('http://127.0.0.1:20000'); // nginx index. working on replacement
$files = substr($files, strpos($files, '<h1>Index of /'));
$files = substr($files, 0, strpos($files, '</body>'));

$html = '<!DOCTYPE html>
<html>
<link rel="icon" href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQAgMAAABinRfyAAAACVBMVEXKbt4AmQAAzAArTnekAAAAAXRSTlMAQObYZgAAADdJREFUeAFjYGARYGBgEA0BEqGhUIJLNGQBg1Zr0AqGVQu9VjFordBaASIgXLAEWAlcB8QAsFEAnzYQ4QKPcGQAAAAASUVORK5CYII=" type="image/x-ico" />
<title>CloverOS GNU/Linux</title>
<style>
	body { color: black; background: white; }
	a { text-decoration: none; }
	a:visited { color: blue; }
	pre:first-of-type { margin: 0; }
	.mono { font-family: monospace; }
	.fileinfo { height: 150px; width: 550px; margin: 0; overflow: auto; resize: both; border: 1px solid black; }
	.ansi1 { font-weight: bold; }
	.ansi32 { color: #00aa00; }
	.ansi34 { color: #0000aa; }
</style>
CloverOS GNU/Linux
<br><br>
Git: <a target="_blank" href="https://gitgud.io/cloveros/cloveros">https://gitgud.io/cloveros/cloveros</a><br>
ISO: <a href="s/'.$isoname.'">https://cloveros.ga/s/'.$isoname.'</a><br>
Libre ISO: <a href="s/'.$libreisoname.'">https://cloveros.ga/s/'.$libreisoname.'</a><br>
GPG: <a target="_blank" href="s/cloveros.gpg">78F5 AC55 A120 07F2 2DF9  A28A 78B9 3F76 B8E4 2805</a><br>
IRC: <a target="_blank" href="irc://irc.rizon.net/cloveros">#cloveros</a> on irc.rizon.net<br>
Twitter: <a target="_blank" href="https://twitter.com/cloveros_ga">https://twitter.com/cloveros_ga</a><br>
Packages: <a target="_blank" href="s/packages.html">'.substr_count($quickpkg, ': ').' https://cloveros.ga/s/packages.html</a><br>
Rsync: rsync://nl.cloveros.ga/cloveros<br>
License: WTFPL<br>
Mirrors: '.$mirrorlinks.'<br>
CFLAGS: <span class="mono">CFLAGS="-Ofast -mmmx -mssse3 -pipe -funroll-loops -flto=8 -floop-block -floop-interchange -floop-strip-mine -ftree-loop-distribution"</span><br>
USE flags: <span class="mono">USE="-systemd -pulseaudio -avahi -dbus -zeroconf -nls -doc -gnome-keyring -gstreamer -libav -openal -kde -gnome -openssl libressl bindist ipv6 http2 dri cli minimal jpeg gif png offensive zsh-completion threads aio jit lto graphite pgo numa alsa joystick xinerama wayland egl vulkan opengl opencl glamor vaapi vdpau xvmc"</span><br>
Validate ISO: <pre class="mono">gpg --keyserver hkp://pool.sks-keyservers.net --recv-key "78F5 AC55 A120 07F2 2DF9 A28A 78B9 3F76 B8E4 2805"
wget https://cloveros.ga/s/signatures/s/'.$isoname.'.asc
gpg --verify '.$isoname.'.asc '.$isoname.'</pre>
<br>
<a target="_blank" href="'.$git.'/installscript.sh">CloverOS install script</a>
<pre class="mono fileinfo">'.$installscriptsh.'</pre>
<br>
<a target="_blank" href="s/quickpkg.txt"><span class="mono">$ sudo quickpkg --include-unmodified-config=y "*/*"</span></a>
<pre class="mono fileinfo">'.$quickpkg.'</pre>
<br>
<a href="'.$git.'/binhost_settings/etc/portage/make.conf" target="_blank">/etc/portage/make.conf</a>
<pre class="mono fileinfo">'.$makeconf.'</pre>
<br>
<a href="'.$git.'/binhost_settings/etc/portage/package.use" target="_blank">/etc/portage/package.use</a>
<pre class="mono fileinfo">'.$packageuse.'</pre>
<br>
<a href="'.$git.'/binhost_settings/etc/portage/package.env" target="_blank">/etc/portage/package.env</a>
<pre class="mono fileinfo">'.$packageenv.'</pre>
<br>
<a href="'.$git.'/binhost_settings/var/lib/portage/world" target="_blank">/var/lib/portage/world</a>
<pre class="mono fileinfo">'.$worldtxt.'</pre>
'.$files.'
</html>';

file_put_contents('../index.html', $html);

$isos = '';
foreach ( $mirrors as $line ) {
	$isos .= "\n".'					<a href="'.$line.'/s/'.$isoname.'">'.$line.'/s/'.$isoname.'</a>';
}
file_put_contents('../indexalt.html', str_replace("\n{iso_links}", $isos, file_get_contents('indexalt.txt')));
?>