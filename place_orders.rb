#!/usr/bin/env ruby
require 'csv'
require 'ib-ruby'
require 'active_support/all'

if ARGV.empty?
  puts "USAGE: ./place_orders.rb ED_RT_CTL [optional fixed fraction] 0.05"
  exit
end

def valid?(signal)
  signal_date = Date.parse(signal['Date/Time'].gsub(/(\d+)\/(\d+)/, "\\2/\\1"))
  signal_date == Date.today
end

def live_account?
  ARGV.size == 2 && ARGV.last.to_f > 0
end

def port_number
  live_account? ? 5001 : 4001
end

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
  IB::Order.new({total_quantity:position_size, action:'BUY', order_type:'LMT', 
    transmit:false, tif:'GTC'}.merge!(args))
end

def sell_order(args={})
  buy_order args.merge!({ action:'SELL'})
end

def place_order(ib, order, contract, parent=nil)
  order.parent_id = parent.local_id if parent
  ib.place_order order, contract
end

def market_close(signal)
  case signal['Ticker']
    # TODO: Use local time zone (15 mins before market close)
    when /ED/; '21:45:00 GMT' # CST
    when /IE/; '20:45:00 GMT' # CET
    when /LL/; '17:30:00 GMT' # BST
  end
end

def open_contracts
  @open_contracts ||= begin
    open_contracts = []
    ib.subscribe(:Alert, :OrderStatus, :OpenOrderEnd) {|msg| }
    ib.subscribe(:OpenOrder) {|msg| open_contracts << msg.contract }
    ib.send_message :RequestAllOpenOrders
    ib.wait_for :OpenOrderEnd
    open_contracts.map {|_| _.symbol + _.expiry[0...6] } # TODO: DRY up
  end
end

def account_balance
  @account_balance ||= begin
    account_balance = 10_000
    ib.subscribe :AccountValue do |msg|
    account_info = msg.data
    if account_info[:key] == 'TotalCashBalance' && account_info[:currency] == 'BASE'
      account_balance = account_info[:value].to_i
      account_balance = account_info[:value]
    end
    end
    ib.send_message :RequestAccountData, subscribe:true
    sleep 1
    ib.send_message :RequestAccountData, subscribe:false
    account_balance.to_f
  end
end

def signal
  @signal ||= begin
    `scp kmcd@10.211.55.3:/cygdrive/c/tmp/#{strategy}.csv tmp`
    signal = CSV.read("./tmp/#{strategy}.csv", headers:true).first
    signal && valid?(signal) ? signal : exit
  end
end

def position_size
  return 1 unless live_account?
  position_risk = signal['stop loss $'].to_f
  account_risk = ARGV.last.to_f
  ((account_risk * account_balance) / position_risk).round
end

def strategy
  ARGV.first
end

def client_id(strategy)
  strategy.hash.abs.to_s[0...4].to_i
end

def ib
  @ib ||= IB::Connection.new client_id:client_id(strategy), port:port_number
end

ib.subscribe(:Alert, :OpenOrder, :OrderStatus) {|msg| puts msg.to_human }
ib.wait_for :NextValidId

oca_group = [ strategy,  DateTime.now.to_s(:db).gsub(/\D/, '') ].join '_'
order_ref = strategy
contract = contract_for signal['Ticker']

entry_order = buy_order limit_price:signal['entry price'], transmit:false,
  order_ref:order_ref

stop_order = sell_order limit_price:signal['stop loss'], 
  aux_price:signal['stop loss'], order_type:'STP', 
  oca_group:oca_group, order_ref:order_ref
  
profit_order = sell_order limit_price:signal['exit price'], oca_group:oca_group, 
  order_ref:order_ref

expire_on = [1.day.from_now.to_date.to_s.gsub(/\D/,''), market_close(signal)].join ' '
expiry_order = sell_order order_type:'MKT', good_after_time:expire_on, 
  order_ref:order_ref, oca_group:oca_group, transmit:true # last in bracket order

place_order ib, entry_order, contract
place_order ib, stop_order, contract, entry_order
place_order ib, profit_order, contract, entry_order
place_order ib, expiry_order, contract, entry_order
