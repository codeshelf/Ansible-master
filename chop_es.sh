exit 128
curator --host elastic3 delete --prefix logstash-engine- --older-than 17
curator --host elastic3 delete --prefix logstash-syslog- --older-than 15
curator --host elastic3 optimize --prefix logstash-syslog- --older-than 1
curator --host elastic3 optimize --prefix logstash-engine- --older-than 1
