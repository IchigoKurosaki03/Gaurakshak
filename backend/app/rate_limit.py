"""Small in-process rate limiter for local deployments.

Use a shared Redis-backed limiter when the API is deployed on multiple workers.
This guard still prevents password/OTP guessing and request floods in the local
single-process setup used by GauRakshak.
"""
from collections import defaultdict, deque
from time import monotonic

from fastapi import HTTPException, Request, status


class SlidingWindowLimiter:
    def __init__(self, *, attempts: int, window_seconds: int) -> None:
        self.attempts = attempts
        self.window_seconds = window_seconds
        self._requests: dict[str, deque[float]] = defaultdict(deque)

    def check(self, request: Request, subject: str = "") -> None:
        client = request.client.host if request.client else "unknown"
        key = f"{client}:{subject.casefold().strip()}"
        now = monotonic()
        bucket = self._requests[key]
        cutoff = now - self.window_seconds
        while bucket and bucket[0] <= cutoff:
            bucket.popleft()
        if len(bucket) >= self.attempts:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Too many attempts. Please wait and try again.",
                headers={"Retry-After": str(self.window_seconds)},
            )
        bucket.append(now)


login_limiter = SlidingWindowLimiter(attempts=5, window_seconds=60)
