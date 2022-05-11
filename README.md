### Prerequisites:
- `docker`
- `docker-compose`
- `make`

### Topology:
```
h1 (10.0.0.1, 00:00:00:00:01)
            |
            | 
         Switch1 
            |
            |
h2 (10.0.0.2, 00:00:00:00:02)
```

### Build P4 program

```bash
make build
```

### Start topology
```bash
make up
```

### Start P4Runtime
```bash
make p4rt-shell
```

### Run Mininet shell and run Ping h1->h2:
Ping doesn't work.
```bash
❯ make mn-cli
Detach with CTRL+D
mininet> h1 ping h2
PING 10.0.0.2 (10.0.0.2) 56(84) bytes of data.
^C
--- 10.0.0.2 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 1028ms

mininet>
```

### Insert flow entries
In p4rt-shell run the following commands.

Entry to forward traffic towards H1: 10.0.0.1:
```build
te = table_entry["MyIngress.ipv4_lpm"](action="ipv4_forward")
te.match["dstAddr"] = "10.0.0.1/32"
te.action["macDestination"] = "00:00:00:00:00:01"
te.action["outputPort"] = "1"
te.insert()
```

Entry to Forward traffic towards H2: 10.0.0.2:
```bash
te = table_entry["MyIngress.ipv4_lpm"](action="ipv4_forward")
te.match["dstAddr"] = "10.0.0.2/32"
te.action["macDestination"] = "00:00:00:00:00:02"
te.action["outputPort"] = "2"
te.insert()
```

Show all entries in the IPv4 LPM table:
```bash
for te in table_entry["MyIngress.ipv4_lpm"].read():
print(te)
```

### Run Mininet shell and run Ping h1->h2:
Now ping works!
```bash
❯ make mn-cli
Detach with CTRL+D
mininet> h1 ping h2
PING 10.0.0.2 (10.0.0.2) 56(84) bytes of data.
64 bytes from 10.0.0.2: icmp_seq=1 ttl=63 time=3.48 ms
64 bytes from 10.0.0.2: icmp_seq=2 ttl=63 time=4.34 ms
64 bytes from 10.0.0.2: icmp_seq=3 ttl=63 time=4.40 ms
^C
--- 10.0.0.2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 3.481/4.074/4.401/0.420 ms
mininet>
```