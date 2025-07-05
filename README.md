# Meta-trader-trading-bot-mq5
A pre Run of my strategy

# Bullish Continuation Trading Strategy (MT5 EA)

This repository contains the logic for a MetaTrader 5 (MT5) Expert Advisor (EA) designed to identify and execute bullish continuation trades based on a combination of technical indicators and candlestick patterns.

## 📈 Strategy Overview

The EA enters **buy trades** based on the following **bullish continuation** criteria:

1. **Bullish Candlestick Pattern**  
   One of the following bullish candlestick formations must occur:
   - Bullish Engulfing
   - Bullish Cross
   - Bullish Harami

2. **Price Above Key Moving Averages**  
   The bullish candle must **close above both the EMA 50 and EMA 200**.

3. **Stochastic Oscillator Confirmation**  
   The Stochastic Oscillator’s **%K and %D lines must cross upward and close above level 20**, indicating momentum exiting the oversold area.

## ✅ Trade Entry

- Once **all three conditions** are met,
- The EA executes a **buy trade on the next candle** after the confirming bullish candle.

## 🔧 Requirements

- MetaTrader 5 platform
- Symbols/timeframe: Optimized for **5-minute (M5)** chart
- EMA and Stochastic indicators must be enabled in the chart environment

## ⚠️ Disclaimer

This strategy is for educational and testing purposes only. Past performance does not guarantee future results. Always test with a demo account before going live.

---