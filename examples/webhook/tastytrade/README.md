# Webhook to tastytrade

To automate webhook alerts to tastytrade, connect tastytrade through its sign-in flow in Nyria, then POST to your strategy's webhook URL from any program that can make HTTPS requests.

## Broker notes

tastytrade connects with your tastytrade account login. Live accounts only.

Crypto is not available through tastytrade's API as of 29 June 2026.

`MODIFY` and `CANCEL` for working orders are not supported on tastytrade. Send `CANCEL` and a new `OPEN` to re-price a resting limit order.

An alert cannot set the order size. Size comes from the bot's budget per entry.

## Minimal example

```bash
curl -X POST https://trades.nyria.io/webhooks/<your-token> \
  -H "Content-Type: application/json" \
  -d '{"ticker": "SPY", "action": "buy"}'
```

```python
import requests
requests.post(
    "https://trades.nyria.io/webhooks/<your-token>",
    json={"ticker": "SPY", "action": "buy"},
    timeout=10,
)
```

## Examples

Copy-paste curl and Python examples tested against a tastytrade bot:
[examples/webhook/tastytrade](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/webhook/tastytrade)

## Full guide

[https://nyria.io](https://nyria.io)
