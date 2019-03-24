cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
recentpackages=$(find /usr/portage/packages/ -type f -printf "%T+%p\n" | grep -Ev "(9999|html|Packages|/s/)" | sed 's@:[0-9]*\.[0-9]*/usr/portage/packages/@ @; s/\.tbz2//; s/+/ /; s/2019-//' | sort -r | head -n 100 | sed 's@\(.*\) \(.*\) \(.*\)@\1 \2 <a href="\3.tbz2">\3</a>@' | awk '{print $0;}' RS='\n' ORS='\\n' | head -c -2)
isoname=(/usr/portage/packages/s/CloverOS-x86_64-*.iso)
isoname=${isoname##*/}
isolist=$(grep "binhost_mirrors=" ../home/user/make.conf | sed 's@,@/s/CloverOS-x86_64-20190322.iso\n@g' | sed 's@\(.*\)@						<a href="\1">\1</a>@g' | sed '1d;$d' | awk '{print $0;}' RS='\n' ORS='\\n' | head -c -2)
sed "s@{iso_link}@$isoname@g; s@{packages_list}@$recentpackages@g; s@{iso_list}@$isolist@g" indexalt.txt;
