//+------------------------------------------------------------------+
//| On_Bot_Start_3.0_TakeProfit |
//| CBR |
//| www.capitalizebr.com |
//+------------------------------------------------------------------+
#property copyright "CBR"
#property link "www.capitalizebr.com"
#property version "3.0"
//+------------------------------------------------------------------+
//| INCLUDES |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh> // biblioteca-padrão CTrade

//+------------------------------------------------------------------+
//| INPUTS |
//+------------------------------------------------------------------+
input double lotSize = 0.1; // tamanho do lote
input int periodoCurta = 10; // período da média móvel curta
input int periodoLonga = 20; // período da média móvel longa
input int takeProfit = 50; // take profit em pontos
input double martingaleMultiplier = 1.5; // fator de martingale
input int violinPeriod = 20; // período do indicador Violin
input double violinFactor = 2.0; // fator do indicador Violin

//+------------------------------------------------------------------+
//| GLOBAIS |
//+------------------------------------------------------------------+
//--- manipuladores dos indicadores de média móvel
int curtaHandle = INVALID_HANDLE;
int longaHandle = INVALID_HANDLE;
//--- vetores de dados dos indicadores de média móvel
double mediaCurta[];
double mediaLonga[];
//--- variáveis para gerenciamento da posição
CTrade trade;
bool positionOpened = false;
int martingaleCount = 0;

