"""
Security Audit Logging Service (Module 19: Security & Validation).
Records administrative actions, privilege elevation attempts, authentication events, and security anomalies.
"""

import logging
import secrets
from collections import deque
from datetime import datetime, timezone
from typing import Any, Deque, Dict, List, Optional, Tuple

from app.schemas.security import SecurityAuditLogItem

logger = logging.getLogger("smartpack.audit")


class AuditService:
    """
    In-memory circular buffer audit log service maintaining the last 500 security events.
    """
    _events: Deque[SecurityAuditLogItem] = deque(maxlen=500)

    @classmethod
    def clear(cls) -> None:
        """Clears all audit events (for test isolation)."""
        cls._events.clear()

    @classmethod
    def log_event(
        cls,
        action: str,
        status: str = "SUCCESS",
        user_id: Optional[int] = None,
        ip_address: Optional[str] = None,
        details: Optional[Dict[str, Any]] = None,
    ) -> SecurityAuditLogItem:
        """
        Creates and stores a security audit log entry.
        """
        event_id = f"evt_{secrets.token_hex(6)}"
        event = SecurityAuditLogItem(
            id=event_id,
            timestamp=datetime.now(timezone.utc),
            action=action.upper(),
            user_id=user_id,
            ip_address=ip_address,
            status=status.upper(),
            details=details or {},
        )

        cls._events.appendleft(event)
        log_level = logging.WARNING if status.upper() in {"FAILURE", "WARNING"} else logging.INFO
        logger.log(
            log_level,
            f"SECURITY AUDIT [{event.status}] Action={event.action} UserID={event.user_id} IP={event.ip_address} Details={event.details}",
        )
        return event

    @classmethod
    def get_audit_logs(
        cls,
        limit: int = 50,
        offset: int = 0,
        action_filter: Optional[str] = None,
        status_filter: Optional[str] = None,
    ) -> Tuple[List[SecurityAuditLogItem], int]:
        """
        Returns paginated and filtered audit events.
        """
        filtered = list(cls._events)

        if action_filter:
            act_clean = action_filter.upper()
            filtered = [e for e in filtered if act_clean in e.action]

        if status_filter:
            stat_clean = status_filter.upper()
            filtered = [e for e in filtered if e.status == stat_clean]

        total = len(filtered)
        paged = filtered[offset : offset + limit]
        return paged, total

    @classmethod
    def clear_logs(cls) -> None:
        """Clears stored audit logs (primarily for testing)."""
        cls._events.clear()
