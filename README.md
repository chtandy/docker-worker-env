### 使用方式
- .env 中的 USERNAME 修改成正確值
- run `docker-compose build`
- run `docker-compose up -d`
- run `docker exec -u ${USERNAME} -i ubuntu mkdir ~/.ssh`
- run `docker exec -u ${USERNAME} -i ubuntu touch ~/.ssh/authorized_keys`
- add current public key data into data/${USERNAME}/.ssh/authorized_keys
- ssh -i {ssh key} -p 1022 ${USERNAME}@localhost

- .bashrc
```
export DOCKER_TLS_VERIFY=1
export DOCKER_CERT_PATH=/certs/client
export DOCKER_HOST=tcp://docker:2376
```
