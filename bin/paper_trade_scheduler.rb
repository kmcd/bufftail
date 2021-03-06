$LOAD_PATH.unshift File.dirname __FILE__
require 'rufus/scheduler'

def scheduler
  @scheduler ||= Rufus::Scheduler.start_new
end

TEN_MINS_BEFORE_CLOSE = {
  liffe:'51 17 * * 1-5 Europe/London',
  eurex:'51 21 * * 1-5 Europe/Berlin',
  globex:'51 15 * * 1-5 America/Chicago'
}

def place_orders(exchange, strategies)
  scheduler.cron TEN_MINS_BEFORE_CLOSE[exchange] do
    strategies.each do |strategy|
      ARGV << strategy
      load 'place_orders.rb'
      ARGV.clear
    end
  end
end

place_orders :liffe, %w[ SS_RTL SS_RT_CTL ]
place_orders :eurex, %w[ EI_RTL EI_RT_CTL SB_RT_CTS ]
place_orders :globex, %w[ ED_RT_CTL ED_ZS_L ]
scheduler.join
