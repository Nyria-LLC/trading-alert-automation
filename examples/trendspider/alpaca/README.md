# TrendSpider to Alpaca

To automate TrendSpider alerts to Alpaca, add an Alpaca API key in Nyria, then configure your TrendSpider alert or Strategy Bot to post to your Nyria webhook.

## Broker notes

Alpaca connects with an API key and secret. Generate a key in your Alpaca dashboard and paste it into Nyria. Paper and live keys both work.

Alpaca trades stocks, options and crypto spot.

An alert cannot set the order size. Size comes from the bot's budget per entry.

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

Copy-paste bodies tested against an Alpaca bot:
[examples/trendspider/alpaca](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/trendspider/alpaca)

## Full guide

[https://nyria.io](https://nyria.io)
