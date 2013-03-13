#!/bin/bash

ruby bin/control_chart.rb CH_L &&
ruby bin/control_chart.rb ED_CH_L &&
ruby bin/control_chart.rb ED_MA_L &&
ruby bin/control_chart.rb ED_MO_L &&
ruby bin/control_chart.rb ED_RT_CTL &&
ruby bin/control_chart.rb ED_SP_S &&
ruby bin/control_chart.rb ED_TR_L &&
ruby bin/control_chart.rb ED_VLZ_L &&
ruby bin/control_chart.rb ED_VL_L &&
ruby bin/control_chart.rb ED_ZS_CTL &&
ruby bin/control_chart.rb ED_ZS_L &&
ruby bin/control_chart.rb EI_CH_L &&
ruby bin/control_chart.rb EI_MA_L &&
ruby bin/control_chart.rb EI_MO_L &&
ruby bin/control_chart.rb EI_RTL &&
ruby bin/control_chart.rb EI_RT_CTL &&
ruby bin/control_chart.rb EI_RT_L &&
ruby bin/control_chart.rb EI_SP_S &&
ruby bin/control_chart.rb EI_TR_L &&
ruby bin/control_chart.rb EI_VLZ_L &&
ruby bin/control_chart.rb EI_VL_L &&
ruby bin/control_chart.rb EI_ZS_CTL &&
ruby bin/control_chart.rb EI_ZS_S &&
ruby bin/control_chart.rb MA_L &&
ruby bin/control_chart.rb MO_L &&
ruby bin/control_chart.rb RT_CTL &&
ruby bin/control_chart.rb RT_L &&
ruby bin/control_chart.rb SB_CH_L &&
ruby bin/control_chart.rb SB_MA_L &&
ruby bin/control_chart.rb SB_MO_L &&
ruby bin/control_chart.rb SB_RT_CTL &&
ruby bin/control_chart.rb SB_RT_CTS &&
ruby bin/control_chart.rb SB_RT_L &&
ruby bin/control_chart.rb SB_TR_L &&
ruby bin/control_chart.rb SB_VLZ_L &&
ruby bin/control_chart.rb SB_VL_L &&
ruby bin/control_chart.rb SB_ZS_CTL &&
ruby bin/control_chart.rb SS_CH_L &&
ruby bin/control_chart.rb SS_MA_L &&
ruby bin/control_chart.rb SS_MO_L &&
ruby bin/control_chart.rb SS_RTL &&
ruby bin/control_chart.rb SS_RTS &&
ruby bin/control_chart.rb SS_RT_CTL &&
ruby bin/control_chart.rb SS_RT_L &&
ruby bin/control_chart.rb SS_TR_L &&
ruby bin/control_chart.rb SS_VLZ_L &&
ruby bin/control_chart.rb SS_VL_L &&
ruby bin/control_chart.rb SS_VZ_S &&
ruby bin/control_chart.rb SS_ZS_CTL &&
ruby bin/control_chart.rb TR_L &&
ruby bin/control_chart.rb VLZ_L &&
ruby bin/control_chart.rb VL_L &&
ruby bin/control_chart.rb ZS_CTL

./bin/control_chart.rhtml
open ./tmp/control_charts.html