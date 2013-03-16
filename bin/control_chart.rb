#!/usr/bin/env ruby
require 'csv'
require 'yaml'
require 'statsample'
require 'gnuplot'

unless strategy = ARGV.first
  puts "USAGE: ./control_chart.rb ED_RT_CTL"
  exit
end

wfa_trades = YAML.load_file("./data/wfa_trades.yml")[strategy]

throw strategy unless wfa_trades

# convert to % return
margin = case strategy
  when /ED/ ; 500
  when /EI/ ; 400
  when /SS/ ; 438
  when /SB/ ; 400
  else
    450
end

margin_risk = margin * 0.1

wfa_trades.
  map(&:to_f).
  map {|_| (( _ > margin_risk) ? margin_risk : _ ).to_f }.
  map {|_| (( _ < -margin_risk) ? -margin_risk : _ ).to_f }.
  compact

trades = wfa_trades.map! {|_| ( _ / margin).round 4 }.flatten

benchmark_mean = trades.each_with_index.map {|t,i| trades[0..i].to_scale.mean }
benchmark_stdev = trades.each_with_index.map {|t,i| trades[0..i].to_scale.sd }

rolling_mean = trades.each_with_index.map do |t,i| 
  roll = i < 30 ? i : 30
  trades[i-roll..i].to_scale.mean
end

rolling_stdev = trades.each_with_index.map do |t,i|
  roll = i < 30 ? i : 30
  trades[i-roll..i].to_scale.sd
end[1..-1].unshift 0

current_mean = rolling_mean.last.round 3
current_sd = rolling_stdev.last.round 3
current_ratio = current_sd == 0.0 ? 0 : (rolling_mean.last / rolling_stdev.last).
  round(2)
rolling_ratio = rolling_mean.zip(rolling_stdev).map {|m,s| s == 0 ? 0 : m / s }

def data_set(data,title='',color=0,linewidth=1, linetype='lines')
  Gnuplot::DataSet.new(data) do |_|
    _.with = linetype
    _.title = title
    _.linecolor = color
    _.linewidth = linewidth
  end
end

Gnuplot.open do |gp|
  Gnuplot::Plot.new( gp ) do |_|
    _.terminal "png"
    objective_function = current_ratio
    
    filename = [objective_function.to_s, strategy.downcase].join '_'
    _.output File.expand_path "./tmp/#{filename}.png"
    _.set "terminal png size 800,600"
    _.title [objective_function, strategy].join ' '
    
    _.data = [
      data_set(trades, '', 12, 1, 'points'),
      data_set(rolling_mean, "Mean #{current_mean}", 2, 3),
      data_set(rolling_stdev, "Stdev #{current_sd}", 3),
      data_set([0] * trades.size, '', 1)
    ]
  end
end