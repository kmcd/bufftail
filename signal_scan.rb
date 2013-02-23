#!/usr/bin/env ruby
# N.B. Ensure Amibroker is running

unless signal = ARGV.first
  puts "USAGE: ./signal_scan.rb ED_RT_CTL"
  puts "Must be one of:"
  puts Dir["/cygdrive/c/Program\ Files/Amibroker/Formulas/Signals/*.apx"].
    map {|_| File.basename(_).gsub /\.apx/, '' }.sort
  exit
end

require 'win32ole'
@amibroker = WIN32OLE.new 'Broker.Application'
@amibroker.LoadDatabase "C:\\\\Program\ Files\\Amibroker\\IQ_eod"

def export_signals(basename)
  filename = "C:\\\\Program\ Files\\Amibroker\\Formulas\\Signals\\#{basename}.apx"
  puts "= Signal scan  #{basename}"
  wfa = @amibroker.AnalysisDocs.Open filename
  wfa.Run 1
  sleep 1 while wfa.IsBusy
  
  export_file = File.basename(filename).gsub /apx/, 'csv'
  wfa.export "C:\\\\tmp\\#{export_file}"
  puts "= Exported     C:\\\\tmp\\#{export_file}"
  wfa.Close
end

export_signals signal
