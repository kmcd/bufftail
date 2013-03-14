#!/usr/bin/env ruby
# N.B. Ensure Amibroker is running
require 'win32ole'
require 'fileutils'

@amibroker = WIN32OLE.new 'Broker.Application'

def export_signals(basename)
  filename = "C:\\\\Program\ Files\\Amibroker\\Formulas\\Signals\\#{basename}.apx"
  wfa = @amibroker.AnalysisDocs.Open filename
  wfa.Run 6
  sleep 1 while wfa.IsBusy
  wfa.Close
end

Dir["*.apx"].map {|_| _.gsub /\.apx/, '' }.flatten.each {|_| export_signals _ }
