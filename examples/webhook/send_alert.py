#!/usr/bin/env python3
"""Send alerts to a Nyria strategy webhook.

Standard library only. The webhook URL comes from the NYRIA_WEBHOOK_URL
environment variable; the token at its end is the only authentication, so keep
it out of source control.

    export NYRIA_WEBHOOK_URL='https://trades.nyria.io/webhooks/<your-token>'
    python3 send_alert.py open-long
    python3 send_alert.py --list

Point it at a strategy with only a paper bot deployed: bots act on every alert
that reaches the strategy.
"""

import json
import os
import sys
import time
import urllib.error
import urllib.request

PLACEHOLDER = "<your-token>"
EXPIRATION = "2026-11-20"  # YYYY-MM-DD, a listed expiration


def leg(side, strike, action):
    return {"side": side, "strike": strike, "expiration": EXPIRATION, "action": action}


# Example alerts. Option legs apply to strategies whose contract selection is
# "Provided in alert"; a "From my rules" strategy takes no legs.
EXAMPLES = {
    "minimal": {"ticker": "AAPL", "action": "buy"},
    "open-long": {"ticker": "AAPL", "action": "OPEN", "direction": "LONG"},
    "close-long": {"ticker": "AAPL", "action": "CLOSE", "direction": "LONG"},
    "open-short": {"ticker": "AAPL", "action": "OPEN", "direction": "SHORT"},
    "close-short": {"ticker": "AAPL", "action": "CLOSE", "direction": "SHORT"},
    "limit-entry": {
        "ticker": "BTCUSD", "action": "OPEN", "direction": "LONG",
        "order_type": "limit", "price": 64000,
    },
    "modify": {"ticker": "BTCUSD", "action": "MODIFY", "direction": "LONG", "price": 64500},
    "cancel": {"ticker": "BTCUSD", "action": "CANCEL", "direction": "LONG"},
    "call": {
        "ticker": "SPY", "action": "OPEN", "direction": "LONG",
        "legs": [{"side": "CALL", "strike": 780, "expiration": EXPIRATION}],
    },
    "close-call": {
        "ticker": "SPY", "action": "CLOSE", "direction": "LONG",
        "legs": [leg("CALL", 780, "sell_to_close")],
    },
    "vertical-spread": {
        "ticker": "SPY", "action": "OPEN", "direction": "SHORT", "price": 1.00,
        "legs": [leg("CALL", 800, "sell_to_open"), leg("CALL", 810, "buy_to_open")],
    },
    "iron-condor": {
        "ticker": "SPY", "action": "OPEN", "direction": "SHORT", "price": 2.00,
        "legs": [
            leg("PUT", 745, "sell_to_open"), leg("PUT", 740, "buy_to_open"),
            leg("CALL", 800, "sell_to_open"), leg("CALL", 805, "buy_to_open"),
        ],
    },
}


def webhook_url():
    url = os.environ.get("NYRIA_WEBHOOK_URL", "")
    if not url or PLACEHOLDER in url:
        sys.exit("Set NYRIA_WEBHOOK_URL to your strategy webhook URL.")
    return url


def fire_alert(payload, url):
    """POST one alert. Returns the parsed response body.

    A 200 means Nyria read the alert and passed it to the bots; it does not mean
    the broker filled anything. Rejections and duplicates also answer 200, so
    check "status" as well as the HTTP code.
    """
    body = json.dumps(payload).encode()
    request = urllib.request.Request(
        url, data=body, headers={"Content-Type": "application/json"}, method="POST"
    )
    try:
        with urllib.request.urlopen(request, timeout=10) as response:
            return json.load(response)
    except urllib.error.HTTPError as error:
        detail = error.read().decode(errors="replace")
        if error.code == 429:
            wait = float(error.headers.get("Retry-After", "1"))
            raise RuntimeError(f"rate limited, retry in {wait:g}s: {detail}") from error
        raise RuntimeError(f"HTTP {error.code}: {detail}") from error


def fire_with_retry(payload, url, attempts=3):
    """Retry the temporary failures (429, 503). Repeating a body is safe: an
    identical body inside the duplicate window is dropped, not traded twice."""
    for attempt in range(1, attempts + 1):
        try:
            return fire_alert(payload, url)
        except RuntimeError as error:
            temporary = "rate limited" in str(error) or "HTTP 503" in str(error)
            if not temporary or attempt == attempts:
                raise
            time.sleep(attempt)


def main(argv):
    if len(argv) != 2 or argv[1] in ("-h", "--help"):
        sys.exit(__doc__)
    if argv[1] == "--list":
        print("\n".join(EXAMPLES))
        return
    if argv[1] not in EXAMPLES:
        sys.exit(f"Unknown example {argv[1]!r}. Run with --list.")
    result = fire_with_retry(EXAMPLES[argv[1]], webhook_url())
    status = result.get("status")
    if status == "processed":
        print("Nyria read the alert and handed it to the bots.")
    else:
        print(f"Nyria did not act on it: {result}")


if __name__ == "__main__":
    main(sys.argv)
