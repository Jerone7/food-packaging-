"""
Unit Tests for Packaging History & 'My Analyses' Schemas (Module 13 - Task 1.1).
Validates schema validation, formatted date generation, and response envelope contracts.
"""

import unittest
from datetime import datetime
from app.schemas.packaging import (
    PackagingHistoryItem,
    UserHistoryResponse,
    PackagingRecordResponse,
    format_history_date,
)


class TestHistorySchemas(unittest.TestCase):
    def test_format_history_date_helper(self):
        """Verify format_history_date correctly formats dates to 'dd MMM yyyy'."""
        dt1 = datetime(2026, 9, 26, 14, 30, 0)
        self.assertEqual(format_history_date(dt1), "26 Sep 2026")

        dt2 = datetime(2026, 9, 25, 9, 15, 0)
        self.assertEqual(format_history_date(dt2), "25 Sep 2026")

        dt3 = datetime(2026, 9, 23, 18, 45, 0)
        self.assertEqual(format_history_date(dt3), "23 Sep 2026")

        dt_none = None
        self.assertEqual(format_history_date(dt_none), "")

    def test_packaging_history_item_auto_formats_date(self):
        """Verify PackagingHistoryItem automatically computes formatted_date on init."""
        item = PackagingHistoryItem(
            id=101,
            user_id=1,
            item_name="Tomato",
            length=30.0,
            width=20.0,
            height=15.0,
            weight=5.0,
            is_fragile=True,
            eco_friendly=True,
            recommended_box_type="Corrugated Kraft Box (5-Ply)",
            recommended_dimensions="30x20x15 cm",
            estimated_cost=3.10,
            sustainability_score=96.5,
            created_at=datetime(2026, 9, 26, 10, 0, 0),
        )

        self.assertEqual(item.item_name, "Tomato")
        self.assertEqual(item.formatted_date, "26 Sep 2026")
        self.assertEqual(item.user_id, 1)
        self.assertTrue(item.is_fragile)
        self.assertTrue(item.eco_friendly)
        self.assertEqual(item.estimated_cost, 3.10)
        self.assertEqual(item.sustainability_score, 96.5)

    def test_user_history_response_serialization(self):
        """Verify UserHistoryResponse serializes multiple records correctly."""
        records = [
            PackagingHistoryItem(
                id=1,
                user_id=1,
                item_name="Tomato",
                length=30.0,
                width=20.0,
                height=15.0,
                weight=5.0,
                recommended_box_type="Corrugated Kraft Box",
                recommended_dimensions="30x20x15 cm",
                estimated_cost=3.10,
                sustainability_score=96.5,
                created_at=datetime(2026, 9, 26, 10, 0, 0),
            ),
            PackagingHistoryItem(
                id=2,
                user_id=1,
                item_name="Apple",
                length=25.0,
                width=18.0,
                height=12.0,
                weight=3.0,
                recommended_box_type="Molded Pulp Tray with Bio-Film",
                recommended_dimensions="25x18x12 cm",
                estimated_cost=2.85,
                sustainability_score=94.0,
                created_at=datetime(2026, 9, 25, 11, 30, 0),
            ),
            PackagingHistoryItem(
                id=3,
                user_id=1,
                item_name="Potato",
                length=35.0,
                width=25.0,
                height=20.0,
                weight=10.0,
                recommended_box_type="Jute-Lined Ventilated Paper Sack",
                recommended_dimensions="35x25x20 cm",
                estimated_cost=1.75,
                sustainability_score=98.0,
                created_at=datetime(2026, 9, 23, 16, 0, 0),
            ),
        ]

        response = UserHistoryResponse(
            total_count=3,
            records=records,
        )

        data = response.model_dump()
        self.assertEqual(data["total_count"], 3)
        self.assertEqual(len(data["records"]), 3)
        self.assertEqual(data["records"][0]["item_name"], "Tomato")
        self.assertEqual(data["records"][0]["formatted_date"], "26 Sep 2026")
        self.assertEqual(data["records"][1]["item_name"], "Apple")
        self.assertEqual(data["records"][1]["formatted_date"], "25 Sep 2026")
        self.assertEqual(data["records"][2]["item_name"], "Potato")
        self.assertEqual(data["records"][2]["formatted_date"], "23 Sep 2026")

    def test_packaging_record_response_backward_compatibility(self):
        """Verify PackagingRecordResponse alias maintains complete backward compatibility."""
        record = PackagingRecordResponse(
            id=55,
            item_name="Fresh Strawberries",
            length=18.0,
            width=12.0,
            height=6.0,
            weight=0.5,
            recommended_box_type="Bio-PLA Ventilated Clamshell",
            recommended_dimensions="18x12x6 cm",
            estimated_cost=4.25,
            sustainability_score=94.0,
            created_at=datetime(2026, 9, 26, 8, 0, 0),
        )

        self.assertEqual(record.id, 55)
        self.assertEqual(record.formatted_date, "26 Sep 2026")
        self.assertIsInstance(record, PackagingHistoryItem)


if __name__ == "__main__":
    unittest.main()
