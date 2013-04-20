require 'yaml'
require 'statsample'

@total_trades = YAML.load_file("./data/wfa_trades.yml").map do |strategy, trades|
  trades.map do |trade|
    case strategy
      when /BL/ ; trade <= -180 ? -180 : trade
      when /TY/ ; trade <= -450 ? -450 : trade
      when /YM/ ; trade <= -300 ? -300 : trade
      when /EX/ ; trade <= -400 ? -400 : trade
      when /DX/ ; trade <= -350 ? -350 : trade
      when /BP/ ; trade <= -300 ? -300 : trade
      when /AD/ ; trade <= -400 ? -400 : trade
      when /CD/ ; trade <= -400 ? -400 : trade
    end
  end
end.flatten

lookback = 10
xbar = 0.25

# FIXME: 1st 10 trades may be below xbar, use extract trades instead
trades_xbar = @total_trades.each_with_index.map do |t,i|
  roll = i < lookback ? i : lookback
  sample = @total_trades[i-roll...i].to_scale
  trade_xbar = sample.mean/sample.sd
  [t,trade_xbar]
end.find_all {|_,xb| xb >= xbar }

trades = trades_xbar.map &:first
# throw trades

losing_trades = trades.find_all {|_| _ < 0 }.to_scale
MAX_LOSS = losing_trades.min.abs
LOSS_PERCENTILE = losing_trades.mean.abs+(losing_trades.sd*3)
quarter_trading_days = 6*11
trades_per_year = trades.size < quarter_trading_days ? trades.size : quarter_trading_days
account = 10_000

def report(description="",message="")
  puts [ "= #{description}".ljust(20), message.to_s ].join ' '
end

def accuracy(trades)
  (trades.count {|_| _ > 0 } / trades.size.to_f).round(2)
end

def trade_risk(trade_xbar=1.0)
  330
end

def account_risk(trade_xbar=1.0)
  # 0.075
  # (trade_risk / 10_000.0) * 2.275
  0.1
end

simulations = 1000.times #trades_per_year.times

fixed_return = simulations.map do
  trades.shuffle[0..trades_per_year].flatten.reduce &:'+'
end.to_scale

fixed_drawdown = simulations.map do
  shuffled_trades = trades.shuffle[0..trades_per_year]
  shuffled_trades.each_with_index.map do |trade,index|
    ((trade - shuffled_trades[0..index].max) / shuffled_trades[0..index].max) / 100
  end.min
end.to_scale

tw = simulations.map do
  st = trades_xbar.shuffle[0..trades_per_year]
  balance = account
  st.each do |trade,trade_xbar|
    contracts = ((balance * account_risk()) / trade_risk(trade_xbar)).to_i
    balance += (trade * contracts)
  end
  balance - account
end.to_scale

dd = simulations.map do
  st = trades_xbar.shuffle[0..trades_per_year]
  balance = account
  compounded_trades = st.map do |trade,trade_xbar|
    contracts = ((balance * account_risk()) / trade_risk(trade_xbar)).to_i
    balance += (trade * contracts)
  end
  compounded_trades.each_with_index.map do |trade,i| 
    (trade - compounded_trades[0..i].max) / compounded_trades[0..i].max
  end.min
end.to_scale

consecutive_losses = simulations.map do
  trades.shuffle.chunk {|_| _ < 0 }.to_a.
    map {|loss| loss.last.size if loss.first }.compact
end.flatten.to_scale

fr50 = fixed_return.mean / account
fdd95 = fixed_drawdown.mean.abs + (fixed_drawdown.sd * 1.64)
tw95 = (tw.mean - (tw.sd * 1.64)) / account
dd95 = dd.mean.abs + (dd.sd * 1.64)
tw50 = tw.mean / account
dd50 = dd.mean.abs

report "Position sizer"
report "Total trades ",          @total_trades.size
report "Trades (xbar #{xbar})",  trades.size
report "Accuracy %",             accuracy(trades) * 100
report "95% cons. losses",       (consecutive_losses.mean + (consecutive_losses.sd * 1.64)).round(2)

puts
report "Fixed size"
report "TW50 return    ", fr50.round(3)
report "DD95 drawdown  ", fdd95.round(3)
report "TW50/DD95      ", (fr50 / fdd95 ).round(3).abs

puts
report "(95%) a/c risk #{account_risk.round(3)}, trade risk: #{trade_risk.to_i}"
report "TW return    ", tw95.round(3)
report "DD drawdown  ", dd95.round(3).abs
report "TW/DD        ", (tw95/dd95).round(3).abs

puts
report "(50%) a/c risk #{account_risk.round(3)}, trade risk: #{trade_risk.to_i}"
report "TW return    ", tw50.round(3)
report "DD drawdown  ", dd50.round(3).abs
report "TW/DD        ", (tw50/dd50).round(3).abs
