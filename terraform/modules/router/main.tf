resource "openwrt_system" "system" {
  hostname = "router"
}

resource "openwrt_configfile" "configs" {
  for_each = fileset(path.module, "configs/*")

  name = each.key
  content = file("${path.module}/${each.key}")
}
