# TrendSpider to Tradier

To automate TrendSpider alerts to Tradier, connect Tradier through its sign-in flow in Nyria, then configure your TrendSpider alert or Strategy Bot to post to your Nyria webhook.

## Broker notes

Tradier offers a live brokerage account and a Sandbox account. The Sandbox is a paper account. Both connect through the Tradier sign-in or Sandbox credentials.

Tradier trades stocks and options only. No crypto.

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

Copy-paste bodies tested against a Tradier bot:
[examples/trendspider/tradier](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/trendspider/tradier)

## Full guide

[https://nyria.io](https://nyria.io)
