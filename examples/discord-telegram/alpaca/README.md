# Discord and Telegram to Alpaca

To automate Discord or Telegram alerts to Alpaca, add an Alpaca API key in Nyria, then point a Nyria strategy at the channel or group you post in.

## Broker notes

Alpaca connects with an API key and secret. Generate a key in your Alpaca dashboard and paste it into Nyria. Paper and live keys both work.

Alpaca trades stocks, options and crypto spot.

An alert cannot set the order size. Size comes from the bot's budget per entry.

## Alert messages

Nyria reads plain text from your Discord channel or Telegram group. Write the alert as you would type it to a trader.

```
SPY long entry
close SPY long
BTCUSD long entry
close long BTCUSD
```

## Setup summary

For Discord: link your Discord account, invite the Nyria bot to your server, and pick one channel per strategy.

For Telegram: connect Telegram through Nyria, start the Nyria bot, then add it to your group or channel as an admin.

## Examples

Tested message shapes for an Alpaca bot:
[examples/discord-telegram/alpaca](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/discord-telegram/alpaca)

## Full guide

[https://nyria.io](https://nyria.io)
