# Webhook examples

Post an alert to a Nyria strategy's webhook with `curl` or Python. TradingView and TrendSpider post to this same endpoint, so a body that works here works from them too.

```text
POST https://trades.nyria.io/webhooks/<your-token>
```

Copy the full URL from the strategy's **Integration** tab. The token is the only authentication: there is no signature header and no IP allowlist. Keep it out of source control, and select **Rotate token** on the Integration tab if it leaks. Every example here uses the placeholder `<your-token>`.

Test against a strategy that has only a paper bot deployed. Bots act on every alert that reaches the strategy.

## Files

| File | What it is |
|---|---|
| [`curl-examples.sh`](curl-examples.sh) | One named `curl` example per alert shape. `./curl-examples.sh list` prints the names. |
| [`send_alert.py`](send_alert.py) | The same shapes in Python, standard library only, with retry on `429` and `503`. |

```bash
export WEBHOOK_URL='https://trades.nyria.io/webhooks/<your-token>'   # paste your own URL
./curl-examples.sh open-long

export NYRIA_WEBHOOK_URL="$WEBHOOK_URL"
python3 send_alert.py iron-condor
```

## Fields

Apart from the ticker and the action, every field is optional.

| Field | Description |
|---|---|
| `instrument`, `ticker`, `symbol` | The ticker, such as `SPY` or `BTCUSD`. All three keys mean the same thing. |
| `action` | `OPEN` or `CLOSE` for entries and exits, `MODIFY` or `CANCEL` for order management. `buy`, `sell`, `entry` and `exit` are also accepted. |
| `direction` | `LONG` or `SHORT`. Send it with `OPEN` and `CLOSE`. |
| `price` | Limit price as a decimal. Used when `order_type` is `limit` or the strategy's limit target is **Alert price**. |
| `order_type` | `market` or `limit`. Overrides the strategy's order type for this alert on the shapes that name `action` and `direction`. |
| `marketPosition`, `prevMarketPosition` | TradingView's `long`, `short` or `flat` before and after a fill. Send both and Nyria works out the action and direction. |
| `legs` | Option legs, for strategies whose contract selection is **Provided in alert**. Up to 4, all on one expiration. |
| `metadata.message_id` | Used to spot duplicates instead of a hash of the body. |

An alert cannot set the size of an entry. Size comes from the bot's budget per entry, and a `quantity` or `notional` key on an entry alert is ignored.

### Option legs

| Field | Description |
|---|---|
| `symbol` | OCC option symbol, such as `SPY261120C00780000`. |
| `side` | `CALL` or `PUT`. |
| `action` | `buy_to_open`, `sell_to_open`, `buy_to_close` or `sell_to_close`. |
| `strike` | Strike price, such as `780`. |
| `expiration` | `YYYY-MM-DD`. Give it, or the leg's `symbol`, on every entry leg. |
| `price` | Limit price for this leg. For a limit spread, the leg prices add up to the spread price. |

On a **From my rules** strategy, send no `legs`. Nyria picks the strike and expiration from the strategy's leg rules, so the alert only says the direction.

## Examples

Minimal body:

```bash
curl -X POST https://trades.nyria.io/webhooks/<your-token> \
  -H "Content-Type: application/json" \
  -d '{"ticker": "AAPL", "action": "buy"}'
```

Open and close a position. `CLOSE` with the direction of the open position closes all of it; there is no partial-close field.

```json
{"ticker": "AAPL", "action": "OPEN", "direction": "LONG"}
```

```json
{"ticker": "AAPL", "action": "CLOSE", "direction": "LONG"}
```

Plain text, when the source can only send free text. Set `Content-Type: text/plain`.

```bash
curl -X POST https://trades.nyria.io/webhooks/<your-token> \
  -H "Content-Type: text/plain" \
  --data-binary "AAPL long entry"
```

Resting limit order, then re-price it, then cancel it. `MODIFY` works on Tradier and Alpaca; Schwab and tastytrade refuse it, so send `CANCEL` and a new `OPEN` there. `MODIFY` and `CANCEL` only touch working orders and never open a trade.

```json
{"action": "OPEN", "instrument": "BTCUSD", "direction": "LONG", "order_type": "limit", "price": 64000}
{"action": "MODIFY", "instrument": "BTCUSD", "direction": "LONG", "price": 64500}
{"action": "CANCEL", "instrument": "BTCUSD", "direction": "LONG"}
```

