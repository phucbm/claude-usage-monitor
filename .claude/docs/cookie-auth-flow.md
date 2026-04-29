# Cookie Authentication & Data Fetching

Claude.ai has no public API or OAuth. The app authenticates by passing the user's browser session cookie directly in HTTP request headers, the same way the browser does when logged in.

---

## What the Cookie Is

The cookie is the full `Cookie` header value copied from a real browser request to claude.ai. It contains multiple key=value pairs separated by semicolons, e.g.:

```
sessionKey=sk-ant-...; lastActiveOrg=<uuid>; intercom-session-...; ...
```

The app only cares about one specific field:

- **`lastActiveOrg=<uuid>`** — the UUID of the user's currently active Claude organization. The app parses this out of the cookie string without making any network request (fast path).

Everything else in the cookie string is treated as opaque and forwarded as-is to claude.ai on each request.

---

## Step 1: Resolving the Organization ID

Before fetching usage, the app needs the organization UUID. It tries two strategies in order:

**Fast path — parse from cookie string**

`AccountsManager.fetchOrganizationId` splits the cookie on `;` and looks for a part starting with `lastActiveOrg=`. If found, that UUID is used immediately with no network call.

**Slow path — bootstrap API**

If `lastActiveOrg=` is not present in the cookie, the app calls:

```
GET https://claude.ai/api/bootstrap
Cookie: <full cookie string>
```

Response (JSON):
```json
{
  "account": {
    "lastActiveOrgId": "<uuid>",
    ...
  }
}
```

The `account.lastActiveOrgId` field is extracted and used going forward.

If both strategies fail, an error is surfaced: `"Could not get org ID"`.

---

## Step 2: Fetching Usage Data

With the org UUID in hand, the app calls:

```
GET https://claude.ai/api/organizations/<orgId>/usage
Cookie: <full cookie string>
Accept: */*
Content-Type: application/json
Origin: https://claude.ai
Referer: https://claude.ai
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 ...
authority: claude.ai
```

The extra headers (Origin, Referer, User-Agent) make the request look like it comes from a browser. Omitting them can cause the API to reject the request.

### Response Shape

```json
{
  "five_hour": {
    "utilization": 42,
    "resets_at": "2026-04-29T14:00:00.000Z"
  },
  "seven_day": {
    "utilization": 310,
    "resets_at": "2026-05-03T00:00:00.000Z"
  },
  "seven_day_sonnet": {
    "utilization": 75,
    "resets_at": "2026-05-03T00:00:00.000Z"
  }
}
```

- `five_hour` — the rolling 5-hour session window (what Claude calls "usage limits")
- `seven_day` — rolling 7-day window across all models
- `seven_day_sonnet` — 7-day window specific to Sonnet; only present on certain plans. If absent, `hasWeeklySonnet` is set to `false` and no Sonnet ring is shown.

`utilization` is an integer count of messages used. The app currently treats this as a usage count out of a fixed limit (defaulting to 100 if no limit is returned). `resets_at` is an ISO 8601 timestamp with fractional seconds.

---

## HTTP Error Handling

Non-200 responses are mapped to a `BillingStatus` enum:

| HTTP status | BillingStatus     | Meaning                                      |
|-------------|-------------------|----------------------------------------------|
| 401         | `.sessionExpired` | Cookie is expired — user must re-paste it    |
| 402         | `.paymentRequired`| Billing issue on the Claude account          |
| 403         | `.forbidden`      | Cookie invalid or account suspended          |
| 429         | `.rateLimited`    | Too many requests; back off and retry later  |
| other 4xx/5xx | `.ok` (with raw error message) | Surfaced as `"HTTP <code>"` |

---

## Storage

Accounts (including the raw cookie string) are persisted to `UserDefaults` under the key `accounts_v2` as a JSON-encoded array of `Account` structs. Only four fields are written to disk:

```
id, label, cookie, showInMenuBar
```

All usage numbers (`sessionUsage`, `weeklyUsage`, `sessionResetsAt`, etc.) are **transient** — they are not persisted and are always re-fetched from the API on launch and on each refresh cycle.

The active account ID is stored separately under `active_account_id`.

---

## Refresh Schedule

- **On launch** — all accounts are fetched immediately via `fetchAllAccounts()`
- **Every 5 minutes** — a `Timer.scheduledTimer(withTimeInterval: 300)` in `AppDelegate` calls `fetchAllAccounts()` again
- **On account add** — the new account is fetched immediately
- **Manual** — the user can trigger a refresh from the UI

Each account is fetched independently; one account failing does not block others.

---

## Multi-Account

Each `Account` object holds its own cookie. When multiple accounts are added, each goes through the same two-step flow (org ID → usage) independently and in parallel. The menu bar badge reflects the **active account** only; other accounts are visible in the panel.

---

## Known Fragility

- These are **undocumented internal endpoints**. Anthropic can rename, restructure, or remove them without notice.
- The `utilization` field has been observed as a message count but its exact semantics (messages vs. tokens vs. compute units) are not officially documented.
- If claude.ai changes its session cookie format and drops `lastActiveOrg=`, the fast path breaks and all accounts fall back to the bootstrap call.
- Cookies expire with the browser session. When a user logs out of claude.ai or their session expires, the stored cookie becomes invalid and they must re-paste a fresh one.
