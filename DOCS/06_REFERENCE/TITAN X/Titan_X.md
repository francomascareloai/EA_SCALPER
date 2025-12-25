*Please Note : These settings are based on your local VPS time (Max Daily Loss Equity Protector and Schedule Settings). See how to set your VPS time here.

**Also Please Note : If you make any deposit to your account during market hours, this can cause you to hit your Weekly Goal, Equity Protector, Account SL or TP prematurely. To avoid this, please wait until the weekend when the market is closed to deposit funds and click the RESET button for whatever Global Setting feature you’re using. 

If you need to deposit funds during market hours please follow these steps : 

1. Disable AutoTrading
2. Click the RESET button on the chart to reset the Weekly Start Balance
3. Turn AutoTrading back ON to resume trading

# Titan X (Reference)

## Deep Study (our notes)

**Study folder:** `DOCS/06_REFERENCE/TITAN X/2025-12-25_deep-study/`

- Manifest: `DOCS/06_REFERENCE/TITAN X/2025-12-25_deep-study/MANIFEST.md`
- Synthesis: `DOCS/06_REFERENCE/TITAN X/2025-12-25_deep-study/SYNTHESIS.md`
- Integration Round 2 (adaptation plan):
  - `DOCS/06_REFERENCE/TITAN X/2025-12-25_integration-round2/SYNTHESIS_round2.md`
  - `DOCS/06_REFERENCE/TITAN X/2025-12-25_integration-round2/CRUCIBLE_round2.md`
  - `DOCS/06_REFERENCE/TITAN X/2025-12-25_integration-round2/FORGE_round2.md`
  - `DOCS/06_REFERENCE/TITAN X/2025-12-25_integration-round2/SENTINEL_round2.md`
  - `DOCS/06_REFERENCE/TITAN X/2025-12-25_integration-round2/CRITIC_gate.md`
  - `DOCS/06_REFERENCE/TITAN X/2025-12-25_integration-round2/ARGUS_spotcheck.md`
- Agent outputs (Round 1 deep study):
  - `DOCS/06_REFERENCE/TITAN X/2025-12-25_deep-study/CRUCIBLE_output.md`
  - `DOCS/06_REFERENCE/TITAN X/2025-12-25_deep-study/SENTINEL_output.md`
  - `DOCS/06_REFERENCE/TITAN X/2025-12-25_deep-study/FORGE_output.md`
  - `DOCS/06_REFERENCE/TITAN X/2025-12-25_deep-study/CRITIC_output.md`

---

SECTION 1 : BASIC SETTINGS

License Type : There are two separate options for this : 

1. Standard : This is your standard license which you can use on either a demo or a live account. When this License Type is selected, make sure the “Titan X Tool - MT4/MT5 Trading Account Number” in your client area matches the account number for the demo or live account you’re using.

2. Demo Only : This is your second demo license which only works on demo. When this License Type is selected, make sure the “Titan X Tool DEMO - MT4/MT5 Trading Account Number” in your client area matches the account number for the demo account you’re using.

Allowed Trade Direction : If you want to only place buy or sell trades or both, you can control that with this feature. 

Starting Lot Size Type : There are two ways you can determine your starting lot size : 

1. Fixed lot size. For example you may want ladders to start with 0.01 lots which you will input for the LS Amount.

2. Risk Level will automatically determine a starting lot size based on your account balance and leverage. 0-1 is lower risk, 2-3 is medium risk and 4+ is high risk. The calculation for this is Lot size = ((current account balance * account leverage/contract size) * Risk)/100))/10.

LS Amount : This input value is the lot size for level 1 trades. If price moves against the original position, then additional levels of trades will open at possibly a higher lot size according to the Lot Size Multiplier.

Starting Lot Size Video Explanation

..Auto-Scale : This can be used for automatic compounding. For example if you want to use a 0.01 lot size per every $2000 then you could set Auto-Scale to true, Starting Lot Size to 0.01 and enter 2000 for the Per Cash Amount setting below. This means for every 2000 in your account the lot size will increase by 0.01. For example if you start with $10,000 then your starting lot would automatically be 0.05 and once your account balance reaches $12,000 then your starting lot would automatically increase to 0.06. 

….Per Cash Amount : This is used for the Auto-Scale feature above and is the base cash amount used for the Auto-Scale feature along with the Starting Lot Size. 

Lots Multiplier : This is used to determine the lot size for trades after level 1. It works by multiplying the previous level’s lot size by the Lots Multiplier value. For example, if your Starting Lot Size is 0.01 and your Lots Multiplier  is 2.0, then if price moves against my initial entry position by the Pip Step amount, then the lot size for the next level trade, level 2 will be 0.01 * 2.0 = 0.02, then if price moves further against that trade, then the next level trade will be 0.02 * 2.0 = 0.04 etc. 

Please Note : 

The result of the lot multiplier calculation sometimes must round up or down due to the fact that lot sizes can only have two after the decimal place. For example, if your Starting Lot Size is 0.01 and your Lots Multiplier  is 1.5, then the lot size for the next trade will be 0.01*1.5 = 0.015. This value is an invalid lot size value since the lot multiplier calculation results in three numbers after the decimal place, so the lot size must round up to 0.02. 

Also, when using the lot multiplier the next trade will always increase by at least 0.01. So another example, if your Starting Lot Size is 0.01 and your Lots Multiplier  is 1.1, then the lot size for the next trade will be 0.01*1.1 = 0.011. Normally this would round down to 0.01, but because it is equal to your Starting Lot Size, 0.01, it must instead increase by at least 0.01 so the result will be 0.02 lots. 

Lots Multiplier Video Explanation

….LSM Interval : This is the interval in which the Lot Multiplier is applied. For example the default value 1 means the Lot Multiplier is applied at every level. For example if the Lot Multiplier is set to 1.5 the lot sizes will be 0.01, 0.02, 0.03 etc.with the Lot Multiplier multiplying every 1 level.  However, if the interval is set to 3 for example, then the lot sizes will be 0.01, 0.01, 0.01, 0.02, 0.02, 0.02, 0.03, 0.03, 0.03 etc. with the Lot Multiplier multiplying every 3 levels. 

..Max Lot Size : This is the maximum lot size that could be placed for any single trade. If this maximum lot size value is reached then Titan will continue to open trades at the Max Lot Size value, but never greater. In other words, the Lot Size Multiplier will not be applied once the Max Lot Size has been reached. For example say your Max Lot Size is set to 1.00, then say your level 6 trade is 0.80 and your Lot Size Multiplier is set to 1.5, so the level 7 trade should open 1.20 lots, but since the Max Lot Size is set to 1.00 then at level 7 only 1.00 lots will open and level 8 also 1.00 lots, level 9 1.00 etc. until finally the ladder is closed.  

Pip Step Type : Here you can select which type of pip step you want to use. There are 4 type : 

