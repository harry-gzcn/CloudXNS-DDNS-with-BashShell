#CloudXNS DDNS with BashShell
#Github:https://github.com/lixuy/CloudXNS-DDNS-with-BashShell
#More: https://03k.org/cloudxns-ddns-with-bashshell.html
#CONF START
API_KEY="abcdefghijklmnopqrstuvwxyz1234567"
SECRET_KEY="abcdefghijk12345"
DDNS="home.xxxx.com"
OUT="pppoe0"
#CONF END

date
IPREX='([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])'
LOCALIP=$(ping $DDNS -c1|grep -Eo "$IPREX"|tail -n1)
PPPOEIP=$(ip addr show $OUT|grep -Eo "$IPREX"|head -n1)
echo "[DNS IP]:$LOCALIP"
echo "[$OUT IP]:$PPPOEIP"
if [ "$LOCALIP" == "$PPPOEIP" ];then
echo "IP SAME,SIKP UPDATE."
exit
fi
URL="http://www.cloudxns.net/api2/ddns"
JSON="{\"domain\":\"$DDNS\",\"ip\":\"$PPPOEIP\"}"
NOWTIME=$(env LANG=en_US.UTF-8 date +'%a %h %d %H:%M:%S %Y')
HMAC=$(echo -n $API_KEY$URL$JSON$NOWTIME$SECRET_KEY|md5sum|cut -d' ' -f1)
POST=$(curl --interface $OUT -k -s $URL -X POST -d $JSON -H "API-KEY: $API_KEY" -H "API-REQUEST-DATE: $NOWTIME" -H "API-HMAC: $HMAC" -H 'Content-Type: application/json')
if (echo $POST |grep -q "success");then
echo "API UPDATE DDNS SUCCESS"
else echo -e "API UPDATE DDNS FAIL\nFAIL INFO:\n$POST"
fi
