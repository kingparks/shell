# ml,cf等域名手动更新DNS,使用acme eg:acmeManual.sh eiyou.ml 
~/.acme.sh/acme.sh --issue --dns -d $1 --yes-I-know-dns-manual-mode-enough-go-ahead-please --force --debug;
echo '请手动添加TXT解析到DNS,按回车继续';read;
~/.acme.sh/acme.sh --renew -d $1 --yes-I-know-dns-manual-mode-enough-go-ahead-please --force --debug;
~/.acme.sh/acme.sh --upgrade --auto-upgrade;