1. Fixed means your Pip Step will not change. It will be fixed at your input value that you set for the Pip Step. 

2. Dynamic means your Pip Step will recalculate after every new trade is opened based on the current volatility of the pair that you’re trading. 

3. Time Based means that the distance between trades will be based on time rather than a pip amount. 

4. Stacked means that the Pip Step will apply as price moves in either direction, drawdown or profit. In other words, trades can be stacked above and below the original entry, Also, the Lot Size for the next trade is determined based on the trade farthest away and the LS Multiplier is applied to that trade. (For further details and examples see PS Amount below).

Fixed Pip Step Video Explanation
Dynamic Pip Step Video Explanation

..PS Amount : The input value here is either used as the Pip Step or DPS Divider or Time (in minutes) depending on which Pip Step Type is selected (Fixed, Dynamic, Time Based or Stacked). 

If you select Fixed above for the Pip Step Type then this value will be used as the Pip Step. This is the distance between trades. For example, if your Pip Step is set to 21 this means that if price moves 21 pips against your initial entry position, then Titan will cost average and open the next trade level. And if price continues to move against you, then after 21 pips, the next trade level will open. This is assuming your Pip Step Multiplier is equal to 1, otherwise the Pip Step would be multiplied for each new level.  

If you select Dynamic for the Pip Step Type then there is a simple calculation that will calculate your Pip Step and it will recalculate after each new trade is opened. To see what your Current Pip Step is, you can view it on the display on your chart. 

The calculation for Dynamic Pip Step takes the average of the ATR(3) value for each of the following timeframes :  H1, H4, D1 and W1 and then divides that number by the DPS Divider value inpout to yield the Current Pip Step which again, is also displayed on your chart. If you input a higher number for the Dynamic Pip Step, your Current Pip Step will decrease. If you input a lower number for the Dynamic Pip Step, your Current Pip Step will increase. 

The nice thing about having a Dynamic Pip Step is that it will dynamically update your Pip Step according to the current volatility of the specific pair that you’re trading. For example, a pair like GBPJPY tends to move much “faster” or more volatile compared to a pair like EURUSD. If GJ has the same pip step as EU then GJ would theoretically open up more trades much more quickly than EU and as a result could expose the account to much more drawdown even if both pairs have the same settings. With Dynamic Pip Step, this solves that problem, because it factors in the most recent volatility. So it will automatically increase GJ’s pip step realtive to EU’s pip step since GJ is a relatively more volatile pair. 

See The Fixed & Dynamic Pip Step Video Explanations Above.

If you select Time Based this means that the distance between trades will be based on a time interval rather than a distance in pips. For example if you enter 21 for the PS Amount it means that after 21 minutes, the next trade in the ladder will be placed. This is best used with the Floating Baskets rather than using a TP. 

If you select Stacked this means that trades will open as price moves into profit or drawdown according to the PS Amount you input. For example, say your starting lot is 1.00 and LS Mutliplier is 2.0. If you enter 21 for the PS Amount it means that if price moves 21 pips into profit, then Titan will open a 2.0 lot trade (trade farthest away * LS Multiplier). Then if price moves 42 pips in the opposite direction so 21 pips against the original entry, then Titan will open a 4.0 lot trade etc. 

Pip Step Multiplier : This input value is applied to the Pip Step. For example, if your Pip Step is 21 and your Pip Step Multiplier is 2.0, this means that as price moves against your initial entry, the distance between the level 1 and level 2 trades will be 21 pips, then if price continues to move against those trades, the distance between the level 2 and level 3 trades will be 21 pips * 2.0 = 42 pips etc. 

Pip Step Multiplier Video Explanation

Max Levels : This is the max number of trade levels allowed or in other words the maximum number of times allowed for Titan to cost average. For example if you enter 12, then Titan is only allowed to be in 12 levels at once, so instead of getting into the 13th level in the sequence, Titan will stop placing new trades for that pair/chart until that ladder closes. 

Max Levels Video Explanation

SECTION 2 : ENTRY SETTINGS

*Please note if all Entry Settings are set to false, then Titan cannot place trades because there is no entry criteria defined. If you have more than one setting set to true then all criteria need to be met for a trade to be placed. 

Use Bi-Directional Mode : If this is set to “true” then Bi-Directional Mode will be activated. If kept at “false”, Bi-Directional Mode will not be used. The way it works is when activated, Titan will be allowed to open trades in both directions (buys and sells) at the same time. The best way to think of it is like you have two EAs functioning independently in opposite directions. So if you have your basic settings set to a 0.01 starting lot size and 1.21 pip step, then you will have both sells and buys trading at the same time according to these settings. However you won’t always be in the same number of trades or “levels” in both directions. For example, if price goes up then buy trades will continue to take profit and open as long as price continues up. Meanwhile the sell trades will cost average according to the pip step and will be in drawdown until price finally retraces enough to hit TP and close the ladder. The cool part about this is that no matter which way the market goes, up or down, you can be banking profits and offsetting drawdown while Titan is cost averaging in the opposite direction!

Bi-Directional Mode Video Explanation

..BD Start Level : If you only want Bi-Directional Mode to turn on after a ladder is in x levels of drawdown, you can define that here. 

Use Ghost Trades : Set this to “true” to activate the Ghost Trades feature. The purpose of Ghost Trades are to minimize risk and optimize entries. Basically the way it works is the Ghost Trades are like virtual trades being taken in the background as a way to “monitor” the market for sniper entries. It could also be described as a “trend exhaustion indicator” depending on how you use it. Because with Ghost Trades you can avoid starting ladders at the beginning of a trend which can lead to huge drawdown. 

You can see the Ghost Trades running in the background visually on your chart. Blue horizontal lines represent buy trades, red horizontal lines represent sell trades, and green horizontal lines represent take profit. 

You can also see on your chart display the total number of GT current levels. 

PLEASE NOTE : When using mutlipair testing with Ghost Trades in the MT5 tester the front pair in the tester settings must match the first pair listed in the Currencies to Trade for most accurate results.

..GT Pip Step : This is the pip step used for Ghost Trades.

..GT TP : This is the take profit used for Ghost Trades. Once the TP is hit, the Ghost Trades will reset in that direction. The TP is calculated based on the breakeven point which is exactly halfway between the first and last trade in the GT ladder. Then the TP is placed beyond that according to the GT TP value. 
..GT Levels : This is the max levels of Ghost Trades allowed. Once this max level is reached, it will trigger a real trade. 

..GT Entry Direction : This will determine which direction will be used for the real trade. If set to Trend then the real trade will be placed in the same direction as the GT ladder that triggered it. If set to Counter Trend then the real trade will be placed in the opposite direction as the GT ladder that triggered it. 

