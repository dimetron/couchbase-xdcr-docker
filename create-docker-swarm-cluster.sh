# Docker Swarm master
docker-machine \
  create \
  -d virtualbox \
  --swarm \
  --swarm-master \
  --swarm-discovery="consul://$(docker-machine ip consul-machine):8500/v1/kv/cluster$1" \
  --engine-opt="cluster-store=consul://$(docker-machine ip consul-machine):8500/v1/kv/cluster$1" \
  --engine-opt="cluster-advertise=eth1:2376" \
  --virtualbox-cpu-count "1" \
  --virtualbox-memory "512"  \
  --virtualbox-no-share \
  swarm-master-$1

# Docker Swarm node-01
docker-machine \
  create \
  -d virtualbox \
  --swarm \
  --swarm-discovery="consul://$(docker-machine ip consul-machine):8500/v1/kv/cluster$1" \
  --engine-opt="cluster-store=consul://$(docker-machine ip consul-machine):8500/v1/kv/cluster$1" \
  --engine-opt="cluster-advertise=eth1:2376" \
  --virtualbox-cpu-count "1" \
  --virtualbox-memory "512"  \
  --virtualbox-no-share \
  swarm-node-$1-01

# Docker Swarm node-02
docker-machine \
  create \
  -d virtualbox \
  --swarm \
  --swarm-discovery="consul://$(docker-machine ip consul-machine):8500/v1/kv/cluster$1" \
  --engine-opt="cluster-store=consul://$(docker-machine ip consul-machine):8500/v1/kv/cluster$1" \
  --engine-opt="cluster-advertise=eth1:2376" \
  --virtualbox-cpu-count "1" \
  --virtualbox-memory "512" \
  --virtualbox-no-share \
  swarm-node-$1-02

# Configure to use Docker Swarm cluster
eval "$(docker-machine env --swarm swarm-master-$1)"

