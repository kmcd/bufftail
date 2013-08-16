require 'yaml'
require 'statsample'

LOOKBACK = 10
XBAR = 0.5
ACCURACY = 0.0
POSITION_SIZE = 0.075

def account
  10_000
end
   
def simulations
  299.times
end

def trade_risk(strategy)
  (closed_fop_trade strategy, 0).abs
end

def account_risk
  account * POSITION_SIZE
end

def premium(premium_paid, trade, profit_target=2)
  closed_trade = trade - premium_paid      
  return -premium_paid if closed_trade < 0
  closed_trade
end

def closed_fop_trade(strategy,trade)
  case strategy
    when /^SP500/ ; premium 900, trade
    when /^VIX/   ; premium 200, trade
    when /FYT/    ; premium 500, trade
    when /CHF/    ; premium 700, trade
    when /GBP/    ; premium 700, trade
    when /AUD/    ; premium 800, trade
  end
end

def trades_data
  @trades_data ||= YAML.load_file "./data/wfa_trades.yml"
end

def trades_xbar(strategy)
  total_trades = trades_data[strategy].map do |trade|
    closed_fop_trade strategy, trade
  end.flatten.reject {|_| _ == 1 }.compact
  
  total_trades.each_with_index.map do |t,i|
    roll = i < LOOKBACK ? i : LOOKBACK
    sample = total_trades[i-roll...i].to_scale
    accuracy = sample.count {|_| _ > 0 } / sample.size.to_f
    trade_xbar = sample.mean/sample.sd
    roi = sample.partition {|_| _ > 0 }.
      map {|_| _.reduce(&:'+') || 1 }.
      map(&:abs).
      reduce &:'/'
    # next unless roi >= 1.0
    
    [t,trade_xbar]
  end.compact
end

def accuracy(trades)
  (trades.count {|_| _ > 0 } / trades.size.to_f).round(2)
end 

def number_of_trades(trades)
  trading_days = 20 * 3 * 1
  average_trades = ((trades.size / (252.0 * 2) ) * trading_days).round
  return trades.size if average_trades > trades.size
  average_trades
end

def contracts(strategy)
  (account_risk.to_f / trade_risk(strategy)).to_i
end

def fixed_return(trades, strategy)
  simulations.map do
    trades.map {|_| _ * contracts(strategy) }.
    shuffle[0..number_of_trades(trades)].flatten.reduce(&:'+')
  end.to_scale
end

def fixed_drawdown(trades, strategy)
  simulations.map do
    shuffled_trades = trades.map {|_| _ * contracts(strategy) }.
      shuffle[0..number_of_trades(trades)]
    shuffled_trades.each_with_index.map do |trade,index|
      shuffled_trades[0..index].reduce &:'+'
    end.find_all {|_| _ < 0 }.min
  end.flatten.compact.to_scale
end

def tw(trades,strategy)
  simulations.map do
    st = trades_xbar(strategy).shuffle[0..number_of_trades(trades)]
    balance = account
    compounded_trades = st.map do |trade,trade_xbar|
      contracts = (balance * POSITION_SIZE / trade_risk(strategy)).round
      balance += (trade * contracts)
      balance - account
    end
  end.flatten.to_scale
end

def dd(trades,strategy)
  simulations.map do
    st = trades_xbar(strategy).shuffle[0..number_of_trades(trades)]
    balance = account
    compounded_trades = st.map do |trade,trade_xbar|
      contracts = ((balance * POSITION_SIZE) / trade_risk(strategy)).round
      balance += (trade * contracts)
      balance - account
    end
    compounded_trades.each_with_index.map do |trade,i| 
      (trade - compounded_trades[0..i].max) / compounded_trades[0..i].max
    end.min
  end.flatten.to_scale
end

SPACING = 25
CONFIDENCE = 0.0

def report(description="",message="")
  print message.to_s.ljust(SPACING)
end

@totals = []

trades_data.keys.each do |strategy|
  trades = trades_xbar(strategy).map &:first
  next if trades.empty? || number_of_trades(trades) < 1
  
  ftw = fixed_return trades, strategy
  fdd = fixed_drawdown trades, strategy
  one_lot_drawdown_95 = (fdd.mean.abs + (fdd.sd * CONFIDENCE))
  one_lot_return_50 = ( ftw.mean - ( ftw.sd * CONFIDENCE ) )
  
  @totals << [number_of_trades(trades), (accuracy(trades) * 100), 
    one_lot_return_50, one_lot_drawdown_95, 
    (one_lot_return_50 / one_lot_drawdown_95 ) ]
  
  report "Strategy",        strategy
  report "Trades ",         number_of_trades(trades)
  report "Accuracy",        (accuracy(trades) * 100).round(2)
  report "1 lot TW50",      one_lot_return_50.round(2)
  report "1 lot DD95",      one_lot_drawdown_95.round(2)
  report "1 lot TW50/DD95", (one_lot_return_50 / one_lot_drawdown_95 ).round(2)
  puts
end

def total_column(number)
  @totals.map {|_| _[number] }.reduce &:'+'
end

def average_column(number)
  total_column(number) / @totals.size
end

report "Strategy",        "TOTAL"
report "Trades ",         total_column(0).to_i
report "Accuracy",        average_column(1).round(2)
report "1 lot TW50",      total_column(2).round(2)
report "1 lot DD95",      average_column(3).round(2)
report "1 lot TW50/DD95", average_column(4).round(2)
puts
