provider "hcloud" {
  token = data.sops_file.secrets.data["hcloud_token"]
}

provider "desec" {
  api_token = data.sops_file.secrets.data["desec_token"]
}

provider "minio" {
  minio_user     = data.sops_file.secrets.data["s3.access_key"]
  minio_password = data.sops_file.secrets.data["s3.secret_key"]
  minio_server   = "fsn1.your-objectstorage.com"
  minio_region   = "fsn1"
  minio_ssl      = true
}

provider "inwx" {
  username = data.sops_file.secrets.data["inwx.username"]
  password = data.sops_file.secrets.data["inwx.password"]
}

provider "openwrt" {
  user = data.sops_file.secrets.data["openwrt.user"]
  password = data.sops_file.secrets.data["openwrt.password"]
  remote = "http://192.168.1.1"
}
