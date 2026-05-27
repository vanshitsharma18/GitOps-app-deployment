#!/bin/bash

echo "======================================"
echo " Kubernetes + Docker Full Cleanup"
echo "======================================"

echo ""
echo "[1/8] Deleting KIND clusters..."
kind get clusters | while read cluster; do
  echo "Deleting cluster: $cluster"
  kind delete cluster --name "$cluster"
done

echo ""
echo "[2/8] Stopping all running Docker containers..."
docker stop $(docker ps -aq) 2>/dev/null

echo ""
echo "[3/8] Removing all Docker containers..."
docker rm -f $(docker ps -aq) 2>/dev/null

echo ""
echo "[4/8] Removing unused Docker networks..."
docker network prune -f

echo ""
echo "[5/8] Removing unused Docker volumes..."
docker volume prune -f

echo ""
echo "[6/8] Removing unused Docker images..."
docker image prune -a -f

echo ""
echo "[7/8] Cleaning Docker system..."
docker system prune -a --volumes -f

echo ""
echo "[8/8] Checking ports commonly used by Kubernetes/ArgoCD..."

PORTS=(8080 8081 3000 30080 30443 6443 9090 9093 9100 9091 9094 9095 9096 9097 9098 9099 31000 32000)

for port in "${PORTS[@]}"
do
  pid=$(lsof -ti tcp:$port)

  if [ ! -z "$pid" ]; then
    echo "Killing process on port $port (PID: $pid)"
    kill -9 $pid 2>/dev/null
  fi
done

echo ""
echo "======================================"
echo " Cleanup Completed"
echo "======================================"

echo ""
echo "Verify:"
echo "  kind get clusters"
echo "  docker ps -a"
echo "  kubectl config get-contexts"
