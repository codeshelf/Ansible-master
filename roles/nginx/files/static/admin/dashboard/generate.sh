#!/bin/bash

# generate index.html
cat header.html > index.new
echo '<div class="col-xs-6">' >> index.new
for server in aldebaran betelgeuse
do
	./get_status.pl $server >> index.new
done
echo "</div>" >> index.new
echo '<div class="col-xs-6">' >> index.new
for server in capella deneb
do
	./get_status.pl $server >> index.new
done
echo "</div>" >> index.new
cat footer.html >> index.new
mv index.new index.html

# generate capella.html
cat header.html > capella.new
./get_status.pl capella >> capella.new
./get_status.pl sc10022 30022 >> capella.new
cat footer.html >> capella.new
mv capella.new capella.html

# generate betelgeuse.html
cat header.html > betelgeuse.new
./get_status.pl betelgeuse >> betelgeuse.new
./get_status.pl sc10004 30004 >> betelgeuse.new
cat footer.html >> betelgeuse.new
mv betelgeuse.new betelgeuse.html

# generate deneb.html
cat header.html > deneb.new
./get_status.pl deneb >> deneb.new
cat footer.html >> deneb.new
mv deneb.new deneb.html

# generate aldebaran.html
cat header.html > aldebaran.new
./get_status.pl aldebaran >> aldebaran.new
cat footer.html >> aldebaran.new
mv aldebaran.new aldebaran.html

exit 0
