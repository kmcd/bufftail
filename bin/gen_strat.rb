WATCH_LIST = {
  ED:64,
  SB:65,
  EI:68,
  SS:77,
  ALL:76
}

CONTRACT_SPEC = {
  ED:   'TickSize = 0.005; PointValue = 2500; MarginDeposit = 400;',
  SB:   '// Schatz & 2 year note should be specified in info window',
  EI:   'TickSize = 0.005; PointValue = 2500; MarginDeposit = 400;',
  SS:   'TickSize = 0.01;  PointValue = 2000; MarginDeposit = 400;',
  ALL:  'TickSize = 0.005; PointValue = 2500; MarginDeposit = 400;'
}                                                                                       

def volatility_filters
  # { VN:'volatility_filter', VHL:'high_low_volatility_filter' }
  { VA:'True'}
end

def strat_filename(market, strategy, code)
  [market, strategy, code].join '_'
end

def afl_filename(market, strategy, code)
  strat_filename(market, strategy, code) + '.afl'
end

def project_filename(market, strategy, code)
  strat_filename(market, strategy, code) + '.apx'
end

def base_project_content(strategy, code)
  File.read [strategy, code].join('_') + '.apx'
end

def gen_afl(strategy, market)
  volatility_filters.each do |code,filter|
    afl = File.read [strategy, code].join('_') + '.afl'
    afl.gsub!(/VOLATILITY_FILTER/, filter)
    afl.gsub!(/CONTRACT_SPEC/, CONTRACT_SPEC[market])
    File.open( afl_filename(market, strategy, code), 'wb' ) {|_| _.puts afl }
  end
end

def project_content(market, strategy, code)
  formula_content = '<FormulaContent>' + afl_content(market, strategy, code) + '</FormulaContent>'
  formula_content.gsub! "\\", "\\\\\\\\"
  
  base_project_content(strategy, code).
    gsub!(/<WatchListID>76<\/WatchListID>/,
      "<WatchListID>#{WATCH_LIST[market.to_sym]}</WatchListID>").
    gsub!(/FORMULA_CONTENT/, formula_content).
    gsub! /<FormulaPath>.*<\/FormulaPath>/,
      "<FormulaPath>Formulas\\\\\\Signals\\\\\\#{afl_filename(market, strategy, code)}</FormulaPath>"
end

def afl_content(market, strategy, code)
  File.read(afl_filename(market, strategy, code)).
    gsub!(/&/,'&amp;').
    gsub!(/\</,'&lt;').
    gsub!(/\>/,'&gt;').
    gsub!("\\", "\\\\\\\\").
    gsub!(/\n/, '\r\n')
end

def gen_project(strategy,market)
  volatility_filters.each do |code,filter|
    File.open( project_filename(market, strategy, code), 'wb' ) do |_|
      _.puts project_content(market, strategy ,code)
    end
  end
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
