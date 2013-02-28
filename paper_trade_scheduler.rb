$LOAD_PATH.unshift File.dirname __FILE__
require 'rufus/scheduler'
@scheduler = Rufus::Scheduler.start_new

TEN_MINS_BEFORE_CLOSE = {
  liffe:'50 17 * * 1-5 Europe/London',
  eurex:'50 21 * * 1-5 Europe/Berlin',
  globex:'50 15 * * 1-5 America/Chigago'
}

def place_orders(exchange, strategies)
  @scheduler.cron TEN_MINS_BEFORE_CLOSE[exchange] do
    strategies.each do |strategy|
      ARGV << strategy
      load 'place_orders.rb'
      ARGV.clear
    end
  end
end

place_orders :liffe, %w[ SS_RTL SS_RT_CTL ]
signal_scan :eurex, %w[ EI_RTL EI_RT_CTL SB_RT_CTS ]
signal_scan :globex, %w[ ED_RT_CTL ED_ZS_L ]
@scheduler.join

# %w[ SS_RTL SS_RT_CTL ].each  {|_| ARGV << _ }
# load 'place_orders.rb'
# ARGV.clear
