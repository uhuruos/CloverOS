<?php
chdir(__DIR__);
$indexalt = file_get_contents('indexalt.txt');
$usermake = file_get_contents('../home/user/make.conf');
$isoname = basename(glob('/usr/portage/packages/s/CloverOS-x86_64-*.iso')[0]);
$mirrors = substr($usermake, strpos($usermake, 'binhost_mirrors="$PORTAGE_BINHOST,') + 34);
$mirrors = substr($mirrors, 0, strpos($mirrors, ',"'));
$mirrors = explode(',', $mirrors);
$isos = '';
foreach ($mirrors as $line) {
	$isos .= '							<a href="'.$line.'/s/'.$isoname.'">'.$line.'/s/'.$isoname.'</a>'."\n";
}
$isos = rtrim($isos);
echo str_replace("{iso_links}", $isos, str_replace("{iso_link}", $isoname, $indexalt));
