#!/usr/bin/env ruby

# Read in trades for strategy
unless strategy = ARGV.first
  puts "USAGE: ./control_chart.rb ED_RT_CTL"
  exit
end

require 'csv'
trades = CSV.read("./tmp/trades.csv", headers:true).
  find_all {|_| _['Order Ref.'] == strategy }

require 'statsample'
require 'gruff'

benchmark_mean, benchmark_stdev = 17.0621818182, 41.5041601971

trades = [-54.3, 33.2,-66.8,33.2,83.2,33.2,33.2,45.7,33.2,33.2,33.2,-141.8,33.2,
-16.8,33.2,33.18,33.2,70.7,33.2,33.2,33.2,-4.3,33.2,33.2,33.2,33.2,33.2,58.2,33.18,
33.2,33.2,33.2,-4.3,33.2,33.2,-4.3,33.2,-104.3,-29.3,33.2,33.18,33.2,-4.3,33.2,
-16.8,33.2,33.2,33.2,33.2,-104.3,33.2,33.18,8.2,33.2,-4.3]

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
current_ratio  = (rolling_mean.last / rolling_stdev.last).round 2

g = Gruff::Line.new
g.theme = { font_color:'black', background_colors:'white' }
g.title = strategy + " m:#{current_mean}, s:#{current_sd}, r:#{current_ratio}"
g.hide_legend = true
g.line_width = 2
g.dot_radius = 0

g.data 'Trades', trades, 'lightgrey'
g.data 'Rolling mean', rolling_mean, 'black'
g.data 'Rolling stdev', rolling_stdev, 'lightblue'

g.data 'Mean', [benchmark_mean] * trades.size, 'green'
g.data 'Zero', [0] * trades.size, 'pink'
g.data 'Stdev -1', [-benchmark_stdev] * trades.size, 'orange'
g.data 'Stdev +2', [-benchmark_stdev*2] * trades.size, 'red'

g.write "./tmp/#{strategy.downcase}.png"