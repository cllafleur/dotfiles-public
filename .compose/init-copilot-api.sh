#!/bin/bash

pushd /tmp
git clone https://github.com/ericc-ch/copilot-api.git
cd copilot-api
docker buildx build -t copilot-api .
rm -Rf /tmp/copilot-api
popd
