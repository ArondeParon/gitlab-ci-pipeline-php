# Build and test PHP applications with Gitlab CI (or any other CI platform)

This is a drastically simplified version of https://github.com/edbizarro/gitlab-ci-pipeline-php
with the following changes:

- `ext-sockets` is enabled by default
- Only PHP 8 on Debian is supported

---

## Laravel projects

All images come with PHP (with all laravel required extensions), Composer (with [hirak/prestissimo](https://github.com/hirak/prestissimo) to speed up installs), Node and [Yarn](https://yarnpkg.com).

Everything you need to test Laravel projects :D

---

## Gitlab pipeline examples

### Laravel test examples

#### Simple ```.gitlab-ci.yml``` using mysql service

```yaml
# Variables
variables:
  MYSQL_ROOT_PASSWORD: root
  MYSQL_USER: homestead
  MYSQL_PASSWORD: secret
  MYSQL_DATABASE: homestead
  DB_HOST: mysql

test:
  stage: test
  services:
    - mysql:5.7
  image: arondeparon/gitlab-ci-pipeline-php:8.0-alpine
  script:
    - yarn install --pure-lockfile
    - composer install --prefer-dist --no-ansi --no-interaction --no-progress
    - cp .env.example .env
    - php artisan key:generate
    - php artisan migrate:refresh --seed
    - ./vendor/phpunit/phpunit/phpunit -v --coverage-text --colors=never --stderr
```

#### Advanced ```.gitlab-ci.yml``` using mysql service, stages and cache

```yaml
stages:
  - test
  - deploy

# Variables
variables:
  MYSQL_ROOT_PASSWORD: root
  MYSQL_USER: homestead
  MYSQL_PASSWORD: secret
  MYSQL_DATABASE: homestead
  DB_HOST: mysql

# Speed up builds
cache:
  key: $CI_BUILD_REF_NAME # changed to $CI_COMMIT_REF_NAME in Gitlab 9.x
  paths:
    - vendor
    - node_modules
    - public
    - .yarn


test:
  stage: test
  services:
    - mysql:5.7
  image: arondeparon/gitlab-ci-pipeline-php:8.0-alpine
  script:
    - yarn config set cache-folder .yarn
    - yarn install --pure-lockfile
    - composer install --prefer-dist --no-ansi --no-interaction --no-progress
    - cp .env.example .env
    - php artisan key:generate
    - php artisan migrate:refresh --seed
    - ./vendor/phpunit/phpunit/phpunit -v --coverage-text --colors=never --stderr
  artifacts:
    paths:
      - ./storage/logs # for debugging
    expire_in: 7 days
    when: always

deploy:
  stage: deploy
  image: arondeparon/gitlab-ci-pipeline-php:8.0-alpine
  script:
    - echo "Deploy all the things!"
  only:
    - master
  when: on_success
```

#### Laravel Dusk tests ```.gitlab-ci.yml``` using mysql service and cache

```yaml
stages:
  - test

# Variables
variables:
  MYSQL_ROOT_PASSWORD: root
  MYSQL_USER: homestead
  MYSQL_PASSWORD: secret
  MYSQL_DATABASE: homestead
  DB_HOST: mysql

# Speed up builds
cache:
  key: $CI_BUILD_REF_NAME # changed to $CI_COMMIT_REF_NAME in Gitlab 9.x
  paths:
    - vendor
    - node_modules
    - public
    - .yarn


test:
  stage: test
  services:
    - mysql:5.7
  image: arondeparon/gitlab-ci-pipeline-php:8.0-chromium
  script:
    - yarn config set cache-folder .yarn
    - yarn install --pure-lockfile
    - composer install --prefer-dist --no-ansi --no-interaction --no-progress
    - cp .env.example .env
    - php artisan key:generate
    - php artisan migrate:refresh --seed
    - php artisan serve &
    - ./vendor/laravel/dusk/bin/chromedriver-linux --port=9515 &
    - sleep 5
    - php artisan dusk
  artifacts:
    paths:
      - ./storage/logs # for debugging
      - ./tests/Browser/screenshots # for Dusk screenshots
      - ./tests/Browser/console
    expire_in: 7 days
    when: always
```
