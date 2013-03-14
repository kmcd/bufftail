WATCH_LIST = {
  ED:64,
  SB:65,
  EI:68,
  SS:77
}

def gen_afl(strategy, market)
  afl = File.read strategy + '.afl'
  File.open( [market,strategy].join('_') + '.afl', 'wb' ) {|_| _.puts afl }
end

def gen_project(strategy,market)
  project = File.read strategy + '.apx'
  market_strat = [market,strategy].join('_')
  project.gsub! /<WatchListID>76<\/WatchListID>/,
    "<WatchListID>#{WATCH_LIST[market.to_sym]}</WatchListID>"
  project.gsub! /<FormulaPath>.*<\/FormulaPath>/, 
    "<FormulaPath>Formulas\\Signals\\#{market_strat}.afl</FormulaPath>"
  
  File.open( market_strat + '.apx', 'wb' ) {|_| _.puts project }
end

def gen_strat(strategy, market)
  gen_afl strategy, market
  gen_project strategy, market
end

# USAGE: gen_strat.rb STRATEGY MARKET, eg gen_strat.rb MA_L ED
unless ARGV.empty? || __FILE__ != 'gen_strat.rb'
  strategy, market = *ARGV.map(&:upcase)
  gen_strat strategy, market
end
