//+------------------------------------------------------------------+
//|                                                    Trend-V20.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
/*
一个成熟的交易系统应该是一个完善的交易系统，需要具备以下要素：
    1、成功率；
    2、盈利空间；
    3、风险空间；
    4、买点定位；
    5、盈利卖点定位；
    6、止损卖点定位；    
    */
    
    /*    
    先做如下定义：
    成功系数：交易系统的成功率以小数点来表示，例如50%的成功率对应的成功系数为0.5。
    盈损系数=盈利空间/(盈利空间+风险空间)。
    时间系数:需要1个交易日，则初始值为1。其后每增加一个交易日，则系数减0.01。
    盈利系数：盈利10%以内，则系数为0。其后每增加10%，则系数增加0.01。例如，盈利50%，则系数为0.04。
    时效系数=时间系数+盈利系数。此系数很好的反应了时间的价值。
    交易系统系数=(成功系数+盈损系数)×时效系数。此系数终极反映了交易系统的成熟度。
    
    理论上来说，交易系统系数最小值为0，最大值为2。此系数对于长线短线都适用。
    */
    
    /*
    对于可行性评估，我们把交易系统划分为以下几种：
    基本交易系统：应该是成功系数大于0.5、盈损系数大于0.5的系统。这是最基本的生存于市场的交易系统。
    风险交易系统：是成功系数小于0.5，或者盈损系数小于0.5，但交易系统系数大于1的系统。我们认为，只有交易系统系数大于1.2的风险交易系统，才是可值得操作的交易系统。
    合格交易系统：是成功系数大于0.5、盈损系数大于0.5，同时交易系统系数大于1.2的交易系统。
    优秀交易系统：是成功系数大于0.5、盈损系数大于0.5，同时交易系统系数大于1.5的交易系统。
    天才交易系统：什么都不说，交易系统系数大于1.8的交易系统。
    例如，一个超短线交易系统，所需时间为1个交易日，盈利空间为5%以上，风险空间为2%以内，成功率为80%，则交易系统系数为(5%/(5%+2%)+0.8)×（1+0）=1.514，为一个优秀的交易系统。
    如果交易系统系数达不到1，则为失败的交易系统。至于交易系统系数达到2的完美的交易系统，只是存在于理论中，市场中永远不存在。
    如果交易系统系数达不到1，则为失败的交易系统。至于交易系统系数达到2的完美的交易系统，只是存在于理论中，市场中永远不存在。    
    */
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, 环球外汇网友交流群@Aother,448036253@qq.com"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int MaSlwPeriod   = 100;   //慢速均线周期

input int MaFstPeriod = 60;      //快速均线周期

