# EA-MQL4
基于MQL4平台使用MQL4语言实现
* Experts内为可以执行自动交易的EA
* Indicators内为指标
* Scripts内为一些便捷操作脚本，拖动到图表上就会立即执行

## 功能说明
### Experts自动交易
AutoCloseEA.mq4是一个自动平仓EA，设定盈利金额启动后会一直执行检测，达到的话自定平掉所有仓单，无论是手动下的单还是自动下的单<br/>
OKMA.mq4是一个基于均线交叉的自动交易EA<br/>
TrendMacd.mq4一个基于MACD指标金叉死叉的趋势型EA<br/>
GoodMA.mq4现阶段历史回测多品种最好的一个，以60MA作为支撑压力，突破后回踩入场<br/>
Pinball.mq4	布林走平时，震荡行情超卖做多超买做空<br/>
BetaMT.mq4 马丁格尔策略，爆仓是它最终的命运，不要被它美丽的资金曲线迷惑<br/>

### Indicators指标或基于ea的指标
EasyTrend.mq4一个傻瓜式的趋势指示器，不要做禁止方向的单子，提高胜率<br/>
XBands.mq4一个把中线调粗了点的布林，便于和其他加粗均线组成系统，而不用重复一条20均线<br/>
Trend-V20.mq4一个指标解读<br/>
Trend-V30.mq4	一个更加详细的趋势解读<br/>
Fishe.mq4	迄今为止最亮的自定义指标，具体效果参考图表GBPAUD，4H的MACD用于指示方向，小周期的自定义均线组成交叉点构成信号，同时提示最大仓位防止重仓<br/>

### Scripts脚本
CloseAll.mq4一键关闭所有订单，手动进行马丁式交易时快速平掉所有仓位<br/>

## 简单清晰的图表
KISS.mq4  指标指示器，简易的解读，大小周期结合，蜡烛剩余时间，枢轴支阻线。<br/>
思路：大周期使用macd相对灵活不易错失机会，小周期使用均线组相对稳定过滤杂波，数轴线只保留了轴心和S1及R1保持简单作为参考。<br/>
注：折线图为系统自带指标ZigZag，去掉了之前不成熟的操作建议，留下思考空间，后续想法改进<br/>
目前相对满意的一个图表，配合图标模板KISS.tpl。<br/>
![伦敦金XAUUSD](https://github.com/Yumerain/EA-MQL4/blob/master/xau.png)
迄今为止最亮的自定义指标<br/>
![英镑兑澳元](https://github.com/Yumerain/EA-MQL4/blob/master/GBPAUD.png)
不要迷信马丁，基础手数0.03，初始资金1000，2020.4.1至2020.9.2才没爆仓<br/>
![马丁EA资金曲线](https://github.com/Yumerain/EA-MQL4/blob/master/acct.png)
