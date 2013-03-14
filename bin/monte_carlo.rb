require 'yaml'
require 'statsample'

@trades = YAML.load_file("./data/wfa_trades.yml").
  map {|strategy, _| _ }.flatten.
  map {|_| (( _ > 40) ? 40 : _ ).to_f }.
  map {|_| (( _ < -40) ? -40 : _ ).to_f }
  
# systems to trade selected from xbar chart
xbar = 1.0
trades = @trades.each_with_index.find_all do |t,i|
  roll = i < 30 ? i : 30
  sample = @trades[i-roll...i].to_scale
  (sample.mean/sample.sd) >= xbar
end.map &:first

# Return
puts "= Position sizer"
puts "= Total trades: " + @trades.size.to_s
puts "= Trades: " + trades.size.to_s

account_risk = 0.05
losing_trades = trades.find_all {|_| _ < 0 }.to_scale
max_loss = losing_trades.min.abs
loss_95 = losing_trades.mean.abs+(losing_trades.sd*0)
risk = max_loss
trades_per_year = 150
account = 10_000

# Return
tw = 500.times.map do
  trades.shuffle[0..trades_per_year].flatten.reduce &:'+'
end.to_scale

# Draw down
dd = 500.times.map do
  st = trades.shuffle[0..trades_per_year]
  st.each_with_index.map {|ar,i| ar - st[0..i].max }.min
end.to_scale

tw95 = (tw.mean - (tw.sd * 2)) / account
dd95 = ( (dd.mean.abs + dd.sd * 2) / account )

puts
puts "= Fixed size"
puts "= TW95 return:    " + tw95.round(3).to_s
puts "= DD95 drawdown:  " + dd95.round(3).abs.to_s
puts "= TW95/DD95:      " + (tw95/dd95).round(3).abs.to_s

tw = trades.size.times.map do
  st = trades.shuffle[0..trades_per_year].flatten
  balance = account
  st.each do |trade|
    contracts = ((balance * account_risk) / risk).round
    balance += (trade * contracts)
  end
  balance - account
end.to_scale

dd = trades.size.times.map do
  st = trades.shuffle[0..trades_per_year].flatten
  balance = account
  compounded_trades = st.map do |trade|
    contracts = ((balance * account_risk) / risk).round
    balance += (trade * contracts)
  end
  compounded_trades.each_with_index.map do |trade,i| 
    (trade - compounded_trades[0..i].max) / compounded_trades[0..i].max
  end.min
end.to_scale

tw95 = (tw.mean - (tw.sd * 2)) / account
dd95 = ( (dd.mean.abs + dd.sd * 2) )

puts
puts "= Fixed fraction"
puts "= a/c risk: #{account_risk}, trade risk: #{risk.to_i}"
puts "= TW95 return:    " + tw95.round(3).to_s
puts "= DD95 drawdown:  " + dd95.round(3).abs.to_s
puts "= TW95/DD95:      " + (tw95/dd95).round(3).abs.to_s
