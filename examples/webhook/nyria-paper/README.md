# Webhook to Nyria Paper

To automate webhook alerts to Nyria Paper, create a paper bot in Nyria without connecting any broker, then POST to your strategy's webhook URL from any program that can make HTTPS requests.

## Broker notes

Nyria Paper is a free simulated broker built into Nyria. No external account or credentials are needed. You can run up to 10 paper bots.

Paper bots trade stocks, options and crypto spot in simulation.

An alert cannot set the order size. Size comes from the bot's budget per entry.

Use a paper bot to test your webhook payloads before connecting a live broker. The same body that works here works unchanged when you switch to a live broker.

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

Copy-paste curl and Python examples tested against a Nyria Paper bot:
[examples/webhook/nyria-paper](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/webhook/nyria-paper)

## Full guide

[https://nyria.io](https://nyria.io)
