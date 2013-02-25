#!/usr/bin/env ruby

# Read in trades for strategy
unless strategy = ARGV.first
  puts "USAGE: ./control_chart.rb ED_RT_CTL"
  exit
end

require 'csv'
trades = CSV.read("./tmp/trades.csv", headers:true).
  find_all {|_| _['Order Ref.'] == strategy }.
  map {|_| _['Realized P&L'] }.compact.
  map &:to_f

require 'statsample'
require 'gruff'

benchmark_mean, benchmark_stdev = 17.06, 41.50

rolling_mean = trades.each_with_index.map do |t,i| 
  roll = i < 10 ? i : 10 
  trades[i-roll..i].to_scale.mean.to_i
end

rolling_stdev = trades.each_with_index.map do |t,i| 
  roll = i < 10 ? i : 10
  trades[i-roll..i].to_scale.sd
end[1..-1].unshift 0

current_mean = rolling_mean.last.round 2
current_sd = rolling_stdev.last.round 2
current_ratio = current_sd == 0.0 ? 0 : (rolling_mean.last / rolling_stdev.last).
  round(2)

g = Gruff::Line.new '600x400'
g.theme = { font_color:'black', background_colors:'white' }
g.title = strategy + " t:#{trades.size} m:#{current_mean}, s:#{current_sd}, r:#{current_ratio}"
g.hide_legend = true
g.line_width = 2
g.dot_radius = 0

g.data 'Trades', trades, 'lightgrey'
g.data 'Rolling mean', rolling_mean, 'black'
g.data 'Rolling stdev', rolling_stdev, 'lightblue'

g.data 'Mean', [benchmark_mean] * trades.size, 'green'
g.data 'Zero', [0] * trades.size, 'orange'
g.data 'Stdev -1', [-benchmark_stdev] * trades.size, 'pink'
g.data 'Stdev +2', [-benchmark_stdev*2] * trades.size, 'red'

g.write "./tmp/#{strategy.downcase}.png"