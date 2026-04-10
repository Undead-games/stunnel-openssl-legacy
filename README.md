# stunnel (legacy PS2 client bridge)

This repository exists to help **preserve connectivity for legacy PlayStation 2 game clients**—for example services that relied on **DNAS** and similar-era infrastructure.

**Purpose:** act as a **bridge** between **today’s servers** and **old PS2 clients** that speak obsolete TLS/SSL options and cipher suites that modern stacks no longer enable by default.

**Important:** the configuration here deliberately enables **deprecated protocols and weak cryptography** that are **unsuitable for general use**. **Do not deploy this for arbitrary or production workloads** outside that narrow preservation goal. Use it only where you understand and accept those trade-offs.

---

*If you are not maintaining compatibility for legacy PS2 software, you almost certainly want a standard, modern stunnel or reverse-proxy setup instead.*
