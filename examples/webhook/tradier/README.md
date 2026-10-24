# Webhook to Tradier

To automate webhook alerts to Tradier, connect Tradier through its sign-in flow in Nyria, then POST to your strategy's webhook URL from any program that can make HTTPS requests.

## Broker notes

Tradier offers a live brokerage account and a Sandbox account. The Sandbox is a paper account. Both connect through the Tradier sign-in or Sandbox credentials.

Tradier trades stocks and options only. No crypto.

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

Copy-paste curl and Python examples tested against a Tradier bot:
[examples/webhook/tradier](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/webhook/tradier)

## Full guide

[https://nyria.io](https://nyria.io)
