# IAM Role for step function
resource "aws_iam_role" "iam_for_sfn" {
    name = "stepFunctionSampleStepFunctionIAM"
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Effect": "Allow",
        "Principal": {
        "Service": "states.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
    }
    ]
}
EOF
}

# IAM Policy for SNS Publishing
resource "aws_iam_policy" "policy_publish_sns" {
    name = "stepFunctionSampleSNSInvocationPolicy"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
              "sns:Publish",
              "sns:SetSMSAttributes",
              "sns:GetSMSAttributes"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "policy_invoke_lambda" {
    name = "stepFunctionSampleLambdaFunctionInvocationPolicy"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction",
                "lambda:InvokeAsync"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

// Attach policy to IAM Role for Step Function
resource "aws_iam_role_policy_attachment" "iam_for_sfn_attach_policy_invoke_lambda" {
    role = "${aws_iam_role.iam_for_sfn.name}"
    policy_arn = "${aws_iam_policy.policy_invoke_lambda.arn}"
}

resource "aws_iam_role_policy_attachment" "iam_for_sfn_attach_policy_publish_sns" {
    role = "${aws_iam_role.iam_for_sfn.name}"
    policy_arn = "${aws_iam_policy.policy_publish_sns.arn}"
}

// Create state machine for step function
resource "aws_sfn_state_machine" "sfn_state_machine" {
    name     = "sample-state-machine"
    role_arn = "${aws_iam_role.iam_for_sfn.arn}"
    definition = <<EOF
{
    "StartAt": "rand-lambda-config",
    "States": {
        "rand-lambda-config": {
            "Comment": "To configure the random-number-generator lambda.",
            "Type": "Pass",
            "Result": {
                "min": 1,
                "max": 10
            },
            "ResultPath": "$",
            "Next": "rand-lambda-generator"
        },
        "rand-lambda-generator": {
            "Comment": "Random number generation lambda based on input.",
            "Type": "Task",
            "Resource": "${ aws_lambda_function.rand-lambda.arn }",
            "Next": "send-notification-if-less-than-5"
        },
        "send-notification-if-less-than-5": {
            "Comment": "A choice state to decide to send out notification for <5 or trigger POW(3) lambda >5.",
            "Type": "Choice",
            "Choices": [
                {
                    "Variable": "$",
                    "NumericGreaterThanEquals": 5,
                    "Next": "pow-3-lambda"
                },
                {
                    "Variable": "$",
                    "NumericLessThan": 5,
                    "Next": "send-multiple-notification"
                }
            ]
        },
        "pow-3-lambda": {
            "Comment": "Increase the input to power of 3 with customized input.",
            "Type": "Task",
            "Parameters": {
                "base.$": "$",
                "exponent": 3
            },
            "Resource": "${ aws_lambda_function.pow-lambda.arn }",
            "End": true
        },
        "send-multiple-notification": {
            "Comment": "Trigger multiple notification using AWS SNS",
            "Type": "Parallel",
            "End": true,
            "Branches": [
                {
                    "StartAt": "send-sms-notification",
                    "States": {
                        "send-sms-notification": {
                            "Type": "Task",
                            "Resource": "arn:aws:states:::sns:publish",
                            "Parameters": {
                                "Message": "SMS: Random number is less than 5 ($)",
                                "PhoneNumber": "${ var.aws_sns_phone_number }"
                            },
                            "End": true
                        }
                    }
                }
            ]
        }
    }
}
EOF

    depends_on = [
        aws_lambda_function.pow-lambda,
        aws_lambda_function.rand-lambda
    ]
}