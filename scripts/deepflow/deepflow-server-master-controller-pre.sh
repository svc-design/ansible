k8s_node=`kubectl  get nodes | awk 'NR>1{print $1}'`

kubectl label node $k8s_node master_controller=enable
kubectl label node $k8s_node tsdb=enable
kubectl label node $k8s_node dfdb=enable
kubectl label node $k8s_node elasticsearch-warm=enable

kubectl describe node  | grep Taint
kubectl taint nodes $k8s_node node-role.kubernetes.io/control-plane:NoSchedule-


kubectl label nodes $k8s_node slave_controller-

kubectl get node --show-labels

mkdir -p /usr/local/deepflow
mount -o ro deepflow-docker-release-v6.5-242.iso /media

rsync -av /media/* /usr/local/deepflow/
ln -sv /usr/local/deepflow/registry /var/lib/registry -f || rsync -av /usr/local/deepflow/registry/* /var/lib/registry/
