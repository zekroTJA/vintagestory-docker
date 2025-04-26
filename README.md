# Vintage Story Server Docker Image

An unofficial Docker image to host a [Vintage Story](https://www.vintagestory.at) server with built-in backup support.

## Setup

Take a look at the provided [docker-compose.yml](docker-compose.yml) to easily setup the server.

## Backup

Backups can be created automatically before a server start.
For this, a Docker secret must be stored in /run/secrets/rcloneconfig.  
rclone is used. The default target is `backup:/`  
Rclone offers a number of very [different destinations](https://rclone.org/overview/). In this example, an S3 endpoint with a specific subdirectory is used.

Example config:

```txt
[contabo]
type = s3
provider = Other
env_auth = false
access_key_id = access_key
secret_access_key = secret_key
endpoint = https://eu2.contabostorage.com/

[backup]
type = alias
remote = contabo:/vintagestory-server
```

This configuration must now be loaded into the container as a secret.
Target file is ``/run/secrets/rcloneconfig``.
If the target file is found, the backup starts each container start.

### Envs for Backup Settings

For exact details please refer to ``backup.sh``.

- ``BACKUP_FILE_FORMAT``:
This can be used to specify the backup timestamp.
It uses the date command line tool to interpret the placeholder varibales (``date ${BACKUP_FILE_FORMAT}``).  
- ``BACKUP_TARGET``: Rclone backup target name
- ``MAX_AGE_BACKUP_FILES``:
Specify the maximum length of time a backup file should be kept. One backup file is always kept.
- ``POST_START_BACKUP``: Enable backup after server stop
- ``PRE_START_BACKUP``: Enable pre start backup  
- ``BACKUP_SUCCESS_SCRIPT``: Will be executed when the backup creation was successful.
- ``BACKUP_FAILED_SCRIPT``: Will be executed when the backup creation has failed.

An example for a `BACKUP_FAILED_SCRIPT` could look as following.
```
curl -u "user:password" -d "$MESSAGE" "https://ntfy.example.com/vintagestory_backups?title=Backup%Failed"
```