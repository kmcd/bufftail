#!/bin/bash
ruby control_chart.rb ED_RT_CTL
sleep 2
ruby control_chart.rb EI_RTL
sleep 2
ruby control_chart.rb EI_RT_CTL
sleep 2
ruby control_chart.rb SS_RTL
sleep 2
ruby control_chart.rb SS_RT_CTL
sleep 2
ruby control_chart.rb SB_RT_CTS
sleep 2
ruby control_chart.rb ED_ZS_L
sleep 2
./control_chart.rhtml
open ./tmp/control_charts.html