# TrendSpider to Nyria Paper

To automate TrendSpider alerts to Nyria Paper, create a paper bot in Nyria without connecting any broker, then configure your TrendSpider alert or Strategy Bot to post to your Nyria webhook.

## Broker notes

Nyria Paper is a free simulated broker built into Nyria. No external account or credentials are needed. You can run up to 10 paper bots.

Paper bots trade stocks, options and crypto spot in simulation.

An alert cannot set the order size. Size comes from the bot's budget per entry.

Use a paper bot to test your TrendSpider alert bodies before connecting a live broker.

## TrendSpider alert body

TrendSpider has no action variable. Write the action into each alert body explicitly.

Entry alert body:

```json
{"symbol": "%alert_symbol%", "action": "buy"}
```

Exit alert body:

```json
{"symbol": "%alert_symbol%", "action": "sell"}
```

For Strategy Bots, replace `%alert_symbol%` with `%bot_symbol%`.

## Account-level Alerts vs. Strategy Bots

Account-level Alerts share one webhook URL and can feed only one Nyria strategy. Strategy Bots each have their own URL and body, so each can post to a different Nyria strategy.

## Examples

Copy-paste bodies tested against a Nyria Paper bot:
[examples/trendspider/nyria-paper](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/trendspider/nyria-paper)

## Full guide

[https://nyria.io](https://nyria.io)