Use Candlestick Filter : Set this to “true” to activate the Candlestick filter. The Candlestick Filter looks at the most recent candle close on the CSF Timeframe. If it closed bullish, Titan will look for buys. If it closed bearish, Titan will look for sells. 

..CSF Start (levels) :  For example if this is set to 5 it means the CSF will only be used after level 5 so for the level 6 trade it will need to wait for a CSF entry signal. 

..CSF Timeframe : For example, if this is set to H1 and the most recent candle closes bearish, then Titan X will look for a bearish candle close on the current timeframe to match the most recent candlestick bias on the higher timeframe and enter a sell. 

..CSF Type : There are a few different options for how you can use the Candlestick Filter. 

1. Start Trades means Titan will only wait for candlestick entry signals for level 1 trades. The rest of the trades in the ladder will not wait for an entry signal and will be placed according to the Pip Step settings. 

2. All Trades means Titan will wait for candlestick entry signals for all trades including both start (aka level 1) trades and cost averaging trades (level 2 and beyond). 

3. CA Trades means Titan will wait for canndlestick entry signals for cost averaging trades (level 2 and beyond) only. 

*Please note when using the Candlestick Filter and setting it to All Trades or CA Trades the distance between trades in a ladder can be larger than your Pip Step unless there is a Candlestick Entry signal present exactly when the Pip Step distance is realized which is unlikely. So in that case the Pip Step becomes more like a minimum distance between trades until a candlestick entry signal is present.  

Candlestick Filter (aka Signal For Entries) Video Explanation

