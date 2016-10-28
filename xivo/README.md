# XiVO statistics

On your XiVO or adapt the config for your installation.
```
apt-get install collectd
```
In directory /etc/collectd/collectd.conf.d

Add a file : amqp.conf
```
LoadPlugin amqp
<Plugin "amqp">
  <Subscribe "xivo">
    Host "127.0.0.1"
    Port "5672"
    VHost "/"
    User "guest"
    Password "guest"
    Exchange "collectd"
    ExchangeType "topic"
    RoutingKey "collectd.#"
  </Subscribe>
</Plugin>
```
Add a file : graphite.conf
```
LoadPlugin write_graphite
<Plugin "write_graphite">
    <Node "graphite">
        Host "192.168.32.41"
        Port "2003"
        EscapeCharacter "_"
        SeparateInstances true
        StoreRates false
        AlwaysAppendDS false
    </Node>
</Plugin>
```
And launch docker graphite/graphana instance.

docker run -d -p 80:80 -p 2003:2003 -p 8125:8125/udp -p 8126:8126 --name grafana-dashboard choopooly/grafana-graphite

Go to your docker_host port 80.

Add an asterisk dialplan like:
```
exten = 1234,1,NoOp(callcontrol)
same  =      n,Set(XIVO_STASIS_ARG=sw1)
same  =      n,Stasis(callcontrol,${XIVO_STASIS_ARG})
same  =      n,Hangup()
```
