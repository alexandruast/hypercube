#!/usr/bin/env bash
set -eEuo pipefail
trap 'RC=$?; echo [error] exit code $RC running $BASH_COMMAND; exit $RC' ERR

SSH_OPTS='-o LogLevel=error -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o BatchMode=yes'

JQ_VERSION='1.5'
JQ_CHECK_CMD='jq --version >/dev/null 2>&1'

PIP_CHECK_CMD='pip --version >/dev/null 2>&1'

ANSIBLE_VERSION='2.6.4'
ANSIBLE_CHECK_CMD='ansible --version >/dev/null 2>&1'

install_jq() {
  sudo curl -LSs https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64 -o /usr/local/bin/jq \
  && sudo chmod +x /usr/local/bin/jq \
  && eval "${JQ_CHECK_CMD}"
}

install_pip() {
  curl -LSs "https://bootstrap.pypa.io/get-pip.py" | sudo python \
  && eval "${PIP_CHECK_CMD}"
}

install_ansible() {
  sudo pip install ansible==${ANSIBLE_VERSION} \
  && eval "${ANSIBLE_CHECK_CMD}"
}

cd /vagrant/

sudo yum -q -y install \
  python \
  libselinux-python

! eval "${PIP_CHECK_CMD}" && install_pip

! eval "${ANSIBLE_CHECK_CMD}" && install_ansible

! eval "${JQ_CHECK_CMD}" && install_jq

KUBE_NODES="$(jq -re '. | map(select(.type =="master" or .type == "worker")) | map(.ip) | join(",")' "${HOME}/nodes.json")"

ANSIBLE_TARGET="${KUBE_NODES}" \
ANSIBLE_EXTRAVARS="{'nodes_json':$(jq -rec . "${HOME}/nodes.json" | tr '"' "'")}" \
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
