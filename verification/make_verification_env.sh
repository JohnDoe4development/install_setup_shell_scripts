#!/bin/bash

cd `dirname $0`

check_docker_service(){
  if ! sudo service docker status > /dev/null 2>&1; then
    echo "Docker service is not running. Starting Docker..."
    sudo service docker start
    sleep 2
    if ! sudo service docker status > /dev/null 2>&1; then
      echo "Failed to start Docker service. Please check system logs. Exiting."
      exit 1
    fi
    echo "Docker service started successfully."
  else
    :
    # echo "Docker service is already running."
  fi
}

remove_container() {
  CONTAINER_NAME=$1
  # コンテナが既に存在する場合は削除してから再作成
  if [ "$(docker ps -aq -f name=$1)" ]; then
    docker rm -f ${CONTAINER_NAME} 1> /dev/null
  fi
}

VERSION=$1
VERSION=${VERSION:-"24"}
# IMG_NAME="ubuntu:${VERSION}.04"
IMG_NAME=verification-ubuntu:${VERSION}

CONTAINER_NAME="verification_${VERSION}"
check_docker_service
remove_container ${CONTAINER_NAME}

# ---

# CAP_ADD_OPT=""
CAP_ADD_OPT="--privileged"
# CAP_ADD_OPT="--cap-add=SYS_ALL"
# CAP_ADD_OPT="--cap-add=SYS_ADMIN"
SECURITY_OPT_FOR_APPARMOR=""
# SECURITY_OPT_FOR_APPARMOR="--security-opt=apparmor:confined"
SECURITY_OPT_FOR_SECCOMP=""
# SECURITY_OPT_FOR_SECCOMP="--security-opt=seccomp:unconfined"

# ---

DOCKER_FILE_RELATIVE_PATH="./Dockerfile"
DOCKER_FILE_DIR_RELATIVE_PATH="."
docker build -t ${IMG_NAME} \
             -f ${DOCKER_FILE_RELATIVE_PATH} ${DOCKER_FILE_DIR_RELATIVE_PATH}

# ---

docker run --rm -d -it \
    ${CAP_ADD_OPT} \
    ${SECURITY_OPT_FOR_APPARMOR} \
    ${SECURITY_OPT_FOR_SECCOMP} \
    -h verification \
    --name ${CONTAINER_NAME} ${IMG_NAME}

scripts=(
    "./hello_world.sh"
)

for script in "${scripts[@]}"; do
    docker cp ${script} ${CONTAINER_NAME}:/root/
    docker exec -it ${CONTAINER_NAME} bash -c "bash $(basename ${script}) && bash"
done

docker rm -f ${CONTAINER_NAME}
