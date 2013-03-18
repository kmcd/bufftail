ssh kmcd@10.211.55.3 tar zcvf /cygdrive/c/tmp/amibroker.tgz '/cygdrive/c/Program\ Files/AmiBroker'
scp kmcd@10.211.55.3:/cygdrive/c/tmp/amibroker.tgz ~/Documents/Dropbox/
ssh kmcd@10.211.55.3 rm -f /cygdrive/c/tmp/amibroker.tgz

