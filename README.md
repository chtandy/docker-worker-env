### 使用方式
- .env 中的 USERNAME 修改成正確值
- run `docker-compose build`
- run `docker exec -u ${USERNAME} -it ubuntu /bin/bash`
- in container, mkdir -p ~/.ssh, touch ~/.ssh/authorized_keys
- add current public key into ~/.ssh/authorized_keys
- exit container
- ssh -i {ssh key} -p 1022 localhost ${USERNAME}
