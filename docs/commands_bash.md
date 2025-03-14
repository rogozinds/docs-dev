




# path remote
/var/log/eb-docker/containers/eb-current-app

# grep
sudo grep "cc8a12e6" *-stdouterr.log  >proccessed.log

#check vector status
sudo systemctl status vector-agent.service

#restart
sudo systemctl restart vector-agent.service

#restart

      systemctl daemon-reload
      systemctl start vector-agent.service
      systemctl enable vector-agent.service

# verify the config

#install vector

sudo curl --proto '=https' --tlsv1.2 -sSfL https://sh.vector.dev | sudo VECTOR_VERSION=0.37.1 bash -s -- -y --prefix /opt/vector
