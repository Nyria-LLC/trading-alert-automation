# Discord and Telegram examples

Nyria reads a Discord channel or a Telegram group or channel that you run, and treats each message as an alert. There is no webhook URL and no template to follow: write the alert the way a trader would.

Every alert needs a ticker, a direction and an action. Word exits the same way as entries, so Nyria can match them.

- [`messages.txt`](messages.txt): message shapes that are read, and two that are not.
- [`discord-embed.json`](discord-embed.json): an embed, as a bot or webhook would post it.

## Message shapes

| Message | Read as |
|---|---|
| `SPY long entry` | Open a long SPY position. |
| `long SPY here` | Open a long SPY position. |
| `Close SPY long` | Close the long SPY position. |
| `Close short BTC` | Close the short BTC position. |
| `AAPL 345C buy to open` | Buy to open the AAPL 345 call. |
| `BTO SPY 12/18 780C` | Buy to open: `12/18` is the expiration, `780C` the 780 call. |
| `SPY 780C/781C bull call spread` | A bull call spread on those strikes. |
| `longed NVDA at 224.40, stop 221` | Long NVDA entry from a quoted tweet. The price and stop are read as metadata; no stop order is placed. |
| `thinking about SPY?` | Nothing. Questions and hedged wording place no order. |

Nyria ignores case, trailing punctuation, emoji and `@everyone` or `@here` mentions. The size of an order always comes from the bot's budget per entry, whatever size the message mentions.

With **From my rules**, the strategy picks the contract (by delta, by a number of strikes from at-the-money, or as an offset from another leg) and the message only needs the direction. With **Provided in alert**, the message names the contract. A strategy holds up to 4 legs on one expiration.

An entry with no date, like `SPY 780C`, takes the nearest listed expiration under **Provided in alert**. That can be today's expiration (0DTE), even late in the day.

## Discord

Nyria reads three things from each message, in this order, and uses the first that gives a ticker, a direction and an action:

1. **Embeds**: `embed.title`, then `embed.description`, then each field's name and value joined by a space.
2. **Quoted tweet**: a Twitter/X link that Discord unfurls. `longed <SYMBOL>` is a long entry, `shorted <SYMBOL>` a short entry, `closed long <SYMBOL>` a long exit and `closed short <SYMBOL>` a short exit.
3. **Free text**: the message body.

For the embed in `discord-embed.json`, Nyria reads `SPY long entry` from the title and finds `780C` in the fields, so each of the strategy's bots buys the SPY 780 call.

Setup in short: link your Discord account, invite the Nyria bot to a server where you have Manage Server, pick one channel per strategy, and optionally filter by author (part of the poster's display name) or keyword. Threads, other channels and DMs are not read.

Limits:

- Editing or deleting a message after it trades does not change the order. Post a normal exit alert.
- Forwarded messages, images and other attachments are not read.
- During a Discord outage the bot can miss up to about 30 seconds of messages while it reconnects. Missed messages are not replayed.
- The author filter narrows a channel but does not lock it, because anyone in the server can take a display name. Use a channel only the caller can post in.

## Telegram

Telegram alerts are free text, in the same shapes as Discord.

Setup in short: select Connect Telegram, press Start in the chat with `@NyriaAlertsBot`, tap Link, then add Nyria to your group or channel as an admin. You need to be the chat's owner, or an admin who can add admins. Nyria only reads messages and never posts.

Limits:

- An alert that Nyria handles more than a minute after it was posted places no new entry. A close in it still runs. Post the alert again to take the entry.
- Edited messages are not traded.
- Messages that other bots post in a group are not read. A bot can relay alerts into a channel where Nyria is an admin.
- Do not point one strategy at a channel and another at its discussion group, or each alert trades twice.

## Same message twice

The same message posted twice within 30 seconds places one order.

## Broker-specific notes

The message format is the same for every broker. What differs is how the broker connects and what it supports.

| Broker | Notes |
|---|---|
| [schwab](schwab) | Connects through Schwab sign-in. Session expires every 7 days. Stocks and options only. |
| [tradier](tradier) | Connects through Tradier sign-in or sandbox. Sandbox is a paper account. No crypto. |
| [tastytrade](tastytrade) | Connects through tastytrade sign-in. Live accounts only. Crypto off since 29 June 2026. |
| [alpaca](alpaca) | Connects with an API key. Paper and live both work. Stocks, options and crypto spot. |
| [nyria-paper](nyria-paper) | No connection needed. Free simulated broker. Stocks, options and crypto spot. |

## Docs

- [Trade alerts from a Discord server you run](https://docs.nyria.io/alerts/discord)
- [Trade alerts from a Telegram chat you run](https://docs.nyria.io/alerts/telegram)
- [Turn Discord trade alerts into broker orders](https://docs.nyria.io/guides/discord-alerts-to-broker-orders)
- [Turn Telegram trade alerts into broker orders](https://docs.nyria.io/guides/telegram-alerts-to-broker-orders)
