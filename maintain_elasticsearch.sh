curator --host elastic3 delete --prefix logstash-engine- --older-than 90
curator --host elastic3 delete --prefix logstash-syslog- --older-than 60
curator --host elastic3 optimize --prefix logstash-syslog- --older-than 1
curator --host elastic3 optimize --prefix logstash-engine- --older-than 1
