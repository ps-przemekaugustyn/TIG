# TIG
Simple setup for **Telegraf &rarr; InfluxDb &rarr; Grafana**

When executed it spawns following services:
- Grafana (http://localhost:3000)
- InfluxDb (http://localhost:8086/health)
- Telegraf (udp://localhost:8092)

#### [Start containers](https://docs.docker.com/compose/reference/up/) in the background

```
docker-compose up -d
```
In order to confirm the stack is up an running we can check endpoints listed above or check logs

```
docker-compose ps
     Name                Command           State                     Ports
---------------------------------------------------------------------------------------------
tig_grafana_1    /run.sh                   Up      0.0.0.0:3000->3000/tcp
tig_influxdb_1   /entrypoint.sh influxd    Up      0.0.0.0:8086->8086/tcp
tig_telegraf_1   /entrypoint.sh telegraf   Up      0.0.0.0:8092->8092/udp, 8094/tcp, 8125/udp
```

```
docker-compose logs telegraf
Attaching to tig_telegraf_1
telegraf_1  | 2020-05-04T17:31:31Z I! Starting Telegraf 1.14.2
telegraf_1  | 2020-05-04T17:31:31Z I! Using config file: /etc/telegraf/telegraf.conf
telegraf_1  | 2020-05-04T17:31:31Z I! Loaded inputs: socket_listener
telegraf_1  | 2020-05-04T17:31:31Z I! Loaded aggregators:
telegraf_1  | 2020-05-04T17:31:31Z I! Loaded processors:
telegraf_1  | 2020-05-04T17:31:31Z I! Loaded outputs: influxdb
telegraf_1  | 2020-05-04T17:31:31Z I! Tags enabled: host=f1817baf913f
telegraf_1  | 2020-05-04T17:31:31Z I! [agent] Config: Interval:10s, Quiet:false, Hostname:"f1817baf913f", Flush Interval:10s
telegraf_1  | 2020-05-04T17:31:31Z D! [agent] Initializing plugins
telegraf_1  | 2020-05-04T17:31:31Z D! [agent] Connecting outputs
telegraf_1  | 2020-05-04T17:31:31Z D! [agent] Attempting connection to [outputs.influxdb]
telegraf_1  | 2020-05-04T17:31:31Z D! [agent] Successfully connected to outputs.influxdb
telegraf_1  | 2020-05-04T17:31:31Z D! [agent] Starting service inputs
telegraf_1  | 2020-05-04T17:31:31Z I! [inputs.socket_listener] Listening on udp://[::]:8092
telegraf_1  | 2020-05-04T17:31:50Z D! [outputs.influxdb] Buffer fullness: 0 / 10000 metrics
```

```
docker-compose logs influxdb
Attaching to tig_influxdb_1
influxdb_1  | influxdb init process in progress...
influxdb_1  | ts=2020-05-04T17:31:28.354245Z lvl=info msg="InfluxDB starting" log_id=0M_Bj2tW000 version=1.8.0 branch=1.8 commit=781490de48220d7695a05c29e5a36f550a4568f5
influxdb_1  | ts=2020-05-04T17:31:28.354315Z lvl=info msg="Go runtime" log_id=0M_Bj2tW000 version=go1.13.8 maxprocs=2
influxdb_1  | ts=2020-05-04T17:31:28.476371Z lvl=info msg="Using data dir" log_id=0M_Bj2tW000 service=store path=/var/lib/influxdb/data
```

#### [Stop containers](https://docs.docker.com/compose/reference/down/)
(please note that -v will remove volumes so the persistancy will be lost)

``` bash
docker-compose down -v
```
## InfluxDb queries
``` bash
show databases
use database_name
show measurements
show tag values from updatedb_shipping_estimates with key = host
show tag values cardinality from crawler6_crawl with key=host

select * from test_measurement	
select * from crawler6_crawl order by time desc limit 10
select * from crawler6_crawl where time>now() -1h order by time desc limit 10
```
## Testing and tools
### Packet Sender
[Packet Sender](https://packetsender.com) is a convenient tool for testing UDP/TCP messages. Please see an example of a measurement packet in samples. Messages should be send to udp://localhost:8092 (telegraf instance).

### Netcat (Linux/Mac)

``` bash
echo "<measurement name>,my_tag_key=my_tag_value,influxdb_database=<target database> value=777"  \
     | nc -vv -u -w1 192.168.108.70 8092
```

### Powershell (Windows/Mac/Linux)
[Installing Powershell on Mac](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos?view=powershell-7)

``` powershell
// download script from repo (it is public)
Invoke-WebRequest -Uri https://raw.githubusercontent.com/ps-przemekaugustyn/TIG/master/powershell/UdpDatagram.ps1 -OutFile UdpDatagram.ps1

// load script (dot sourcing)
. ./UdpDatagram.ps1

// execute function
Send-UdpDatagram -EndPoint "10.21.101.174" -Port 30000 -Message "test_measurement_przemek4,tagname=tagvalue,influxdb_database=spu executiontime=123,sqlexecutiontime=155"
```

### Tcpdump (Mac/Linux)

To capture outgoing UDP traffic on particular network interface (below it is an OpenVPN tap0 interface) we can use [tcpdump](https://explainshell.com/explain?cmd=tcpdump+-i+tap0+udp+port+30000+-vvv+-X) in order to confirm that we are actually sending datagrams:

``` bash
ifconfig |grep -Eo "^\w+:"
```
```
lo0:
gif0:
stf0:
en5:
ap1:
en0:
...
vnic0:
vnic1:
tap0:
```
``` bash
tcpdump -i tap0 udp port 30000 -vvv -X
```
```
tcpdump: listening on tap0, link-type EN10MB (Ethernet), capture size 262144 bytes
23:38:33.004007 IP (tos 0x0, ttl 64, id 44140, offset 0, flags [none], proto UDP (17), length 131)
    10.21.103.151.56765 > 10.21.101.174.30000: [udp sum ok] UDP, length 103
	0x0000:  4500 0083 ac6c 0000 4011 ec8e 0a15 6797  E....l..@.....g.
	0x0010:  0a15 65ae ddbd 7530 006f db86 7465 7374  ..e...u0.o..test
	0x0020:  5f6d 6561 7375 7265 6d65 6e74 5f70 727a  _measurement_prz
	0x0030:  656d 656b 342c 7461 676e 616d 653d 7461  emek4,tagname=ta
	0x0040:  6776 616c 7565 2c69 6e66 6c75 7864 625f  gvalue,influxdb_
	0x0050:  6461 7461 6261 7365 3d73 7075 2065 7865  database=spu.exe
	0x0060:  6375 7469 6f6e 7469 6d65 3d31 3233 2c73  cutiontime=123,s
	0x0070:  716c 6578 6563 7574 696f 6e74 696d 653d  qlexecutiontime=
	0x0080:  3135 35                                  155
```