resource "aws_iam_role" "clixx-role" {
  name = "clixx_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "clixx-pol" {
  name = "clixx-s3-pol"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "clixx-attach" {
  role       = aws_iam_role.clixx-role.id
  policy_arn = aws_iam_policy.clixx-pol.arn
}

resource "aws_iam_instance_profile" "clixx-profile" {
  name = "clixx-s3"
  role = aws_iam_role.clixx-role.id
}
