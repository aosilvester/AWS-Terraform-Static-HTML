provider "aws" {
  profile    = "default"
  region     = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-b374d5a5"
  instance_type = "t2.micro"
}

resource "aws_eip" "ip" {
    vpc = true
}

#Main Domain Bucket
resource "aws_s3_bucket" "alexsilvesternetmain" {
    #name of bucket as it appears in AWS S3 console page
  bucket = "alexsilvester.net"
  acl    = "private"

  website {
    index_document = "index.html"
  }
}

#Main Domain bucket policy - to make resources publicly visible
resource "aws_s3_bucket_policy" "alexsilvesternetmain" {
    # dynamic naming in dependent resources to avoid errors when changing names
  bucket = "${aws_s3_bucket.alexsilvesternetmain.id}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "Policy1583108552248",
    "Statement": [
        {
            "Sid": "Stmt1583108547224",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.alexsilvesternetmain.bucket}/*"
        }
    ]
}
POLICY
}

#Adding html doc to main domain bucket
resource "aws_s3_bucket_object" "object" {
  bucket = "${aws_s3_bucket.alexsilvesternetmain.id}"
  key = "index.html"
  source = "./index.html"
}

#SubDomain bucket - to redirect to main bucket
resource "aws_s3_bucket" "alexsilvesternetsub" {
    bucket = "www.alexsilvester.net"
    acl = "private"
    website {
        redirect_all_requests_to = "http://alexsilvester.net"
    }
}
