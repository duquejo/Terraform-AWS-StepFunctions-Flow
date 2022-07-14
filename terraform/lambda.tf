# Generate output file from lambda code.
data "archive_file" "archive-pow-lambda" {
    type = "zip"
    source_file = "../src/pow-lambda/index.js"
    output_path = "../src/pow-lambda/archive.zip"
}

# Generate output file from lambda code.
data "archive_file" "archive-rand-lambda" {
    type = "zip"
    source_file = "../src/rand-lambda/index.js"
    output_path = "../src/rand-lambda/archive.zip"
}

# Create AWS IAM Role for lambdas.
# Fix: Removed leading spaces
resource "aws_iam_role" "iam_for_lambda" {
    name = "stepFunctionSampleLambdaIAM"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

# Create AWS Lambda function

resource "aws_lambda_function" "pow-lambda" {
    filename = "../src/pow-lambda/archive.zip"
    function_name = "step-function-pow"
    role = aws_iam_role.iam_for_lambda.arn
    handler = "index.handler"
    runtime = "nodejs12.x"
}

resource "aws_lambda_function" "rand-lambda" {
    filename = "../src/rand-lambda/archive.zip"
    function_name = "step-function-rand"
    role = aws_iam_role.iam_for_lambda.arn
    handler = "index.handler"
    runtime = "nodejs12.x"    
}