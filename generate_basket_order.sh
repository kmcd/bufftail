# REMOTE Windows XP desktop interative not working; run command on windows instead

# Copy signal scan to windows tmp dir
# echo 'put signal_scan.rb' | sftp -b - kmcd@10.211.55.3:/cygdrive/c/tmp/

# SSH into windows box & run signal scan
# ssh kmcd@10.211.55.3 '/cygdrive/c/Ruby193/bin/ruby.exe `cygpath -aw "/cygdrive/c/tmp/signal_scan.rb"`'

# Copy signal files to working directory
mkdir signals && cd signals
echo "mget /cygdrive/c/tmp/*.csv" | sftp -b - kmcd@10.211.55.3

# Merge signal files into basket order file