//+------------------------------------------------------------------+
//| Expert initialization function |
//+------------------------------------------------------------------+
int OnInit()
{

//--- atribuir p/ os manupuladores de média móvel
curtaHandle = iMA(_Symbol, _Period, periodoCurta, 0, MODE_SMA, PRICE_CLOSE);
longaHandle = iMA(_Symbol, _Period, periodoLonga, 0, MODE_SMA, PRICE_CLOSE);

ArraySetAsSeries(mediaCurta, true);
ArraySetAsSeries(mediaLonga, true);

return (INIT_SUCCEEDED);
   

//+------------------------------------------------------------------+
//| INCLUDES |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh> // biblioteca-padrão CTrade

//+------------------------------------------------------------------+
//| INPUTS |
//+------------------------------------------------------------------+
input double lotSize = 0.1; // tamanho do lote
input int periodoCurta = 10; // período da média móvel curta
input int periodoLonga = 20; // período da média móvel longa
input int takeProfit = 50; // take profit em pontos
input double martingaleMultiplier = 1.5; // fator de martingale
input int violinPeriod = 20; // período do indicador Violin
input double violinFactor = 2.0; // fator do indicador Violin

//+------------------------------------------------------------------+
//| GLOBAIS |
//+------------------------------------------------------------------+
//--- manipuladores dos indicadores de média móvel
int curtaHandle = INVALID_HANDLE;
int longaHandle = INVALID_HANDLE;
//--- vetores de dados dos indicadores de média móvel
double mediaCurta[];
double mediaLonga[];
//--- variáveis para gerenciamento da posição
CTrade trade;
bool positionOpened = false;
int martingaleCount = 0;

//+------------------------------------------------------------------+
//| Expert initialization function |
//+------------------------------------------------------------------+

int OnInit()

{
//--- atribuir p/ os manupuladores de média móvel
curtaHandle = iMA(_Symbol, _Period, periodoCurta, 0, MODE_SMA, PRICE_CLOSE);
longaHandle = iMA(_Symbol, _Period, periodoLonga, 0, MODE_SMA, PRICE_CLOSE);

ArraySetAsSeries(mediaCurta, true);
ArraySetAsSeries(mediaLonga, true);

return (INIT_SUCCEEDED);
}


//+---------------------------------------------------- -------------------+ 
//| Função de desinicialização especializada |
 //+---------------------------------------------------- -------------------+ 
void OnDeinit(const int reason) 
{
 }

//+------------------------------------------------------------------+
//| Função principal |
//+------------------------------------------------------------------+
void OnTick()
{
if (isNewBar())
{
//--- execute a lógica operacional do robô

    //+------------------------------------------------------------------+
    //| OBTENÇÃO DOS DADOS |
    //+------------------------------------------------------------------+
    int copied1 = CopyBuffer(curtaHandle, 0, 0, 3, mediaCurta);
    int copied2 = CopyBuffer(longaHandle, 0, 0, 3, mediaLonga);

    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double last = SymbolInfoDouble(_Symbol, SYMBOL_LAST);

    Comment("Preço ASK = ", ask, "\nPreço BID = ", bid);

    //----
    bool sinalCompra = false;
    bool sinalVenda = false;

    //--- se os dados tiverem sido copiados corretamente
    if (copied1 == 3 && copied2 == 3)
    {
        //--- sinal de compra
        if (mediaCurta[1] > mediaLonga[1] && mediaCurta[2] < mediaLonga[2])
        {
            sinalCompra = true;
         }
        }
       }
        //
//--- sinal de venda if (short average[1] < long average[1] && short average[2] > long average[2]) { sellsignal = true; } } }

//+------------------------------------------------------------------+
//| ABERTURA DA POSIÇÃO |
//+------------------------------------------------------------------+
if (!positionOpened)
{
    //--- sinal de compra, abra posição de compra
    if (sinalCompra)
    {
        //--- abra uma posição de compra com o tamanho do lote definido
        trade.Buy(lotSize);

        //--- atualiza a variável para indicar que a posição foi aberta
        positionOpened = true;

        //--- reseta a contagem do martingale
        martingaleCount = 0;

        //--- coloca a posição no break even
        trade.SetBreakEven(10);
    }

    //--- sinal de venda, abra posição de venda
    else if (sinalVenda)
    {
        //--- abra uma posição de venda com o tamanho do lote definido
        trade.Sell(lotSize);

        //--- atualiza a variável para indicar que a posição foi aberta
        positionOpened = true;

        //--- reseta a contagem do martingale
        martingaleCount = 0;

        //--- coloca a posição no break even
        trade.SetBreakEven(10);
     }
  }
 }

//+------------------------------------------------------------------+
//| GERENCIAMENTO DA POSIÇÃO |
//+------------------------------------------------------------------+
else
{
    //--- se a posição de compra está aberta, verifique se deve ser fechada
    if (trade.PositionType() == POSITION_TYPE_BUY)
    {
        //--- calcula o lucro em pontos
        double lucro = (bid - trade.PositionOpenPrice()) / _Point;

        //--- verifica se o take profit foi atingido
        if (lucro >= takeProfit)
        {
            //--- fecha a posição
            trade.Close();

            //--- atualiza a variável para indicar que a posição foi fechada
            positionOpened = false;
        }
    }
}
    //--- se a posição de venda está aberta, verifique se deve ser fechada
    else if (trade.PositionType() == POSITION_TYPE_SELL)
    {
        //--- calcula o lucro em pontos
        double lucro = (trade.PositionOpenPrice() - ask) / _Point;

        //--- verifica se o take profit foi atingido
        if (lucro >= takeProfit)
        {
            //--- fecha a posição
            trade.Close();

            //--- atualiza a variável para indicar que a posição foi fechada
            positionOpened = false;
        }
    }

    //--- se a posição ainda estiver aberta e o preço estiver a favor da posição, coloca no break even
    if (positionOpened && trade.Profit() > 0)
    {
        trade.SetBreakEven(10);
    }

    //--- se a posição ainda estiver aberta e o preço estiver contra a posição, aplica martingale
    if (positionOpened && trade.Profit() < 0)
    {
        martingaleCount++;

        //--- verifica se ainda há margem para aplicar martingale
        if (martingaleCount <= 3)
        {
            double novoLote = lotSize * MathPow(martingaleMultiplier, martingaleCount);
           
//---- //--- sinal de compra if (mediaLong[1] > mediaLong[1] && mediaLong[2] < mediaLong[2]) { buySignal = true; } //--- sinal de banda if (mediaLong[1] < mediaLong[1] && mediaCurta[2] > mediaLong[2]) { bandSign = true; }

    //+------------------------------------------------------------------+
    //| GERENCIAMENTO DA POSIÇÃO |
    //+------------------------------------------------------------------+
    //--- verifica se já há posição aberta
    if (!positionOpened)
    {
        //--- se houver sinal de compra
        if (sinalCompra)
        {
            //--- abre a posição de compra
            trade.Buy(lotSize);
            //--- atualiza o flag de posição aberta
            positionOpened = true;
        }
        //--- se houver sinal de venda
        else if (sinalVenda)
        {
            //--- abre a posição de venda
            trade.Sell(lotSize);
            //--- atualiza o flag de posição aberta
            positionOpened = true;
        }
    }
    else //--- há posição aberta
    {
        //--- se a posição é de compra
        if (trade.PositionType() == POSITION_TYPE_BUY)
        {
            //--- calcula o lucro da posição em pontos
            double lucro = (ask - trade.PositionOpenPrice()) / _Point;
            //--- se o lucro atingir o take profit
            if (lucro >= takeProfit)
            {
                //--- fecha a posição
                trade.Close();
                //--- atualiza o flag de posição aberta
                positionOpened = false;
                //--- reseta o contador de martingale
                martingaleCount = 0;
            }
            else //--- se o lucro ainda não atingiu o take profit
            {
                //--- calcula o valor do stop loss
                double stopLoss = trade.PositionOpenPrice() - (violinFactor * iCustom(_Symbol, _Period, "Violin", violinPeriod, 0, 0));
                //--- modifica o stop loss
                trade.ModifyPosition(trade.PositionOpenPrice(), stopLoss, 0);
            }
        }
        //--- se a posição é de venda
        else if (trade.PositionType() == POSITION_TYPE_SELL)
        {
            //--- calcula o lucro da posição em pontos
            double lucro = (trade.PositionOpenPrice() - bid) / _Point;
            //--- se o lucro atingir o take profit
            if (lucro >= takeProfit)
            {
                //--- fecha a posição
                trade.Close();
                //--- atualiza o flag de posição aberta
                positionOpened = false;
                //--- reseta o contador de martingale
                martingaleCount = 0;
            }
            else //--- se o lucro ainda não atingiu o take profit
            {
                //--- calcula o valor do stop loss
                double stopLoss = trade.PositionOpenPrice() + (violinFactor * iCustom(_Symbol, _Period, "Violin", violinPeriod, 0, 0));
                //--- modifica o stop loss
                trade.ModifyPosition(trade.PositionOpenPrice(), stopLoss, 0);
            }
        }

        //--- se houve uma mudança no número de ordens abertas
        if (trade.OrdersTotal() != martingaleCount)
       
//--- se o robô estiver em posição de compra
if (positionOpened && trade.PositionType() == POSITION_TYPE_BUY)
{
//--- verifique se há lucro suficiente para fechar a posição
if (bid - trade.PositionOpenPrice() >= takeProfit * _Point)
{
//--- feche a posição e reinicie o controle de martingale
trade.PositionClose();
positionOpened = false;
martingaleCount = 0;
}
}
//--- se o robô não estiver em posição e houver sinal de compra
else if (!positionOpened && sinalCompra)
{
//--- abra uma posição de compra e configure o stop loss e take profit
trade.Buy(lotSize, ask);
trade.PositionModify(0, 0, bid - takeProfit * _Point, 0);
positionOpened = true;
}
}
}

//+------------------------------------------------------------------+
//| Funções auxiliares |
//+------------------------------------------------------------------+
bool isNewBar()
{
static datetime lastBarTime = 0;

if (lastBarTime != iTime(_Symbol, _Period, 0))
{
    lastBarTime = iTime(_Symbol, _Period, 0);
    return (true);
}
else
{
    return (false);
}
}

double getViolin() { double ma = iMA(_Symbol, _Period, violinPeriod, 0, MODE_EMA, PRICE_CLOSE); desvio duplo = 0,0; dupla soma = 0,0;

for (int i = 0; i < violinPeriod; i++)
{
    deviation += MathPow(iMA(_Symbol, _Period, violinPeriod, i, MODE_EMA, PRICE_CLOSE) - ma, 2);
}

deviation = MathSqrt(deviation / violinPeriod);

for (int i = 0; i < violinPeriod; i++)
{
    double w = MathExp(-(MathPow(i, 2) / (2 * MathPow(deviation, 2))));
    sum += w * iMA(_Symbol, _Period, violinPeriod, i, MODE_EMA, PRICE_CLOSE);
}

return (sum / violinPeriod);

}
    //--- se há posição aberta
    if (positionOpened)
    {
        //--- se houve disparo de take profit
        if (positionProfit() >= takeProfit)
        {
            Comment("Take profit disparado. Lucro da operação = ", positionProfit());
            trade.PositionClose();
            positionOpened = false;
            martingaleCount = 0;
            return;
        }

        //--- se houve disparo de stop loss
        if (positionLoss() >= trade.PositionStopLoss())
        {
            Comment("Stop loss disparado. Prejuízo da operação = ", positionLoss());
            trade.PositionClose();
            positionOpened = false;
            martingaleCount++;
            return;
        }
    }

    //--- sinal de venda
    if (mediaCurta[1] < mediaLonga[1] && mediaCurta[2] > mediaLonga[2])
    {
        sinalVenda = true;
    }

    //--- sinal de violino
    bool sinalViolin = (iVi(_Symbol, _Period, violinPeriod, violinFactor, PRICE_CLOSE, 0) > 0);

    //--- se houver sinal de compra e não houver posição aberta
    if (sinalCompra && !positionOpened && !sinalViolin)
    {
        Comment("Sinal de compra detectado.");
        bool buyResult = trade.Buy(lotSize, 0, 0, 0, 0);
        if (buyResult)
        {
            positionOpened = true;
            martingaleCount = 0;
            Comment("Ordem de compra executada. Volume = ", lotSize);
        }
    }

    //--- se houver sinal de venda e não houver posição aberta
    if (sinalVenda && !positionOpened && !sinalViolin)
    {
        Comment("Sinal de venda detectado.");
        bool sellResult = trade.Sell(lotSize, 0, 0, 0, 0);
        if (sellResult)
        {
            positionOpened = true;
            martingaleCount = 0;
            Comment("Ordem de venda executada. Volume = ", lotSize);
        }
    }

    //--- se houver posição aberta e o sinal de violino for verdadeiro
    if (positionOpened && sinalViolin)
    {
        Comment("Sinal de violino detectado. Fechando posição.");
        trade.PositionClose();
        positionOpened = false;
        martingaleCount++;
    }

    //--- se ultrapassou o limite de martingale, fecha tudo
    if (martingaleCount > 2)
    {
        Comment("Número máximo de martingales atingido. Encerrando todas as posições.");
        trade.PositionClose();
        positionOpened = false;
        martingaleCount = 0;
    }
}

//--- sinal de venda if (short average[1] < long average[1] && short average[2] > long average[2]) { sellsignal = true; } } }
//+------------------------------------------------------------------+
//| OPERACIONAL |
//+------------------------------------------------------------------+
//--- se não há posição aberta
if (!positionOpened)
{
    //--- sinal de compra detectado
    if (sinalCompra)
    {
        //--- enviar ordem de compra a mercado
        double stopLoss = ask - 3 * Point();
        double volume = lotSize * martingaleMultiplier * MathPow(2, martingaleCount);
        if (trade.Buy(volume, stopLoss, ask + takeProfit * Point()))
        {
            //--- alterar o status de posição aberta
            positionOpened = true;
            //--- zerar contagem de martingale
            martingaleCount = 0;
        }
    }
    //--- sinal de venda detectado
    else if (sinalVenda)
    {
        //--- enviar ordem de venda a mercado
        double stopLoss = bid + 3 * Point();
        double volume = lotSize * martingaleMultiplier * MathPow(2, martingaleCount);
        if (trade.Sell(volume, stopLoss, bid - takeProfit * Point()))
        {
            //--- alterar o status de posição aberta
            positionOpened = true;
            //--- zerar contagem de martingale
            martingaleCount = 0;
        }
    }
}
//--- se há posição aberta
else
{
    //--- recuperar o tipo da posição aberta
    ENUM_ORDER_TYPE type = trade.Type();
    //--- sinal de venda detectado em posição de compra
    if (type == ORDER_TYPE_BUY && sinalVenda)
    {
        //--- fechar posição de compra e abrir posição de venda
        double stopLoss = bid + 3 * Point();
        double volume = lotSize * martingaleMultiplier * MathPow(2, martingaleCount);
        if (trade.Sell(volume, stopLoss, bid - takeProfit * Point()))
        {
            //--- incrementar a contagem de martingale
            martingaleCount++;
        }
    }
    //--- sinal de compra detectado em posição de venda
    else if (type == ORDER_TYPE_SELL && sinalCompra)
    {
        //--- fechar posição de venda e abrir posição de compra
        double stopLoss = ask - 3 * Point();
        double volume = lotSize * martingaleMultiplier * MathPow(2, martingaleCount);
        if (trade.Buy(volume, stopLoss, ask + takeProfit * Point()))
        {
            //--- incrementar a contagem de martingale
            martingaleCount++;
        }
    }
    //--- posição de compra em lucro, verificar stop loss
    else if (type == ORDER_TYPE_BUY)
    {
        double stopLoss = trade.StopLoss();
        double violin = iCustom(_Symbol, _Period, "Violin", violinPeriod, violinFactor, 0);
        if (last <= stopLoss || last <= violin)
        {
            //--- fechar posição de compra
            trade.Close(ORDER_TYPE_BUY, trade.Volume());
            //--- alterar o status de posição aberta
            positionOpened = false;
        }
    }
    //--- posição de venda em lucro, verificar stop loss
    //---
    bool sinalCompra = false;
    bool sinalVenda = false;

    //--- se os dados tiverem sido copiados corretamente
    if (copied1 == 3 && copied2 == 3)
    {
        //--- sinal de compra
        if (mediaCurta[1] > mediaLonga[1] && mediaCurta[2] < mediaLonga[2])
        {
            sinalCompra = true;
        }
        //--- sinal de venda
        if (mediaCurta[1] < mediaLonga[1] && mediaCurta[2] > mediaLonga[2])
        {
            sinalVenda = true;
        }
    }
    //+------------------------------------------------------------------+

    //+------------------------------------------------------------------+
    //| ABERTURA DA POSIÇÃO |
    //+------------------------------------------------------------------+
    if (sinalCompra && !positionOpened)
    {
        //--- abre a posição de compra
        double volume = lotSize * martingaleMultiplier;
        double stopLoss = ask - violinFactor * iCustom(_Symbol, _Period, "Violin", violinPeriod, 0);
        double takeProfitPrice = ask + takeProfit * _Point;
        bool buyOrder = trade.Buy(volume, _Symbol, slippage, stopLoss, takeProfitPrice);
        if (buyOrder)
        {
            positionOpened = true;
            martingaleCount = 0;
            Comment("Ordem de compra aberta. Volume: ", volume);
        }
        else
        {
            Comment("Erro ao abrir ordem de compra. Código do erro: ", trade.ResultRetcode(), ". Descrição do erro: ", trade.ResultRetcodeDescription());
        }
    }
    else if (sinalVenda && !positionOpened)
    {
        //--- abre a posição de venda
        double volume = lotSize * martingaleMultiplier;
        double stopLoss = bid + violinFactor * iCustom(_Symbol, _Period, "Violin", violinPeriod, 0);
        double takeProfitPrice = bid - takeProfit * _Point;
        bool sellOrder = trade.Sell(volume, _Symbol, slippage, stopLoss, takeProfitPrice);
        if (sellOrder)
        {
            positionOpened = true;
            martingaleCount = 0;
            Comment("Ordem de venda aberta. Volume: ", volume);
        }
        else
        {
            Comment("Erro ao abrir ordem de venda. Código do erro: ", trade.ResultRetcode(), ". Descrição do erro: ", trade.ResultRetcodeDescription());
        }
    }
    //+------------------------------------------------------------------+

    //+------------------------------------------------------------------+
    //| FECHAMENTO DA POSIÇÃO |
    //+------------------------------------------------------------------+
    if (positionOpened)
    {
        //--- verifica o lucro atual
        double profit = trade.Profit();
        if (profit >= takeProfit * _Point || profit <= -takeProfit * _Point)
        {
            //--- fecha a posição atual
            bool closeOrder = trade.Close();
            if (closeOrder)
            {
                positionOpened = false;
                Comment("Ordem fechada. Lucro: ", profit);
            }
            else
            {
                Comment("Erro ao fechar ordem. Código do erro: ", trade.ResultRetcode(), ". Descrição do erro: ", trade.ResultRetcodeDescription());
            }
        }
        else if (profit <= -slippage * _Point)
        {
            //--- abre uma ordem de martingale
            martingaleCount++;
    //---
    bool sinalCompra = false;
    bool sinalVenda = false;

    //--- se os dados tiverem sido copiados corretamente
    if (copied1 == 3 && copied2 == 3)
    {
        //--- sinal de compra
        if (mediaCurta[1] > mediaLonga[1] && mediaCurta[2] < mediaLonga[2])
        {
            sinalCompra = true;
        }
        //--- sinal de venda
        else if (mediaCurta[1] < mediaLonga[1] && mediaCurta[2] > mediaLonga[2])
        {
            sinalVenda = true;
        }
    }

    //+------------------------------------------------------------------+
    //| ABERTURA DE POSIÇÃO |
    //+------------------------------------------------------------------+
    //--- se houver sinal de compra e posição ainda não foi aberta
    if (sinalCompra && !positionOpened)
    {
        //--- abre posição de compra com o tamanho de lote especificado
        if (trade.Buy(lotSize) == true)
        {
            positionOpened = true;
            martingaleCount = 0;
        }
    }
    //--- se houver sinal de venda e posição ainda não foi aberta
    else if (sinalVenda && !positionOpened)
    {
        //--- abre posição de venda com o tamanho de lote especificado
        if (trade.Sell(lotSize) == true)
        {
            positionOpened = true;
            martingaleCount = 0;
        }
    }

    //+------------------------------------------------------------------+
    //| ENCERRAMENTO DE POSIÇÃO |
    //+------------------------------------------------------------------+
    //--- se posição estiver aberta
    if (positionOpened)
    {
        double currentProfit = trade.Profit();
        int currentTicket = trade.OrderTicket();
        double currentTakeProfit = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
        double currentSpread = SymbolInfoDouble(_Symbol, SYMBOL_SPREAD);

        //--- se posição estiver em lucro
        if (currentProfit > 0)
        {
            //--- define o take profit da posição
            double newTakeProfit = currentSpread + (currentProfit / takeProfit);
            trade.SetTakeProfit(currentTicket, newTakeProfit);

            //--- se take profit foi atingido
            if (last >= newTakeProfit && trade.Close(currentTicket) == true)
            {
                positionOpened = false;
            }
        }
        //--- se posição estiver em prejuízo
        else
        {
            //--- se martingale estiver habilitado e houver
            //--- ultrapassagem do limite de martingale
            if (martingaleMultiplier > 1.0 && martingaleCount >= 2)
            {
                double newLotSize = lotSize * martingaleMultiplier;
                martingaleCount = 0;

                //--- tenta abrir posição com novo tamanho de lote
                if (trade.Buy(newLotSize) == true)
                {
                    lotSize = newLotSize;
                    positionOpened = true;
                }
            }
            //--- caso contrário, verifica se posição deve ser fechada
            else
            {
                //--- obtém o valor atual do indicador Violin
                double violinValue = iCustom(_Symbol, _Period, "Violin", violinPeriod, violinFactor);

                //--- se preço atingir o valor do indicador Violin
                if
        //--- sinal de venda
        if (mediaCurta[1] < mediaLonga[1] && mediaCurta[2] > mediaLonga[2])
        {
            sinalVenda = true;
        }
    }

    //+------------------------------------------------------------------+
    //| OPERACIONAL |
    //+------------------------------------------------------------------+
    if (!positionOpened)
    {
        //--- abrir posição de compra
        if (sinalCompra)
        {
            trade.Buy(lotSize, ask, 0, "", 0, 0, 0, "");
            positionOpened = true;
            martingaleCount = 0;
            Comment("Ordem de COMPRA aberta.");
        }
        //--- abrir posição de venda
        if (sinalVenda)
        {
            trade.Sell(lotSize, bid, 0, "", 0, 0, 0, "");
            positionOpened = true;
            martingaleCount = 0;
            Comment("Ordem de VENDA aberta.");
        }
    }
    else
    {
        //--- atualizar stop loss e take profit
        double orderOpenPrice = trade.PositionOpenPrice();
        int orderType = trade.PositionType();

        if (orderType == POSITION_TYPE_BUY)
        {
            double newStopLoss = orderOpenPrice + (violinFactor * iCustom(NULL, 0, "Violin", violinPeriod, 0));
            if (newStopLoss > bid)
            {
                trade.ModifyPosition(orderOpenPrice, newStopLoss, orderOpenPrice + (takeProfit * _Point));
                Comment("Stop Loss atualizado para: ", newStopLoss, "\nTake Profit atualizado para: ", orderOpenPrice + (takeProfit * _Point));
            }
        }
        else if (orderType == POSITION_TYPE_SELL)
        {
            double newStopLoss = orderOpenPrice - (violinFactor * iCustom(NULL, 0, "Violin", violinPeriod, 0));
            if (newStopLoss < ask)
            {
                trade.ModifyPosition(orderOpenPrice, newStopLoss, orderOpenPrice - (takeProfit * _Point));
                Comment("Stop Loss atualizado para: ", newStopLoss, "\nTake Profit atualizado para: ", orderOpenPrice - (takeProfit * _Point));
            }
        }

        //--- encerrar posição com martingale
        if (trade.PositionProfit() > 0)
        {
            double orderProfit = trade.PositionProfit();
            double orderStopLoss = trade.PositionStopLoss();
            double newLotSize = lotSize * MathPow(martingaleMultiplier, martingaleCount);
            if (orderProfit >= (takeProfit * _Point))
            {
                trade.Close(trade.PositionTicket(), bid, 0, 0, "");
                Comment("Ordem de ", (orderType == POSITION_TYPE_BUY) ? "COMPRA" : "VENDA", " fechada com lucro de ", orderProfit, " pontos.");
                positionOpened = false;
                martingaleCount = 0;
            }
            else if (orderStopLoss < bid && martingaleCount < 5)
            {
                trade.ModifyPosition(orderOpenPrice, orderOpenPrice - (newStopLoss - orderOpenPrice), 0);
                trade.Buy(newLotSize, ask, 0, "", 0, 0, 0, "");
                Comment("Nova ordem de COMPRA aberta com lote de ", newLotSize);
                martingaleCount++;
            }
        }
        else
       
    //--- se o sinal de compra está presente
    if (sinalCompra)
    {
        //--- se não há posição aberta
        if (!positionOpened)
        {
            //--- abre posição de compra
            trade.Buy(lotSize);
            positionOpened = true;
            Comment("Aberta posição de compra");
        }
        //--- se há posição aberta
        else
        {
            //--- verifica se há lucro
            if (trade.NetProfit() >= takeProfit * _Point)
            {
                //--- fecha posição com lucro
                trade.Close();
                positionOpened = false;
                Comment("Fechada posição de compra com lucro");
                martingaleCount = 0;
            }
        }
    }
    //--- se o sinal de venda está presente
    else if (sinalVenda)
    {
        //--- se não há posição aberta
        if (!positionOpened)
        {
            //--- abre posição de venda
            trade.Sell(lotSize);
            positionOpened = true;
            Comment("Aberta posição de venda");
        }
        //--- se há posição aberta
        else
        {
            //--- verifica se há lucro
            if (trade.NetProfit() >= takeProfit * _Point)
            {
                //--- fecha posição com lucro
                trade.Close();
                positionOpened = false;
                Comment("Fechada posição de venda com lucro");
                martingaleCount = 0;
            }
        }
    }
    //--- se nenhum sinal está presente
    else
    {
        //--- verifica se há posição aberta
        if (positionOpened)
        {
            //--- aplica martingale
            martingaleCount++;
            double newLotSize = lotSize * MathPow(martingaleMultiplier, martingaleCount);
            trade.ModifyPosition(newLotSize, 0);
            Comment("Martingale aplicado: novo tamanho de lote = ", newLotSize);
        }
    }
    //+------------------------------------------------------------------+

    //+------------------------------------------------------------------+
    //| ANÁLISE DO INDICADOR VIOLIN |
    //+------------------------------------------------------------------+
    double violin[];
    int copied3 = iCustom(_Symbol, _Period, "Violin", violinPeriod, violinFactor, 0, 0, violin);
    ArraySetAsSeries(violin, true);

    //--- se os dados tiverem sido copiados corretamente
    if (copied3 > 0)
    {
        //--- sinal de compra
        if (violin[1] > 0 && violin[2] < 0)
        {
            sinalCompra = true;
            sinalVenda = false;
        }
        //--- sinal de venda
        else if (violin[1] < 0 && violin[2] > 0)
        {
            sinalCompra = false;
            sinalVenda = true;
        }
    }
    //+------------------------------------------------------------------+
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Função de verificação de nova barra |
//+------------------------------------------------------------------+
bool isNewBar()
{
    static datetime lastTime = 0;
    datetime curTime = iTime(_Symbol, _Period, 0);
    if (curTime != lastTime)
    {
        lastTime = curTime;
        return true;
    }
    return false;}
    }
    
   }
   }
   }
   }
//+------------------------------------------------------------------+
