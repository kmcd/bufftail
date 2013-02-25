#!/usr/bin/env ruby
unless signals = ARGV.first
  puts "USAGE: ./place_orders.rb ED_RT_CTL [optional fixed fraction] 0.05"
  exit
end

require 'csv'
`scp kmcd@10.211.55.3:/cygdrive/c/tmp/#{signals}.csv tmp`
signal = CSV.read("./tmp/#{signals}.csv", headers:true).first
exit '= No signals' unless signal

require 'ib-ruby'
require 'active_support/all'
client_id = lambda {|_| _.hash.abs.to_s[0...4].to_i }
ib = IB::Connection.new :client_id => client_id[signals], :port => 4001

@account_balance = 10_000
ib.subscribe :AccountValue do |msg|
  account_info = msg.data
  if account_info[:key] == 'TotalCashBalance' && account_info[:currency] == 'BASE'
    @account_balance = account_info[:value].to_i
    account_balance = account_info[:value]
  end
end
ib.send_message :RequestAccountData, subscribe:true
sleep 1
ib.send_message :RequestAccountData, subscribe:false

@position_size = if ARGV.size == 2
  position_risk = signal['stop loss $'].to_f
  account_risk = ARGV.last.to_f
  ((account_risk * @account_balance) / position_risk).round
else
  1
end

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
    when /IE/; IB::Symbols::Futures.future 'I', 'LIFFE', 'EUR'
    when /LL/; IB::Symbols::Futures.future 'L', 'LIFFE', 'GBP'
  end
  contract.sec_type = 'FUT'
  contract.expiry = expiry_for ticker
  return contract
end

def buy_order(args={})
  IB::Order.new({total_quantity:@position_size, action:'BUY', order_type:'LMT', 
    transmit:false, tif:'GTC'}.merge!(args))
end

def sell_order(args={})
  buy_order args.merge!({ action:'SELL'})
end

def place_order(ib, order, contract, parent=nil)
  order.parent_id = parent.local_id if parent
  ib.place_order order, contract
end

oca_group = [ signals,  DateTime.now.to_s(:db).gsub(/\D/, '') ].join '_'
order_ref = signals
contract = contract_for signal['Ticker']
ib.wait_for :NextValidId

entry_order = buy_order limit_price:signal['entry price'], transmit:false,
  order_ref:order_ref

stop_order = sell_order limit_price:signal['stop loss'], 
  aux_price:signal['stop loss'], order_type:'STP', 
  oca_group:oca_group, order_ref:order_ref
  
profit_order = sell_order limit_price:signal['exit price'], oca_group:oca_group, 
  order_ref:order_ref

# 30 mins before CME GLOBEX close (will need to alter for LIFFE)
expire_on = [1.day.from_now.to_date.to_s.gsub(/\D/,''), "15:30:00 CST"].join ' '
expiry_order = sell_order order_type:'MKT', good_after_time:expire_on, 
  order_ref:order_ref, oca_group:oca_group, transmit:true # last in bracket order

place_order ib, entry_order, contract
place_order ib, stop_order, contract, entry_order
place_order ib, profit_order, contract, entry_order
place_order ib, expiry_order, contract, entry_order

ib.send_message :RequestAllOpenOrders
