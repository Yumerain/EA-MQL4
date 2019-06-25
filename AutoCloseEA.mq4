//+------------------------------------------------------------------+
//|                                                  AutoCloseEA.mq4 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Aother."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//--- 输入参数
input double CloseAtProfit         =100;        //平仓盈利额，默认100


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{   
   // 遍历订单，统计盈利
   double totalProfit = SumProfit();
   Print("DEBUG=>统计利润=[",totalProfit,"]，设定退出利润=[",CloseAtProfit,"]");
   if(totalProfit >CloseAtProfit)
   {      
      CloseAllOrder();
   }   
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| 统计盈利
//+------------------------------------------------------------------+
double SumProfit()
{
   double sum = 0;
   // 遍历订单，关闭全部
   for(int i=0;i<OrdersTotal();i++)
   {      
      // 选中仓单，选择不成功时，跳过本次循环
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
      {
         Print("统计盈利=>注意！选中仓单失败！序号=[",i,"]");
         continue;
      }
      sum += OrderProfit();
    }
    return sum;
}


//+------------------------------------------------------------------+
//| 平仓，关闭所有订单
//+------------------------------------------------------------------+
void CloseAllOrder()
{
   // 遍历订单，关闭全部
   for(int i=0;i<OrdersTotal();i++)
   {      
      // 选中仓单，选择不成功时，跳过本次循环
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
      {
         Print("自动平仓=>注意！选中仓单失败！序号=[",i,"]");
         continue;
      }
      //如果 仓单编号不是本系统编号，或者 仓单货币对不是当前货币对时，跳过本次循环
      /*if(OrderMagicNumber() != MAGICMA || OrderSymbol()!= _Symbol)
      { 
         Print("注意！订单魔术标记不符！仓单魔术编号=[",OrderMagicNumber(),"]","本EA魔术编号=[",MAGICMA,"]");
         continue;
      }*/
      Print("自动平仓=>处理订单ticket=[",OrderTicket(),"],品种=[",OrderSymbol(),"],手数=[",OrderLots(),"]");
      // 多单平仓：
      if(OrderType()==OP_BUY)
      {
         if(!OrderClose(OrderTicket(),OrderLots(),Bid,2,White)) Print("自动平仓=>关闭[多]单出错",GetLastError());
         continue;
      }
      // 空单平仓：
      if(OrderType()==OP_SELL)
      {
         if(!OrderClose(OrderTicket(),OrderLots(),Ask,3,White)) Print("自动平仓=>关闭[空]单出错",GetLastError());
         continue;
      }
   }
}
