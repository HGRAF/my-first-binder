using AlphaVantage
AlphaVantage.global_key!("D4YX98JUGBVQTLFT")

using DataFrames, StatsPlots, Dates, DataFramesMeta

gr(size=(800,470))


# Get daily S&P 500 data
other_stocks=["NVDA", "IBM", "SLB", "HAL", "AMZN", "AMD", "BYDDF", "GELYF"]

stocks=["NVDA"]

for i=1:length(stocks)
    println()
    println()
    println("Company Overview","\n")
    
    co = AlphaVantage. company_overview(stocks[i])
    for k in keys(co)
        println(k," => ", co[k])
    end


    spy= time_series_daily(stocks[i],outputsize="compact", datatype="csv");
    # Convert to a DataFrame
    data = DataFrame(spy[1],:auto);
    println(stocks[i])
    println(first(data,5),"\n")
    # Add column names
    data = rename(data, Symbol.(vcat(spy[2]...)));
    # Convert timestamp column to Date type
    data[!, :timestamp] = Dates.Date.(data[!, :timestamp]);
    data[!, :close] = Float64.(data[!, :close])
    # Plot the timeseries
    display(plot(data[!, :timestamp], data[!, :close], label="Close",
        ylabel="US Dollar", title=stocks[i]))
    #savefig("sp500.png")


    cashflow = AlphaVantage.cashflowFromFinancing_annuals(stocks[i])

    display(plot(Date.(cashflow[:Date]), 
        parse.(Float64, cashflow[:cashflowFromFinancing]) ./ 1e9, 
        label="Cash Flow from Financing (billions)",
        title = stocks[i], xlabel="Date", ylabel="Cash flow [1e9]", 
        legend=:topleft))

  
    rsiRaw = AlphaVantage.RSI(stocks[i], "daily", 10, "open", datatype="csv");
    rsiDF = DataFrame(rsiRaw[1], :auto)
        
    rsiDF = rename(rsiDF, Symbol.(vcat(rsiRaw[2]...)))
    println(first(rsiDF,5))
    rsiDF.time = DateTime.(rsiDF.time, "yyyy-mm-dd HH:MM:SS")
    rsiDF.RSI = Float64.(rsiDF.RSI);
        
    #rsiSub = @where(rsiDF, :time .> DateTime(today() - Day(1)));
    #display(plot(rsiSub[!, :time], rsiSub[!, :RSI], title="TSLA"))
    #display(hline!([30, 70], label=["Oversold", "Overbought"]))
        
    rsi_fi = first(rsiDF,60)
    display(plot(rsi_fi.time, rsi_fi.RSI, title="RSI of "*stocks[i], label="RSI of "*stocks[i], legend = :topleft))
    display(hline!([30, 70], label=["Oversold", "Overbought"]))
    

    earnings = AlphaVantage.earnings(stocks[i])

    reported = AlphaVantage.reportedEPS_quarterly(stocks[i])
    display(plot(Date.(reported[:Date]), 
        parse.(Float64, reported[:reportedEPS]), legend = :topleft, 
        label="Reported EPS", title = stocks[i]*" quarterly Earnings"))
end
