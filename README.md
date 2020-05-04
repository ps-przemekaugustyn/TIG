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

```
docker-compose down -v
```

## Packet Sender
[Packet Sender](https://packetsender.com) is a convenient tool for testing UDP/TCP messages. Please see an example of a measurement packet in samples. Messages should be send to udp://localhost:8092 (telegraf instance).