Min Time Between CA Trades : This is the minimum time between cost averaging trades (level 2 and beyond. This becomes especially useful to avoid becoming over exposed due to sharp spikes in the market. For example, during news or when using a smaller pip step. 

Minimum Time Between Trades Video Explanation

Use MA Filter : Set this to “true” to activate the MA Filter.

..MA Entry Delay : This feature is designed to avoid over-exposure in a single direction. So if MA Entry Delay is set to true, then it means that once the MA entry criteria has been met in a direction, either buy or sell, only 1 ladder is allowed to open in that direction and another new ladder cannot open in that same direction until the entry criteria for the opposite criteria has been met first. 

For example for buys (and vice versa for sells), if 2 MAs are being used, then a new buy ladder will not open until the 2 MAs have crossed (i.e. the smaller MA crosses below the larger MA) and then crosses back again. 

Also in the same way, if 3 MAs are being used, then a new buy ladder will not open until the 3 MAs have crossed (i.e. the smaller MA crosses below the medium and crosses below the larger) and then crosses back again. 

And finally if only 1 MA is being used then a new buy ladder will not open unless the previous candle has closed below the MA. 

..MA Method : Set this to “exponential” or “simple” depending on which MA method you’d like to use. 

..MA Timeframe : MA is short for Moving Average which is calculated based on the average price over a given period or number of candles on any given timeframe. So this calculation will vary across timeframes.  If you want to use MAs based on your current timeframe, you can leave this set to “current''. 

..MA 1,2,3 : You can use up to 3 MA values. For example you might want a “fast” (smallest value), “medium” (middle value) and “slow” (largest value) MA. If using all 3 values, when the fast and medium values are above the slow value, Titan will look for buys. If both are below, Titan will look for sells. And if the slow value happens to be between the fast and the medium values, no trades would be taken. 

Or if you’d only like to use 2 of the 3 possible MA values just set one of them to 0. And similarly, if the fast value is above the slow value Titan will look for buys and if below, Titan will look for sells. 

Or if you’d like to use only 1 of the 3 possible MA values, just set the other two to 0. And if price is above the single MA, Titan will look for buys and if below, Titan will look for sells.   

..MA Entry Direction : If set to Trend then Titan will function that same way as described above. However if set to Counter Trend then Titan will function the opposite way. For example if the fast and medium value are above the slow value, instead of buys Titan will look for sells. And if below, Titan will look for buys. 

Use RSI Filter : Set this to “true” to activate the RSI filter. 

..RSI Timeframe : The RSI is an oscillator or a momentum indicator that can show when a market is overbought or oversold. The RSI calculates based on the price data of any given timeframe. The higher timeframes tend to give less false signals whereas the higher timeframes tend to be more accurate. 

..RSI Period : The period is how many candles back the RSI should calculate for any given timeframe. A higher period value will move less and give less, but more accurate signals whereas a lower period value will give more but less accurate signals. 

..RSI Upper Limit : If the RSI Entry Direciton is set to Counter Trend, then the RSI must close above this value for a new sell ladder to open. If set to Trend, then the RSI must close above this value for a new buy ladder to open. 

..RSI Lower Limit : If the RSI Entry Direciton is set to Counter Trend, the RSI must close below this value for a buy ladder to open. If set to Trend, then the RSI must close below this value for a new sell ladder to open. 

..RSI Entry Direction : This will determine the direction of the trade when the RSI Upper/Lower Limit is reached. 

Use Max Charts : Set this to “true” to activate the Max Charts feature. 

..Max Charts : This is the maximum number of charts that can have open trades at the same time. For example if Max Charts is set to 3, and a 4th chart/pair is trying to open a trade, it will be rejected and the Ghost Trade data will be reset. We developed this feature with Entry Settings in mind. The trade-off to having better entries and more strict entry criteria is that although it can reduce drawdown significantly, it will also reduce trading frequency which often results in less profits. With Max Charts however, it allows you to use stricter entry criteria to help reduce drawdown AND trade more pairs so you can make more profits while still controlling total maximum exposure. For example you could load up all 28 pairs to maximize entry opportunities but keep Max Charts set to 3 so your account doesn’t trade too many pairs at once which can be much more risky. You can see how many charts are being used on your chart display. It will say “Max Charts 2 / 3” etc. 

Use Spread Filter : To use the Spread Filter, this must be set to “true”. 

..Maximum Allowed Spread : For example, if you set this value to 50 this means that if the current spread at the time of the trade is greater than or equal to 50 then Titan will SKIP the trade entirely. To view the current spread, locate the Market Watch window and right click and select “Spread”. 

Spread Filter Video Explanation

Order Comment : Enter anything you like! Or not! This will be used as a “comment” on each trade placed by Titan so that you can easily identify which trades are placed by Titan and which trades are placed manually or from other sources. This setting is entirely optional and can be left blank if you don’t want to use it.

Order Comment Video Explanation
 
SECTION 3 : TAKE PROFIT SETTINGS

Take Profit (All Trades) : Take Profit input value equals the distance (in pips) from the break even point. For example, let’s say you have TP = 4. The distance between the entry price of the first trade in a ladder and the TP would be 4 pips. However, as Titan begins to open cost averaging trades, the TP will modify to 4 pips beyond the breakeven point (typically somewhere in between the first and last trade taken in any given ladder of cost averaging trades). So, the more cost averaging trades that open, the more valuable those same 4 pips of profit become because of the increasing volume of total lots being traded. 

Take Profit Video Explanation

Use Account Take Profit : Set this to “true” to activate the Account Take Profit feature. This feature is particularly useful for trading a prop firm challenge because this way you can tell Titan to stop trading as soon as you’ve reached your profit objective. 

..Account TP : When the account’s equity equals this input value, then Titan will close all trades. You can see the distance to your Account TP at any time on your chart display. 

Use Profit Basket : Set this to “true” to activate the Profit Basket feature. 

..PB Goal : The PB Goal value you input represents the amount of profit you want to “collect”. Please note this value considers both floating and realized profit/loss based on the PB Start Balance (dsiplayed on the chart which you can also reset using the button if needed). Once this PB Goal target is reached, Titan will close all trades and turn AutoTrading off. If you want Titan to resume AutoTrading after reaching the PB Goal, see below..

..Auto Reset : If set to “true” this means Titan will reset the PB Goal automatically and resume trading once the Profit Basket Goal is reached. This way Titan will continue “filling baskets of profit” automatically each time the Profit Basket Goal is reached without you having to manually resume AutoTrading. 

Use Floating Baskets : Set this to “true” to activate the Floating Baskets feature. This will automatically disable the Take Profit so that all profits will be controlled by the Floating Baskets instead. 

..FB Directional Based : If set to true then Titan will calculate profits in each direction separately. This can be useful when Bi-Directional Mode is set to true. For example if your FB Goal is 200 then once buys reach $200 profit, then only the buy trades will close. (And vice versa for sells). 

..FB Type : This is the type of Floating Basket that will be used. And the FB Goal will be applied based on this input. There are three FB Types :

1. Pair $ means once the floating profits on that single pair reach the FB Goal amount, all trades on that pair only will close

2. Account $ means once the account’s floating profits reach $250 then all trades on all pairs on the account will close.

3. Account % means once the account’s floating profits equals 5% of the account balance, then all trades on all pairs on the account will close. 

This way users can select if they want the FB Goal to be calculated based on the floating profits on a single pair (select Pair), or the account as a whole (select Account) or as a percentage of the account as a whole (select Account %). See examples for each below in the FB Goal explanation. 

..FB Goal : This value is the amount of floating profit you want to collect. It is a cash amount for the Pair and Account FB Type, but if Account % is selected, then this value would be a %. For example if “Pair” is selected for the FB Type and you enter 250 for the FB Goal it means once the floating profits on that single pair reach $250 all trades on that pair only will close. If “Account” is selected for the FB Type and you enter 250 for the FB Goal it means once the account’s floating profits reach $250 then all trades on all pairs on the account will close. And finally if “Account %” is selected for the FB Type and you enter 5 for the FB Goal it means once the account’s floating profits equals 5% of the account balance, then all trades on all pairs on the account will close. 

Also, you can see how far away you are from reaching the FB Goal at any time by referencing the “Margin to FB” on your chart display. 

..FB Start : This is a trailing stop loss function but based on floating profits instead of a pip amount. So the FB Start is the trigger and the FB Stop is how much Titan will trail by. For example if the FB Start value is 250 and the FB Stop value is 250, then this means once floating profits reach $250 then Titan will begin locking in profits. You can see how much profit you have locked at any time by referencing “FB Profits Locked” on your chart display.

..FB Stop : This is kinda like an invisible stop loss, it’s how much Titan will trail by after the FB Start has been triggered. You can always see where this “invisible stop loss” is set by referencing “FB Profits Locked” on your chart display. So as your floating profits increase past your FB Start value, the FB Stop will lock in more and more profits always trailing by the FB Stop amount. For example (assuming you have FB Type set to Pair or Account) if you have FB Start set to 250 and FB Stop set to 20, then once floating profits reach 250, you will already have locked in $230 profit so if your floating profits never increase past 250, worst case you will end up with $230 of profit. And if your profits continue to go past 250, say up to 280, then you will have $260 worth of profits locked in. And when your floating profits drop from there to 260, then all trades on the Pair or Account (based on your FB Type) will close. 

..Auto Reset : If set to “true” this means Titan will reset the FB Goal automatically and resume trading once the FB Goal is reached. This way Titan will continue “filling baskets of floating profit” automatically each time the FB Goal is reached without you having to manually resume AutoTrading. 

Use Weekly Goal : If this is set to “true” then the Weekly Goal function will be activated. 

..WG (%) : For example, if you set this to 5 this means once your Weekly Floating % equals 5% then all trades will close. Weekly Floating % is calculated based on your Weekly Starting Balance and considers both floating and realized profit/loss for the week. The Weekly Starting Balance will reset at the beginning of each new trading week and the Weekly Floating % will also adjust to reflect this. 

Please Note : 

The Weekly Goal is based on the “Weekly Floating %” which is based on the “Weekly Start Balance”. You can see all these values on your chart display. The Weekly Start Balance is your account balance at the beginning of the week when the market opens, and it should automatically reset each week. 

If you notice that the “Weekly Start Balance” is inaccurate for any reason, you can always reset it by clicking the grey “Reset” button and this will trigger a pop up which will confirm that you are about to reset your “Weekly Start Balance”.

Weekly Goal Video Explanation

Use Daily Goal: Set this to “true” to use the Daily Goal function. 

..DG Type : You can set this to Account $ or Account %. Account $ means that the DG Amount will be based on a cash amount so that when the account equity reaches that amount, all trades will close. Account % means that the DG Amount is based on a % of the account. So for example if I set this to 1% it means once my Daily Floating (which appears on the display) reaches 1%, then all trades will close. 

..DG Amount : This is the value that is used based on the DG Type you select. 

SECTION 4 : STOP LOSS SETTINGS

Stop Loss (Each Trade) :  This just means that each position will have a fixed SL of whatever the value is set to in pips. If set to 0.0 then no SL will be placed. If set to 100 then each trade will have a stop loss of 100 pips. This can also be useful for trading with prop firms to make your account more unique. You can set this value to any random number large enough to not get in the way of your trading strategy as a way to make your trades more unique compared to someone else running the same strategy or set file. 

Use Account Stop-Loss : To use the Account Stop-Loss function set this to “true”. 

..Account Stop-Loss : The Account Stop-Loss input function means that the account equity must not, at any time, fall below the Account SL input value. 

Titan will close all trades and stop trading until the user manually adjusts this input value and resets Titan on the chart.

You can quickly see the “distance” to your Account Stop-Loss input value or as we call the amount of “Margin to Account SL” on the display. 

Account Stop-Loss Video Explanation

Use Trailing Stop Loss : Set this to “true” to activate the Trailing Stop Loss feature. 

..TSL Type : There are a couple of different trailing stop types :

1. Start Trades : This means that the trailing stop loss will only be triggered for level 1 trades. All other trades level 2 and beyond will function normally without a trailing stop loss. 

2. All Trades : This means that the trailing stop loss will trail ALL trades including cost averaging trades and not just start trades. For example, if there are 3 levels of trades open in a ladder, there is a breakeven point somewhere between those 3 levels of trades. So with the TSL Type set to All Trades, Titan will create a general stop loss to trail ALL 3 levels of trades, not only the start/level 1 trade. By trailing all trades, this has much more profit potential since you will be trailing price with more lots (more $/pip) compared to only trailing start trades. On the other hand, these cost averaging trades are typically how the system makes the most profit, so if your trailing stop is too tight, then you might miss out on profits you would've otherwise made had you kept the TSL off or only used TSL on start trades.

..TSL Start : Trail Start is the number of pips past the breakeven point that the trailing stop loss will trigger.

*Please Note : The Take Profit must be greater than the Trail Start for this to work properly otherwise the TP will always hit before the Trail Start is triggered.  

..TSL Stop : Trail Stop is the number of pips that the trailing stop loss will trail price.

For example, say your Trail Start is set to 4. And your Trail Stop is set to 3. Then, once the price reaches 4 pips profit, the trailing stop will trigger and it will trail price by 3 pips thus "locking in” 1 pips profit with unlimited upside profit potential as long as price doesn't retrace 3 pips and hit the stop loss. 

Another example. Say you set Trail Start to 5 and Trail Stop also to 5, then once the trailing stop triggers, the worst case is you would break even on the trade, whereas best case is you would be able to capture unlimited more profit than your fixed Take Profit amount.  

..TSL Interval : This can be used to define how frequently you want the TSL to move. For example if you set the TSL Interval to 10, and your Trail Start is 10 and Trail Stop is 5. Then it means Titan will trigger the TSL at the Trail Start and then will wait to move the SL until 10 pips profit beyond that before moving the stop loss again. And Titan will only move your stop loss in 10 pip increments after that instead of every tick. So in this example Titan would wait until 20 pips profit and then would move the SL to 15 pips. And then Titan would wait again until 30 pips profit and then would move the SL to 25 pips etc.

..Delete TP When TSL Starts : If this is set to “true” then the function will be activated. This means when the trailing stop is triggered, it will delete the Take Profit. This is useful because it leaves your profit potential uncapped.

Use Equity Protector : If set to “true” this means the Equity Protector and it’s correlated functions will be used.

..EP Type : This is the type of Equity Protector that will be used. And the EP Amount will be applied based on this input. There are three EP Types :

1. Floating Loss means when the account’s open P/L is equal to the EP Amount, then all trades will automatically close.

Based on Floating Loss EP Video Explanation

2. Account % means when the account’s floating loss is equal to 20% of the account balance, all trades will automatically close. And finally if EP Type is set to “Max Daily Loss”, this 

Based on Percent EP Video Explanation

3. MDL Balance is based on the FTMO “Maximum Daily Loss” limit and is based on CE(S)T. During the summer CE(S)T is GMT+1, during the winter it is GMT+2. Make sure your VPS local time is set to CE(S)T since all time-based inputs are based on the VPS local time. The nice thing about this is that you won’t have to worry about daylight savings time since your VPS should adjust for this automatically. 

This way FTMO calculates the “Maximum Daily Loss” limit = Day’s Closed Profit/Loss + Floating Profit/Loss. This could also be called Daily Floating and it is measured from 00:00 CE(S)T - 23:59 CE(S)T. This means it resets everyday at midnight CE(S)T. 

So, users will enter their own Max Daily Loss input value which means, once the Daily Floating = EP Amount  input value, then all trades will close on the account.

You can easily see your current Daily Floating on Titan’s display which uses the same formula :

Daily Floating = Closed Profit/Loss (from midnight to midnight) + Floating Profit/Loss. 

Please Note : All trades will close at 23:45 IFF the floating loss on the account is greater than the EP Amount for the Max Daily Loss. This is to avoid an automatic fail when the Max Daily Loss resets for the new day. 

4. MDL Equity works much the same as MDL Balance except everyday at midnight Titan will check the current equity on the account and this will display on the chart display as the “Daily Start Equity”. The Daily Floating would then be based on the Daily Start Equity and once the Daily Floating reaches the EP Amount value, then Titan will close all trades.

5. MDL Highest Value works much the same as MDL Equity and MDL Balance except everyday at midnight Titan will check the current equity or balance on the account and this will display on the chart display as the “Daily Start Balance/Equity”. The Daily Floating would then be based on the Daily Start Balance/Equity and once the Daily Floating reaches the EP Amount value, then Titan will close all trades. 

Traders should make themselves aware of the drawdown rules for the specific prop firm they’re trading with and which of the EP’s to use. To help here’s a guide for 3 of the most popular prop firms we use with Titan X and which EP Type fits best: 
●	FTMO = MDL Balance
●	TFF = MDL Equity
●	MFF = MDL Highest Value

..Auto-Resume : There are 3 types of Auto-Resume options to choose from : 

1. Next Day : After EP is hit, this will automatically resume trading the next day. (After midnight according to your VPS local time). 

2. Immediately : This will immediately resume trading after EP is hit. 

3. False : This will NOT auto-resume trading after EP is hit. Only if the user manually resumes it. 

SECTION 5 : DD MANAGEMENT SETTINGS
Please Note : *These settings are based on your local VPS Time

Use Yoga Mode : If this is set to “true” then Yoga Mode will be activated. The idea behind this function is to control drawdown by giving Titan “breathing room” for when drawdown gets too high. 

..Yoga Type : For this input there are two options : 

1. Account % - This means the Yoga Start and Yoga Stop inputs will be based on a % of the account’s floating loss. 

2. Account $ - This means the Yoga Start and Yoga Stop inputs will be based on a $ amount of the account’s floating loss. 

..Yoga Start : This is the trigger for Yoga Mode to turn ON. 

For example, if you enter 1250, and you have selected Account $ for Yoga Type this means once the floating loss reaches -1250 Yoga Mode will turn ON. (You can see when Yoga Mode is ON/OFF on your chart display). Or if you have selected Account % for Yoga Type and the Yoga Start value is set to 10, this means once the floating loss reaches -10% Yoga Mode will turn ON.This means that Titan will continue trading all pairs normally until TP is reached. 

Once any pair reaches TP while Yoga Mode is still ON Titan will pause trading on that pair and will not open any new level 1 trades until the Yoga Stop level is reached. 

You may see trades continue to open while Yoga is ON but that is because Titan will continue to manage existing ladders while Yoga is ON. It is only once TP is hit will Titan pause trading and will not open any new ladders until Yoga is OFF. 

..Yoga Stop : This is the trigger for Yoga Mode to turn OFF. 

For example, if you enter 750, and you have selected Account $ for Yoga Type this means once the floating loss reaches -750 Yoga Mode will turn OFF. Or if you have selected Account % for Yoga Type and the Yoga Start value is set to 10, this means once the floating loss reaches -10% Yoga Mode will turn OFF. This means Titan will resume trading all pairs normally again. 

Yoga Mode is different from Lipo Mode and Amp Mode which are designed to take losses on positions accumulating drawdown in order to protect the account. Instead, Yoga Mode will simply stop trading on pairs once they hit their TP while freeing up margin for the pair or pairs that are in more significant drawdown. This way those runaway pairs have a little more “breathing room” or “runway” to hit TP without the risk of other pairs opening new ladders and adding to the overall drawdown while the runaway pairs are trying to recover. 

Yoga Mode Video Explanation

Use Lipo Mode : If this is set to “true” then Lipo Mode will be activated. If kept at “false”, Lipo Mode will not be used. The idea behind this function is to control drawdown by “trimming the fat” or closing the smallest trade level in a ladder before opening a new trade level. This has two main benefits. First, it helps control drawdown/risk by gradually reducing total lot size as price moves further away from the original entry and cost averaging trades begin to stack. Second, it causes the TP to move closer to the current price which makes it more likely for the price to reach the TP faster. 

..Begin Trim After Level : For example, let’s say the user enters 10 for the value input. This means after 10 levels or trades are placed in the sequence, on the 11th trade, the 1st trade in the sequence (smallest lot size) will close. Then, on the 12th trade, the 2nd trade in the grid sequence (new smallest lot size) will close etc. 

Lipo Mode Video Explanation

Use Amp Mode : If this is set to “true” then Amp Mode will be used. If set to “false” Amp mode will not be used. This feature is designed for closing sequences of trades that have too many levels open and are contributing too much drawdown to the account. Although closing losing trades can be hard psychologically, sometimes it is necessary in order to protect your account. 

..Cut After Level : This is how you can set WHEN you want Titan to “Amputate” your trades and trigger Amp Mode. For example, if you set this to 16, it means Titan will open the 16th level trade and AFTER the 16th level, instead of opening the 17th level, Titan will “Amp” or close all the trades in that direction on that pair. (Please note if you have Bi-Directional Mode set to “true” it will only “Amp” the direction, buy or sell trades, that have reached 16 levels). 

..Amp Threshold (%) : The purpose of this input is so that Titan doesn’t “Amp” trades unnecessarily. Since the whole purpose of Amp mode is to control drawdown, there really isn’t a reason to Amp if your drawdown isn’t significant. So the Amp Threshold value means that Titan will not trigger Amp Mode until the account’s floating loss in % is greater than the Amp Threshold value even if the current level is greater than the Cut After Level input value. 

..Resume Trading After (min) : After a pair “Amps” you may not want to resume trading on that pair right away and instead wait for a later time once the market has “calmed down” a bit. So with this input you can delay when the pair resumes trading after “Amp-ing” that pair. 

Amp Mode Video Explanation

Use Lot Multiplier Manager : Set this to “true” to activate the Lot Multiplier Manager feature. This is best used for gradually limiting exposure as ladders open up depper levels instead of increasing it (although it could be used to lever up on deeper levels as well). 

..LMM Type : This is used for defining the units for the LMM Start value. If set to Levels and LMM Start is set to 4 then it means the LMM will trigger on level 4. If set to DD% then and LMM Start is set to 10 then it means the LMM will trigger at 10% drawdown. 

..LMM Start : This is the value where once reached, it will trigger the Lot Multiplier Manager. 

..LMM Interval : This is how often the LMM Multiplier should be applied. So for example if set to 2 it means after the LMM is triggered at the LMM Start value, then every two levels it would be applied again. So for example if my LMM Start is set to 4, and my original Lot Multiplier is set to 1.5 and my LMM Multiplier is 0.5, then at level 4 my Lot Multiplier would be multiplied by 0.5 so the Lot Multiplier for levels 4 & 5 would be 0.75. Then at level 6, the Lot Multiplier would be applied again would be 0.38 for levels 6&7 etc. 

When using the Lot Multiplier Manager you can see on the chart display if it’s been triggered or not and in what direction (buy or sell direction). 

Use Pip Step Manager : Set this to “true” to activate the Pip Step Manager feature. This feature is particularly useful for controlling drawdown and avoiding opening lots on your account too quickly. As drawdown increases this feature can automatically expand your Pip Step which can help control drawdown during trends.

..PSM Type : This is used for defining the units for the PSM Start value. If set to Levels and PSM Start is set to 4 then it means the PSM will trigger on level 4. If set to DD% then and PSM Start is set to 10 then it means the PSM will trigger at 10% drawdown. 

..PSM Start : This is the value where once reached, it will trigger the Pip Step Manager. 

..PSM Interval : This is how often the PSM Multiplier should be applied. So for example if set to 2 it means after the PSM is triggered at the PSM Start value, then every two levels it would be applied again. So for example if my PSM Start is set to 8, and my original Pip Step is set to 10 and my PSM Multiplier is 2, then at level 8 my Pip Step would be multiplied by 2 so the distance between level 8 and 9 would be 20 pips and from 9-10 it would also be 20 pips still. Then at level 10, the distance from 10-11 would be 40 and from 11-12 would also be 40 etc. 

When using the Pip Step Manager you can always check your current pip step on the chart display. 

..PSM Multiplier : This is the multiplier for the original Pip Step value. Once the PSM Start value is reached this value will be multiplied by the Pip Step and will be applied again every x levels according to the PSM Interval. 

Use TP Manager : Set this to “true” to activate the TP Manager feature. This is particularly useful for getting out of deeper ladders easier by automatically moving the TP closer to current price after a pre-defined level. 

..TPM Start (level) : This is the level at which the TP Manager will trigger. 

..TPM New TP : This is the new TP value that will be applied once the TPM Start level is reached. 

..TPM Interval : This means every x levels after the TPM Start (level), the TPM will decrease the TP by the TPM Increment.

..TPM Increment : This is how much the TP will decrease after every x number of levels according to the TPM Interval. 

For example if the TPM Interval and TPM Increment is set to 2 and the TPM Start (level) is set to 7 and TPM New TP is set to 4, then it means at level 7 the TP will switch to 4 and then every 2 levels deeper after that the TP will decrease by 2 pips. So by level 9 the TP = 2 and by level 11 the TP = 0 and by level 13 the TP = -2 meaning the trades would actually close in a loss.

This is very useful as the deeper the level, the more drawdown and less profits/more loss you should be willing to take in order to limit drawdown and protect the account. 

Use FB Manager : Set to “true” to activate the FB Manger

..FB Interval Start : This is the amount in floating loss when reached, the FB Goal will change to the FB New Goal. 

..FB New Goal : When the FB Interval Start is reached, the FB Goal will change to this value. 

..FB Interval : This means every x (according to the FB Type) the FB Goal will decrease by the FB Increment value. 

..FB Increment : This is how much the FB Goal will decrease every FB Interval according to the FB Type.

For example say you have the following settings :  

FB Type : Pair $ 
FB Goal : 25
FB Interval Start : 100
FB New Goal : 10
FB Interval : 20
FB Increment : 5

This means that starting at -$100 drawdown on any pair, the FB Goal will change to $10 and every -$20 of additional drawdown (-$120, -$140, -$160 etc.) the FB Goal will lower by $5. 
So at -$100 dd, FB Goal is $10, at -$120 dd, FB Goal is $5, at -$140 dd, FB Goal is $0, at -$160 dd, FB Goal is -$5, at -$180 dd, FB Goal is -$10 etc. 

On your chart display, you can monitor these settings. For example you can see the Margin to the next FB Interval on your chart display, so as your drawdown increases the distance or margin to your next FB Interval gets closer. You can also see the current FB Goal. 

These settings are particularly useful as another way to protect your account and limit drawdown and could even be a potentially “smarter” and more dynamic equity protector compared to a static equity protector. Because instead of taking a big loss all at once you are taking advantage of the fact the market always retraces before going lower or higher. The problem is sometimes it’s not enough to reach your TP whereas here with these settings, you are essentially only lowering your profit goal as you get into deeper drawdown which makes it easier to close trades on the retracements. 

Use CSF Manager : Set this to “true” to activate the CSF Manager.

New CSF Timeframe Start (levels) : This is when the CSF Manager should trigger. For example if this is set to 5, then it means at level 5, the next entry will be based on the New CSF Timeframe.

New CSF Timeframe : This is the new timeframe that will be used for all trades after the CSF Manager has been triggered by the New CSF Timeframe Start (levels). 

New Min Time Between CA Trades (min) : This is the New Min Time Between CA Trades that will be used for all trades after the CSF Manager has been triggered by the New CSF Timeframe Start (levels). 

Use Trend Trade : Set this to “true” to activate the Trend Trade feature. We think of this as a last resort only to be used if necessary because depending on how you use it it could help save your account if you’re lucky or not. However we’re planning on building out this feature further so it is less of a gamble. 

..TT Type : There are two types you can choose from for the Trend Trade : 

1. CA : This means the Trend Trade will cost average out of it’s position if necessary. So the TT Lots (%) will determine the starting lots, and the same inputs in the basic settings will be used for the TT ladder as well (i.e. pip step, lot multi etc.). For the TP the TT TP will be used which is either based on pips or the chart floating profits.  

The rest of the TT features Close Together and TT Once will also work with the TT ladder. However if CA is selected, then TT SL will be ignored since it will cost average instead of using a SL. 

2. Single Trade : This means instead of cost averaging the TT will be a single trade to hedge against the ladder. This was the original way the TT was designed to be used. 

..TT Lots (%) : This is for setting the lot size for the Trend Trade. Once the TT Start level is reached, Titan will place a lot size as a % of the sum total of total lots in that ladder. For example if the TT Start is set to trigger the Trend Trade at level 12, and the sum total of all 12 levels is 2.5 lots and I have my TT Lots %  set to 110% then Titan will place the trade in the opposite direction of the ladder at 110% * 2.5 = 2.75 lots.

..TT Start Level : This is the level at which the Trend Trade will trigger. 

..TT Once : This means Titan will place a Trend Trade only once and if it hits the TT TP or TT SL then it won’t place another Trend Trade and will leave the ladder open in a loss. 

..Close Together : If set to true this means the Trend Trade and Ladder will close together. So if the Trend Trade hits the TT TP or TT SL , the ladder will close with it or if the ladder hits TP then the Trend Trade will close with it. 

..TT TP Type : For this you can select either Pips or Chart Floating Profits. If Pips is selected the TT TP Amount will be in units of Pips meaning the TP for the Trend Trade will be placed to capture that amount of pips profit away from the entry. If Chart Floating Profits is selected then the TT TP Amount will be in units of cash amount, and once the chart is floating that much in profit then all trades on that particular pair/chart will close together automatically (regardless of the Close Together setting in this case). 

..TT TP Amount :  This is the amount in units of either Pips or Chart Floating Profits (depending on whcih was selected for the TT TP Type setting) to trigger the Trend Trade to close and take profit. 

..TT SL (pips) : This is the amount in pips of loss away from the Trend Trade entry price where the SL for the Trend Trade will be placed. 

SECTION 6 : SCHEDULE SETTINGS

Trading Days (0=Sunday, 1=Monday etc.) : This allows you to choose which days of the week you want to trade. If you set Monday to true and Tuesday to false, Titan will continue to manage and cost average on ladders that were opened on Monday. However it will not start any new ladders on Tuesday. 

Use Close All Trades & Pause Start Trades at Day/Time : If this is set to “true” then this function will be activated. “Pause Trading” means no new trades will be opened until the following week when the market opens. This function was specifically designed with the FTMO challenge in mind. Once funded, traders are not allowed to hold trades over the weekend. This is a fail-safe in case a trader were to accidentally forget to close trades before the weekend. 

..Day (0=Sunday, 1=Monday, etc.) : Here you enter the day to pause trading and close all trades however the days are represented numerically. For example, if I enter the number 5 for the input value, then this means Titan will pause trading and close all trades on Friday. 

..Time : Here you enter the time to pause trading and close all trades. 

Use Close All Trades & Pause Trading at Day/Time Video Explanation

Use Pause Start Trades at Day/Time : If set this to “true” the function will be activated. This function allows you to schedule when you want Titan to begin “powering down” by pausing new ladders or start trades from opening after a trade or ladder of trades hit take profit. 

For example, if you want to begin “powering down” on Wednesday at 11 pm, it will trigger the function at that day/time. After that day/time once the take-profit is hit, Titan will not take any more trades on that pair until the following week.

If Bi-Directional Mode is on, Titan will only stop trading in the direction that hits take profit and will continue trading in the opposite direction until the take profit is hit in that direction also. 

This function was also originally designed with the FTMO challenge in mind. Once funded, traders are not allowed to hold trades over the weekend. Instead of waiting to close all trades just before the weekend which could result in big losses, this function is a way of telling Titan to gradually stop trading for the week as ladders reach their take-profit targets. 

..Day (0=Sunday, 1=Monday, etc.) : This is for setting the specific day when the function will be triggered.  However the days are represented numerically. So if I enter the number 3 for the input value, then this means Titan will trigger this Pause Trading function on Wednesday which means Titan will continue opening cost averagig trades (level 2 and beyond) until any ladder has reached its TP. Then at that point instead of entering a new ladder, Titan will pause trading until the following week when the market opens. 

..Time : Here you enter the exact time you want the Pause Trading function to trigger. 

Use Pause Trading After Date/Time Once Take Profit Is Hit Video Explanation

Use Trading Sessions : Set this to “true” to enable trading sessions settings and all its functions. 

Trade Asian, London, New York : Set any of these to true and define the start and end time for these sessions. These do not need to necessarily be set to the exact open and close time for New York session, you could just set this to a time you are available to monitor the charts for example. These can be set to any time you wish and you can use any or all of the sessions. 

..End Time Action : Each of the trading sessions has an End Time Action option you can select from the drop down menu which means at the End Time (hr) the selected action will execute. 

1. Close All Trades - All trades on the account will close and no new trades will open until the next Start Time.
2. Pause Start Trades - All open ladders will continue to open new levels until they reach their TP. Then no new ladders or start trades will open until the next Start Time.
3. Nothing - No special actions will be taken at the End Time.


SECTION 7 : NEWS SETTINGS

News Filter : To activate and use the news filter and all its features, set this to “true”. 

Titan’s New Filter is based on the economic calendar publicly available on https://www.forexfactory.com/calendar. There you can see which currency the news will impact the most. The news filter settings will only apply to the specific pairs impacted by news related to that particular currency. For example GBP news will only affect currency symbols that include GBP. 

Set GMT Offset Manually : Usually this setting does not need to be used. However if you notice that Titan is pausing for news at the wrong times or that the news lines on the chart representing the news are drawn at inaccurate times, then this setting activates the manual override. To use it, set this to “true” and set the GMT offset below. 

..GMT Offset (hours) : To determine your GMT offset, you need to determine the difference between your broker’s server time and GMT time. Your broker’s server time is shown in the Market Watch window. For example if the current GMT time is 3:00 and the time shown in your broker’s MT4 terminal in the Market Watch is 5:00, then the offset is 2 hours and you would input 2 for this setting. If you’re unsure, usually you can message your broker and ask what their GMT offset is. 

Disable Trading for News : This setting was originally designed to be compliant with FTMO news rules which say you cannot open or close trades 2 min before or after (most) high impact news. To disable closing/opening trades before/after news, set this to “true”. To set the exact minutes before/after news to disable auto-trading, enter it below. 

..Disable Trading Before/After News (min) : To be compliant with FTMO funded account rules, you need to set this to at least 2 min, we’ve set the default to 3 min as a buffer just in case. Essentially by doing this, it means that 3 minutes before and after the news you are filtering (set below), Titan will remove Take Profit, Stop Loss, and turn AutoTrading off. Then, 3 min after the news, AutoTrading will be turned back on and Take Profits and Stop Loss targets will be put back. So, if you leave this set at 3 min, it means that for 6 min starting 3 min before the news release, no trades will close or open. You can see this all working by checking the trade tab, you’ll notice the TP and SL prices are modified to 0 before and after news, and in the expert tab you’ll notice Titan toggling AutoTrading on/off, also x minutes before and after news according to the input value you’ve set. 

Low/Medium/High/FTMO/NFP News Action : You can select the action you want Titan to take during low impact news (or whichever level of impact setting you’ve set). There are three options to choose from : 

1. Close All Trades - All trades on the account will close and no new trades will open until the Before/After time has passed.
2. Pause Start Trades - All open ladders will continue to open new levels until they reach their TP. Then no new ladders or start trades will open until the Before/After time has passed
3. Nothing - No special actions will be taken for this News. 

You can see the upcoming news, related currency and level of impact here : https://www.forexfactory.com/calendar . In the Impact column, the yellow folder represents low impact news, the orange folder represents medium impact news, and the red folder is high impact news. 

..Low/Medium/High/NFP News Action Before/After (min) : Typically volatility can occur both before and after news. So some users prefer to pause start trades (or whatever action they’ve selected) for longer before high impact news, but shorter before low impact news. It’s totally up to you. For example if you set this to 15 min, it means that no new ladders or start trades will open for 30 min starting 15 min before the news release and then 15 min after. There will be a text on your chart display box that will show trading is currently paused for news and for which impacted currency. 

Draw News Lines : If you like seeing the past and upcoming news on your charts, leave this set to “true”. The lines are color coordinated according to the impact (set colors below). Also if you hover your cursor over these lines, you can see which News Event the line represents as well as which currency it’s related to. 

..Low/Medium/High Impact Color : Here you can select which colors you’d like to represent the levels of impact of news for the lines on your chart. For example if you leave the default colors, you’ll see green lines for low impact news, blue lines for medium impact news and red lines for high impact news (including NFP).  

SECTION 8 : TESTER SETTINGS
(MT5 version only, these will override any of the other settings while in the tester)

Use Tester Settings : If set to “true”, then all the settings below will be used for the tester. If left at false, then the settings below will not be used for the tester. Please note setting this to true/false will only affect which settings are used in the tester. If live trading, all tester settings will be ignored automatically. 

Show Panel on Chart : When using visual mode, you can choose to either show or hide the panel on the chart. If set to “false” this will dramatically increase the speed of the backtest.  

Currencies To Trade : This is the multi-pair currency feature. Here you can list the currencies you’d like to test separated by a comma. (I.e EURUSD,XAUUSD,GBPUSD) etc.

PLEASE NOTE : When using mutlipair testing with Ghost Trades in the MT5 tester the front pair in the tester settings must match the first pair listed in the Currencies to Trade for most accurate results.

Take Profits : Here you can set different TPs for each of the individual pairs you’ve listed for Currencies To Trade. Just make sure to match the order of the TP values to also match the order of the Currencies To Trade. For example if you set the first Take Profit value to 21 and the first currency listed is EURUSD then it means EURUSD will use 21 for its TP value. 

Pip Steps / DPS Dividers : Here you can set different Pips Step or DPS Divider values for each of the individual pairs you’ve listed for Currencies To Trade. If in the Basic Settings section you have Fixed selected for the Pip Step Type then the value here will be a fixed Pip Step. If in the Basic Settings section you have Dynamic selected for the Pip Step Type then the value here will be a Dynamic Pip Step. Just make sure to match the order of the values to also match the order of the Currencies To Trade. For example if you set the first value to 21 and the first currency listed is EURUSD then it means EURUSD will use 21 for its Pip Steps / DPS Dividers value. 

TSL Starts : Here you can set different TSL Start values for each of the individual pairs you’ve listed for Currencies To Trade. Just make sure to match the order of the TSL Start values to also match the order of the Currencies To Trade. For example if you set the first TSL Start value to 10 and the first currency listed is EURUSD then it means EURUSD will use 10 for its TSL Start value. 


TSL Stops : Here you can set different TSL Stop values for each of the individual pairs you’ve listed for Currencies To Trade. Just make sure to match the order of the TSL Stop values to also match the order of the Currencies To Trade. For example if you set the first TSL Stop value to 10 and the first currency listed is EURUSD then it means EURUSD will use 10 for its TSL Stop value. 
