//+------------------------------------------------------------------+
//|                                                     CloseAll.mq4 |
//|                                           Copyright 2019, Aother |
//|                                                 448036253@qq.com |
//|       一键关闭所有订单，手动进行马丁式交易时快速平掉所有仓位     |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Aother"
#property link      "448036253@qq.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   int count = OrdersTotal();
   Print("一键平仓开始执行，开始处理[",count,"]个订单……");
   // 遍历订单，关闭全部
   for(int i=0;i<count;i++)
   {      
      // 选中仓单，选择不成功时，跳过本次循环
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)
      {
         Print("一键平仓=>注意！选中仓单失败！序号=[",i,"]");
         continue;
      }
      //Print("一键平仓=>处理订单ticket=[",OrderTicket(),"],品种=[",OrderSymbol(),"],手数=[",OrderLots(),"]");
      // 多单平仓：
      if(OrderType()==OP_BUY)
      {
         if(!OrderClose(OrderTicket(),OrderLots(),Bid,0,White)) Print("一键平仓=>关闭[多]单出错",GetLastError());
         continue;
      }
      // 空单平仓：
      if(OrderType()==OP_SELL)
      {
         if(!OrderClose(OrderTicket(),OrderLots(),Ask,0,White)) Print("一键平仓=>关闭[空]单出错",GetLastError());
         continue;
      }
   }
   Print("一键平仓执行结束");
}
