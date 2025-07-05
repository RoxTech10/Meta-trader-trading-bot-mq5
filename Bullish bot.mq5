//+------------------------------------------------------------------+
//|           Buy Strategy      |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
CTrade trade;

// Input parameters
input double LotSize = 0.1;
input int StopLoss = 50;     // in points
input int TakeProfit = 100;  // in points
input int EMA_Fast = 50;
input int EMA_Slow = 200;
input int Stoch_K = 5;
input int Stoch_D = 3;
input int Stoch_Slowing = 3;

// Indicators handles
int emaFastHandle, emaSlowHandle, stochHandle;

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   emaFastHandle = iMA(_Symbol, PERIOD_M5, EMA_Fast, 0, MODE_EMA, PRICE_CLOSE);
   emaSlowHandle = iMA(_Symbol, PERIOD_M5, EMA_Slow, 0, MODE_EMA, PRICE_CLOSE);
   stochHandle   = iStochastic(_Symbol, PERIOD_M5, Stoch_K, Stoch_D, Stoch_Slowing, MODE_SMA, STO_LOWHIGH);

   if (emaFastHandle == INVALID_HANDLE || emaSlowHandle == INVALID_HANDLE || stochHandle == INVALID_HANDLE)
   {
      Print("Error creating indicator handles.");
      return(INIT_FAILED);
   }

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert Tick Function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   static datetime lastTradeTime = 0;

   datetime currentTime = iTime(_Symbol, PERIOD_M5, 0);
   if (currentTime == lastTradeTime) return;

   lastTradeTime = currentTime;

   // Get EMA values
   double emaFast[], emaSlow[];
   if (!CopyBuffer(emaFastHandle, 0, 1, 2, emaFast)) return;
   if (!CopyBuffer(emaSlowHandle, 0, 1, 2, emaSlow)) return;

   // Get Stochastic %K and %D values
   double K[], D[];
   if (!CopyBuffer(stochHandle, 0, 1, 2, K)) return;
   if (!CopyBuffer(stochHandle, 1, 1, 2, D)) return;

   // Previous candle data
   double open = iOpen(_Symbol, PERIOD_M5, 1);
   double close = iClose(_Symbol, PERIOD_M5, 1);
   double low = iLow(_Symbol, PERIOD_M5, 1);
   double high = iHigh(_Symbol, PERIOD_M5, 1);

   // Condition 1: Bullish candlestick pattern
   bool bullishEngulfing = (iOpen(_Symbol, PERIOD_M5, 2) > iClose(_Symbol, PERIOD_M5, 2)) &&
                           (close > open) &&
                           (open < iClose(_Symbol, PERIOD_M5, 2)) &&
                           (close > iOpen(_Symbol, PERIOD_M5, 2));

   bool bullishHarami = (iClose(_Symbol, PERIOD_M5, 2) < iOpen(_Symbol, PERIOD_M5, 2)) &&
                        (open > iClose(_Symbol, PERIOD_M5, 2)) &&
                        (close < iOpen(_Symbol, PERIOD_M5, 2));

   bool bullishCross = close > open && low < open && high > close;

   bool isBullishPattern = bullishEngulfing || bullishHarami || bullishCross;

   // Condition 2: Close above both EMAs
   bool isAboveEMAs = close > emaFast[1] && close > emaSlow[1];

   // Condition 3: Stochastic crossover from oversold and above 20
   bool stochCrossover = 
      K[1] < 20 && D[1] < 20 &&
      K[0] > D[0] &&
      K[0] > 20 && D[0] > 20;

   // Final condition met
   if (isBullishPattern && isAboveEMAs && stochCrossover)
   {
      if (PositionsTotal() == 0)
      {
         double sl = NormalizeDouble(Bid - StopLoss * _Point, _Digits);
         double tp = NormalizeDouble(Bid + TakeProfit * _Point, _Digits);

         if (trade.Buy(LotSize, _Symbol, Bid, sl, tp, "Bullish Entry"))
         {
            string msg = StringFormat("Buy Trade Executed at %.5f | SL: %.5f | TP: %.5f", Bid, sl, tp);
            Alert(msg);
            Print(msg);

            // Add visual label (arrow) on chart
            string labelName = "BUY_SIGNAL_" + TimeToString(TimeCurrent(), TIME_SECONDS);
            double arrowPrice = iLow(_Symbol, PERIOD_M5, 1) - 10 * _Point;
            ObjectCreate(0, labelName, OBJ_ARROW_UP, 0, Time[1], arrowPrice);
            ObjectSetInteger(0, labelName, OBJPROP_COLOR, clrLime);
            ObjectSetInteger(0, labelName, OBJPROP_WIDTH, 2);
         }
      }
   }
}
