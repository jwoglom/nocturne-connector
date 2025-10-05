connector-api:
    #!/usr/bin/env bash
    ALPINE_ARCH="${ALPINE_ARCH:-aarch64}"
    if [ "$ALPINE_ARCH" = "armv7" ]; then
        export GOARCH=arm
        export GOARM=7
    elif [ "$ALPINE_ARCH" = "armhf" ]; then
        export GOARCH=arm
        export GOARM=6
    else
        export GOARCH=arm64
    fi
    cd src && rm -f connector-api && GOOS=linux go build -ldflags "-s -w" -o connector-api

run: connector-api
    sudo -E ./build.sh

lint:
    pre-commit run --all-files

docker-qemu:
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
