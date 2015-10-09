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
for server in betelgeuse capella
do
	./get_status.pl $server >> index.new
done
echo "</div>" >> index.new
echo '<div class="col-xs-6">' >> index.new
echo '<h3>Testing</h3>' >> index.new
for server in aldebaran deneb test stage
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
./footer.sh >> deneb.new
mv -f deneb.new deneb.html

# generate aldebaran.html
cat header.html > aldebaran.new
./get_status.pl aldebaran >> aldebaran.new
./footer.sh >> aldebaran.new
mv -f aldebaran.new aldebaran.html

exit 0
