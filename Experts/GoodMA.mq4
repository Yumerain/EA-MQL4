//+------------------------------------------------------------------+
//|                                                           GoodMA.mq4 |
//|                           Copyright 448036253@qq.com |
//|                                           http://www.mql4.com |
/*                                     KISS                                            */
/* Keep It Simple Stupid（保持键和傻瓜化）        */
/* 好的交易系统不必复杂，保持交易系统的简单性可以带来较少的麻烦   */
//+------------------------------------------------------------------+
#property copyright "Copyright 2018 "
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//定义本EA操作的订单的唯一标识号码，由此可以实现在同一账户上多系统操作，各操作EA的订单标识码不同，就不会互相误操作。凡是EA皆不可缺少，非常非常重要！
#define MAGICMA  20181022

//--- 输入
input double Lots            =0.01;        //每单(手数)的交易量
//--- 方向ma周期
input int DirMaPeriod    =60;           //方向均线周期

input double SL               =200;
input double TP               =500;

//--- 参数
// 开发模式
bool debug = false;
// 是否对方向初始化
bool inited = false;
//方向：true-多, false-空
bool direction;


//+------------------------------------------------------------------+
/* 初始化 */
//+------------------------------------------------------------------+
int OnInit()
{
   Print("EA初始化了……");
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
/* 运行结束 */
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{ 
   Print("EA运行结束，已经卸载。" );
}

//+------------------------------------------------------------------+
/* 图标Tick事件 */
//+------------------------------------------------------------------+
void OnTick()
{
   // 检测蜡烛图是否足够数量，数量少了不足以形成可靠的周期线
   if(Bars(_Symbol,_Period)<60) // 如果总柱数少于60
   {
      Print("我们只有不到60个报价柱，无法用于计算可靠的指标, EA 将要退出!!");
      return;
   }
   
   // 【多空反转信号】
  // 多：K柱第一次收价在[方向]均线上方(最低价大于均线值)，并且均线向上，标记【做多】
  // 空：K柱第一次收价在[方向]均线下方(最高价小于均线值)，并且均线向下，标记【做空】
  // 当形成新的K线柱时前一根k柱刚刚收盘，判断方法：当前K线的成交价次数>1时
   if(Volume[0]<=1) {
     double heights[1], lows[1];
     CopyHigh(_Symbol,PERIOD_CURRENT,1,1,heights);
     CopyLow(_Symbol,PERIOD_CURRENT,1,1,lows);
     double height = heights[0];
     double low = lows[0];
     double maDir=iMA(_Symbol,PERIOD_CURRENT,DirMaPeriod,0,MODE_SMA,PRICE_CLOSE,0);
     double maDirPre=iMA(_Symbol,PERIOD_CURRENT,DirMaPeriod,1,MODE_SMA,PRICE_CLOSE,0);
     // 多头
     if(height>=maDir && low>=maDir && maDirPre < maDir){
        inited = true;
        direction = true;
     }
     // 空头
     else if(height<=maDir && low<=maDir && maDirPre > maDir){
        inited = true;
        direction = false;
     }
     else{
       inited = false;
     }
     Print("获取到方向[",direction,"],最高价=[",height,"],最低价=[",low,"],方向ma=[",maDir,"]");
   }
   
   // 资金管理：计算开仓量
   
   // 开仓计算
   CalcForOpen();
   
}

//+------------------------------------------------------------------+
/* 统计当前图表货币的持仓订单数 */
//+------------------------------------------------------------------+
int OrdersCount()
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
      /*//如果 仓单编号不是本系统编号，或者 仓单货币对不是当前货币对时，跳过本次循环
      if(OrderMagicNumber() != MAGICMA || OrderSymbol()!= _Symbol)
      { 
         Print("注意！订单魔术标记不符！仓单魔术编号=[",OrderMagicNumber(),"]","本EA魔术编号=[",MAGICMA,"]");
         continue;
      }*/
      if(OrderSymbol() == _Symbol)
      {
         count++;
      }      
   }
   return count;
}

//+------------------------------------------------------------------+
/* 计算开仓 */
//+------------------------------------------------------------------+
void CalcForOpen()
{
    // 当前货币持仓情况下不开新仓
    int openCount = OrdersCount();
    if(openCount>0)
    {
        if(debug)Print("当前货币[",_Symbol,"]开仓数量=[",openCount,"]");
        return;
    }
    
    // 没有获取到方向则不继续
    if(!inited)
    {     
        if(debug)Print("没有获取到方向，不开仓");
        return;
    }
   
    // 方向均线值
    double maDir=iMA(_Symbol,PERIOD_CURRENT,DirMaPeriod,0,MODE_SMA,PRICE_CLOSE,0);
    // 价格tick
    MqlTick  lastTick;
    SymbolInfoTick(_Symbol,lastTick);    
    
    if(direction)
    {
        // 多：当实时价格触及60均线时(小于或等于均线值)，且方向向上，开多单，止损20点，或出现多空反转信号平仓
        if(lastTick.bid <= maDir)
        {
        //发送仓单（当前货币对，卖出方向，手数，买价，滑点=2，止损20点，止赢50点，EA编号，不过期，标上红色箭头）
        Print("【多】单开仓结果：",OrderSend(_Symbol,OP_BUY,Lots,Ask,2,Ask-SL*Point,Bid+TP*Point,"",MAGICMA,0,Red));
        return;
        }
    }   
    else
    {
        // 空：当实时价格触及60均线时(大于或等于均线值)，且方向向下，开多单，止损20点，或出现多空反转信号平仓
        if(lastTick.bid >= maDir)
        {        
        //发送仓单（当前货币对，买入方向，手数，卖价，滑点=2，止损20点，止赢50点，EA编号，不过期，标上蓝色箭头）
        Print("【空】单开仓结果：",OrderSend(_Symbol,OP_SELL,Lots,Bid,2,Bid+SL*Point,Ask-TP*Point,"",MAGICMA,0,Blue));
        return;
        }
    }
}
