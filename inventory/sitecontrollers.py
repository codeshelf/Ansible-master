#!/usr/bin/env python
# psql -d database -c "select domainid from aldebaran.uom_master" -h dbmaster -U codeshelf -tA -F ""

#[sitecon]
#sc10000 ansible_ssh_port=10000 diag_port=30000 codeshelf_server=aldebaran.codeshelf.com customer=Demo codeshelf_version=stage alert=yes

#[sitecon:vars]
#codeshelf_networknumber=1
#codeshelf_channel=5
#ansible_ssh_host=home1
#exclude_from_hosts=yes
#cred="0.6910096026612129"
import subprocess
import json

def get_sitecons(db,manager_schema):
	cmd = "psql|-d|database|-c|select u.username,t.name from "+manager_schema+".users as u join "+manager_schema+".tenant as t on u.tenant_id=t.id where length(u.username)=5 and u.username similar to '\d+' and u.active=true and t.active=true|-h|"+db+"|-U|codeshelf|-tA|-F|"
	output = subprocess.Popen(cmd.split("|"), stdout=subprocess.PIPE).communicate()[0]
	recs = output.split();
	users = {}
	for user in recs:
		serial = user[:5]
		server = manager_schema[8:]
		customer = user[5:]
		if customer == "default":
			customer = server
		version = server

		#if version == "aldebaran":
		#	version = "stage" # temporary!

		alert = "yes"
		if version == "stage" or version == "test":
			alert = "no"
		hostname = "sc"+serial
		#print "debug: "+hostname+","+version+","+customer+","+server
		dport = int(serial)+20000
		uvars = {"ansible_hostname":hostname,"ansible_ssh_host":"home1","ansible_ssh_port":serial,"diag_port":dport,"codeshelf_server":server+".codeshelf.com","customer":customer,"codeshelf_version":version,"alert":alert,"exclude_from_hosts":"yes","cred":"0.6910096026612129"}
		users[hostname] = uvars;
	return users


sitecons = []
hostvars = {}
mgr_schemas = {"pgtest":["manager_test","manager_stage"],"dbmaster":["manager_aldebaran","manager_betelgeuse","manager_capella","manager_deneb"]}
for db in mgr_schemas:
	for schema in mgr_schemas[db]:
		results = get_sitecons(db,schema)
		for sitecon in results:
			sitecons.append(sitecon)
		hostvars.update(results)

inventory = {"sitecon": sitecons}
hostvars_map = {"hostvars": hostvars}
inventory["_meta"] = hostvars_map

print json.dumps(inventory)
