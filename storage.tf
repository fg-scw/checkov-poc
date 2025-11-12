resource "scaleway_object_bucket" "public_assets" {
  name   = "${var.project_name}-public-assets"
  region = var.region

  versioning { enabled = true }

  tags = {
    project = var.project_name
    env     = var.environment
    type    = "assets"
  }
}

resource "scaleway_object_bucket_acl" "public_assets_acl" {
  bucket = scaleway_object_bucket.public_assets.name
  region = var.region
  acl    = "private"
}

resource "scaleway_object_bucket" "private_data" {
  name   = "${var.project_name}-private-data"
  region = var.region

  versioning { enabled = true }

  tags = {
    project = var.project_name
    env     = var.environment
    type    = "private"
  }
}

resource "scaleway_object_bucket_acl" "private_data_acl" {
  bucket = scaleway_object_bucket.private_data.name
  region = var.region
  acl    = "private"
}
