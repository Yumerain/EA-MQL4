//+------------------------------------------------------------------+
//|                                                      TrendMacd.mq4 |
//|             Copyright Aother 448036253@qq.com |
//|                                           http://www.mql4.com |
/*                               KISS                               */
/* Keep It Simple Stupid（保持键和傻瓜化）                          */
/* 好的交易系统不必复杂，保持交易系统的简单性可以带来较少的麻烦。   */
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//定义本EA操作的订单的唯一标识号码，由此可以实现在同一账户上多系统操作，各操作EA的订单标识码不同，就不会互相误操作。凡是EA皆不可缺少，非常非常重要！
#define MAGICMA  201808031

//--- 输入
input double Lots            =0.01;        //每单(手数)的交易量
input double TP               =1000;         //止盈点数
input double SL                =300;         //止损点数

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
/*
函数是 初始化 事件处理程序。 必须是空型或者整型，无参数：
初始化事件处理程序在EA交易或者指标下载后即时生成；它不生成脚本。OnInit()函数用于初始化。如果OnInit()返回值为整型，非零结果意味着初始化失败，生成初始化失败原因代码REASON_INITFAILED 。
要优化EA交易的输入参数，推荐使用ENUM_INIT_RETCODE枚举值作为返回代码。这些值用于组织优化的过程，包括选择最合适的测试代理。在EA交易的初始化期间测试开始之前您可以使用TerminalInfoInteger() 函数请求一个代理的配置和资源信息(内核数量，空余内存额，等等)。根据所获得的信息，您可以在EA交易优化过程中选择允许使用这个测试代理，或拒绝使用它。
*/
//+------------------------------------------------------------------+
int OnInit()
{
   Print("EA初始化了……");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
/*
函数称为失败初始化，是初始化失败事件处理程序。必须是空型且有一个包括初始化失败原因代码 的常量整型参数。如果声明不同类型，编译程序会发出警告，但函数不可调用。对于脚本来说不会生成初始化失败事件，因此OnDeinit()函数不用于脚本。
在以下情况下EA交易和指标生成初始化失败：Deinit事件在以下情况下为EA交易和指标而生成：
再次初始化前，mql5程序下的交易品种和图表周期发生变化；
再次初始化前，输入参数发生变化；
mql5程序卸载前。
*/
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{ 
   Print("EA运行结束，已经卸载。" );
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
/*
仅仅EA交易依附的图表中，交易品种收到新订单号时EA交易会生成 新订单号 事件。自定义指标或者脚本中确定OnTick()函数是无效的，因为订单号事件不为它们而生。
订单号事件只为EA交易而生，但是却不意味着EA交易需要OnTick()函数，因为EA交易不仅需要生成订单号，也需要生成计时器，预定事件和图表事件。这些都需要空型，无参数：
*/
//+------------------------------------------------------------------+
void OnTick()
{
   // 检测蜡烛图是否足够数量，数量少了不足以形成可靠的周期线
   if(Bars(_Symbol,_Period)<60) // 如果总柱数少于60
   {
      Print("我们只有不到60个报价柱，无法用于计算可靠的指标, EA 将要退出!!");
      return;
   }
   // 当形成新的K线柱时才执行，判断方法：当前K线的成交价次数>1时，则返回
   if(Volume[0]>1) return;
   
   // 计算当前周期的macd值
   // 指标
   double indicatorPrev=iMACD(_Symbol,PERIOD_CURRENT,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double indicator=iMACD(_Symbol,PERIOD_CURRENT,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   // 信号
   double signalPrev=iMACD(_Symbol,PERIOD_CURRENT,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   double signal=iMACD(_Symbol,PERIOD_CURRENT,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);
   
   // (平空单)
    if(indicator>signal)
    {
        CloseForType(OP_SELL);    
    }
    // (平多单)
     if(indicator<signal)
     {
        CloseForType(OP_BUY);
     }
   
   // 信号为多头，金叉下多单 (平空单)
   if(signal>0 && (indicator>signal && indicatorPrev < signalPrev) && CountOrder(OP_BUY)==0)
   {
      //发送仓单（当前货币对，卖出方向，手数，买价，滑点=2，止损，止赢，EA编号，不过期，标上红色箭头）
      //double stoploss=NormalizeDouble(Bid-SL*Point,Digits);
      //double takeprofit=NormalizeDouble(Bid+TP*Point,Digits);
      Print("【多】单开仓结果：",OrderSend(_Symbol,OP_BUY,Lots,Ask,2,0,0,"",MAGICMA,0,Red));
      return;
   }
   
   // 信号为空头，死叉下空单 (平多单)
   if(signal<0 &&  (indicator<signal && indicatorPrev > signalPrev) && CountOrder(OP_SELL)==0)
   {
      //发送仓单（当前货币对，买入方向，手数，卖价，滑点=2，止损，止赢，EA编号，不过期，标上蓝色箭头）
    //  double stoploss=NormalizeDouble(Ask+SL*Point,Digits);
    //  double takeprofit=NormalizeDouble(Ask-TP*Point,Digits);
      Print("【空】单开仓结果：",OrderSend(_Symbol,OP_SELL,Lots,Bid,2,0,0,"",MAGICMA,0,Blue));
      return;
   }
}

// 统计订单数量
int CountOrder(int OP_Type)
{
    int count = 0;
   // 遍历订单处理
   for(int i=0;i<OrdersTotal();i++)
   {
      // 选中仓单，选择不成功时，跳过本次循环
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
      {
         Print("注意！选中仓单失败！序号=[",i,"]");
         continue;
      }
      //如果 仓单编号不是本系统编号，或者 仓单货币对不是当前货币对时，跳过本次循环
      if(OrderMagicNumber() != MAGICMA || OrderSymbol()!= _Symbol)
      { 
         Print("注意！订单魔术标记不符！仓单魔术编号=[",OrderMagicNumber(),"]","本EA魔术编号=[",MAGICMA,"]");
         continue;
      }
      // 统计单数
      if(OrderType()==OP_Type)
      {
         count++;
      }
   }
   return count;
}


// 关闭订单
void CloseForType(int OP_Type)
{
   // 遍历订单处理
   for(int i=0;i<OrdersTotal();i++)
   {
      // 选中仓单，选择不成功时，跳过本次循环
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
      {
         Print("注意！选中仓单失败！序号=[",i,"]");
         continue;
      }
      //如果 仓单编号不是本系统编号，或者 仓单货币对不是当前货币对时，跳过本次循环
      if(OrderMagicNumber() != MAGICMA || OrderSymbol()!= _Symbol)
      { 
         Print("注意！订单魔术标记不符！仓单魔术编号=[",OrderMagicNumber(),"]","本EA魔术编号=[",MAGICMA,"]");
         continue;
      }
      // 关闭多单平仓：
      if(OrderType()==OP_BUY && OP_Type==OP_BUY)
      {
         if(!OrderClose(OrderTicket(),OrderLots(),Bid,2,White)) Print("关闭[多]单出错",GetLastError());
         continue;
      }
      // 关闭空单平仓：
      if(OrderType()==OP_SELL && OP_Type==OP_SELL)
      {
         if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,White)) Print("关闭[空]单出错",GetLastError());
         continue;
      }
   }
}
