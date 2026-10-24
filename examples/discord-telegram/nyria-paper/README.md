# Discord and Telegram to Nyria Paper

To automate Discord or Telegram alerts to Nyria Paper, create a paper bot in Nyria without connecting any broker, then point the strategy at the channel or group you post in.

## Broker notes

Nyria Paper is a free simulated broker built into Nyria. No external account or credentials are needed. You can run up to 10 paper bots.

Paper bots trade stocks, options and crypto spot in simulation.

An alert cannot set the order size. Size comes from the bot's budget per entry.

Use a paper bot to test your alert messages before connecting a live broker.

## Alert messages

Nyria reads plain text from your Discord channel or Telegram group. Write the alert as you would type it to a trader.

```
SPY long entry
close SPY long
BTCUSD long entry
AAPL short entry
```

## Setup summary

For Discord: link your Discord account, invite the Nyria bot to your server, and pick one channel per strategy.

For Telegram: connect Telegram through Nyria, start the Nyria bot, then add it to your group or channel as an admin.

## Examples

Tested message shapes for a Nyria Paper bot:
[examples/discord-telegram/nyria-paper](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/discord-telegram/nyria-paper)

## Full guide

[https://nyria.io](https://nyria.io)
