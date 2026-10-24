# Webhook to Alpaca

To automate webhook alerts to Alpaca, add an Alpaca API key in Nyria, then POST to your strategy's webhook URL from any program that can make HTTPS requests.

## Broker notes

Alpaca connects with an API key and secret. Generate a key in your Alpaca dashboard and paste it into Nyria. Paper and live keys both work.

Alpaca trades stocks, options and crypto spot.

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

For crypto, use the spot pair as the ticker, for example `BTCUSD`.

## Examples

Copy-paste curl and Python examples tested against an Alpaca bot:
[examples/webhook/alpaca](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/webhook/alpaca)

## Full guide

[https://nyria.io](https://nyria.io)
