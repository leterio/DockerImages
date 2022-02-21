# MiniDLNA

[DockerFile](https://github.com/leterio/DockerImages/blob/master/minidlna/Dockerfile)

[Compose](https://github.com/leterio/DockerImages/blob/master/minidlna/docker-compose.yml)

## Usage
```
docker run --rm viniciusleterio/minidlna -params
```

## ENV Variables:

* MINIDLNA_UID (-U)

  Set the minidlna user UID

* MINIDLNA_GID (-G)

  Set the minidlna user GID

* GROUP\[0-9\]* (-g)

  Add a group and include the minidlna user
  
  NOTE: Useful when using multiples directories with multiples permissions by group

* OPTION\[0-9\]* (-O)

  Set an option to MiniDNLA config file

* MINIDLNA_FRIENDLY_NAME (-f)

  Set the friendly name of MiniDNLA

* MINIDLNA_INOTIFY (-i)

  Enable to MiniDNLA monitore files under media_dir  

* MINIDLNA_MEDIA_DIR[0-9]* (-m)

  Set MiniDNLA media directories

## VOLUMES

You have to mount all desired media dirs insde the /data in the container, then map each with the "MINIDLNA_MEDIA_DIR" env variable.