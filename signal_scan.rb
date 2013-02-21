require 'win32ole'
@amibroker = WIN32OLE.new 'Broker.Application'
@amibroker.LoadDatabase "C:\\\\Program\ Files\\Amibroker\\IQ_eod"

def export_signals(filename)
  puts "= Signal scan  #{filename}"
  wfa = @amibroker.AnalysisDocs.Open filename
  wfa.Run 1
  sleep 1 while wfa.IsBusy
  
  export_file = File.basename(filename).gsub /apx/, 'csv'
  wfa.export "C:\\\\tmp\\#{export_file}"
  puts "= Exported     C:\\\\tmp\\#{export_file}"
  
  wfa.Close
end

strategy_file_names = %w[ 
ED_RT_CTL
EI_RT_CTL
EI_RTL
SS_RT_CTL
SS_RTL
SS_RTS
]

strategy_file_names.each do |_|
  export_signals "C:\\\\Program\ Files\\Amibroker\\Formulas\\Signals\\#{_}.apx"
end
