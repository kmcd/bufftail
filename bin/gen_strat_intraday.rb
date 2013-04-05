def strat_filename(market, strategy)
  [market, strategy].join '_'
end

def afl_filename(market, strategy)
  strat_filename(market, strategy) + '.afl'
end

def project_filename(market, strategy)
  strat_filename(market, strategy) + '.apx'
end

def base_project_content(strategy)
  File.read [strategy].join('_') + '.apx'
end

def gen_afl(strategy, market)
  afl = File.read [strategy].join('_') + '.afl'
  File.open( afl_filename(market, strategy), 'wb' ) {|_| _.puts afl }
end

def project_content(market, strategy)
  formula_content = '<FormulaContent>' + afl_content(market, strategy) + '</FormulaContent>'
  formula_content.gsub! "\\", "\\\\\\\\"
  
  base_project_content(strategy).
    gsub!(/FORMULA_CONTENT/, formula_content).
    gsub! /<FormulaPath>.*<\/FormulaPath>/,
      "<FormulaPath>Formulas\\\\\\Signals\\\\\\#{afl_filename(market, strategy)}</FormulaPath>"
end

def afl_content(market, strategy)
  File.read(afl_filename(market, strategy)).
    gsub!(/&/,'&amp;').
    gsub!(/\</,'&lt;').
    gsub!(/\>/,'&gt;').
    gsub!("\\", "\\\\\\\\").
    gsub!(/\n/, '\r\n')
end

def gen_project(strategy,market)
  File.open( project_filename(market, strategy), 'wb' ) do |_|
    _.puts project_content(market, strategy)
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
