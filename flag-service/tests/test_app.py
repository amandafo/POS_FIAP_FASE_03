import importlib
import os
import sys
from pathlib import Path
from unittest.mock import MagicMock, patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
os.environ.setdefault("DATABASE_URL", "postgres://local/test")
os.environ.setdefault("AUTH_SERVICE_URL", "http://auth-service:8001")

with patch("psycopg2.pool.SimpleConnectionPool", return_value=MagicMock()):
    service = importlib.import_module("app")


def test_health():
    response = service.app.test_client().get("/health")

    assert response.status_code == 200
    assert response.get_json() == {"status": "ok"}


def test_create_flag_requires_authorization():
    response = service.app.test_client().post("/flags", json={"name": "checkout"})

    assert response.status_code == 401


def test_create_flag_rejects_missing_name():
    auth_response = MagicMock(status_code=200)
    with patch.object(service.requests, "get", return_value=auth_response):
        response = service.app.test_client().post(
            "/flags",
            headers={"Authorization": "Bearer teste"},
            json={},
        )

    assert response.status_code == 400
    assert "name" in response.get_json()["error"]
