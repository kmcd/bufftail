#!/bin/bash
ruby control_chart.rb ED_RT_CTL &&
ruby control_chart.rb ED_ZS_L &&
ruby control_chart.rb ED_SP_S &&
ruby control_chart.rb EI_RTL &&
ruby control_chart.rb EI_RT_CTL &&
ruby control_chart.rb EI_ZS_S &&
ruby control_chart.rb SB_RT_CTS &&
ruby control_chart.rb SB_MA_L &&
ruby control_chart.rb SS_RTL &&
ruby control_chart.rb SS_RT_CTL && 
ruby control_chart.rb SS_VZ_S

./control_chart.rhtml
open ./tmp/control_charts.html