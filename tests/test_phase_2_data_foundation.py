import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MIGRATION_PATH = ROOT / "supabase" / "migrations" / "202603220001_phase_2_minimal_data_foundation.sql"
MIGRATION_SQL = MIGRATION_PATH.read_text()

REQUIRED_TABLES = [
    "content_versions",
    "ingestion_runs",
    "profiles",
    "decks",
    "cards",
    "journeys",
    "assets",
    "saves",
    "entitlements",
    "analytics_events",
]

REQUIRED_INDEXES = [
    "idx_content_versions_type_status",
    "idx_ingestion_runs_source_status",
    "idx_decks_status_slug",
    "idx_cards_deck_status",
    "idx_journeys_status_slug",
    "idx_assets_owner_status",
    "idx_saves_user_updated",
    "idx_entitlements_lookup",
    "idx_analytics_events_name_created",
]

EXPECTED_POLICIES = {
    "profiles": ["profiles_select_own", "profiles_update_own", "profiles_insert_own"],
    "decks": ["decks_select_published"],
    "cards": ["cards_select_published"],
    "journeys": ["journeys_select_published"],
    "assets": ["assets_select_published_nonpremium"],
    "saves": ["saves_select_own", "saves_insert_own", "saves_update_own", "saves_delete_own"],
    "entitlements": ["entitlements_select_own", "entitlements_service_write"],
    "analytics_events": ["analytics_insert_authenticated", "analytics_select_service_role"],
    "content_versions": ["content_versions_select_published", "content_versions_service_write"],
    "ingestion_runs": ["ingestion_runs_service_role"],
}


class Phase2MigrationTests(unittest.TestCase):
    def test_migration_file_exists(self):
        self.assertTrue(MIGRATION_PATH.exists())

    def test_required_tables_exist(self):
        for table in REQUIRED_TABLES:
            with self.subTest(table=table):
                self.assertRegex(
                    MIGRATION_SQL,
                    rf"create table if not exists public\.{table}\b",
                )

    def test_required_indexes_exist(self):
        for index_name in REQUIRED_INDEXES:
            with self.subTest(index=index_name):
                self.assertIn(f"create index if not exists {index_name}", MIGRATION_SQL)

    def test_rls_enabled_and_forced(self):
        for table in REQUIRED_TABLES:
            with self.subTest(table=table):
                self.assertIn(f"alter table public.{table} enable row level security;", MIGRATION_SQL)
                self.assertIn(f"alter table public.{table} force row level security;", MIGRATION_SQL)

    def test_expected_policies_exist(self):
        for table, policies in EXPECTED_POLICIES.items():
            for policy in policies:
                with self.subTest(table=table, policy=policy):
                    pattern = rf'create policy "{re.escape(policy)}"\s+on public\.{table}'
                    self.assertRegex(MIGRATION_SQL, pattern)

    def test_deny_by_default_sensitive_tables_only_grant_expected_access(self):
        self.assertNotIn("create policy \"entitlements_select_published\"", MIGRATION_SQL)
        self.assertNotIn("create policy \"saves_select_all\"", MIGRATION_SQL)
        self.assertNotIn("create policy \"profiles_select_all\"", MIGRATION_SQL)
        self.assertIn("using (auth.uid() = user_id);", MIGRATION_SQL)
        self.assertIn("using ((auth.jwt() ->> 'role') = 'service_role')", MIGRATION_SQL)


if __name__ == "__main__":
    unittest.main()
