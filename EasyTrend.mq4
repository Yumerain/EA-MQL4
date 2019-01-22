//+------------------------------------------------------------------+
//|                                                    Trend-V00.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, 环球外汇网友交流群@Aother,448036253@qq.com"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input int MaSlwPeriod   = 100;   //慢速均线周期

input int MaFstPeriod = 60;      //快速均线周期


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   //创建对象
   ObjectCreate(0,"lblMaBig",OBJ_LABEL,0,NULL,NULL);
   ObjectCreate(0,"lblMaSmall",OBJ_LABEL,0,NULL,NULL);
   ObjectCreate(0,"lblAuthor",OBJ_LABEL,0,NULL,NULL);
   ObjectCreate(0,"lblConclusion",OBJ_LABEL,0,NULL,NULL);
   ObjectCreate(0,"lblAdvice",OBJ_LABEL,0,NULL,NULL);
   //设置内容
   ObjectSetString(0,"lblMaBig",OBJPROP_TEXT,"4H慢均线");
   ObjectSetString(0,"lblMaSmall",OBJPROP_TEXT,"4H快均线");
   ObjectSetString(0,"lblAuthor",OBJPROP_TEXT,"作者：环球外汇网@Aother");
   ObjectSetString(0,"lblConclusion",OBJPROP_TEXT,"趋势感知");
   ObjectSetString(0,"lblAdvice",OBJPROP_TEXT,"操作建议：无");
   //设置颜色
   ObjectSetInteger(0,"lblMaBig",OBJPROP_COLOR,clrHotPink);
   ObjectSetInteger(0,"lblMaSmall",OBJPROP_COLOR,clrBlue);
   ObjectSetInteger(0,"lblAuthor",OBJPROP_COLOR,clrGray);
   ObjectSetInteger(0,"lblAdvice",OBJPROP_COLOR,clrRed);
   //--- 定位右上角 
   ObjectSetInteger(0,"lblMaBig",OBJPROP_CORNER ,CORNER_RIGHT_UPPER); 
   ObjectSetInteger(0,"lblMaSmall",OBJPROP_CORNER ,CORNER_RIGHT_UPPER); 
   ObjectSetInteger(0,"lblAuthor",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   ObjectSetInteger(0,"lblConclusion",OBJPROP_CORNER,CORNER_RIGHT_UPPER);
   //--- 定位右下角
   ObjectSetInteger(0,"lblAdvice",OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   //设置XY坐标
   ObjectSetInteger(0,"lblMaBig",OBJPROP_XDISTANCE,200);   
   ObjectSetInteger(0,"lblMaBig",OBJPROP_YDISTANCE,80); 
   ObjectSetInteger(0,"lblMaSmall",OBJPROP_XDISTANCE,200);   
   ObjectSetInteger(0,"lblMaSmall",OBJPROP_YDISTANCE,100);
   ObjectSetInteger(0,"lblConclusion",OBJPROP_XDISTANCE,200);
   ObjectSetInteger(0,"lblConclusion",OBJPROP_YDISTANCE,120); 
   ObjectSetInteger(0,"lblAuthor",OBJPROP_XDISTANCE,200);
   ObjectSetInteger(0,"lblAuthor",OBJPROP_YDISTANCE,140);
   ObjectSetInteger(0,"lblAdvice",OBJPROP_XDISTANCE,450);
   ObjectSetInteger(0,"lblAdvice",OBJPROP_YDISTANCE,20);
   
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{   
   ObjectsDeleteAll(0, 0, OBJ_LABEL);
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // 趋势感知
   // 4H慢均线
   double maSlw = iMA(_Symbol,PERIOD_H4,MaSlwPeriod,1,MODE_SMA,PRICE_CLOSE,0);
   // 4H快均线
   double maFst = iMA(_Symbol,PERIOD_H4,MaFstPeriod,1,MODE_SMA,PRICE_CLOSE,0);
   // 当前K柱价格
   MqlTick  lastTick;
   SymbolInfoTick(_Symbol,lastTick);
   // 取买价和卖价的均值(各自点差的一半)
   double price = (lastTick.bid + lastTick.ask)/2;
   string strTMP;
   // 精度减少1位，精确到一个点
   strTMP = "4H慢均线：%." + IntegerToString((int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS)-1) + "f";
   ObjectSetString(0,"lblMaBig",OBJPROP_TEXT,StringFormat(strTMP,maSlw));
   strTMP = "4H快均线：%." + IntegerToString((int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS)-1) + "f";
   ObjectSetString(0,"lblMaSmall",OBJPROP_TEXT,StringFormat(strTMP,maFst));     
   
   // 操作建议
   string advice = "";
   // 强势多头，打死坚决不做空，K价下探触及均线时支撑概率较大
   if(price > maSlw && price > maFst && maFst > maSlw)
   {
      ObjectSetString(0,"lblConclusion",OBJPROP_TEXT,"趋势感知：强势多头↑↑↑");
      ObjectSetInteger(0,"lblConclusion",OBJPROP_COLOR,clrLime);
      advice = "操作建议：打死坚决不做空";
   }   
   // 强势空头，打死坚决不做多，K价下探触及均线时支撑概率较大
   else if(price < maSlw && price < maFst && maFst < maSlw)
   {   
      ObjectSetString(0,"lblConclusion",OBJPROP_TEXT,"趋势感知：强势空头↓↓↓");
      ObjectSetInteger(0,"lblConclusion",OBJPROP_COLOR,clrHotPink);
      advice = "操作建议：打死坚决不做多";
   }
   else
   {   
      ObjectSetString(0,"lblConclusion",OBJPROP_TEXT,"趋势感知：无");
      ObjectSetInteger(0,"lblConclusion",OBJPROP_COLOR,clrBlack);
      advice = "操作建议：无";
   }
   // 显示操作建议
   ObjectSetString(0,"lblAdvice",OBJPROP_TEXT,advice);
   ObjectSetInteger(0,"lblAdvice",OBJPROP_XDISTANCE,16*StringLen(advice) + 16); 
   
}
