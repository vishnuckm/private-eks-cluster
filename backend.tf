terraform {
  backend "s3" {
        bucket = "vishnu-bucket-eks-12123"
        key     = "myproject022/terraform.tfstate"
        region = "us-west-2"
  }
}
