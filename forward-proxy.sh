
proxy_rule() {
  local p=${1}
 echo DOCKER -d 192.168.0.143 ! -i br-891d5ebed3ab -p tcp -m tcp --dport $p  -j DNAT --to-destination 172.19.0.2:$p
}
forw_rule() {
  local p=${1}
 echo DOCKER -d 172.19.0.2/32 ! -i br-891d5ebed3ab -o br-891d5ebed3ab -p tcp -m tcp --dport $p -j ACCEPT
}
add_rule (){
sudo iptables -t nat -A $(proxy_rule $1)
sudo iptables -A $(forw_rule $1)
}

delete_rule() {
sudo  iptables -t nat -D $(proxy_rule $1)
sudo iptables -D $(forw_rule $1)
}

for p in $(kubectl get svc -n prow |grep -i nodeport |
  awk '($0=$5)&&sub(/.*:/,e)sub("/.*",e)'); do
 echo $p
add_rule $p
done
