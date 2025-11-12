resource "scaleway_object_bucket" "public_assets" {
  name   = "demo-public-assets-ckv-bad"
  region = "fr-par"
}

resource "scaleway_object_bucket_acl" "public_assets_acl" {
  bucket = scaleway_object_bucket.public_assets.name
  region = "fr-par"
  acl    = "public-read"
}
