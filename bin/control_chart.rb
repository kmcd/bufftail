#!/usr/bin/env ruby
require 'csv'
require 'yaml'
require 'statsample'
require 'gnuplot'

unless strategy = ARGV.first
  puts "USAGE: ./control_chart.rb ED_RT_CTL"
  exit
end

paper_trades = CSV.read("../../tmp/trades.csv", headers:true).
  find_all {|_| _['Order Ref.'] == strategy }.
  map {|_| _['Realized P&L'] }.compact.
  map(&:to_f).
  map {|_| _ > 20 ? 20.0 : _ }.compact

wfa_trades = YAML.load_file("./data/wfa_trades.yml")[strategy].
  map(&:to_f).
  map {|_| _ > 20 ? 20.0 : _ }.compact

# convert to % return
margin = case strategy
  when /ED/ ; 500
  when /EI/ ; 400
  when /SS/ ; 438
  when /SB/ ; 400
  else
    450
end
paper_trades.map! {|_| ( _ / margin).round 4 }
wfa_trades.map! {|_| ( _ / margin).round 4 }
trades = [ wfa_trades, paper_trades ].flatten

benchmark_mean = wfa_trades.to_scale.mean
benchmark_stdev = wfa_trades.to_scale.sd

rolling_mean = trades.each_with_index.map do |t,i| 
  roll = i < 10 ? i : 10 
  trades[i-roll..i].to_scale.mean
end

rolling_stdev = trades.each_with_index.map do |t,i|
  roll = i < 10 ? i : 10
  trades[i-roll..i].to_scale.sd
end[1..-1].unshift 0

rolling_loss_mean = trades.each_with_index.map do |t,i| 
  roll = i < 10 ? i : 10 
  trades[i-roll..i].map {|_| _ > 0 ? 0 : _ }.to_scale.mean
end

rolling_loss_stdev = trades.each_with_index.map do |t,i| 
  roll = i < 10 ? i : 10 
  sd = trades[i-roll..i].map {|_| _ > 0 ? 0 : _ }.to_scale.sd
  sd.nan? ? 0 : sd
end

current_mean = rolling_mean.last.round 3
current_sd = rolling_stdev.last.round 3
current_ratio = current_sd == 0.0 ? 0 : (rolling_mean.last / rolling_stdev.last).
  round(2)
current_loss = rolling_loss_mean.last.round 3
current_semidev = rolling_loss_stdev.last.round 3
current_loss_ratio = (current_loss/current_semidev).round 2

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
      
      data_set([benchmark_mean] * trades.size, '', 2),
      data_set([0] * trades.size, '', 1),
      data_set([-benchmark_stdev] * trades.size, '', 1),
      data_set([-benchmark_stdev*2] * trades.size, '', 1)
    ]
  end
end