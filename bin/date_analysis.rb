require 'nokogiri'
require 'open-uri'
require 'active_support/all'
require 'statsample'

class Array
  def to_hist
    inject(Hash.new(0)) {|t,e| t[e] += 1 ; t }
  end
end

today = Time.now.to_s.gsub(/\D/, '')[0...8]
todays_reports =  `ls -tr ./tmp/*ample*/trades.html | grep '#{today}'`
LOOKBACK = 10
XBAR = 1.0

trade_dates = todays_reports.split("\n").uniq {|_| _[/[A-Z]+_[A-Z]+_*[A-Z]*/] }.sort.map do |report|
  strategy = report[/[A-Z]+_[A-Z]+_*[A-Z]*/]
  doc = Nokogiri::HTML open(report)
  
  exit_dates = doc.css('table tr td:nth-child(4)').map do |_|
    _.to_s[/\d+\/\d+\/\d+/].gsub /(\d+\/)(\d+\/)/, "\\2\\1"
  end
  
  trades = doc.css('table tr td:nth-child(6)').map {|_| _.to_s[/-*\d+\.\d+/].to_f }
  
  trades_xbar = trades.each_with_index.map do |t,i|
    roll = i < LOOKBACK ? i : LOOKBACK
    sample = trades[i-roll...i].to_scale
    trade_xbar = sample.mean/sample.sd
    exit_dates[i] if trade_xbar >= XBAR
  end
end.flatten.compact

daily_trades = Hash[ trade_dates.map {|_| _[/^\d+/].to_i }.to_hist.sort_by(&:first) ]
monthy_trades = Hash[ trade_dates.map {|_| _[/\/\d+\//].gsub(/\D/, '').to_i }.to_hist.sort_by(&:first) ]

puts "= X-BAR #{XBAR.round(3).to_s}+"
puts
puts "= Monthly trades"
puts monthy_trades.to_a.map {|_| _.join ' -> ' }.flatten
puts
puts "= Daily trades"
puts daily_trades.to_a.map {|_| _.join ' -> ' }.flatten
