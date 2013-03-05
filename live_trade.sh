# LIFFE: Short Sterling
ruby place_orders.rb SS_RTL 0.07

# LIFFE: Euribor
ruby place_orders.rb EI_RTL 0.03
ruby place_orders.rb EI_RT_CTL 0.08

# GLOBEX order will be 60 mins. early
ruby place_orders.rb SB_RT_CTS 0.03 # 0.11 verify paper trade before increacing

# GLOBEX: Eurodollar
ruby place_orders.rb ED_RT_CTL 0.03
ruby place_orders.rb ED_ZS_L 0.14