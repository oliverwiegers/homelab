# OpenWRT

## Initial Setup

- Enable SSH using the Web UI

```bash
ssh root@192.168.1.1 -oHostKeyAlgorithms=+ssh-rsa
opkg update
opkg install luci-mod-rpc luci-lib-ipkg luci-compat
/etc/init.d/uhttpd restart
```

## Requirements

- JSON-RPC API
  - See [here](https://github.com/openwrt/luci/blob/master/docs/JsonRpcHowTo.md)
