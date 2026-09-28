import io
import os
import shutil
import time
import unittest
from fastapi.testclient import TestClient

from app.main import app
from app.api.deps import get_current_admin_user
from app.models.user import User
from app.services.ml_classifier import ml_classifier
from app.services.hybrid_recommender import hybrid_recommender


class TestAIModelsE2ELifecycle(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)
        self.admin_user = User(
            id=1,
            email="admin@freshflow.ai",
            hashed_password="hash",
            full_name="MLOps Administrator",
            role="Administrator",
            is_active=True,
            is_admin=True,
        )
        app.dependency_overrides[get_current_admin_user] = lambda: self.admin_user

    def tearDown(self):
        app.dependency_overrides.clear()

    def test_full_mlops_lifecycle(self):
        """
        Executes complete MLOps lifecycle:
        Upload -> Profile -> Train -> Evaluate -> Hot-Swap Deploy -> Verify Live Inference -> Rollback.
        """
        # 1. Prepare synthetic dataset CSV
        csv_header = (
            "food_name,category,moisture_pct,fat_pct,ph,water_activity,respiration_rate_5c,respiration_rate_20c,"
            "ethylene_sensitivity_score,chilling_injury_threshold_c,storage_temp_c,storage_duration_days,"
            "quantity_kg,is_fragile,eco_friendly_priority,is_frozen,is_high_lipid,is_high_resp,is_acidic,"
            "is_perishable_animal_protein,target_polymer_class\n"
        )
        # Create 70 samples (10 per each of the 7 classes)
        classes = [
            "BREATHABLE_BIO_EMAP",
            "METALLIZED_BARRIER",
            "HIGH_BARRIER_EVOH_VSP",
            "CELLULOSE_KRAFT_LINED",
            "RECYCLABLE_POLYOLEFIN",
            "CRYOGENIC_DEEP_FREEZE",
            "RETORT_ACID_BARRIER",
        ]
        csv_rows = []
        for i, cls in enumerate(classes):
            for rep in range(10):
                csv_rows.append(
                    f"Sample_{cls}_{rep},Berry,85.0,0.5,3.6,0.95,10.0,22.0,0.5,-1.0,4.0,14,2.5,1.0,1.0,0.0,0.0,1.0,0.0,0.0,{cls}\n"
                )
        csv_content = (csv_header + "".join(csv_rows)).encode("utf-8")

        # 2. Upload dataset via API
        upload_resp = self.client.post(
            "/api/v1/admin/models/datasets/upload",
            files={"file": ("e2e_dataset.csv", io.BytesIO(csv_content), "text/csv")},
            data={"description": "E2E Test Dataset"},
        )
        self.assertEqual(upload_resp.status_code, 201)
        upload_data = upload_resp.json()
        self.assertIn("dataset", upload_data)
        dataset_id = upload_data["dataset"]["dataset_id"]
        self.assertEqual(upload_data["dataset"]["total_samples"], 70)

        # 3. Profile dataset
        profile_resp = self.client.get(f"/api/v1/admin/models/datasets/{dataset_id}")
        self.assertEqual(profile_resp.status_code, 200)
        profile_data = profile_resp.json()
        self.assertEqual(len(profile_data["class_distribution"]), 7)
        self.assertIn("feature_summary", profile_data)

        # 4. Train a RandomForest model on this dataset
        train_resp = self.client.post(
            "/api/v1/admin/models/train",
            json={
                "algorithm": "RANDOM_FOREST",
                "dataset_id": dataset_id,
                "hyperparameters": {
                    "n_estimators": 20,
                    "max_depth": 5,
                    "scaling_method": "standard",
                },
            },
        )
        self.assertIn(train_resp.status_code, [200, 202])
        job_data = train_resp.json()
        job_id = job_data["job_id"]

        # 5. Poll / Resolve Job Status & Registration
        max_attempts = 40
        job_status_data = None
        for _ in range(max_attempts):
            job_status_resp = self.client.get(f"/api/v1/admin/models/jobs/{job_id}")
            self.assertEqual(job_status_resp.status_code, 200)
            job_status_data = job_status_resp.json()
            if job_status_data["status"] in ["completed", "failed"]:
                break
            time.sleep(0.1)

        self.assertIsNotNone(job_status_data)
        self.assertEqual(job_status_data["status"], "completed")
        self.assertIsNotNone(job_status_data["model_result"])
        trained_model_id = job_status_data["model_result"]["model_id"]
        self.assertEqual(job_status_data["model_result"]["algorithm"], "RANDOM_FOREST")

        # 6. Deep Evaluation Details & Confusion Matrix
        eval_resp = self.client.get(f"/api/v1/admin/models/{trained_model_id}/evaluation")
        self.assertEqual(eval_resp.status_code, 200)
        eval_data = eval_resp.json()
        self.assertIn("accuracy", eval_data)
        self.assertIn("f1_macro", eval_data)
        self.assertEqual(len(eval_data["per_class_metrics"]), 7)
        self.assertEqual(len(eval_data["confusion_matrix"]), 7)
        self.assertGreater(len(eval_data["feature_importances"]), 0)

        # 7. Hot-Swap Deploy to Live Inference
        deploy_resp = self.client.post(
            f"/api/v1/admin/models/{trained_model_id}/deploy",
            json={"model_id": trained_model_id, "deployment_notes": "E2E Deployment Verification"},
        )
        self.assertEqual(deploy_resp.status_code, 200)
        deploy_data = deploy_resp.json()
        self.assertEqual(deploy_data["deployed_model_id"], trained_model_id)

        # 8. Verify live classifier has hot-swapped model
        self.assertEqual(ml_classifier.active_model_id, trained_model_id)
        
        # Test live recommendation pipeline uses hot-swapped model cleanly
        recommendation_payload = {
            "food_name": "Strawberries",
            "category": "Fruits",
            "moisture": 85.0,
            "fat": 0.5,
            "ph": 3.6,
            "respiration_rate_20c": 22.0,
            "storage_temp_c": 4.0,
            "duration": 14,
            "weight": 2.5,
            "is_fragile": True,
            "eco_friendly": True,
        }
        rec_resp = self.client.post("/api/v1/packaging/recommend", json=recommendation_payload)
        self.assertEqual(rec_resp.status_code, 200)
        rec_data = rec_resp.json()
        self.assertIn("primary_recommendation", rec_data)
        self.assertIsNotNone(rec_data["primary_recommendation"])

        # 9. Test Rollback
        previous_model_id = deploy_data.get("previous_model_id")
        if previous_model_id and previous_model_id != trained_model_id:
            rollback_resp = self.client.post(
                f"/api/v1/admin/models/{previous_model_id}/rollback",
                json={"target_model_id": previous_model_id, "reason": "E2E Rollback Verification"},
            )
            self.assertEqual(rollback_resp.status_code, 200)
            rollback_data = rollback_resp.json()
            self.assertEqual(rollback_data["deployed_model_id"], previous_model_id)
            self.assertEqual(ml_classifier.active_model_id, previous_model_id)


if __name__ == "__main__":
    unittest.main()
