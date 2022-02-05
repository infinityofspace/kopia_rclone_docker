# kopia + rclone Docker image

Docker image with kopia and rclone

---

[![release build](https://github.com/infinityofspace/kopia_rclone_docker/actions/workflows/docker-publish-release.yml/badge.svg)](https://github.com/infinityofspace/kopia_rclone_docker/actions/workflows/docker-publish-release.yml)
[![weekly build](https://github.com/infinityofspace/kopia_rclone_docker/actions/workflows/docker-publish-weekly.yml/badge.svg)](https://github.com/infinityofspace/kopia_rclone_docker/actions/workflows/docker-publish-weekly.yml)

---

### Table of Contents

1. [About](#about)
2. [Versions](#versions)
    1. [Supported architectures](#supported-architectures)
3. [Usage](#usage)
    1. [Examples](#examples)
4. [Build locally](#build-locally)
5. [Third party notices](#third-party-notices)
6. [License](#license)

---

## About

This docker image contains kopia and rclone build from source which can be used out of the box.
[kopia](https://github.com/kopia/kopia) is an open source backup tool with other useful features such as encryption,
deduplication and compression. It has a [rclone](https://github.com/rclone/rclone) integration for storing the backups
in one of the cloud storage systems supported by rclone.

## Versions

The following table contains the version information of the included kopia and rlcone for each image version/tag:

|      image version      | kopia version | rclone version |
|:-----------------------:|:-------------:|:--------------:|
|     0.4, *latest*,      |    v0.10.4    |    v1.57.0     |
| 0.4-noui, *latest-noui* |    v0.10.4    |    v1.57.0     |
|           0.3           |    v0.9.5     |    v1.57.0     |
|        0.3-noui         |    v0.9.5     |    v1.57.0     |
|           0.2           |    v0.8.4     |    v1.56.0     |
|        0.2-noui         |    v0.8.4     |    v1.56.0     |
|         weekly          |       -       |       -        |
|       weekly-noui       |       -       |       -        |

The `*-noui` tags are kopia builds without the web ui of the kopia server.

*Note: The `weekly` tag is not intended for productive use, as it automatically builds the image with the changes of the
respective master branches every sunday at 0 o'clock.*

### Supported architectures

Images are created for the following architectures:

- amd64
- arm64/v8
- arm/v7

## Usage

You can pull the latest version of the image with this command:

```commandline
docker pull ghcr.io/infinityofspace/kopia_rclone_docker:latest
```

To use rclone, you must first create a configuration of the storage system to be used. The rclone configuration is in
the `/rclone` path. If you have not already created an rclone configuration for the desired storage system you can use
the following command and follow the rclone instructions to create such configuration:

```commandline
docker run \
    -v $(pwd)/rclone:/rclone \
    ghcr.io/infinityofspace/kopia_rclone_docker:latest \
        rclone config
```

The usage of rclone can be found in the [official documentation](https://rclone.org/docs/).

Now we use the rclone storage system configuration for kopia. You can use the kopia commands as normal:

```commandline
docker run \
    -v $(pwd)/rclone:/rclone \
    ghcr.io/infinityofspace/kopia_rclone_docker:latest \
        kopia --version
```

You can also put all the kopia commands into a shell script and then run them in the docker container at startup (here
the `kopia_cmds.sh ` file contains all the commands, make sure the file is executable). Moreover, you can specify the
kopia password with the `KOPIA_PASSWORD` environment variable:

```commandline
docker run \
    -v $(pwd)/rclone:/rclone \
    -v $(pwd)/kopia_cmds.sh:/kopia_cmds.sh \
    -e KOPIA_PASSWORD=mysecretpassword \
    ghcr.io/infinityofspace/kopia_rclone_docker:latest \
        /kopia_cmds.sh 
```

To store the kopia configuration independently of a docker container you can use docker volumes. The kopia configuration
is in the `/kopia/config` path and the kopia cache is in `/kopia/cache`. Here we store the kopia configuration and data
cache in docker volumes:

```commandline
docker run \
    -v $(pwd)/rclone:/rclone \
    -v kopia_config:/kopia/config \
    -v kopia_cache:/kopia/cache \
    -e KOPIA_PASSWORD=mysecretpassword \
    ghcr.io/infinityofspace/kopia_rclone_docker:latest \
        kopia repository create rclone \
        --remote-path testcloud:/path/to/the/backup/dir
```

The following environment variables are defined for the docker image:

- KOPIA_CONFIG_PATH=/kopia/config/repository.config
- KOPIA_LOG_DIR=/kopia/logs
- KOPIA_CACHE_DIRECTORY=/kopia/cache
- RCLONE_CONFIG=/rclone/rclone.conf
- KOPIA_CHECK_FOR_UPDATES=false

You can override them if you want to adjust the paths or values.

The official usage documentation of kopia can be found [here](https://kopia.io/docs/).

### Examples

rclone or kopia can be used as usual. In the examples, we assume that we already have a valid rclone configuration in
the current working directory. Some examples are listed below:

#### rclone

Get quota information of the remote `mycloud`:

```commandline
docker run \
    -v $(pwd)/rclone:/rclone \
    ghcr.io/infinityofspace/kopia_rclone_docker:latest \
        rclone about mycloud:
```

List all content in the path `/backups` on the remote `mycloud`:

```commandline
docker run \
    -v $(pwd)/rclone:/rclone \
    ghcr.io/infinityofspace/kopia_rclone_docker:latest \
        rclone ls mycloud:/backups
```

Show the version number of rclone:

```commandline
docker run \
    -v $(pwd)/rclone:/rclone \
    ghcr.io/infinityofspace/kopia_rclone_docker:latest \
        rclone version
```

#### kopia

Initialise a new kopia repository in the remote path `/backup/data` on the remote `mycloud`. Additionally, the password
used to encrypt the repo data is `mysecretpassword` and the kopia configuration respectively cache is written to the
Docker volumes `kopia_config` and `kopia_cache`:

```commandline
docker run \
    -v $(pwd)/rclone:/rclone \
    -v kopia_config:/kopia/config \
    -v kopia_cache:/kopia/cache \
    -e KOPIA_PASSWORD=mysecretpassword \
    ghcr.io/infinityofspace/kopia_rclone_docker:latest \
        kopia repository create rclone \
        --remote-path mycloud:/backup/data
```

Connect to an existing kopia repository in the remote path `/backup/data` on the remote `mycloud`. Additionally, the
password used to encrypt the repo data is `mysecretpassword` and the kopia configuration respectively cache is written
to the Docker volumes `kopia_config` and `kopia_cache`:

```commandline
docker run \
    -v $(pwd)/rclone:/rclone \
    -v kopia_config:/kopia/config \
    -v kopia_cache:/kopia/cache \
    -e KOPIA_PASSWORD=mysecretpassword \
    ghcr.io/infinityofspace/kopia_rclone_docker:latest \
        kopia repository connect rclone \
        --remote-path mycloud:/backup/data
```

Set the `global` policy for the number of kept annual snapshot of the currently connected repo to `12`, where the
currently connected repo is stored in the docker volume kopia_config:

```commandline
docker run \
    -v $(pwd)/rclone:/rclone \
    -v kopia_config:/kopia/config \
    -v kopia_cache:/kopia/cache \
    -e KOPIA_PASSWORD=mysecretpassword \
    ghcr.io/infinityofspace/kopia_rclone_docker:latest \
      kopia \
      policy \
      set \
      --global \
      --keep-annual 12
```

## Build locally

Before you create the image you must first clone the repo:

```commandline
git clone https://github.com/infinityofspace/kopia_rclone_docker.git
```

Change the current working directory:

```commandline
cd kopia_rclone_docker
```

You can build the image yourself locally instead of using the prebuild image. Use the following command to build the
docker image with a full kopia server version. This version includes the web gui and is built directly from the
`master` branches of kopia and rclone:

```commandline
docker build -t kopia_rclone_docker .
```

If you don't need the web gui of kopia server, then you can specify this with the build argument `KOPIA_BUILD_TYPE=noui`
and kopia will be built without the web gui:

```commandline
docker build \
    --build-arg KOPIA_BUILD_TYPE=noui \
    -t kopia_rclone_docker \
    .
```

If you want to use a specific version of kopia or rlcone for the image build, you can do this with the environment
variables `RCLONE_BRANCH` and `KOPIA_BRANCH` respectively:

```commandline
docker build \
    --build-arg KOPIA_BUILD_TYPE=noui \
    --build-arg RCLONE_BRANCH=v1.56.0 \
    --build-arg KOPIA_BRANCH=v0.8.4 \
    -t kopia_rclone_docker \
    .
```

## Third party notices

This project uses source code with different licenses, these are listed in the following:

- rclone:
    - [link to project](https://github.com/rclone/rclone)
    - [link to license](https://raw.githubusercontent.com/rclone/rclone/master/COPYING)
- kopia:
    - [link to project](https://github.com/kopia/kopia)
    - [link to license](https://raw.githubusercontent.com/kopia/kopia/master/LICENSE)

By using this docker image, you agree to the listed licenses.

## License

[MIT](License) - Copyright (c) 2021 Marvin Heptner
