# kopia + rclone Docker image

Docker image with kopia and rclone

---

[![release build](https://github.com/infinityofspace/kopia_rclone_docker/actions/workflows/docker-publish-release.yml/badge.svg)](https://github.com/infinityofspace/kopia_rclone_docker/actions/workflows/docker-publish-release.yml)
[![weekly build](https://github.com/infinityofspace/kopia_rclone_docker/actions/workflows/docker-publish-weekly.yml/badge.svg)](https://github.com/infinityofspace/kopia_rclone_docker/actions/workflows/docker-publish-weekly.yml)
[![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/infinityofspace/kopia_rclone_docker?include_prereleases&label=lastest%20version&style=plastic)](https://github.com/infinityofspace/kopia_rclone_docker/releases)

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

You can find detailed information about the supported versions of kopia and rclone in
the [versions' wiki](https://github.com/infinityofspace/kopia_rclone_docker/wiki/versions).

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

#### Backup Docker volumes

The following example describes the backup of any Docker volume.
Advantages of the backup with kopia and rclone:
- end to end encrypted backup
- duplicate the backup with kopia repository [synchronization](https://kopia.io/docs/advanced/synchronization/)
- incremental backups
- send backup to remote storage (this means that if local storage space is limited, complete backups that require more storage than is available locally are still possible)

Before we get started, we need to customise the image. We need to add `curl` to the base image, which we need to interact with the Docker socket.
For this purpose, create the file `Dockerfile` with the following content:
```Dockerfile
FROM ghcr.io/infinityofspace/kopia_rclone_docker:latest

RUN apk add --no-cache curl
```

In the next step, create the `docker-compose.yml` file with the following content:
```docker-compose
version: "3"

    services:
        kopia:
            build: .
            restart: unless-stopped
            ports:
                - 127.0.0.1:8080:8080
            environment:
                - KOPIA_PERSIST_CREDENTIALS_ON_CONNECT=true
            volumes:
                - kopia_config:/kopia/config
                - kopia_logs:/kopia/logs

                # rclone config folder
                - ./rclone_config:/rclone
                # custom docker container shutdown and startup scripts folder
                - ./scripts:/scripts

                # rootless docker socket location
                - "$XDG_RUNTIME_DIR/docker.sock:/var/run/docker.sock"
                # uncomment the next line when you use a rootfull docker socket location
                # - /var/run/docker.sock:/var/run/docker.sock

                # all volumes which should be backed up
                - volume1:/volumes/volume1:ro
            command:
                - kopia
                - server
                - start
                - --insecure
                - --address=0.0.0.0:8080
                - --server-username=${USER}
                - --server-password=${KOPIA_PASSWORD}

volumes:
    kopia_config:
    kopia_logs:
    volume1:
        external: true
```

The service `kopia` is defined in the docker compose file, which offers a web UI for creating and managing backups.
This Web UI can be accessed at the address `http://localhost:8080`.

However, before you start the docker compose service, you must first create scripts for the shutdown and start docker container that use the desired volume.
Create the container shutdown and restart scripts in a folder called `scripts` next to the docker compose file (the name of the container is in this example `container_service1`):

Shutdown script:
```bash
#!/bin/sh

curl --unix-socket /var/run/docker.sock -X POST http:/v1.24/containers/container_service1/stop
```
Start script:
```bash
#!/bin/sh

curl --unix-socket /var/run/docker.sock -X POST http:/v1.24/containers/container_service1/start
```

You can name these as you wish, in this example the file is named `container_service1-shutdown.sh` for the shutdown and `container_service1-start.sh` for the start script.
After you have created the scripts, you still have to make them executable. This is possible under common Unix systems with this command:
```commandline
chmod -x scripts/*
```

The last preparation step is to define the kopia user and password. This is done using the following `.env` file:
```
USER=
KOPIA_PASSWORD=
```

Finally, start the kopia docker service with the command:
```commandline
docker compose up -d
```

---

Now open the address `http://localhost:8080` of the Web UI in a web browser. At the first start, set up the kopia repository and select `rclone` as the provider.
Also make sure the config file is set to `/kopia/config/repository.config`. In the next step, we set up the backup of volume `volume1` by entering the path `/volumes/volume1` of
volume `volume1` of the container under the menu item `Policies` in the input field `enter directory to find or set policy` and creating the policy with the button `Set Policy`.
To stop the container in the backup process so that no unstable data state of the backup occurs, we must now set up the shutdown and start scripts in the previously
created policy. To do this, use the `Edit` button of the corresponding policy in the `Policies` menu item. Now enter the script path `container_service1-shutdown.sh` in
the `Before Snapshot` entry of the `Snapshot Action` menu. For the entry `After Snapshot` enter `container_service1-start.sh` and save the policy with the `Save Policy` button.

At this point, the Docker volume `volume1` can be backed up. Ideally, set up a scheduled backup in the policy for the path so that a backup is performed automatically.

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
