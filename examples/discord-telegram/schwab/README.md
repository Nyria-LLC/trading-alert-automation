# Discord and Telegram to Charles Schwab

To automate Discord or Telegram alerts to Charles Schwab, connect Schwab through its sign-in flow in Nyria, then point a Nyria strategy at the channel or group you post in.

## Broker notes

Schwab access expires every 7 days. Reconnect from the Nyria broker page before the session ends or bots stop placing orders.

Schwab trades stocks and options only. No crypto.

Stock orders are in whole shares. Options support up to 4 legs on one expiration.

An alert cannot set the order size. Size comes from the bot's budget per entry.

## Alert messages

Nyria reads plain text from your Discord channel or Telegram group. Write the alert as you would type it to a trader.

```
SPY long entry
close SPY long
AAPL short entry
close short AAPL
```

Any mention of crypto in a message routed to a Schwab bot has no effect. Schwab does not support crypto orders.

## Setup summary

For Discord: link your Discord account, invite the Nyria bot to your server, and pick one channel per strategy.

For Telegram: connect Telegram through Nyria, start the Nyria bot, then add it to your group or channel as an admin.

## Examples

Tested message shapes for a Schwab bot:
[examples/discord-telegram/schwab](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/discord-telegram/schwab)

## Full guide

[https://nyria.io](https://nyria.io)
