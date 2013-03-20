require './gen_strat.rb'

def base_strats
  %w[ CH_L CH_CTL MA_L MO_L OS_L OS_CTL RT_CTL RT_L SP_L SP_CTL TR_CTL TR_L ZS_CTL 
    ZS_L ]
end

def gen_new_strat(market)
  base_strats.each {|_| gen_strat _, market }
end

# USAGE: gen_strats.rb MARKET
(ARGV.empty? ? %w[ ED EI SS SB ] : ARGV).each {|_| gen_new_strat _.upcase }

# Remove base strats
base_strats.each {|_| `rm #{_}*.a{fl,px}` }
