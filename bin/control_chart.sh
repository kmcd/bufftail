#!/bin/bash
ruby bin/control_chart.rb ED_MA_L &&
ruby bin/control_chart.rb ED_RT_CTL &&
ruby bin/control_chart.rb ED_SP_S &&
ruby bin/control_chart.rb ED_TR_L &&
ruby bin/control_chart.rb EI_MA_L &&
ruby bin/control_chart.rb EI_RTL &&
ruby bin/control_chart.rb EI_RT_CTL &&
ruby bin/control_chart.rb EI_TR_L &&
ruby bin/control_chart.rb SB_MA_L &&
ruby bin/control_chart.rb SB_RT_CTS &&
ruby bin/control_chart.rb SB_TR_L &&
ruby bin/control_chart.rb SS_RTL &&
ruby bin/control_chart.rb SS_RT_CTL &&
ruby bin/control_chart.rb SS_TR_L &&
ruby bin/control_chart.rb SS_VZ_S

./bin/control_chart.rhtml
open ./tmp/control_charts.html