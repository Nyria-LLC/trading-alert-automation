# Discord and Telegram to tastytrade

To automate Discord or Telegram alerts to tastytrade, connect tastytrade through its sign-in flow in Nyria, then point a Nyria strategy at the channel or group you post in.

## Broker notes

tastytrade connects with your tastytrade account login. Live accounts only.

Crypto is not available through tastytrade's API as of 29 June 2026.

An alert cannot set the order size. Size comes from the bot's budget per entry.

## Alert messages

Nyria reads plain text from your Discord channel or Telegram group. Write the alert as you would type it to a trader.

```
SPY long entry
close SPY long
AAPL short entry
close short AAPL
```

Any mention of crypto in a message routed to a tastytrade bot has no effect.

## Setup summary

For Discord: link your Discord account, invite the Nyria bot to your server, and pick one channel per strategy.

For Telegram: connect Telegram through Nyria, start the Nyria bot, then add it to your group or channel as an admin.

## Examples

Tested message shapes for a tastytrade bot:
[examples/discord-telegram/tastytrade](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/discord-telegram/tastytrade)

## Full guide

[https://nyria.io](https://nyria.io)
