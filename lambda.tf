resource "aws_lambda_function_event_invoke_config" "inventory" {
  function_name = data.aws_lambda_function.inventory.function_name

  destination_config {
    on_success {
      destination = data.aws_cloudwatch_event_bus.inventory.arn
    }

    on_failure {
      destination = data.aws_sqs_queue.inventory_dlq.arn
    }
  }
}