A single-leg option, bought and later closed:

```json
{"ticker": "SPY", "action": "open", "direction": "long",
 "legs": [{"side": "CALL", "strike": 780, "expiration": "2026-11-20"}]}
```

```json
{"ticker": "SPY", "action": "CLOSE", "direction": "LONG",
 "legs": [{"side": "CALL", "strike": 780, "expiration": "2026-11-20", "action": "sell_to_close"}]}
```

A bear call spread for a net credit:

```json
{"ticker": "SPY", "action": "OPEN", "direction": "SHORT", "price": 1.00,
 "legs": [
   {"side": "CALL", "strike": 800, "expiration": "2026-11-20", "action": "sell_to_open"},
   {"side": "CALL", "strike": 810, "expiration": "2026-11-20", "action": "buy_to_open"}
 ]}
```

A four-leg iron condor:

```json
{"ticker": "SPY", "action": "OPEN", "direction": "SHORT", "price": 2.00,
 "legs": [
   {"side": "PUT",  "strike": 745, "expiration": "2026-11-20", "action": "sell_to_open"},
   {"side": "PUT",  "strike": 740, "expiration": "2026-11-20", "action": "buy_to_open"},
   {"side": "CALL", "strike": 800, "expiration": "2026-11-20", "action": "sell_to_open"},
   {"side": "CALL", "strike": 805, "expiration": "2026-11-20", "action": "buy_to_open"}
 ]}
```

A spread has defined risk only when every leg fills. If the broker rejects a protective long leg, you can be left with a short leg. Nyria does not close an iron condor on its own, so send an exit alert.

## TrendSpider

TrendSpider has no `action` or `quantity` variable, so write the action into each alert: `"buy"` on entry alerts and `"sell"` on exit alerts, and leave quantity out. Paste this into the alert's note, which TrendSpider posts as the request body:

```json
{
  "symbol": "%alert_symbol%",
  "action": "buy",
  "price": "%last_price%"
}
```

Account-level Alerts share one webhook URL, so they can feed only one Nyria strategy. A Strategy Bot has its own URL and body, uses `%bot_symbol%` in place of `%alert_symbol%`, and can post to a different strategy. See the [TrendSpider guide](https://docs.nyria.io/alerts/trendspider).

## Duplicates and retries

The same body again within 30 seconds, or within 5 minutes with no other alert in between, is dropped and answers `200` with `{"status": "duplicate"}`. Retrying after a network failure is therefore safe. To scale into a position, make each body different:

```json
{"ticker": "AAPL", "action": "OPEN", "direction": "LONG", "metadata": {"message_id": "scale-in-2026-11-02T13:31:15Z"}}
```

Duplicates are matched per strategy. Two strategies that get the same payload each place their own order.

## Responses

| Status | Meaning |
|---|---|
| `200`, `"status": "processed"` | Read and handed to your bots. This does not mean the broker filled anything. |
| `200`, `"rejected": true` | The strategy is not Active. |
| `200`, `"status": "rejected"` | The ticker is not in the strategy's list, that direction is off, or there is no open position to close. |
| `200`, `"status": "duplicate"` | A repeat of an earlier body. |
| `400` | The body is empty, or the token in the URL is malformed. |
| `404` | No strategy has that token. |
| `413` | The payload is larger than 256 KB. |
| `422` | Nyria could not use the alert, for example a missing field, an unknown symbol, no matching strike, or more than 4 option legs. |
| `429` | Over the rate limit of 10 alerts at once, then 1 a second. Wait as long as `Retry-After` says. |
| `503` | A temporary failure. Sending the same alert again can succeed. |
| `500` | Any other failure. The strategy's **Logs** tab has the reason. |

`raise_for_status()` in Python and `curl --fail` catch 4xx and 5xx but not a rejection or a duplicate, which answer `200`, so check `status` too. Always set a timeout.

## Docs

- [Webhook payload reference](https://docs.nyria.io/webhook-reference)
- [Send alerts from your own bot](https://docs.nyria.io/alerts/custom-webhook)
- [Multi-leg options strategies](https://docs.nyria.io/strategies/multi-leg-options)
- [Closing a position](https://docs.nyria.io/closing-positions)
