#!/bin/bash

# ensure we are in the correct place
cd /var/www/static/dashboard
ret=$?
if [[ $ret != 0 ]]
then
	exit 1
fi

# generate index.html
cat header.html > index.new
echo '<div class="col-xs-6">' >> index.new
echo '<h3>Production</h3>' >> index.new
for server in betelgeuse capella deneb procyon
do
	./get_status.pl $server >> index.new
done
echo "</div>" >> index.new
echo '<div class="col-xs-6">' >> index.new
echo '<h3>Testing</h3>' >> index.new
for server in aldebaran test stage undying
do
	./get_status.pl $server >> index.new
done
echo "</div>" >> index.new
./footer.sh >> index.new
mv -f index.new index.html

# generate capella.html
cat header.html > capella.new
./get_status.pl capella >> capella.new
./get_status.pl sc10022 30022 >> capella.new
./get_status.pl sc10024 30024 >> capella.new
./footer.sh >> capella.new
mv -f capella.new capella.html

# generate betelgeuse.html
cat header.html > betelgeuse.new
./get_status.pl betelgeuse >> betelgeuse.new
./get_status.pl sc10025 30025 >> betelgeuse.new
./footer.sh >> betelgeuse.new
mv -f betelgeuse.new betelgeuse.html

# generate deneb.html
cat header.html > deneb.new
./get_status.pl deneb >> deneb.new
./get_status.pl sc10019 30019 >> deneb.new
./get_status.pl sc10026 30026 >> deneb.new
./footer.sh >> deneb.new
mv -f deneb.new deneb.html

# generate aldebaran.html
cat header.html > aldebaran.new
./get_status.pl aldebaran >> aldebaran.new
./get_status.pl sc10000 30000 >> aldebaran.new
./footer.sh >> aldebaran.new
mv -f aldebaran.new aldebaran.html

# generate procyon.html
cat header.html > procyon.new
./get_status.pl procyon >> procyon.new
./get_status.pl sc10020 30020 >> procyon.new
./get_status.pl sc10021 30021 >> procyon.new
./footer.sh >> procyon.new
mv -f procyon.new procyon.html

# generate sc.html with all site cons in it
cat header.html > sc.new
./get_status.pl sc10000 30000 >> sc.new
./get_status.pl sc10001 30001 >> sc.new
./get_status.pl sc10002 30002 >> sc.new
./get_status.pl sc10003 30003 >> sc.new
./get_status.pl sc10004 30004 >> sc.new
./get_status.pl sc10005 30005 >> sc.new
./get_status.pl sc10006 30006 >> sc.new
./get_status.pl sc10007 30007 >> sc.new
./get_status.pl sc10008 30008 >> sc.new
./get_status.pl sc10009 30009 >> sc.new
./get_status.pl sc10010 30010 >> sc.new
./get_status.pl sc10011 30011 >> sc.new
./get_status.pl sc10012 30012 >> sc.new
./get_status.pl sc10013 30013 >> sc.new
./get_status.pl sc10014 30014 >> sc.new
./get_status.pl sc10015 30015 >> sc.new
./get_status.pl sc10016 30016 >> sc.new
./get_status.pl sc10017 30017 >> sc.new
./get_status.pl sc10018 30018 >> sc.new
./get_status.pl sc10019 30019 >> sc.new
./get_status.pl sc10020 30020 >> sc.new
./get_status.pl sc10021 30021 >> sc.new
./get_status.pl sc10022 30022 >> sc.new
./get_status.pl sc10023 30023 >> sc.new
./get_status.pl sc10024 30024 >> sc.new
./get_status.pl sc10025 30025 >> sc.new
./get_status.pl sc10026 30026 >> sc.new
./get_status.pl sc10027 30027 >> sc.new
./get_status.pl sc10028 30028 >> sc.new
./get_status.pl sc10029 30029 >> sc.new
./get_status.pl sc10030 30030 >> sc.new
./get_status.pl sc10031 30031 >> sc.new
./get_status.pl sc10032 30032 >> sc.new
./get_status.pl sc10033 30033 >> sc.new
./get_status.pl sc10034 30034 >> sc.new
./footer.sh >> sc.new
mv -f sc.new sc.html

exit 0
