#!/usr/bin/env ruby
require 'win32ole'
amibroker = WIN32OLE.new 'Broker.Application'
amibroker.LoadDatabase "C:\\\\Program\ Files\\Amibroker\\IQ_eod"

filename = "C:\\\\Program\ Files\\Amibroker\\Formulas\\Custom\\backfill.apx"
puts "= Backfilling"
wfa = amibroker.AnalysisDocs.Open filename
wfa.Run 0
sleep 1 while wfa.IsBusy
wfa.Close
