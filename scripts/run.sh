#!/bin/bash

echo "custom /etc/hosts"
echo '127.0.0.1 github.com' >> /etc/hosts
echo "running nginx"
nginx
echo "setting up kubeconfig"
./usr/local/app/scripts/init_kubeconfig.sh
echo "starting istioctl commands"
./usr/local/app/scripts/create_istio_system.sh
