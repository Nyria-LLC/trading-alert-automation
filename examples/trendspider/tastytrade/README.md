# TrendSpider to tastytrade

To automate TrendSpider alerts to tastytrade, connect tastytrade through its sign-in flow in Nyria, then configure your TrendSpider alert or Strategy Bot to post to your Nyria webhook.

## Broker notes

tastytrade connects with your tastytrade account login. Live accounts only.

Crypto is not available through tastytrade's API as of 29 June 2026.

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

Copy-paste bodies tested against a tastytrade bot:
[examples/trendspider/tastytrade](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/trendspider/tastytrade)

## Full guide

[https://nyria.io](https://nyria.io)
