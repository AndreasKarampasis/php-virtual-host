# php-virtual-host
Bash script to create or delete virtual host.
Creates basic php project.
## Installing
1. Download script
2. Change permission to make script executable
```
chmod +x path/to/phproject.sh
```
## Usage
```
path/to/phproject.sh [ create | delete ] [ domain name ] [root folder name]
```
Root folder name is optional.
```
path/to/phproject.sh [ create | delete ] [ domain name ]
```
## Example
### Create
Create new virtual host
```
./phproject.sh create foo.local
```
Create new virtual host with custom root folder name.
```
./phproject.sh create foo.local folder_name
```
### Delete
Delete virtual host
```
./phproject.sh delete foo.local
```
Delete virtual host with custom root folder name.
```
./phproject.sh delete foo.local folder_name
```
# Acknowledgments
- Inspiration: [RoverWire](https://github.com/RoverWire/virtualhost) virtualhost script.
