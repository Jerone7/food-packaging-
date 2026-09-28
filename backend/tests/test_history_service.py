"""
Unit Tests for Packaging History Domain Service (Module 13 - Task 1.2).
Tests history retrieval, user-scoped association, deletion, and empirical offline samples.
"""

import unittest
from datetime import datetime, timezone
from app.services.packaging_service import PackagingHistoryService


class TestHistoryService(unittest.TestCase):
    def setUp(self):
        PackagingHistoryService.reset_memory_store(with_samples=True)

    def test_default_sample_history_stream(self):
        """Verify empirical history samples load correctly with expected order and dates."""
        import asyncio

        records = asyncio.run(PackagingHistoryService.get_user_history(db=None, user_id=1))
        self.assertGreaterEqual(len(records), 3)

        item_names = [r.item_name for r in records[:3]]
        self.assertEqual(item_names, ["Tomato", "Apple", "Potato"])

        # Check schema transformation
        schemas = [PackagingHistoryService.to_history_item_schema(r) for r in records[:3]]
        self.assertEqual(schemas[0].formatted_date, "26 Sep 2026")
        self.assertEqual(schemas[1].formatted_date, "25 Sep 2026")
        self.assertEqual(schemas[2].formatted_date, "23 Sep 2026")

    def test_save_new_history_record_with_user(self):
        """Verify saving a new recommendation associates user_id and updates chronological stream."""
        import asyncio

        new_record = asyncio.run(
            PackagingHistoryService.save_history(
                db=None,
                user_id=1,
                item_name="Fresh Strawberries",
                length=18.0,
                width=12.0,
                height=6.0,
                weight=0.5,
                is_fragile=True,
                eco_friendly=True,
                recommended_box_type="Bio-based PLA Ventilated Pouch",
                recommended_dimensions="18.0 x 12.0 x 6.0 cm",
                cushioning_material="Recycled Fiber Liner",
                estimated_cost=4.25,
                sustainability_score=94.0,
                notes="Cold chain export clamshell.",
            )
        )

        self.assertIsNotNone(new_record.id)
        self.assertEqual(new_record.user_id, 1)
        self.assertEqual(new_record.item_name, "Fresh Strawberries")

        # Verify it is returned at the top of user history
        user_history = asyncio.run(PackagingHistoryService.get_user_history(db=None, user_id=1))
        self.assertEqual(user_history[0].item_name, "Fresh Strawberries")

    def test_get_history_by_id(self):
        """Verify retrieving an individual historical analysis run by ID."""
        import asyncio

        record = asyncio.run(PackagingHistoryService.get_history_by_id(db=None, history_id=201, user_id=1))
        self.assertIsNotNone(record)
        self.assertEqual(record.item_name, "Tomato")
        self.assertEqual(record.recommended_box_type, "Corrugated Kraft Box (5-Ply)")

        # Verify not found for nonexistent ID
        none_record = asyncio.run(PackagingHistoryService.get_history_by_id(db=None, history_id=9999))
        self.assertIsNone(none_record)

    def test_delete_history_item(self):
        """Verify deleting an entry removes it from the user's history."""
        import asyncio

        deleted = asyncio.run(PackagingHistoryService.delete_history_item(db=None, history_id=203, user_id=1))
        self.assertTrue(deleted)

        remaining = asyncio.run(PackagingHistoryService.get_user_history(db=None, user_id=1))
        remaining_names = [r.item_name for r in remaining]
        self.assertNotIn("Potato", remaining_names)

    def test_clear_user_history(self):
        """Verify clearing user history removes all items for that user."""
        import asyncio

        cleared_count = asyncio.run(PackagingHistoryService.clear_user_history(db=None, user_id=1))
        self.assertGreaterEqual(cleared_count, 3)

        empty_history = asyncio.run(PackagingHistoryService.get_user_history(db=None, user_id=1))
        self.assertEqual(len(empty_history), 0)


if __name__ == "__main__":
    unittest.main()
