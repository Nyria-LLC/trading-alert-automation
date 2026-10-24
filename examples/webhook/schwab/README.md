# Webhook to Charles Schwab

To automate webhook alerts to Charles Schwab, connect Schwab through its sign-in flow in Nyria, then POST to your strategy's webhook URL from any program that can make HTTPS requests.

## Broker notes

Schwab access expires every 7 days. Reconnect from the Nyria broker page before the session ends or bots stop placing orders.

Schwab trades stocks and options only. No crypto.

Stock orders are in whole shares. Options support up to 4 legs on one expiration.

`MODIFY` and `CANCEL` for working orders are not supported on Schwab. Send `CANCEL` and a new `OPEN` to re-price a resting limit order.

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

Copy-paste curl and Python examples tested against a Schwab bot:
[examples/webhook/schwab](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/webhook/schwab)

## Full guide

[https://nyria.io](https://nyria.io)
