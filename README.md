# shell


### 自动下载到本地
```bash
bash -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/Jetereting/shell/main/down.sh)"
```

## 远程执行命令：
因为远程执行会把脚本命令转化为文本，再以 -c 解析，因此不再支持参数
```bash
bash -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/Jetereting/shell/main/brew.sh)"
```
