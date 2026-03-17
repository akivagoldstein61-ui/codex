import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCHEMAS_DIR = ROOT / "contracts" / "schemas"

SCHEMA_FILES = {
    "event-envelope.schema.json": ["version", "request_id", "idempotency_key", "created_at"],
    "deck-spec.schema.json": ["deck_id", "content_hash", "content_version_id", "request_id", "idempotency_key"],
    "card-spec.schema.json": ["card_id", "deck_id", "content_hash", "content_version_id", "request_id", "idempotency_key"],
    "journey-spec.schema.json": ["journey_id", "content_hash", "content_version_id", "request_id", "idempotency_key"],
    "content-validation-report.schema.json": ["valid", "errors", "warnings", "request_id", "idempotency_key"],
    "asset-manifest.schema.json": ["manifest_id", "content_hash", "content_version_id", "request_id", "idempotency_key"],
    "entitlement-check-result.schema.json": ["subject_user_id", "resource_id", "allowed", "request_id", "idempotency_key"],
}


class ContractSchemaTests(unittest.TestCase):
    def test_all_expected_schemas_exist(self):
        for schema_name in SCHEMA_FILES:
            with self.subTest(schema_name=schema_name):
                self.assertTrue((SCHEMAS_DIR / schema_name).exists())

    def test_required_fields_present(self):
        for schema_name, fields in SCHEMA_FILES.items():
            with self.subTest(schema_name=schema_name):
                schema = json.loads((SCHEMAS_DIR / schema_name).read_text())
                required = set(schema.get("required", []))
                for field in fields:
                    self.assertIn(field, required)


if __name__ == "__main__":
    unittest.main()
