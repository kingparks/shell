# 下载脚本并放置运行路径
set -e;
curl -o tmp_git_shell.zip https://codeload.github.com/kingparks/shell/zip/refs/heads/main
unzip -o -d tmp_git_shell  tmp_git_shell.zip
cd tmp_git_shell/shell-main
shells=`ls | grep .sh | tr "\n" " "`;
chmod +x `echo $shells`;
sudo mv `echo $shells` /usr/local/bin;
cd ../../;
rm -rf tmp_git_shell tmp_git_shell.zip;
echo "下载完成！"
