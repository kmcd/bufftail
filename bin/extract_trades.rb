require 'nokogiri'
require 'open-uri'
require 'YAML'


todays_reports =  `ls -tr ./Reports/*ample*/trades.html | grep '#{Time.now.to_s.gsub(/\D/, '')[0...8]}'`

trades = todays_reports.split("\n").uniq {|_| _[/[A-Z]+_[A-Z]+_*[A-Z]*/] }.sort.map do |report|
  strategy = report[/[A-Z]+_[A-Z]+_*[A-Z]*/]
  doc = Nokogiri::HTML open(report)
  trades = doc.css('table tr td:nth-child(6)').map {|_| _.to_s[/-*\d+\.\d+/].to_f }
  
  [strategy, trades]
end

File.open('trades.yml','w') {|_| _.puts Hash[ trades ].to_yaml }
