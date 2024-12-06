#!/bin/bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

git clone https://github.com/nroggendorff/nginx-yxorp.git .

docker build . -t nginx-yxorp

SESSION_NAME="yxorp"

COMMAND="docker run -d -p 80:80 -p 443:443 --name yxorp nginx-yxorp bash /host.sh $1 $2 $3"

tmux has-session -t $SESSION_NAME 2>/dev/null

if [ $? != 0 ]; then
    tmux new-session -d -s $SESSION_NAME "$COMMAND"
    echo "Running '$COMMAND' in tmux session '$SESSION_NAME'."
else
    echo "Session '$SESSION_NAME' already exists."
fi
