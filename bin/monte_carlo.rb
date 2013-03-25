require 'yaml'
require 'statsample'

@total_trades = YAML.load_file("./data/wfa_trades.yml").
  map {|strategy, _| _ }.flatten
  
lookback = 10
xbar = 1.0

# FIXME: 1st 10 trades may be below xbar, use extract trades instead
trades_xbar = @total_trades.each_with_index.map do |t,i|
  roll = i < lookback ? i : lookback
  sample = @total_trades[i-roll...i].to_scale
  trade_xbar = sample.mean/sample.sd
  [t,trade_xbar]
end.find_all {|_,xb| xb >= xbar }

trades = trades_xbar.map &:first

losing_trades = trades.find_all {|_| _ < 0 }.to_scale
MAX_LOSS = losing_trades.min.abs
LOSS_PERCENTILE = losing_trades.mean.abs+(losing_trades.sd*1.65)
trades_per_year = 160
account = 10_000

def report(description="",message="")
  puts [ "= #{description}".ljust(20), message.to_s ].join ' '
end

def accuracy(trades)
  (trades.count {|_| _ > 0 } / trades.size.to_f).round(2)
end

def account_risk(trade_xbar=1.0)
  0.1
end

def trade_risk(trade_xbar=1.0)
  LOSS_PERCENTILE
end

fixed_return = trades.size.times.map do
  trades.shuffle[0..trades_per_year].flatten.reduce &:'+'
end.to_scale

fixed_drawdown = trades.size.times.map do
  shuffled_trades = trades.shuffle[0..trades_per_year]
  shuffled_trades.each_with_index.map do |trade,index|
    ((trade - shuffled_trades[0..index].max) / shuffled_trades[0..index].max) / 100
  end.min
end.to_scale

consecutive_losses = trades.size.times.map do
  trades.shuffle.chunk {|_| _ < 0 }.to_a.
    map {|loss| loss.last.size if loss.first }.compact.max
end.to_scale

max_consecutive_losses = (consecutive_losses.mean * (consecutive_losses.sd * 1.65)).to_i

tw = trades.size.times.map do
  st = trades_xbar.shuffle[0..trades_per_year]
  balance = account
  st.each do |trade,trade_xbar|
    contracts = ((balance * account_risk()) / trade_risk(trade_xbar)).round
    balance += (trade * contracts)
  end
  balance - account
end.to_scale

dd = trades.size.times.map do
  st = trades_xbar.shuffle[0..trades_per_year]
  balance = account
  compounded_trades = st.map do |trade,trade_xbar|
    contracts = ((balance * account_risk()) / trade_risk(trade_xbar)).round
    balance += (trade * contracts)
  end
  compounded_trades.each_with_index.map do |trade,i| 
    (trade - compounded_trades[0..i].max) / compounded_trades[0..i].max
  end.min
end.to_scale

fr95 = (fixed_return.mean - (fixed_return.sd * 1.64)) / account
dd95 = ( (fixed_drawdown.mean.abs + fixed_drawdown.sd * 1.64) )
tw95 = (tw.mean - (tw.sd * 1.64)) / account
dd95 = ( (dd.mean.abs + dd.sd * 1.64) )
tw50 = tw.mean / account
dd50 = dd.mean.abs

report "Position sizer"
report "Total trades ",          @total_trades.size
report "Trades (xbar #{xbar}) ", trades.size
report "Accuracy %",             accuracy(trades) * 100
report "Max losses",             max_consecutive_losses

puts
report "Fixed size"
report "TW95 return    ", fr95.round(3)
report "DD95 drawdown  ", dd95.round(3)
report "TW95/DD95      ", (fr95 / dd95 ).round(3).abs

puts
report "a/c risk #{account_risk.round(2)}, trade risk: #{trade_risk.to_i} @ 95%"
report "TW return    ", tw95.round(3)
report "DD drawdown  ", dd95.round(3).abs
report "TW/DD        ", (tw95/dd95).round(3).abs

puts
report "a/c risk #{account_risk.round(2)}, trade risk: #{trade_risk.to_i} @ 50%"
report "TW return    ", tw50.round(3)
report "DD drawdown  ", dd50.round(3).abs
report "TW/DD        ", (tw50/dd50).round(3).abs
