# LIFFE: Short Sterling
ruby place_orders SS_RTL SS_RT_CTL

# LIFFE: Euribor
# EUREX: Schatz, GLOBEX
# N.B. 2 year note order 1 hr. early if placed simulataneously with Schatz
ruby place_orders EI_RTL EI_RT_CTL SB_RT_CTS

# GLOBEX: Eurodollar
ruby place_orders ED_RT_CTL ED_ZS_L
