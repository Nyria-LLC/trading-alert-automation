#!/usr/bin/env bash
# curl examples for a Nyria strategy webhook.
#
# Usage:  WEBHOOK_URL='https://trades.nyria.io/webhooks/<your-token>' ./curl-examples.sh <name>
#         ./curl-examples.sh list
#
# The URL is on the strategy's Integration tab. The token at its end is the only
# authentication, so keep it out of source control. Point this at a strategy with
# only a paper bot deployed: bots act on every alert that reaches the strategy.
set -euo pipefail

post_json() { curl -sS -X POST "$WEBHOOK_URL" -H "Content-Type: application/json" -d "$1"; echo; }
post_text() { curl -sS -X POST "$WEBHOOK_URL" -H "Content-Type: text/plain" --data-binary "$1"; echo; }

example_names="minimal plain-text open-long close-long open-short close-short limit-entry modify cancel
scale-in call-leg put-leg close-option-leg vertical-spread iron-condor tradingview-position-change"

if [ "${1:-list}" = "list" ]; then
  echo "$example_names" | tr ' ' '\n' | sed '/^$/d'
  exit 0
fi

: "${WEBHOOK_URL:?Set WEBHOOK_URL to your strategy webhook URL}"
case "$WEBHOOK_URL" in
  *'<your-token>'*) echo "WEBHOOK_URL still holds the placeholder." >&2; exit 1 ;;
esac

case "$1" in
  # The smallest valid body: a ticker and an action.
  minimal)
    post_json '{"ticker": "AAPL", "action": "buy"}' ;;

  # Plain text works when the source can only send free text.
  plain-text)
    post_text 'AAPL long entry' ;;

  # Explicit entries and exits. CLOSE closes the whole open position.
  open-long)
    post_json '{"ticker": "AAPL", "action": "OPEN", "direction": "LONG", "order_type": "market"}' ;;
  close-long)
    post_json '{"ticker": "AAPL", "action": "CLOSE", "direction": "LONG"}' ;;
  open-short)
    post_json '{"ticker": "AAPL", "action": "OPEN", "direction": "SHORT"}' ;;
  close-short)
    post_json '{"ticker": "AAPL", "action": "CLOSE", "direction": "SHORT"}' ;;

  # A resting limit order. The size still comes from the bot's budget per entry.
  limit-entry)
    post_json '{"action": "OPEN", "instrument": "BTCUSD", "direction": "LONG", "order_type": "limit", "price": 64000}' ;;

  # Re-price a working order (Tradier and Alpaca), then pull a working entry.
  modify)
    post_json '{"action": "MODIFY", "instrument": "BTCUSD", "direction": "LONG", "price": 64500}' ;;
  cancel)
    post_json '{"action": "CANCEL", "instrument": "BTCUSD", "direction": "LONG"}' ;;

  # A second entry with the same fixed text would be dropped as a duplicate.
  # A unique metadata.message_id makes each body different.
  scale-in)
    post_json "{\"ticker\": \"AAPL\", \"action\": \"OPEN\", \"direction\": \"LONG\", \"metadata\": {\"message_id\": \"scale-in-$(date -u +%Y%m%dT%H%M%SZ)\"}}" ;;

  # Option legs, for strategies whose contract selection is "Provided in alert".
  # Each leg takes side (CALL or PUT), strike, expiration (YYYY-MM-DD) and, optionally, action.
  call-leg)
    post_json '{"ticker": "SPY", "action": "open", "direction": "long", "legs": [{"side": "CALL", "strike": 780, "expiration": "2026-11-20"}]}' ;;
  put-leg)
    post_json '{"ticker": "SPY", "action": "open", "direction": "long", "legs": [{"side": "PUT", "strike": 740, "expiration": "2026-11-20"}]}' ;;
  close-option-leg)
    post_json '{"ticker": "SPY", "action": "CLOSE", "direction": "LONG", "legs": [{"side": "CALL", "strike": 780, "expiration": "2026-11-20", "action": "sell_to_close"}]}' ;;

  # A two-leg vertical credit spread (bear call) with a net limit price. Up to 4 legs, one expiration.
  vertical-spread)
    post_json '{"ticker": "SPY", "action": "OPEN", "direction": "SHORT", "price": 1.00, "legs": [{"side": "CALL", "strike": 800, "expiration": "2026-11-20", "action": "sell_to_open"}, {"side": "CALL", "strike": 810, "expiration": "2026-11-20", "action": "buy_to_open"}]}' ;;

  # A four-leg iron condor: short 745 put and 800 call, long 740 put and 805 call.
  iron-condor)
    post_json '{"ticker": "SPY", "action": "OPEN", "direction": "SHORT", "price": 2.00, "legs": [{"side": "PUT", "strike": 745, "expiration": "2026-11-20", "action": "sell_to_open"}, {"side": "PUT", "strike": 740, "expiration": "2026-11-20", "action": "buy_to_open"}, {"side": "CALL", "strike": 800, "expiration": "2026-11-20", "action": "sell_to_open"}, {"side": "CALL", "strike": 805, "expiration": "2026-11-20", "action": "buy_to_open"}]}' ;;

  # What a TradingView strategy alert sends: Nyria reads the position change.
  tradingview-position-change)
    post_json '{"ticker": "SPY", "action": "buy", "marketPosition": "long", "prevMarketPosition": "flat", "price": 771.20}' ;;

  *) echo "Unknown example: $1 (run ./curl-examples.sh list)" >&2; exit 1 ;;
esac
