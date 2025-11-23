#!/bin/bash

# デフォルト値の設定
IS_ROOT=0
DEBUG=0
CONTAINER_NAME="verification_24"

# ヘルプメッセージの表示
usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --root, -r     Root権限でコンテナにアクセス
  --debug, -d    デバッグモードを有効にする
  --container, -c CONTAINER_NAME  コンテナ名を指定（デフォルト: ubuntu_xrdp_24）
  --help, -h     このヘルプメッセージを表示

Examples:
  $0                    # 通常モードでログイン
  $0 --root             # Root権限でログイン
  $0 --debug            # デバッグモードでログイン
  $0 --root --debug     # Root権限かつデバッグモードでログイン
  $0 -c my_container    # 指定したコンテナにログイン
EOF
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --root|-r)
            IS_ROOT=1
            shift
            ;;
        --debug|-d)
            DEBUG=1
            shift
            ;;
        --container|-c)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

if [ ${DEBUG} -eq 1 ]; then
    echo "[DEBUG] IS_ROOT: ${IS_ROOT}"
    echo "[DEBUG] CONTAINER_NAME: ${CONTAINER_NAME}"
    echo "[DEBUG] DEBUG: ${DEBUG}"
fi

docker_exec() {
    if [ ${IS_ROOT} -eq 0 ]; then
        echo "[USER MODE]"
        docker exec -u ubuntu:ubuntu -it "${CONTAINER_NAME}" /bin/bash
        # docker exec -u ubuntu:ubuntu -it "${CONTAINER_NAME}" /bin/bash -c "$1"
    else
        echo "[ROOT MODE]"
        docker exec -it "${CONTAINER_NAME}" /bin/bash
    fi
}

docker_exec

