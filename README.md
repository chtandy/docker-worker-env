### 使用方式
- .env 中的 USERNAME 修改成正確值
- run `docker-compose build`
- sudo mkdir data/${USERNAME}/.ssh
- sudo vim data/${USERNAME}/.ssh/authorized_keys
- add current public key into data/${USERNAME}/.ssh/authorized_keys
- run `docker-compose up -d`
- ssh -i {ssh key} -p 1022 localhost ${USERNAME}
