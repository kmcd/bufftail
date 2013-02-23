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

g = Gruff::Line.new 500
g.title = strategy
g.data :trades, trades

g.write "./tmp/line_transparent.png"