string TimerLimit = "";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   EventSetTimer(1);
   //创建对象
   ObjectCreate(0,"lblTimer",OBJ_LABEL,0,NULL,NULL);
   ObjectCreate(0,"lblBigPeriod",OBJ_LABEL,0,NULL,NULL);
   ObjectCreate(0,"lblMacd",OBJ_LABEL,0,NULL,NULL);
   ObjectCreate(0,"lblMa",OBJ_LABEL,0,NULL,NULL);
   ObjectCreate(0,"lblAuthor",OBJ_LABEL,0,NULL,NULL);
   ObjectCreate(0,"lblAdvice",OBJ_LABEL,0,NULL,NULL);
   //设置内容
   ObjectSetString(0,"lblTimer",OBJPROP_TEXT,_Symbol+"蜡烛剩余");
   ObjectSetString(0,"lblBigPeriod",OBJPROP_TEXT,"大周期");
   ObjectSetString(0,"lblMacd",OBJPROP_TEXT,"MACD感知");
   ObjectSetString(0,"lblMa",OBJPROP_TEXT,"均线感知");
   ObjectSetString(0,"lblAuthor",OBJPROP_TEXT,"作者：环球外汇网@Aother");
   ObjectSetString(0,"lblAdvice",OBJPROP_TEXT,"操作建议：待定");
   //设置颜色
   ObjectSetInteger(0,"lblTimer",OBJPROP_COLOR,clrBlack);
   ObjectSetInteger(0,"lblBigPeriod",OBJPROP_COLOR,clrRed);
   ObjectSetInteger(0,"lblMacd",OBJPROP_COLOR,clrLime);
   ObjectSetInteger(0,"lblMa",OBJPROP_COLOR,clrBlue);
   ObjectSetInteger(0,"lblAuthor",OBJPROP_COLOR,clrGray);
   ObjectSetInteger(0,"lblAdvice",OBJPROP_COLOR,clrRed);
   //--- 定位右上角 
   ObjectSetInteger(0,"lblTimer",OBJPROP_CORNER ,CORNER_RIGHT_UPPER); 
   ObjectSetInteger(0,"lblBigPeriod",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,"lblMacd",OBJPROP_CORNER ,CORNER_RIGHT_UPPER); 
   ObjectSetInteger(0,"lblMa",OBJPROP_CORNER ,CORNER_RIGHT_UPPER); 
   ObjectSetInteger(0,"lblAuthor",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   //--- 定位右下角
   ObjectSetInteger(0,"lblAdvice",OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   //设置XY坐标
   ObjectSetInteger(0,"lblTimer",OBJPROP_XDISTANCE,200);   
   ObjectSetInteger(0,"lblTimer",OBJPROP_YDISTANCE,40);
   ObjectSetInteger(0,"lblBigPeriod",OBJPROP_XDISTANCE,200);  
   ObjectSetInteger(0,"lblBigPeriod",OBJPROP_YDISTANCE,60);
   ObjectSetInteger(0,"lblMacd",OBJPROP_XDISTANCE,200);   
   ObjectSetInteger(0,"lblMacd",OBJPROP_YDISTANCE,80); 
   ObjectSetInteger(0,"lblMa",OBJPROP_XDISTANCE,200);
   ObjectSetInteger(0,"lblMa",OBJPROP_YDISTANCE,100);
   ObjectSetInteger(0,"lblAuthor",OBJPROP_XDISTANCE,200);
   ObjectSetInteger(0,"lblAuthor",OBJPROP_YDISTANCE,120);
   ObjectSetInteger(0,"lblAdvice",OBJPROP_XDISTANCE,450);
   ObjectSetInteger(0,"lblAdvice",OBJPROP_YDISTANCE,20);
   
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   
  
   
   ObjectsDeleteAll(0, 0, OBJ_LABEL);
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // MACD主周期的佛手形态是否成立，可以到下级别小周期观察是否翻越0轴
   // 多佛手，尽量做0轴上方的；空佛手，尽量做0轴下方的；0轴上方的空和下方的多点位除非是某个重要阻力或支撑，否则4h一下级别这类佛手最好不要做，没空间
   
   // 趋势感知：上一个收盘价的指标
   //MACD主要，使用默认参数
   double macdMain = iMACD(_Symbol,PERIOD_CURRENT,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   //MACD信号，使用默认参数
   double macdSignal = iMACD(_Symbol,PERIOD_CURRENT,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   //MACD主要，大周期
   double macdBigMain = iMACD(_Symbol,Period()*4,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   //MACD信号，大周期
   double macdBigSignal = iMACD(_Symbol,Period()*4,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   
   // 慢均线
   double maSlw = iMA(_Symbol,PERIOD_CURRENT,MaSlwPeriod,1,MODE_SMA,PRICE_CLOSE,1);
   // 快均线
   double maFst = iMA(_Symbol,PERIOD_CURRENT,MaFstPeriod,1,MODE_SMA,PRICE_CLOSE,1);
   
   //MqlTick  lastTick;
   // 当前K柱价格
   //SymbolInfoTick(_Symbol,lastTick);
   // 取买价和卖价的均值(各自点差的一半)
   //double price = (lastTick.bid + lastTick.ask)/2;
   // 上一个收盘k柱价格
   double closes[1];
   CopyClose(_Symbol,PERIOD_CURRENT,1,1,closes);
   double price = closes[0];
   
   //string strTMP;
   // 精度减少1位，精确到一个点
   //strTMP = "4H慢均线：%." + IntegerToString((int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS)-1) + "f";
   //ObjectSetString(0,"lblMaBig",OBJPROP_TEXT,StringFormat(strTMP,maSlw));
   //strTMP = "4H快均线：%." + IntegerToString((int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS)-1) + "f";
   //ObjectSetString(0,"lblMaSmall",OBJPROP_TEXT,StringFormat(strTMP,maFst));

   // 操作建议
   string advice = "";
   
  //大周期
   if(macdBigSignal>0)
   {
         if(macdBigMain>=macdBigSignal)
         {
            ObjectSetString(0,"lblBigPeriod",OBJPROP_TEXT,"MACD大周期：多头趋势");
            advice = "操作建议：打死坚决不做空，宜突破进场、回踩进场，遇支撑涨概率大";          
         }   
         else
         {
            ObjectSetString(0,"lblBigPeriod",OBJPROP_TEXT,"MACD大周期：多头调整");
            advice = "操作建议：见好就收";
         }
   }
   else if(macdBigSignal<0)
   {
      if(macdBigMain<=macdBigSignal)
      {
         ObjectSetString(0,"lblBigPeriod",OBJPROP_TEXT,"MACD大周期：空头趋势");
         advice = "操作建议：打死坚决不做多，宜突破进场、回踩进场，遇阻回落概率大";
      }
      else
      {
         ObjectSetString(0,"lblBigPeriod",OBJPROP_TEXT,"MACD大周期：空头调整");
         advice = "操作建议：见好就收";
      }
   }
   else
   {
      ObjectSetString(0,"lblBigPeriod",OBJPROP_TEXT,"MACD大周期：无信号");
      advice = "操作建议：待定";   
   }
   
   // 当前周期
   double a = iMACD(_Symbol,PERIOD_CURRENT,12,26,9,PRICE_CLOSE,MODE_MAIN,3);
   double b = iMACD(_Symbol,PERIOD_CURRENT,12,26,9,PRICE_CLOSE,MODE_MAIN,2);
   double c = iMACD(_Symbol,PERIOD_CURRENT,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   if(macdSignal>0)
   {
         if(macdMain>=macdSignal)
         {
            if(a>=b && b<c)
            {
               ObjectSetString(0,"lblMacd",OBJPROP_TEXT,"MACD感知：多头趋势，佛手多");
            }
            else
            {
               ObjectSetString(0,"lblMacd",OBJPROP_TEXT,"MACD感知：多头趋势");
            }         
         }   
         else
         {
            ObjectSetString(0,"lblMacd",OBJPROP_TEXT,"MACD感知：多头调整");
         }
   }
   else if(macdSignal<0)
   {
      if(macdMain<=macdSignal)
      {
         if(a<=b && b>c)
         {
            ObjectSetString(0,"lblMacd",OBJPROP_TEXT,"MACD感知：空头趋势，佛手空");
         }
         else
         {
            ObjectSetString(0,"lblMacd",OBJPROP_TEXT,"MACD感知：空头趋势");
         }
      }
      else
      {
         ObjectSetString(0,"lblMacd",OBJPROP_TEXT,"MACD感知：空头调整");
      }      
   }
   else
   {
      ObjectSetString(0,"lblMacd",OBJPROP_TEXT,"MACD感知：无信号");
   }
   
   
   // 强势多头，打死坚决不做空，K价下探触及均线时支撑概率较大
   if(price > maSlw && price > maFst && maFst > maSlw)
   {
      ObjectSetString(0,"lblMa",OBJPROP_TEXT,"均线感知：多头趋势");
      //ObjectSetInteger(0,"lblMa",OBJPROP_COLOR,clrLime);
      //advice = "操作建议：待定";
   }   
   // 强势空头，打死坚决不做多，K价下探触及均线时支撑概率较大
   else if(price < maSlw && price < maFst && maFst < maSlw)
   {   
      ObjectSetString(0,"lblMa",OBJPROP_TEXT,"均线感知：空头趋势");
      //ObjectSetInteger(0,"lblMa",OBJPROP_COLOR,clrHotPink);
      //advice = "操作建议：待定";
   }
   // 震荡偏空
   else if(price < maSlw && price < maFst && maFst > maSlw)
   {   
      ObjectSetString(0,"lblMa",OBJPROP_TEXT,"均线感知：偏空震荡");
      //ObjectSetInteger(0,"lblMa",OBJPROP_COLOR,clrHotPink);
      //advice = "操作建议：待定";       
   }
   // 震荡偏多
   else if(price > maSlw && price > maFst && maFst < maSlw)
   {   
      ObjectSetString(0,"lblMa",OBJPROP_TEXT,"均线感知：偏多震荡");
      //ObjectSetInteger(0,"lblMa",OBJPROP_COLOR,clrHotPink);
      //advice = "操作建议：待定";           
   }
   else
   {   
      ObjectSetString(0,"lblMa",OBJPROP_TEXT,"均线感知：震荡");
      //ObjectSetInteger(0,"lblMa",OBJPROP_COLOR,clrBlack);
      //advice = "操作建议：待定";
   }
   
   
   // 显示操作建议
   ObjectSetString(0,"lblAdvice",OBJPROP_TEXT,advice);
   ObjectSetInteger(0,"lblAdvice",OBJPROP_XDISTANCE,13*StringLen(advice) + 13); 
   
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   // 定时刷新计算当前蜡烛剩余时间
   long hour = Time[0] + 60 * Period() - TimeCurrent();
   long minute = (hour - hour % 60) / 60;
   long second = hour % 60;
   ObjectSetString(0,"lblTimer",OBJPROP_TEXT,StringFormat("%s蜡烛剩余：%d分%d秒",_Symbol,minute,second));
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   
}
//+------------------------------------------------------------------+
