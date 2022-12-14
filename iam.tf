resource "aws_iam_role" "invoke_sfn" {
  name = "aws-event-driven-architecture-eventbridge-invoke-sfn"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "events.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

  inline_policy {
    name = "aws-event-driven-architecture-eventbridge-invoke-sfn"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "states:StartExecution"
            ],
            "Resource": [
                "arn:aws:states:us-east-1:548368368580:stateMachine:OrderProcessing"
            ]
        }
    ]
}
EOF
  }
}

resource "aws_iam_role" "invoke_api" {
  name = "aws-event-driven-architecture-eventbridge-invoke-api"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "events.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF

  inline_policy {
    name = "aws-event-driven-architecture-eventbridge-invoke-api"

    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "events:InvokeApiDestination"
            ],
            "Resource": [
                "arn:aws:events:us-east-1:548368368580:api-destination/api-destination/*"
            ]
        }
    ]
}
EOF
  }
}
