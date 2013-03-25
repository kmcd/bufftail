require './gen_strat.rb'

def base_strats
  %w[ CH_L MA_L MO_L OS_L RT_L SP_L TR_L ZS_L ]
end

def gen_new_strat(market)
  base_strats.each {|_| gen_strat _, market }
end

# USAGE: gen_strats.rb MARKET
(ARGV.empty? ? %w[ ED EI SS SB ] : ARGV).each {|_| gen_new_strat _.upcase }

# Remove base strats
base_strats.each {|_| `rm #{_}*.a{fl,px}` }
