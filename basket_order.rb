require 'csv'
require 'ib-ruby'
require 'active_support/all'

ib = IB::Connection.new :client_id => 1112, :port => 4001
ib.subscribe(:Alert, :OpenOrder, :OrderStatus) { |msg| puts msg.to_human }

def front_month
  IB::Symbols::Futures.next_expiry(1.month.ago)
end

def expiry_for(ticker)
  return front_month if ticker =~ /#C$/

  month_code = ticker[/\w\d+$/][/\w/]
  year = ticker[/\w\d+$/][/\d+/]
  month = case month_code
    when 'H' ; '03'
    when 'M' ; '06'
    when 'U' ; '09'
    when 'Z' ; '12'
  end
  "20#{year}#{month}"
end

def bond_quote(signal_price, ecbot=true)
  return signal_price unless ecbot
  points = signal_price.to_s[/\d+\./].to_f
  quarter_points = ((signal_price).to_s[/\.\d+/].to_f * 100).round(2).to_s
  
  rounded_quarter_points = case quarter_points[/\d$/].to_i
    when (1..2) ; 0.25
    when (3..5) ; 0.5
    when (6..9) ; 0.75
  end + quarter_points.to_i
  points + rounded_quarter_points/32
end

def assert_bond_quote(exp,act)
  throw bond_quote(exp) unless bond_quote(exp) == act
end
assert_bond_quote 110.062, 110.1953125

def ecbot?(contract)
  contract.symbol =~ /(zf|zt|zn)/i
end
  
def contract_for(ticker)
  contract = case ticker
    when /ED/; IB::Symbols::Futures.future 'GE', 'GLOBEX', 'USD'
    when /EI/; IB::Symbols::Futures.future 'I', 'LIFFE', 'EUR'
    when /LL/; IB::Symbols::Futures.future 'L', 'LIFFE', 'GBP'
  end
  contract.sec_type = 'FUT'
  contract.expiry = expiry_for ticker
  return contract
end

Dir['./signals/*.csv'].each do  |signal_file|
  # Ticker,Date/Time,PositionScore,entry price,exit price,stop loss,profit target $,stop loss $,
  # LLM13,2/19/2013,0.015,99.480,99.495,99.261,30.000,438.000
  next unless signal = CSV.read(signal_file, headers:true).first
  order_ref = "basket_#{rand(9999)}"
  contract = contract_for signal['Ticker']
  ib.wait_for :NextValidId
  
  next if contract.symbol == 'L'
  puts '= ' + contract.symbol
  
  #-- Parent Order --
  buy_order = IB::Order.new :total_quantity => 1,
    :limit_price => bond_quote(signal['entry price'], ecbot?(contract)),
    :action => 'BUY',
    :order_type => 'LMT',
    :transmit => false,
    :tif => 'GTC',
    :outside_rth => true
    
  #-- Child STOP --
  stop_order = IB::Order.new :total_quantity => 1,
    :limit_price => bond_quote(signal['stop loss'], ecbot?(contract)),
    :aux_price => bond_quote(signal['stop loss'], ecbot?(contract)),
    :action => 'SELL',
    :order_type => 'STP',
    :parent_id => buy_order.local_id,
    :transmit => true,
    :tif => 'GTC', 
    :oca_group => order_ref
    
  #-- Profit LMT
  profit_order = IB::Order.new :total_quantity => 1,
    :limit_price => bond_quote(signal['exit price'], ecbot?(contract)),
    :action => 'SELL',
    :order_type => 'LMT',
    :transmit => true,
    :outside_rth => true,
    :tif => 'GTC',
    :parent_id => buy_order.local_id,
    :oca_group => order_ref
    
  #-- Expiry
  expire_on = (1.day.from_now.end_of_day - 4.hours).to_s
  expire_on.gsub! /-/, ''
  expire_on.gsub! /\+\d+$/, 'UTC'
  
  expiry_order = IB::Order.new :total_quantity => 1,
    :action => 'SELL',
    :order_type => 'MKT',
    :parent_id => buy_order.local_id,
    :transmit => true,
    :outside_rth => true,
    :good_after_time => expire_on,
    :tif => 'GTC',
    :oca_group => order_ref
  
  # place parent order
  ib.place_order buy_order, contract
  stop_order.parent_id = buy_order.local_id
  profit_order.parent_id = buy_order.local_id
  expiry_order.parent_id = buy_order.local_id
  
  puts buy_order
  puts
  puts stop_order
  puts
  puts profit_order
  puts
  puts expiry_order
  puts
  
  # place child orders
  ib.place_order stop_order, contract
  ib.place_order profit_order, contract
  ib.place_order expiry_order, contract
end
