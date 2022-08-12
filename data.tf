data "aws_sns_topic" "order" {
  name = "Orders"
}

data "aws_sfn_state_machine" "order_process" {
  name = "OrderProcessing"
}

data "aws_lambda_function" "inventory" {
  function_name = "InventoryFunction"
}

data "aws_cloudwatch_event_bus" "inventory" {
  name = "Inventory"
}

data "aws_sqs_queue" "inventory_dlq" {
  name = "InventoryFunctionDLQ"
}
