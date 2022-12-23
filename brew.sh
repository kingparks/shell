# brew 切换为中国源 

sudo bash -c "$(curl -fsSL 	https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
sudo chown -R $(whoami) /Users/au/Library/Caches/Homebrew
exit;
brew update-reset;
git config --global --add safe.directory /opt/homebrew/Library/Taps/homebrew/homebrew-cask;
git config --global --add safe.directory /opt/homebrew/Library/Taps/homebrew/homebrew-core;

