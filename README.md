# stunnel (legacy PS2 client bridge)

This repository exists to help **preserve connectivity for legacy PlayStation 2 game clients**—for example services that relied on **DNAS** and similar-era infrastructure.

**Purpose:** act as a **bridge** between **today’s servers** and **old PS2 clients** that speak obsolete TLS/SSL options and cipher suites that modern stacks no longer enable by default.

**Important:** the configuration here deliberately enables **deprecated protocols and weak cryptography** that are **unsuitable for general use**. **Do not deploy this for arbitrary or production workloads** outside that narrow preservation goal. Use it only where you understand and accept those trade-offs.

---

*If you are not maintaining compatibility for legacy PS2 software, you almost certainly want a standard, modern stunnel or reverse-proxy setup instead.*

Docker Hub image: https://hub.docker.com/r/panzerpunk/stunnel

## Example config

```ini
foreground = yes
pid =
output = /dev/stdout
debug = 7

[dnas]
accept = 443
cert = /etc/dnas/certs/cert.pem
key = /etc/dnas/certs/cert-key.pem
connect = dnas-backend:80
ciphers = ALL
```

## Run

```bash
docker run --rm -v ./configs/stunnel.conf:/etc/stunnel/stunnel.conf -v ./certs:/etc/dnas/certs -p 443:443 panzerpunk/stunnel:latest /etc/stunnel/stunnel.conf
```
