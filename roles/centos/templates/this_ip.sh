cd /home/ansible/roles/centos/templates
cp hosts.j2.1 hosts.j2
echo `ifconfig eth2 | sed -n -e "s/\s*inet addr:\([[:digit:]\.]*\).*/\1/p"` master >> hosts.j2
