resource "aws_cloudwatch_event_bus" "order" {
  name = "Orders"
}

resource "aws_cloudwatch_event_rule" "order_dev_rule" {
  name           = "OrdersDevRule"
  description    = "Catchall rule for development purposes"
  event_bus_name = "Orders"

  event_pattern = <<EOF
{
   "account": ["${var.account_id}"],
   "source": ["com.aws.orders"]
}
EOF
}

resource "aws_cloudwatch_log_group" "orders" {
  name = "/aws/events/orders"
}

resource "aws_cloudwatch_event_target" "orders" {
  rule           = aws_cloudwatch_event_rule.order_dev_rule.name
  arn            = aws_cloudwatch_log_group.orders.arn
  event_bus_name = "Orders"
}

resource "aws_cloudwatch_event_connection" "api" {
  name               = "basic-auth-connection"
  authorization_type = "BASIC"

  auth_parameters {
    basic {
      username = "myUsername"
      password = "myPassword"
    }
  }
}

resource "aws_cloudwatch_event_api_destination" "order_events_rule" {
  name                             = "api-destination"
  invocation_endpoint              = "https://nbpb33p5z8.execute-api.us-east-1.amazonaws.com/Prod/"
  http_method                      = "POST"
  invocation_rate_limit_per_second = 20
  connection_arn                   = aws_cloudwatch_event_connection.api.arn
}

resource "aws_cloudwatch_event_rule" "events" {
  name           = "OrdersEventsRule"
  description    = "Send com.aws.orders source events to API Destination"
  event_bus_name = "Orders"

  event_pattern = <<EOF
{
  "source": [
    "com.aws.orders"
  ]
}
EOF
}

resource "aws_cloudwatch_event_target" "api" {
  rule           = aws_cloudwatch_event_rule.events.name
  arn            = aws_cloudwatch_event_api_destination.order_events_rule.arn
  event_bus_name = "Orders"
  role_arn       = aws_iam_role.invoke_api.arn

  http_target {
    header_parameters       = {}
    path_parameter_values   = []
    query_string_parameters = {}
  }
}

resource "aws_cloudwatch_event_rule" "eu_order" {
  name           = "EUOrdersRule"
  event_bus_name = "Orders"

  event_pattern = <<EOF
{
  "detail": {
    "location": [ { "prefix": "eu-" } ]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "eu_order_cwlog" {
  rule           = aws_cloudwatch_event_rule.eu_order.name
  arn            = aws_cloudwatch_log_group.orders.arn
  event_bus_name = "Orders"
}

resource "aws_cloudwatch_event_target" "eu_order_sfn" {
  rule           = aws_cloudwatch_event_rule.eu_order.name
  arn            = data.aws_sfn_state_machine.order_process.arn
  event_bus_name = "Orders"
  role_arn       = aws_iam_role.invoke_sfn.arn
}

resource "aws_cloudwatch_event_rule" "us_lab" {
  name           = "USLabSupplyRule"
  event_bus_name = "Orders"

  event_pattern = <<EOF
{
  "detail": {
    "category": [ "lab-supplies" ],
    "location": [ { "prefix": "us-" } ]
  }
}
EOF
}

resource "aws_cloudwatch_log_group" "us_lab" {
  name = "/aws/events/us-lab"
}

resource "aws_cloudwatch_event_target" "us_lab_cwlog" {
  rule           = aws_cloudwatch_event_rule.us_lab.name
  arn            = aws_cloudwatch_log_group.us_lab.arn
  event_bus_name = "Orders"
}

resource "aws_cloudwatch_event_target" "us_lab_sns" {
  rule           = aws_cloudwatch_event_rule.us_lab.name
  arn            = data.aws_sns_topic.order.arn
  event_bus_name = "Orders"
}

resource "aws_cloudwatch_event_rule" "order_process" {
  name           = "OrderProcessingRule"
  event_bus_name = "Orders"

  event_pattern = <<EOF
{
  "source": [
    "com.aws.orders"
  ],
  "detail-type": [
    "Order Processed"
  ]
}
EOF
}

resource "aws_cloudwatch_log_group" "order_process" {
  name = "/aws/events/order-process"
}

resource "aws_cloudwatch_event_target" "order_process_cwlog" {
  rule           = aws_cloudwatch_event_rule.order_process.name
  arn            = aws_cloudwatch_log_group.order_process.arn
  event_bus_name = "Orders"
}

resource "aws_cloudwatch_event_target" "order_process_lambda" {
  rule           = aws_cloudwatch_event_rule.order_process.name
  arn            = data.aws_lambda_function.inventory.arn
  event_bus_name = "Orders"
}
