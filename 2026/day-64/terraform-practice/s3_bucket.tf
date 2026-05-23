#Name must EXACTLY match the manually created bucket.
resource "aws_s3_bucket" "imported" {
  bucket = "terraweek-import-test-sonali"         
}
