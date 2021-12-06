terraform{
  backend "s3"{
    bucket          = "stackbuckstate-fatimat"
    key             = "terraform.tfsate"
    region          = "us-east-1"
    dynamodb_table  = "statelock-tf"
  }
}
