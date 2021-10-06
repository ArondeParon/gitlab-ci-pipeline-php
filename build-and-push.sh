#!/bin/bash
docker build --compress -t arondeparon/gitlab-ci-pipeline-php:8.0 -f php/8.0/Dockerfile .
docker tag arondeparon/gitlab-ci-pipeline-php:8.0 arondeparon/gitlab-ci-pipeline-php:8.0
docker push arondeparon/gitlab-ci-pipeline-php:8.0
