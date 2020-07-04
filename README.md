# cowrie-setup-tool
## Description
Bash tool to automatically deploy a fully functional Cowrie honeypot. Tested on Ubuntu 19.10 LTS. Not compatible with Ubuntu 20+.

The tool requires some user inputs, but the deployment process is completely automated.

Cowrie honeypot documentation can be found [here](https://cowrie.readthedocs.io/en/latest/index.html)


## Optional: elk-setup-tool
After successfully deploying Cowrie honeypot with the previous tool, we can install ELK to process Cowrie's output with elk_setup_tool. The installation will take around 15 minutes and will need of a little bit of user interaction.
After the installation, go to localhost:80 and refresh until you get "Kibana server is not ready yet" (takes about 2-3 minutes). After that, wait a minute and refresh the page.

Get GeoIP data from www.maxmind.com. After registering, log into your account and go to "Download databases". There, download the GeoLite2 City GZIP, extract it and cd into the mmdb file location. Then execute:
```
sudo mkdir -p /opt/logstash/vendor/geoip/
sudo mv GeoLite2-City.mmdb /opt/logstash/vendor/geoip
sudo systemctl restart logstash
sudo systemctl restart filebeat
```

After that, execute:
```
curl 'http://localhost:9200/_cat/indices?v'
```
You should see a cowrie index cowrie-logstash-DATE
Then, in Kibana's GUI create an index pattern (*Management/Stack Management/Kibana/Index Patterns*) for 
```
cowrie-logstash-*
```
Use default settings and timestamp

Refer to elastic’s [documentation](https://www.elastic.co/guide/index.html) about proper configuration of the system for the best elasticsearch’s performance

*All credit for Cowrie honeypot goes to [Michel Oosterhof](https://github.com/cowrie/cowrie).*
