require './gen_strat.rb'

def gen_new_strat(market)
  base_strats = %w[ CH_L MA_L MO_L RT_CTL RT_L TR_L VL_L VLZ_L ZS_CTL ]
  existing_strats = `ls #{market}_*.apx`.split("\n").
    map {|_| _.gsub /(#{market}_|\.apx)/,'' }
  
  if existing_strats.empty?
    base_strats.each {|_| gen_strat _, market }
  else
    s = [ base_strats, existing_strats ].flatten.sort
    new_stats = s.find_all {|_| s.count(_)  == 1 && base_strats.include?(_) }
    new_stats.each {|_| gen_strat _, market }
  end
end

# USAGE: gen_strats.rb MARKET
unless ARGV.empty?
  ARGV.each {|_| gen_new_strat _.upcase }
end
