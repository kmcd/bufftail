require 'csv'
require 'ib-ruby'
require 'active_support/all'

ib = IB::Connection.new :client_id => 1112, :port => 4001
ib.subscribe(:Alert, :OpenOrder, :OrderStatus) { |msg| puts msg.to_human }


def expiry_for(ticker)
  month_code = ticker[/\w\d+$/][/\w/]
  year = ticker[/\w\d+$/][/\d+/]
  month = case month_code
    when 'H'; '03'
    when 'M'; '06'
    when 'U'; '09'
    when 'Z'; '12'
  end
  "20#{year}#{month}"
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

def order(args={})
end

raise RuntimeError unless $file
exit unless signal = CSV.read($file, headers:true).first

order_ref = "basket_#{rand(9999)}" # from filename, eg ED_RT_CTL
contract = contract_for signal['Ticker']
ib.wait_for :NextValidId

#-- Parent Order --
buy_order = IB::Order.new :total_quantity => 1,
  :limit_price => signal['entry price'],
  :action => 'BUY',
  :order_type => 'LMT',
  :transmit => false,
  :tif => 'GTC',
  :outside_rth => true
  
#-- Child STOP --
stop_order = IB::Order.new :total_quantity => 1,
  :limit_price => signal['stop loss'],
  :aux_price => signal['stop loss'],
  :action => 'SELL',
  :order_type => 'STP',
  :parent_id => buy_order.local_id,
  :transmit => true,
  :tif => 'GTC', 
  :oca_group => order_ref
  
#-- Profit LMT
profit_order = IB::Order.new :total_quantity => 1,
  :limit_price => signal['exit price'],
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
ib.place_order stop_order, contract
ib.place_order profit_order, contract
ib.place_order expiry_order, contract
