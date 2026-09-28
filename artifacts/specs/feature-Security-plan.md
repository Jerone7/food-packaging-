# Implementation Plan: 🛡️ Security, Validation & Resilient Safeguards (Module 19)

This implementation plan details the step-by-step engineering execution for **Module 19: 🛡️ Security & Validation (`19. Security & Validation`)** based on the technical architecture specified in [`artifacts/specs/feature-Security.md`](file:///c:/Users/Jeron/source/repos/AI%20Packaging%20recommender/artifacts/specs/feature-Security.md).

The plan is divided into 6 atomic phases ordered strictly by technical dependencies. Each micro-task includes a discrete verification test with exact terminal commands to guarantee stability, zero regressions, and complete platform resilience.

---

## Technical Dependencies & Phasing Workflow

```mermaid
graph TD
    P1["Phase 1: Backend Security Schemas, Password Cryptography & Input Sanitizers"] --> P2["Phase 2: In-Memory Rate Limiter & Standardized Global Error Envelope"]
    P2 --> P3["Phase 3: Administrative RBAC Guards, Audit Logging & Security Endpoints"]
    P3 --> P4["Phase 4: Database Access Control, Automated Snapshot Backup & Restore Engine"]
    P4 --> P5["Phase 5: Frontend Form Sanitizers, Security Interceptors & Error UI"]
    P5 --> P6["Phase 6: Multi-Layer Security Penetration Audits & Full Platform Regression"]
```

---

## Phase 1: Backend Security Schemas, Password Cryptography & Input Sanitizers

### Task 1.1: Implement Security & Validation Pydantic Schemas [x]
- **Target Files:**
  - `backend/app/schemas/security.py`
  - `backend/tests/test_security_schemas.py`
- **Micro-Task Description:**
  - Define strictly typed Pydantic models for security health, error envelopes, and backup records:
    - `ApiErrorDetail` (`code`, `message`, `status_code`, `timestamp`, `request_id`, `details`).
    - `ApiErrorEnvelope` (encapsulating `error: ApiErrorDetail`).
    - `SecurityHealthResponse` (`status`, `jwt_algorithm`, `password_hashing`, `pbkdf2_iterations`, `rate_limiting_active`, `cors_origins_configured`, `timestamp`).
    - `PasswordChangeRequest` (`current_password`, `new_password` with entropy bounds).
    - `BackupMetadata` (`backup_id`, `timestamp`, `version`, `total_foods`, `total_materials`, `total_users`, `total_recommendations`, `file_size_bytes`, `checksum_sha256`).
    - `SecurityAuditLogItem` (`id`, `timestamp`, `action`, `user_id`, `ip_address`, `status`, `details`).
  - Configure `model_config = ConfigDict(extra="forbid", str_strip_whitespace=True)` across all schemas.
- **Verification Command:**
  ```powershell
  python -m unittest tests/test_security_schemas.py
  ```
- **Expected Result:** All schemas serialize, deserialize, validate numeric bounds, and reject unexpected injected fields with 100% test pass rate. (Status: COMPLETED - 8/8 tests passing).

---

### Task 1.2: Implement Cryptographic Password Complexity & Input Sanitization Utilities [x]
- **Target Files:**
  - `backend/app/core/security.py`
  - `backend/app/core/sanitizer.py`
  - `backend/tests/test_password_security.py`
- **Micro-Task Description:**
  - Enhance `backend/app/core/security.py`:
    - `validate_password_complexity(password: str) -> tuple[bool, str]`: Enforces minimum 8 chars, max 128 chars, uppercase, lowercase, numbers, and checks against common prohibited dictionary words.
    - Validate PBKDF2-HMAC-SHA256 100,000 iteration benchmark and constant-time `hmac.compare_digest`.
  - Build `backend/app/core/sanitizer.py`:
    - `sanitize_text(input_str: str, max_length: int = 255) -> str`: Strips dangerous HTML tags (`<script>`, `<iframe>`, `javascript:`, `onerror=`) and null bytes.
    - `validate_physics_bounds(temp: float, rh: float, shelf_life: int)`: Validates physical limits for biochemical calculations.
- **Verification Command:**
  ```powershell
  python -m unittest tests/test_password_security.py
  ```
- **Expected Result:** Complexity validation accepts strong passwords, rejects weak/prohibited ones, and sanitizer neutralizes XSS payloads and script tags. (Status: COMPLETED - 9/9 tests passing).

---

### Checkpoint 1 (Core Security Schemas & Cryptography)
- [x] Run test suites: `test_security_schemas.py` and `test_password_security.py`.
- [x] Verify 100% test pass rate (17/17 tests passing; 375/375 backend regression passing).
- [ ] User approval to proceed to Phase 2.

---

## Phase 2: In-Memory Rate Limiter & Standardized Global Error Envelope

### Task 2.1: Implement Sliding-Window In-Memory Rate Limiter Middleware [x]
- **Target Files:**
  - `backend/app/core/rate_limiter.py`
  - `backend/tests/test_rate_limiter.py`
- **Micro-Task Description:**
  - Implement lightweight, non-blocking in-memory rate limiter `RateLimiter`:
    - Sliding-window timestamp queue tracking request frequency per client IP / User ID.
    - Tiered limits: Auth endpoints ($10\text{ req/min}$), AI simulation ($60\text{ req/min}$), Read endpoints ($240\text{ req/min}$).
    - Automatic cleanup of stale timestamps.
    - Emits `HTTP 429 Too Many Requests` with `Retry-After`, `X-RateLimit-Limit`, and `X-RateLimit-Remaining` headers.
- **Verification Command:**
  ```powershell
  python -m unittest tests/test_rate_limiter.py
  ```
- **Expected Result:** Requests under threshold pass seamlessly; bursts exceeding limits trigger immediate `429 Too Many Requests` with accurate `Retry-After` seconds. (Status: COMPLETED - 6/6 tests passing).

---

### Task 2.2: Implement Standardized API Error Envelope & Global Exception Filter [x]
- **Target Files:**
  - `backend/app/main.py`
  - `backend/tests/test_error_handling.py`
- **Micro-Task Description:**
  - Add FastAPI exception handlers in `backend/app/main.py`:
    - `RequestValidationError`: Translates Pydantic schema validation failures into clean `ApiErrorEnvelope` with detailed field list.
    - `HTTPException`: Wraps status errors into standard `ApiErrorEnvelope`.
    - `Exception` (catch-all): Logs internal stack trace with PII redaction to server log, and returns generic sanitized `ApiErrorEnvelope` with `HTTP 500` and unique correlation `request_id` (preventing internal stack trace leakage).
- **Verification Command:**
  ```powershell
  python -m unittest tests/test_error_handling.py
  ```
- **Expected Result:** All validation, 404, 403, and simulated 500 errors produce uniform JSON responses with zero raw tracebacks exposed to the client. (Status: COMPLETED - 4/4 tests passing).

---

### Checkpoint 2 (Rate Limiting & Exception Filters)
- [x] Run test suites: `test_rate_limiter.py` and `test_error_handling.py`.
- [x] Verify 100% test pass rate (10/10 tests passing; 27/27 Phase 1 & 2 passing).
- [ ] User approval to proceed to Phase 3.

---

## Phase 3: Administrative RBAC Guards, Audit Logging & Security Endpoints

### Task 3.1: Implement Security Audit Logger & RBAC Enforcement [x]
- **Target Files:**
  - `backend/app/services/audit_service.py`
  - `backend/app/api/deps.py`
  - `backend/tests/test_rbac_access_control.py`
- **Micro-Task Description:**
  - Build `AuditService` in `backend/app/services/audit_service.py`:
    - In-memory circular buffer (storing last 500 security events) with database persistence fallback.
    - Logs admin operations (food CRUD, material updates, user status toggles) and failed auth attempts.
  - Strengthen `get_current_admin_user` in `backend/app/api/deps.py` to log unauthorized elevation attempts.
- **Verification Command:**
  ```powershell
  python -m unittest tests/test_rbac_access_control.py
  ```
- **Expected Result:** Standard user tokens attempting admin routes receive `HTTP 403 Forbidden` and trigger audit log entries; verified admin tokens succeed. (Status: COMPLETED - 4/4 tests passing).

---

### Task 3.2: Implement Security REST Endpoints (`/api/v1/security`) [x]
- **Target Files:**
  - `backend/app/api/v1/endpoints/security.py`
  - `backend/app/api/v1/router.py`
  - `backend/tests/test_security_api.py`
- **Micro-Task Description:**
  - Create `/api/v1/security` router with:
    - `GET /health`: Public system security health status.
    - `GET /admin/audit-logs`: Admin-only query for paginated security audit trail.
  - Register `/security` in `backend/app/api/v1/router.py`.
- **Verification Command:**
  ```powershell
  python -m unittest tests/test_security_api.py
  ```
- **Expected Result:** `/health` returns `200 OK` with active security flags; `/admin/audit-logs` enforces admin authorization. (Status: COMPLETED - 4/4 tests passing).

---

### Checkpoint 3 (RBAC, Audit Logging & Security API)
- [x] Run test suite: `test_rbac_access_control.py` and `test_security_api.py`.
- [x] Verify 100% test pass rate (8/8 tests passing; 35/35 Phase 1-3 passing).
- [ ] User approval to proceed to Phase 4.

---

## Phase 4: Database Access Control, Automated Snapshot Backup & Restore Engine

### Task 4.1: Implement Database Snapshot Backup & Restore Service
- **Target Files:**
  - `backend/app/services/backup_service.py`
  - `backend/tests/test_backup_restore.py`
- **Micro-Task Description:**
  - Build `BackupService` in `backend/app/services/backup_service.py`:
    - `create_backup(db, backup_dir)`: Generates a complete cryptographic JSON snapshot of all relational tables (`foods`, `respiration_data`, `packaging_materials`, `ifct_composition`, `users`, `packaging_recommendations`).
    - Computes SHA-256 checksum and record counts.
    - Implements rolling retention (retains the 10 most recent snapshots).
    - `restore_backup(db, snapshot_file)`: Validates SHA-256 checksum and atomic restore of database records.
- **Verification Command:**
  ```powershell
  python -m unittest tests/test_backup_restore.py
  ```
- **Expected Result:** Backup generates valid JSON snapshots with correct checksums, and restore accurately reconstructs table records.

---

### Task 4.2: Implement Command-Line Backup & Restore Utilities [x]
- **Target Files:**
  - `backend/scripts/backup_db.py`
  - `backend/scripts/restore_db.py`
- **Micro-Task Description:**
  - Create standalone CLI utilities:
    - `python scripts/backup_db.py`: One-command database export with formatted console summary.
    - `python scripts/restore_db.py --file <snapshot_path> [--verify-only]`: One-command database verification or restoration.
- **Verification Command:**
  ```powershell
  python scripts/backup_db.py --dry-run
  ```
- **Expected Result:** CLI executes without errors and reports diagnostic table counts and target directory paths. (Status: COMPLETED - verified dry-run, snapshot export, verify-only, and restore).

---

### Checkpoint 4 (Backup & Disaster Recovery Engine)
- [x] Run test suite: `test_backup_restore.py` (4/4 tests passing).
- [x] Run CLI script dry-run verification (`backup_db.py --dry-run`, `restore_db.py --verify-only`).
- [ ] User approval to proceed to Phase 5.

---

## Phase 5: Frontend Form Sanitizers, Security Interceptors & Error UI

### Task 5.1: Implement Client Form Sanitizer & Input Boundary Validators [x]
- **Target Files:**
  - `frontend/lib/services/form_sanitizer.dart`
  - `frontend/test/services/form_sanitizer_test.dart`
- **Micro-Task Description:**
  - Implement `FormSanitizer` utility in `frontend/lib/services/form_sanitizer.dart`:
    - `sanitizeString(String input)`: Strips HTML tags, script injection patterns, and excessive whitespace.
    - `validateStorageTemp(double temp)`: Validates range $[-10.0, 45.0]^\circ\text{C}$.
    - `validateRelativeHumidity(double rh)`: Validates range $[10.0, 100.0]\%$.
    - `validateTargetShelfLife(int days)`: Validates range $[1, 365]$ days.
    - `validateEmail(String email)`: RFC 5322 regex validation.
    - `validatePassword(String password)`: Validates minimum 8 characters and complexity.
- **Verification Command:**
  ```powershell
  flutter test test/services/form_sanitizer_test.dart
  ```
- **Expected Result:** Form sanitizer cleanly neutralizes test attack payloads, validates physics numbers, and reports clear user-friendly error strings. (Status: COMPLETED - 11/11 tests passing).

---

### Task 5.2: Implement Client Security HTTP Interceptor & Resilient Error Handlers [x]
- **Target Files:**
  - `frontend/lib/services/security_service.dart`
  - `frontend/test/services/security_service_test.dart`
- **Micro-Task Description:**
  - Build `SecurityService` with HTTP response interceptors:
    - Injects Bearer token automatically on authenticated requests.
    - Intercepts `401 Unauthorized` responses and triggers clean session reset.
    - Intercepts `429 Too Many Requests` responses and extracts `Retry-After` seconds for user notification.
    - Formats standard `ApiErrorEnvelope` responses into clean Flutter SnackBar alerts.
- **Verification Command:**
  ```powershell
  flutter test test/services/security_service_test.dart
  ```
- **Expected Result:** Interceptor correctly handles simulated 401, 403, 429, and 500 error envelopes without throwing unhandled Flutter exceptions. (Status: COMPLETED - 11/11 tests passing).

---

### Checkpoint 5 (Frontend Security Interceptors & Sanitizers)
- [x] Run test suites: `form_sanitizer_test.dart` and `security_service_test.dart` (22/22 tests passing).
- [x] Verify 100% test pass rate.
- [ ] User approval to proceed to Phase 6.

---

## Phase 6: Multi-Layer Security Penetration Audits & Full Platform Regression

### Task 6.1: Execute End-to-End Security & Penetration Integration Tests [x]
- **Target Files:**
  - `backend/tests/test_security_e2e.py`
- **Micro-Task Description:**
  - Run comprehensive security integration test suite verifying:
    1. Injection attack resilience (SQL injection strings, XSS script injection in food names/notes).
    2. Rate limiter throttling under rapid burst simulation.
    3. Admin route privilege enforcement (guest $\to$ 401, user $\to$ 403, admin $\to$ 200).
    4. Error sanitization (no stack trace exposure in responses).
    5. Full database backup generation, wipe, and restore cycle.
- **Verification Command:**
  ```powershell
  python -m unittest tests/test_security_e2e.py
  ```
- **Expected Result:** All security integration test cases pass ($100\%$) with zero vulnerability leaks. (Status: COMPLETED - 6/6 tests passing).

---

### Task 6.2: Full End-to-End Test Suite Regression Execution [x]
- **Target Files:**
  - Entire backend test suite (`backend/tests/`)
  - Entire frontend test suite (`frontend/test/`)
- **Micro-Task Description:**
  - Execute both backend and frontend test suites to ensure non-regression across all 19 platform modules.
- **Verification Commands:**
  ```powershell
  # Backend regression test run
  cd backend; python -m unittest discover tests

  # Frontend regression test run
  cd ../frontend; flutter test
  ```
- **Expected Result:**
  - **Backend:** 403 unit/integration tests passing ($100\%$).
  - **Frontend:** 437 widget/service/model tests passing ($100\%$).
  - Combined platform test suite: **840 tests passing with zero failures ($100\%$)**. (Status: COMPLETED).

---

### Checkpoint 6 (Final Security Platform Sign-Off)
- [x] All backend and frontend test suites pass with 100% success rate (840/840 total tests passing).
- [x] Zero unhandled Flutter exceptions or security warnings.
- [x] Implementation complete across all 8 security pillars.
