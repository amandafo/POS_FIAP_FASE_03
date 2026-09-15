output "queue_url" { value = aws_sqs_queue.events.url }
output "queue_arn" { value = aws_sqs_queue.events.arn }
output "dead_letter_queue_url" { value = aws_sqs_queue.dead_letter.url }
output "dynamodb_table_name" { value = aws_dynamodb_table.analytics.name }
output "dynamodb_table_arn" { value = aws_dynamodb_table.analytics.arn }
