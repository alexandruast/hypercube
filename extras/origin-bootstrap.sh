#!/usr/bin/env bash
set -eEuo pipefail
trap 'RC=$?; echo [error] exit code $RC running $BASH_COMMAND; exit $RC' ERR

SSH_OPTS='-o LogLevel=error -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o BatchMode=yes'

sudo yum localinstall -q -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

sudo yum -q -y install \
  jq  \
  pip \
  python \
  libselinux-python \
  ansible

ORIGIN="$(jq -re '.kube_tools | map(.ip) | join(",")' "environment.json")"
KUBE_MASTERS="$(jq -re '.kube_masters | map(.ip) | join(",")' "environment.json")"
KUBE_WORKERS="$(jq -re '.kube_workers | map(.ip) | join(",")' "environment.json")"
ALL_NODES="$(jq -rec '[.kube_masters,.kube_workers,.kube_tools | .[] | {ip: .ip, hostname: .hostname} ]' "environment.json")"
EXTRAVARS_HOSTS="$(echo ${ALL_NODES} | tr '"' "'")"

cd /vagrant/

# setting up origin
ANSIBLE_TARGET="${ORIGIN}" \
ANSIBLE_EXTRAVARS="{'etc_hosts':${EXTRAVARS_HOSTS}}" \
  ./apl-wrapper.sh ansible/target-origin.yml

# setting up kube-masters
ANSIBLE_TARGET="${KUBE_MASTERS}" \
ANSIBLE_EXTRAVARS="{'etc_hosts':${EXTRAVARS_HOSTS}}" \
  ./apl-wrapper.sh ansible/target-kubernetes.yml

# setting up kube-workers
ANSIBLE_TARGET="${KUBE_WORKERS}" \
ANSIBLE_EXTRAVARS="{'etc_hosts':${EXTRAVARS_HOSTS}}" \
  ./apl-wrapper.sh ansible/target-kubernetes.yml

exit 0

cmd="sudo kubeadm init --apiserver-advertise-address=${KUBE_MASTER} --pod-network-cidr=10.244.0.0/16"
echo "running ${cmd}, please wait..."
result=$(${cmd})

node_join_cmd="$(echo "${result}" | grep -e "discovery-token-ca-cert-hash")"

for node in $(echo "${KUBE_NODES}" | tr ',' '\n'); do
  ssh ${SSH_OPTS} ${node} "sudo ${node_join_cmd}"
done

cd ${HOME}

mkdir -p ${HOME}/.kube
sudo cp -i /etc/kubernetes/admin.conf ${HOME}/.kube/config
sudo chown "$(id -u)":"$(id -g)" ${HOME}/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

curl -SsL https://storage.googleapis.com/kubernetes-helm/helm-v2.9.1-linux-amd64.tar.gz | tar zxv \
  && sudo mv ./linux-amd64/helm /usr/local/bin \
  && sudo chown root:root /usr/local/bin/helm \
  && rm -fr ./linux-amd64
 
kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
kubectl create clusterrolebinding serviceaccounts-cluster-admin --clusterrole=cluster-admin --group=system:serviceaccounts
 
helm init
helm repo update
