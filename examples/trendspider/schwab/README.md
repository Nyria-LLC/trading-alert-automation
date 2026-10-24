# TrendSpider to Charles Schwab

To automate TrendSpider alerts to Charles Schwab, connect Schwab through its sign-in flow in Nyria, then configure your TrendSpider alert or Strategy Bot to post to your Nyria webhook.

## Broker notes

Schwab access expires every 7 days. Reconnect from the Nyria broker page before the session ends or bots stop placing orders.

Schwab trades stocks and options only. No crypto.

Stock orders are in whole shares. Options support up to 4 legs on one expiration.

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

Copy-paste bodies tested against a Schwab bot:
[examples/trendspider/schwab](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/trendspider/schwab)

## Full guide

[https://nyria.io](https://nyria.io)
