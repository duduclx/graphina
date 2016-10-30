# logstash and elastic search docker image

instead of running:
#run logstash docker
#docker run -p 25826:25826/udp -it --rm -v $(pwd):/config-dir logstash logstash -f /config-dir/logstash.conf
for switchboard supervision

maybe we can use an elk (elasticsearsh + logstash + kibana) docker image,

and connect graphite to the elasticsearch,

and then use:

#run logstash docker
#docker run -p 25826:25826/udp -it --rm -v $(pwd):/config-dir logstash logstash -f /config-dir/logstash.conf

to be able to see logstash log in grafana

have to look around that.
