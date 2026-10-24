# Trading alert automation

Turn TradingView, TrendSpider, Discord and Telegram alerts into broker orders: alert message examples, Pine Script templates and webhook formats.

**How do I automate trading alerts to my brokerage account?** Send the alert to a service that reads it and places the order for you. With [Nyria](https://nyria.io), you create a strategy for the alert source (TradingView, TrendSpider, a Discord server or Telegram chat you run, or your own code), connect your Charles Schwab, Tradier, tastytrade or Alpaca account or the free Nyria Paper simulator, and point the alert at the strategy's webhook URL. The alert names a ticker, a side and whether it opens or closes a position. Nyria reads it and a bot places the order in your own account. TradingView webhooks need a paid plan with two-factor sign-in on. An alert cannot set the order size or attach a stop. Live trading is from $15 a month.

This repository collects working examples for one job: getting an alert you already produce to place an order in a brokerage account, without writing a broker integration yourself. Everything here is checked against the [Nyria docs](https://docs.nyria.io), which stay the source of truth for field names and behavior. Examples that are run through Nyria's alert tester live in [Nyria-LLC/trading-alert-examples](https://github.com/Nyria-LLC/trading-alert-examples).

## Questions answered

- [What is trading alert automation?](#what-is-trading-alert-automation)
- [How does a webhook alert become an order?](#how-does-a-webhook-alert-become-an-order)
- [Which alert sources work?](#which-alert-sources-work)
- [How do I automate TradingView alerts to Charles Schwab, Tradier, tastytrade, Alpaca or Nyria Paper?](#which-brokers-can-an-alert-trade)
- [What alert formats does Nyria read?](#what-alert-formats-does-nyria-read)
- [Can alerts trade options and multi-leg spreads?](#can-alerts-trade-options)
- [Can alerts trade crypto?](#can-alerts-trade-crypto)
- [Should I test on paper first?](#paper-first)
- [What can alert automation not do?](#limits)
- [Short answers to common questions](FAQ.md)

## What is trading alert automation?

A trading alert is a message: a TradingView alert firing, a caller posting `SPY long entry` in a Discord channel, a script of your own sending an HTTP request. On its own it only tells you something happened. Alert-to-order automation adds the missing steps in the middle:

1. **Receive** the alert from where it is produced.
2. **Read** it: work out the ticker, the direction and the action (open or close).
3. **Decide the order** from settings you chose in advance: order type, size, and for options the contract.
4. **Send the order** to your broker account and keep a log of what happened.

The parts you write are the alert and its wording. The parts you configure once are the rules that turn it into an order.

## How does a webhook alert become an order?

```text
 alert source                webhook                      bot                       broker
 ------------      ------------------------      ---------------------      ---------------------
 TradingView   -->  POST trades.nyria.io     -->  reads ticker, side,  -->  order placed in your
 TrendSpider        /webhooks/<your-token>        and action; sizes it       account (Charles Schwab,
 your script                                      from the bot's budget      Tradier, tastytrade,
                                                  per entry                  Alpaca) or Nyria Paper
```

- The token at the end of the URL is the only authentication. Treat the URL like a password and rotate the token if it leaks.
- The alert does not set the size of an entry. Size comes from the bot's settings, so a `quantity` key on an entry alert is ignored.
- Duplicate bodies are dropped: the same body again within 30 seconds, or within 5 minutes with no other alert in between, answers `200` with `{"status": "duplicate"}`. To scale into a position, make each body different, for example with a unique `metadata.message_id`.
- A `200` means the alert was read and handed to the bots. It does not mean the broker filled anything; the bot's log shows what the broker did.
- Rate limit per webhook: 10 alerts at once, then 1 a second. Over that, the webhook answers `429` with a `Retry-After` header.

## Which alert sources work?

| Source | How the alert arrives | Message format | Examples |
|---|---|---|---|
| TradingView | Webhook URL in the alert's Notifications tab | Plain text or JSON | [examples/tradingview](examples/tradingview) |
| TrendSpider | Webhook from an Alert or a Strategy Bot | JSON | [examples/trendspider](examples/trendspider) |
| Discord | Nyria reads one channel of a server you run | Plain text, embeds | [examples/discord-telegram](examples/discord-telegram) |
| Telegram | Nyria reads one group or channel you run | Plain text | [examples/discord-telegram](examples/discord-telegram) |
| Python and custom webhooks | HTTPS `POST` to the webhook URL | Plain text or JSON | [examples/webhook](examples/webhook) |

A strategy reads alerts from one source. TradingView webhooks need a paid TradingView plan with two-factor authentication turned on.

### TradingView alerts

Open the alert dialog with Alt+A (Option+A on a Mac), set the Condition to your strategy with Order fills only, paste a message, and tick Webhook URL under Notifications. A `strategy()` needs one alert per ticker; an `indicator()` needs one alert per side, because it has no `{{strategy.*}}` placeholders.

```json
{
  "action": "{{strategy.order.action}}",
  "instrument": "{{ticker}}",
  "marketPosition": "{{strategy.market_position}}",
  "prevMarketPosition": "{{strategy.prev_market_position}}",
  "contracts": "{{strategy.order.contracts}}",
  "price": {{close}}
}
```

The open-source Pine Script v6 [Nyria Alert Builder](examples/tradingview/nyria-alert-builder.pine) writes the message for every order it places. Guide: [automate TradingView alerts](https://nyria.io/guides/automate-tradingview-alerts).

### TrendSpider alerts

TrendSpider has no action or quantity variable, so write `buy` into entry alerts and `sell` into exit alerts, and paste this into the alert's note:

```json
{
  "symbol": "%alert_symbol%",
  "action": "buy",
  "price": "%last_price%"
}
```

Account-level Alerts share one webhook URL, so they feed one Nyria strategy. A Strategy Bot has its own URL and body, uses `%bot_symbol%` in place of `%alert_symbol%`, and can post to a different strategy. See [examples/trendspider](examples/trendspider) and the [TrendSpider docs](https://docs.nyria.io/alerts/trendspider).

### Discord alerts

Nyria reads one channel of a server you run, as a bot with the View Channels permission only. Post the call the way a trader would:

```text
SPY long entry
BTO SPY 12/18 780C
Close SPY long
```

See [examples/discord-telegram](examples/discord-telegram) and [Discord alerts to broker orders](https://nyria.io/guides/discord-alerts-to-broker).

### Telegram alerts

Nyria reads one Telegram group or channel you run, as an admin that only reads. Point the strategy at a channel or its discussion group, never both. An edited message places no order. See [Telegram alerts to broker orders](https://nyria.io/guides/telegram-alerts-to-broker).

### Python and custom webhooks

Any program that can make an HTTPS request can send an alert. With Python and `requests`:

```python
import os
import requests

url = os.environ["NYRIA_WEBHOOK_URL"]
alert = {"ticker": "AAPL", "action": "OPEN", "direction": "LONG"}
response = requests.post(url, json=alert, timeout=10)
print(response.status_code, response.json())
```

See [examples/webhook](examples/webhook) and [Send alerts from your Python script to your broker](https://nyria.io/guides/python-webhook-alerts-to-broker).

## Which brokers can an alert trade?

| Broker | Connects with | Stocks | Options | Crypto spot | Paper |
|---|---|---|---|---|---|
| Charles Schwab | Schwab sign-in, reconnect every 7 days | yes | up to 4 legs | no | no, use Nyria Paper |
| Tradier | Tradier sign-in, or sandbox credentials | yes | up to 4 legs | no | Tradier Sandbox |
| tastytrade | tastytrade sign-in | yes | up to 4 legs | no, disabled in its API | no, use Nyria Paper |
| Alpaca | API key | yes | up to 4 legs | yes | Alpaca paper account |
| Nyria Paper | nothing to connect | yes | up to 4 legs | yes | free simulated broker |

The alert is the same for every broker. The bot you deploy decides where the order goes.

### TradingView alerts to Charles Schwab

Connect Schwab in Nyria, create a strategy with TradingView as the alert source, and paste the strategy's webhook URL into the alert. Each alert becomes an order in your Charles Schwab account.

**Connect it**

1. In Nyria, select Integrations, then the Charles Schwab card, then Connect live account.
1. Sign in at schwab.com and select Allow on the Authorize App screen. No developer account or API key is needed.
1. Schwab ends Nyria's access every 7 days. Select Reconnect live account and sign in again each week.

**Wire the alert**

1. In Nyria, select Create strategy, pick TradingView as the alert source and choose the asset type (stocks or options).
2. In TradingView, on a paid plan with two-factor sign-in on, press Alt+A, set the Condition to your strategy or indicator and paste a message from the list below.
3. Under Notifications tick Webhook URL and paste the strategy's URL, `https://trades.nyria.io/webhooks/<your-strategy-token>`.
4. Back in Nyria, select Check format, then deploy a bot on Nyria Paper first and on the live account once the log reads the way you meant.

**Alert messages**

An entry and its exit from an indicator, one alert for each side:

```json
{
  "action": "OPEN",
  "instrument": "{{ticker}}",
  "direction": "LONG"
}
```

```json
{
  "action": "CLOSE",
  "instrument": "{{ticker}}",
  "direction": "LONG"
}
```

Every message above is read back by Nyria's alert tester in [trading-alert-examples](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/tradingview/schwab), with the matching files for TrendSpider, Discord, Telegram, Python and webhooks.

**What the alert must say.** A ticker, a side and whether it opens or closes a position. For options it can add the strike, expiration and call or put, or leave them out and let the strategy pick the contract.

**What it can not do.** Set the size, because each bot sizes the order from its own budget per entry. Attach a stop or target, because Nyria sends market and limit orders only and exits come from exit alerts. Trade crypto at Schwab, which it does not carry through Nyria.

**What Schwab does with the order**

- Live accounts only, connected through Schwab's own sign-in. Nyria's token places and cancels orders and cannot move money.
- Stocks in whole shares and options in whole contracts. Nyria enters whole shares, so Schwab Stock Slices are not used for entries.
- Market and limit orders. A spread goes as one order for all its legs, priced as a net debit or credit when it is a limit order.
- The strategy's Duration goes to Schwab as set: Day, Good till canceled or Fill or kill.
- Schwab needs options approval at the level the trade requires. Spreads need a higher level than buying calls or puts.
- Short stock and short spreads need a margin account.
- Schwab's API does not offer crypto, so a crypto alert places no order at Schwab. Use Alpaca or Nyria Paper for crypto.
- MODIFY is refused at Schwab. To re-price a resting entry, send CANCEL, then a new OPEN.

More: [TradingView alerts to Charles Schwab on nyria.io](https://nyria.io/automate/tradingview-to-schwab), [Charles Schwab in the docs](https://docs.nyria.io/integrations/brokers/schwab).

### TradingView alerts to Tradier

Connect Tradier in Nyria, create a strategy with TradingView as the alert source, and paste the strategy's webhook URL into the alert. Each alert becomes an order in your Tradier account.

**Connect it**

1. In Nyria, select Integrations, then the Tradier card, then Connect live account, and approve access on Tradier's own screen.
1. For Tradier's sandbox instead, select Connect paper account and paste the sandbox account number and access token from developer.tradier.com.
1. The sandbox is a separate account from the live one, so the same strategy can run on both.

**Wire the alert**

1. In Nyria, select Create strategy, pick TradingView as the alert source and choose the asset type (stocks or options).
2. In TradingView, on a paid plan with two-factor sign-in on, press Alt+A, set the Condition to your strategy or indicator and paste a message from the list below.
3. Under Notifications tick Webhook URL and paste the strategy's URL, `https://trades.nyria.io/webhooks/<your-strategy-token>`.
4. Back in Nyria, select Check format, then deploy a bot on Nyria Paper first and on the live account once the log reads the way you meant.

**Alert messages**

A strategy alert, one for every fill:

```json
{
  "action": "{{strategy.order.action}}",
  "instrument": "{{ticker}}",
  "marketPosition": "{{strategy.market_position}}",
  "prevMarketPosition": "{{strategy.prev_market_position}}",
  "contracts": "{{strategy.order.contracts}}",
  "price": {{close}}
}
```

A limit entry at the bar close:

```json
{
  "action": "OPEN",
  "instrument": "{{ticker}}",
  "direction": "LONG",
  "order_type": "limit",
  "price": {{close}}
}
```

Every message above is read back by Nyria's alert tester in [trading-alert-examples](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/tradingview/tradier), with the matching files for TrendSpider, Discord, Telegram, Python and webhooks.

**What the alert must say.** A ticker, a side and whether it opens or closes a position. For options it can add the strike, expiration and call or put, or leave them out and let the strategy pick the contract.

**What it can not do.** Set the size, because each bot sizes the order from its own budget per entry. Attach a stop or target, because Nyria sends market and limit orders only and exits come from exit alerts. Trade crypto at Tradier, which it does not carry through Nyria.

**What Tradier does with the order**

- Live accounts connect through Tradier's sign-in. Paper uses Tradier Sandbox credentials.
- Market and limit orders, for entries and exits. A spread goes as one order for all its legs.
- Day and Good till canceled go to Tradier as set. Tradier has no fill or kill, so a strategy set to Fill or kill sends Day.
- No fractional shares, and options in whole contracts.
- Tradier restricts market orders outside regular hours. Turn on Limit trading hours on the strategy to keep entries inside them.
- Short stock and short spreads need a margin account and the options level the trade requires.
- Tradier does not offer crypto, so a crypto alert places no order there. Use Alpaca or Nyria Paper for crypto.
- MODIFY works at Tradier, so a resting limit entry can be re-priced with a second alert.

More: [TradingView alerts to Tradier on nyria.io](https://nyria.io/automate/tradingview-to-tradier), [Tradier in the docs](https://docs.nyria.io/integrations/brokers/tradier).

### TradingView alerts to tastytrade

Connect tastytrade in Nyria, create a strategy with TradingView as the alert source, and paste the strategy's webhook URL into the alert. Each alert becomes an order in your tastytrade account.

**Connect it**

1. In Nyria, select Integrations, then the tastytrade card. Under Live trading select Connect live account.
1. Sign in at tastytrade and select Authorize. Nyria imports every account under the login, and you pick the one a bot trades.

**Wire the alert**

1. In Nyria, select Create strategy, pick TradingView as the alert source and choose the asset type (stocks or options).
2. In TradingView, on a paid plan with two-factor sign-in on, press Alt+A, set the Condition to your strategy or indicator and paste a message from the list below.
3. Under Notifications tick Webhook URL and paste the strategy's URL, `https://trades.nyria.io/webhooks/<your-strategy-token>`.
4. Back in Nyria, select Check format, then deploy a bot on Nyria Paper first and on the live account once the log reads the way you meant.

**Alert messages**

An options entry. The strategy's leg rules pick the contract:

```json
{
  "action": "OPEN",
  "instrument": "{{ticker}}",
  "direction": "LONG"
}
```

A multi-leg entry at a net price:

```json
{
  "action": "OPEN",
  "instrument": "{{ticker}}",
  "direction": "LONG",
  "order_type": "limit",
  "price": 1.50
}
```

Every message above is read back by Nyria's alert tester in [trading-alert-examples](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/tradingview/tastytrade), with the matching files for TrendSpider, Discord, Telegram, Python and webhooks.

**What the alert must say.** A ticker, a side and whether it opens or closes a position. For options it can add the strike, expiration and call or put, or leave them out and let the strategy pick the contract.

**What it can not do.** Set the size, because each bot sizes the order from its own budget per entry. Attach a stop or target, because Nyria sends market and limit orders only and exits come from exit alerts. Trade crypto at tastytrade, which it does not carry through Nyria.

**What tastytrade does with the order**

- Live accounts only, connected through tastytrade's own sign-in. The password goes to tastytrade and never to Nyria.
- Market and limit orders. A spread goes as one order for all its legs, priced as a net debit or credit when it is a limit order.
- Day and Good till canceled go to tastytrade as set. tastytrade has no fill or kill, so a strategy set to Fill or kill sends Day.
- Stocks in whole shares and options in whole contracts. Defined-risk spreads need options level 3 or higher at tastytrade.
- Crypto trading has been disabled through tastytrade's API since 29 June 2026. A crypto alert fails the entry with a crypto unavailable notice. Use Alpaca or Nyria Paper for crypto.
- MODIFY is refused at tastytrade. To re-price a resting entry, send CANCEL, then a new OPEN.

More: [TradingView alerts to tastytrade on nyria.io](https://nyria.io/automate/tradingview-to-tastytrade), [tastytrade in the docs](https://docs.nyria.io/integrations/brokers/tastytrade).

### TradingView alerts to Alpaca

Connect Alpaca in Nyria, create a strategy with TradingView as the alert source, and paste the strategy's webhook URL into the alert. Each alert becomes an order in your Alpaca account.

**Connect it**

1. In the Alpaca dashboard, switch to Paper or Live and select Generate New Keys. Copy the API key ID and the secret key; Alpaca shows the secret once. Give the key trading permission only.
1. In Nyria, select Integrations, then the Alpaca card, then Connect paper account or Connect live account. Select Accept and continue and paste both values.
1. A paper key works only on paper and a live key only on live, so the same strategy can run on both.

**Wire the alert**

1. In Nyria, select Create strategy, pick TradingView as the alert source and choose the asset type (stocks, options or crypto).
2. In TradingView, on a paid plan with two-factor sign-in on, press Alt+A, set the Condition to your strategy or indicator and paste a message from the list below.
3. Under Notifications tick Webhook URL and paste the strategy's URL, `https://trades.nyria.io/webhooks/<your-strategy-token>`.
4. Back in Nyria, select Check format, then deploy a bot on Nyria Paper first and on the live account once the log reads the way you meant.

**Alert messages**

A crypto entry on a crypto chart:

```json
{
  "action": "OPEN",
  "instrument": "{{ticker}}",
  "direction": "LONG"
}
```

The matching exit:

```json
{
  "action": "CLOSE",
  "instrument": "{{ticker}}",
  "direction": "LONG"
}
```

Every message above is read back by Nyria's alert tester in [trading-alert-examples](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/tradingview/alpaca), with the matching files for TrendSpider, Discord, Telegram, Python and webhooks.

**What the alert must say.** A ticker, a side and whether it opens or closes a position. For options it can add the strike, expiration and call or put, or leave them out and let the strategy pick the contract.

**What it can not do.** Set the size, because each bot sizes the order from its own budget per entry. Attach a stop or target, because Nyria sends market and limit orders only and exits come from exit alerts.

**What Alpaca does with the order**

- Alpaca connects with an API key, not a sign-in. Nyria stores the key encrypted at rest.
- Stocks, options up to 4 legs and crypto spot. Options trading must be turned on in the Alpaca account.
- Market and limit orders. Stock orders take the strategy's Duration as set. Option orders go to Alpaca as Day, and crypto orders as Good till canceled.
- Stocks in whole shares. Crypto trades in fractions, so a $100 entry with BTC at $64,000 buys 0.00156 BTC.
- US equities only. Alpaca restricts some order types outside market hours; turn on Limit trading hours on the strategy to keep entries inside them.
- MODIFY works at Alpaca, so a resting limit entry can be re-priced with a second alert.

More: [TradingView alerts to Alpaca on nyria.io](https://nyria.io/automate/tradingview-to-alpaca), [Alpaca in the docs](https://docs.nyria.io/integrations/brokers/alpaca).

### TradingView alerts to Nyria Paper

Nyria Paper is a simulated broker built into Nyria. Point a TradingView alert at a strategy and deploy a paper bot to watch each alert become a simulated order, with no broker and no card.

**Connect it**

1. In Nyria, select Integrations, then the Nyria Paper card, then Create Nyria Paper account.
1. It opens with a simulated balance and needs no broker, API key or card.

**Wire the alert**

1. In Nyria, select Create strategy, pick TradingView as the alert source and choose the asset type (stocks, options or crypto).
2. In TradingView, on a paid plan with two-factor sign-in on, press Alt+A, set the Condition to your strategy or indicator and paste a message from the list below.
3. Under Notifications tick Webhook URL and paste the strategy's URL, `https://trades.nyria.io/webhooks/<your-strategy-token>`.
4. Back in Nyria, select Check format and deploy a paper bot. The next alert becomes a simulated order.

**Alert messages**

A plain-text strategy alert:

```text
{{strategy.order.action}} {{ticker}} @ {{close}}
```

A short entry from an indicator:

```json
{
  "action": "OPEN",
  "instrument": "{{ticker}}",
  "direction": "SHORT"
}
```

Every message above is read back by Nyria's alert tester in [trading-alert-examples](https://github.com/Nyria-LLC/trading-alert-examples/tree/main/examples/tradingview/nyria-paper), with the matching files for TrendSpider, Discord, Telegram, Python and webhooks.

**What the alert must say.** A ticker, a side and whether it opens or closes a position. For options it can add the strike, expiration and call or put, or leave them out and let the strategy pick the contract.

**What it can not do.** Set the size, because each bot sizes the order from its own budget per entry. Attach a stop or target, because Nyria sends market and limit orders only and exits come from exit alerts.

**What Nyria Paper does with the order**

- Simulated end to end: no order reaches a broker or exchange and no money moves.
- Stocks, options (single legs and spreads up to 4 legs) and crypto spot.
- A market order fills at the ask to buy and the bid to sell, from the quote Nyria read when the alert arrived. A limit order fills or is refused at once against that quote.
- Options alerts are refused while the options market is closed, and the log says so. Stocks and crypto fill at any hour.
- There is no slippage, so paper results usually read better than a live account would on the same alerts.
- Nothing queues, so there is no working order to MODIFY or CANCEL.

More: [TradingView alerts to Nyria Paper on nyria.io](https://nyria.io/automate/tradingview-to-paper), [Nyria Paper in the docs](https://docs.nyria.io/integrations/brokers/nyria-paper).

## What alert formats does Nyria read?

There is no fixed template. A ticker, a direction and an action are enough.

| Format | Example | Where it is used |
|---|---|---|
| Plain text | `long SPY here`, `SPY long entry`, `Close short BTC` | Every source |
| Plain text, option | `BTO SPY 12/18 780C`, `SPY 780C buy to open` | Discord, Telegram, custom webhook |
| Minimal JSON | `{"ticker": "SPY", "action": "buy"}` | TradingView, TrendSpider, custom webhook |
| TradingView default strategy message | `{"action": "{{strategy.order.action}}", "instrument": "{{ticker}}", "marketPosition": "{{strategy.market_position}}", "prevMarketPosition": "{{strategy.prev_market_position}}", "contracts": "{{strategy.order.contracts}}", "price": {{close}}}` | TradingView strategies |
| Explicit JSON | `{"instrument": "SPY", "action": "OPEN", "direction": "LONG", "order_type": "limit", "price": 771.20}` | Custom webhook, TradingView indicators |
| JSON with option legs | `{"ticker": "SPY", "action": "OPEN", "direction": "LONG", "legs": [{"side": "CALL", "strike": 780, "expiration": "2026-12-18"}]}` | Strategies set to "Provided in alert" |

How `buy` and `sell` are read depends on the strategy. On a long-only strategy, `buy` opens a long and `sell` closes it. On a strategy that trades both sides, `buy` covers an open short and otherwise opens a long, and `sell` closes an open long and otherwise opens a short. To state the side explicitly, send `action` (`OPEN` or `CLOSE`) with `direction` (`LONG` or `SHORT`).

The `ticker`, `instrument` and `symbol` keys all mean the same thing. Field-by-field detail is in the [webhook payload reference](https://docs.nyria.io/webhook-reference).

## Can alerts trade options?

Yes. Options strategies can hold up to 4 legs, all on one expiration, which covers single calls and puts, verticals and iron condors. A spread goes to the broker as one order. Contracts come from one of two places:

- **From my rules**: the alert only says the direction, and the strategy's leg rules pick strikes and expiration (by delta, by a number of strikes from at-the-money, by target price or as an offset from another leg). TradingView options strategies always work this way.
- **Provided in alert**: the alert carries a `legs` array with one entry per leg, or a Discord or Telegram line such as `BTO SPY 12/18 780C`. See [examples/webhook](examples/webhook).

Calendars, diagonals and ratio spreads cannot be built, because every leg shares one expiration and one quantity.

## Can alerts trade crypto?

Crypto spot trades at Alpaca and on Nyria Paper. Charles Schwab and Tradier do not carry it, and tastytrade disabled crypto in its API on 29 June 2026. Send a crypto ticker such as `BTCUSD`, sized from the bot's budget per entry; crypto trades in fractions, so a $100 entry with BTC at $64,000 buys 0.00156 BTC. Crypto perpetual futures are simulated on Nyria Paper only. There are no exchange futures or forex.

## Paper first

Run every new alert through a paper bot before any live account sees it. Nyria Paper is a free simulated broker with no card and no time limit. Let the alerts fire for a few sessions and compare each order on the bot's log with the alert that caused it. Look for doubled alerts, missed alerts and readings that differ from what you meant. Move to a live bot only when they match, and start with a small budget per entry.

A paper fill shows that your alert was read and routed. It does not predict how a live fill would have gone.

## Limits

- Brokers: Charles Schwab, Tradier, tastytrade, Alpaca and Nyria Paper.
- Stocks, crypto spot and options up to 4 legs on one expiration. No futures or forex.
- Market and limit orders only. Nyria places no stop or target order at your broker; exits come from your exit alerts.
- `MODIFY` works on Tradier and Alpaca. Schwab and tastytrade refuse it.
- No daily-loss cap: a bot keeps taking alerts until you pause it.
- Nothing here is financial advice, and an automated order can lose money. Read the [risk disclosure](https://docs.nyria.io/risk-disclosure).

## What is in this repository

| Path | Contents |
|---|---|
| [examples/tradingview](examples/tradingview) | Alert message templates and the open-source Pine Script v6 "Nyria Alert Builder" |
| [examples/trendspider](examples/trendspider) | TrendSpider Alert and Strategy Bot bodies |
| [examples/webhook](examples/webhook) | `curl` and Python examples, including option legs, closes and order management |
| [examples/discord-telegram](examples/discord-telegram) | Message shapes Nyria reads in Discord and Telegram |
| [FAQ.md](FAQ.md) | Short answers to the questions traders ask most |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to add or fix an example |

## Docs

- [Automate TradingView alerts to your broker](https://docs.nyria.io/guides/automate-tradingview-alerts)
- [TradingView alert messages](https://docs.nyria.io/alerts/tradingview/messages)
- [Webhook payload reference](https://docs.nyria.io/webhook-reference)
- [Send alerts from your own bot](https://docs.nyria.io/alerts/custom-webhook)
- [Choose an alert source](https://docs.nyria.io/alert-sources)
- [Multi-leg options strategies](https://docs.nyria.io/strategies/multi-leg-options)
- [TrendSpider](https://docs.nyria.io/alerts/trendspider), [Discord](https://docs.nyria.io/alerts/discord) and [Telegram](https://docs.nyria.io/alerts/telegram)
- [Paper trading](https://docs.nyria.io/paper-trading)
- [Alert tester](https://nyria.io/tools/alert-tester) and [TradingView alert message builder](https://nyria.io/tools/tradingview-alert-builder)

## Built for Nyria

The examples in this repository target [Nyria](https://nyria.io), a service that reads alerts from these sources and places the orders in your broker account. The message shapes follow its docs, so they will not match other tools unchanged. The examples are MIT licensed, and issues and pull requests are welcome; see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE)
