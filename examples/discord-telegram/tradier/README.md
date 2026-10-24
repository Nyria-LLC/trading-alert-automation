# Discord and Telegram to Tradier

To automate Discord or Telegram alerts to Tradier, connect Tradier through its sign-in flow in Nyria, then point a Nyria strategy at the channel or group you post in.

## Broker notes

Tradier offers a live brokerage account and a Sandbox account. The Sandbox is a paper account. Both connect through the Tradier sign-in or Sandbox credentials.

Tradier trades stocks and options only. No crypto.

An alert cannot set the order size. Size comes from the bot's budget per entry.

## Alert messages

Nyria reads plain text from your Discord channel or Telegram group. Write the alert as you would type it to a trader.

```
SPY long entry
close SPY long
AAPL short entry
close short AAPL
```

Any mention of crypto in a message routed to a Tradier bot has no effect. Tradier does not support crypto orders.

## Setup summary

For Discord: link your Discord account, invite the Nyria bot to your server, and pick one channel per strategy.

For Telegram: connect Telegram through Nyria, start the Nyria bot, then add it to your group or channel as an admin.

## Examples

Tested message shapes for a Tradier bot:
[examples/discord-telegram/tradier](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/discord-telegram/tradier)

## Full guide

[https://nyria.io](https://nyria.io)
