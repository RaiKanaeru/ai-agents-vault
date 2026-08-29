---
title: Fix Server Process Exit on Rate-Limit Execution Timeout
tags: [omnirouter, bugfix, rate-limit, nodejs, unhandled-rejection]
date: 2026-08-29
---

# Fix Server Process Exit on Rate-Limit Execution Timeout

## Symptoms
`npm start` / Node.js process crashed and terminated when an upstream provider (such as `tokenrouter/z-ai/glm-5.3-free`) exceeded OmniRoute's local rate-limit execution expiration (`resilienceSettings.requestQueue.maxWaitMs=15000ms`).

Stack trace:
```
⏰ [RATE-LIMIT] tokenrouter:... — limiter-managed execution expired after 15s
[ERROR] [504]: Request exceeded OmniRoute's local rate-limit execution expiration ...
file:///D:/omnirouter/OmniRoute/src/shared/utils/httpClientAbortGuard.mjs:127
    throw err;
    ^
Error: Request exceeded OmniRoute's local rate-limit execution expiration ...
  code: 'RATE_LIMIT_EXECUTION_TIMEOUT',
  status: 504
```

## Root Cause
1. **Uncaught Promise Rejection in Request Deduplication**: `open-sse/services/requestDedup.ts` creates `sharedPromise` for in-flight requests. When a request failed or timed out, `reject(err)` was called on `sharedPromise`. Because `sharedPromise` had no `.catch()` handler attached when only 1 request was running, Node.js raised an `unhandledRejection`.
2. **Fatal Crash Guard Handling**: `src/shared/utils/httpClientAbortGuard.mjs` had an `unhandledRejection` listener that executed `throw reason;`, turning any unhandled rejection into an `uncaughtException` and crashing the server process. Furthermore, `isClientAbortError` did not recognize local rate-limit timeout/queue error codes or `AbortError`/`TimeoutError`.
3. **Pipeline Re-throwing**: In `src/sse/handlers/chatHelpers.ts`, `executeChatWithBreaker` re-threw unexpected rate-limit error codes instead of converting them to standard 504/503 HTTP responses.

## Fix
1. **`open-sse/services/requestDedup.ts`**:
   - Attached `sharedPromise.catch(() => {})` at creation time to prevent unhandled rejection events when single requests time out or fail.
2. **`src/shared/utils/httpClientAbortGuard.mjs`**:
   - Extended `isClientAbortError` with `RATE_LIMIT_EXECUTION_TIMEOUT`, `RATE_LIMIT_QUEUE_FULL`, `RATE_LIMIT_QUEUE_WEDGED`, `RATE_LIMIT_QUEUE_TIMEOUT`, `AbortError`, and `TimeoutError`.
   - Updated `installProcessCrashGuard` so `unhandledRejection` logs errors (`logger("error", "[server] unhandledRejection:", reason)`) instead of throwing and terminating Node.js.
3. **`src/sse/handlers/chatHelpers.ts`**:
   - Caught rate-limit error codes in `executeChatWithBreaker` and returned structured error responses.

## Verification
- Unit test in `tests/unit/httpClientAbortGuard.test.mjs` passed.
- Contract test in `tests/unit/rate-limit-execution-timeout-message-4165.test.ts` passed, verifying zero `unhandledRejection` emissions.
- `tests/unit/chat-helpers.test.ts` (27/27) and `tests/unit/rate-limit*.test.ts` (82/82) all passed.
