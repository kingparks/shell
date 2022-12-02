# 下载脚本并放置运行路径
git clone https://ghproxy.com/https://github.com/Jetereting/shell.git tmp_git_shell &&
cd tmp_git_shell;
shells=`ls | grep .sh | tr "\n" " "`;
chmod +x `echo $shells`;
sudo mv `echo $shells` /usr/local/bin;
rm -rf ../tmp_git_shell;
echo "完成！"
