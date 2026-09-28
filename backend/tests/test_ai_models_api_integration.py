import unittest
from fastapi.testclient import TestClient
from app.main import app
from app.api.deps import get_current_admin_user, get_current_user
from app.models.user import User


class TestAIModelsAPIIntegration(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)
        self.admin_user = User(
            id=1,
            email="admin@freshflow.ai",
            hashed_password="hash",
            full_name="System Administrator",
            role="Administrator",
            is_active=True,
            is_admin=True,
        )
        self.regular_user = User(
            id=2,
            email="user@freshflow.ai",
            hashed_password="hash",
            full_name="Regular Operator",
            role="Packaging Engineer",
            is_active=True,
            is_admin=False,
        )

    def tearDown(self):
        app.dependency_overrides.clear()

    def test_openapi_schema_contains_ai_models_endpoints(self):
        response = self.client.get("/api/v1/openapi.json")
        self.assertEqual(response.status_code, 200)
        schema = response.json()
        
        paths = schema.get("paths", {})
        
        # Verify core endpoints exist under /api/v1/admin/models
        expected_endpoints = [
            "/api/v1/admin/models/datasets/upload",
            "/api/v1/admin/models/datasets",
            "/api/v1/admin/models/datasets/{dataset_id}",
            "/api/v1/admin/models/train",
            "/api/v1/admin/models/jobs/{job_id}",
            "/api/v1/admin/models/retrain",
            "/api/v1/admin/models/registry",
            "/api/v1/admin/models/{model_id}",
            "/api/v1/admin/models/{model_id}/evaluation",
            "/api/v1/admin/models/{model_id}/deploy",
            "/api/v1/admin/models/{model_id}/rollback",
        ]
        for ep in expected_endpoints:
            self.assertIn(ep, paths, f"Endpoint {ep} not found in OpenAPI paths")
            
        # Verify tag
        found_tags = set()
        for path, path_item in paths.items():
            if path.startswith("/api/v1/admin/models"):
                for method, op in path_item.items():
                    if isinstance(op, dict) and "tags" in op:
                        found_tags.update(op["tags"])
        self.assertIn("AI Model Management & MLOps", found_tags)

    def test_unauthenticated_request_rejected(self):
        response = self.client.get("/api/v1/admin/models/registry")
        self.assertEqual(response.status_code, 401)

    def test_non_admin_forbidden(self):
        def require_admin():
            from fastapi import HTTPException, status
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Admin privileges required.")
            
        app.dependency_overrides[get_current_admin_user] = require_admin
        response = self.client.get("/api/v1/admin/models/registry")
        self.assertEqual(response.status_code, 403)

    def test_admin_access_allowed(self):
        app.dependency_overrides[get_current_admin_user] = lambda: self.admin_user
        response = self.client.get("/api/v1/admin/models/registry")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("models", data)
        self.assertIn("total_models", data)
        self.assertIsInstance(data["models"], list)


if __name__ == "__main__":
    unittest.main()
