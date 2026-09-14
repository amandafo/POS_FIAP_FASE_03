import importlib
import json
import os
import sys
from pathlib import Path
from unittest.mock import MagicMock, patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
os.environ.setdefault("AWS_REGION", "us-east-1")
os.environ.setdefault("AWS_SQS_URL", "http://sqs.local/queue")
os.environ.setdefault("AWS_DYNAMODB_TABLE", "ToggleMasterAnalytics")

session = MagicMock()
with patch("boto3.Session", return_value=session), patch("threading.Thread.start"):
    service = importlib.import_module("app")


def test_health():
    response = service.app.test_client().get("/health")

    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_process_message_persists_and_deletes_valid_event():
    service.dynamodb_client = MagicMock()
    service.sqs_client = MagicMock()
    message = {
        "MessageId": "message-1",
        "ReceiptHandle": "receipt-1",
        "Body": json.dumps(
            {
                "user_id": "user-1",
                "flag_name": "checkout",
                "result": True,
                "timestamp": "2026-09-14T00:00:00Z",
            }
        ),
    }

    service.process_message(message)

    service.dynamodb_client.put_item.assert_called_once()
    service.sqs_client.delete_message.assert_called_once_with(
        QueueUrl="http://sqs.local/queue",
        ReceiptHandle="receipt-1",
    )


def test_process_message_keeps_invalid_json_in_queue():
    service.dynamodb_client = MagicMock()
    service.sqs_client = MagicMock()

    service.process_message(
        {"MessageId": "message-2", "ReceiptHandle": "receipt-2", "Body": "invalido"}
    )

    service.dynamodb_client.put_item.assert_not_called()
    service.sqs_client.delete_message.assert_not_called()
