# shell


### 自动下载到本地
```bash
bash -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/Jetereting/shell/main/down.sh)"
```

## 远程执行命令：
因为远程执行会把脚本命令转化为文本，再以 -c 解析，因此不再支持参数

### cloudflare 优选ip 并自动替换hosts
```
sudo bash -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/Jetereting/shell/main/cloudflare_better_ip_rep.sh)"
```

### cloudflare 优选ip
```
bash -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/Jetereting/shell/main/cloudflare_better_ip.sh)"
```

### 更新 brew 源为阿里
```bash
bash -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/Jetereting/shell/main/brew.sh)"
```

