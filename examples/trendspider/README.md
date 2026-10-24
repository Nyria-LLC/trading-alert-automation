# TrendSpider examples

Webhook bodies for TrendSpider Alerts and Strategy Bots that post to a Nyria strategy. TrendSpider sends the alert's note as the request body, so the body is the whole alert.

You need a TrendSpider plan that includes webhook alerts, and a Nyria strategy whose alert source is TrendSpider.

## Files

| File | What it is |
|---|---|
| [`alert-buy.json`](alert-buy.json) | An entry for an Alert. `%alert_symbol%` is the symbol the alert fired on. |
| [`alert-sell.json`](alert-sell.json) | An exit for an Alert. |
| [`strategy-bot-buy.json`](strategy-bot-buy.json) | An entry for a Strategy Bot, which uses `%bot_symbol%`. |
| [`strategy-bot-sell.json`](strategy-bot-sell.json) | An exit for a Strategy Bot. |

TrendSpider has no action or quantity variable. Write `"action": "buy"` into each entry alert and `"action": "sell"` into each exit alert, and leave quantity out so the Nyria bot sizes the order. The same bodies, tested against Nyria's alert tester for each broker, are in [trading-alert-examples](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/trendspider).

## Alerts or Strategy Bots?

| | Alerts | Strategy Bots |
|---|---|---|
| Webhook URL | One URL for the whole account (Account & Settings) | A URL and body for each bot |
| Symbol variable | `%alert_symbol%` | `%bot_symbol%` |
| Can feed several Nyria strategies | No | Yes |

## Set up Alerts

1. In Nyria, open the strategy's Integration tab and copy the webhook URL: `https://trades.nyria.io/webhooks/<your-strategy-token>`. Keep it private.
2. In TrendSpider, open User Icon, then Account & Settings, check Webhook and paste the URL. Use method POST. Every alert you arm posts to this one Nyria strategy.
3. Paste the body into the alert's note.
4. Select Send Test Alert. On the Nyria strategy's Logs tab, check the alert arrived and how Nyria read it. Then set the TrendSpider alert Active.

## Set up Strategy Bots

Each bot has its own webhook URL and body, so each can post to a different Nyria strategy. Give the bot's entry webhook `"action": "buy"` and its exit webhook `"action": "sell"`.

## Docs

- [Connect TrendSpider alerts](https://docs.nyria.io/alerts/trendspider)
- [Webhook payload reference](https://docs.nyria.io/webhook-reference)
