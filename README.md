# hpapdb
Scripts to sync the hpap MySQL schemas between the production and development 
servers

Requirements on both servers:

 - commands: dialog, mysql, fortune and cowsay
 - ability to use mysql account to do dumps and restores
 - ssh keys for passwordless logins:
 [How to set up SSH Keys](docs/SSHKEYS.md)
 - A `.my.cnf` file in your HOME directory with the following content to 
 provide passwordless mysql logins
```
[client]
user = <your mysql username>
password = <your mysql password>
host = localhost
```
To install: 
```
git clone https://github.com/Epistasislab/hpapdb
cd hpapdb
./install [install directory] 
```
- The package will be installed in `$HOME/bin` if `[install directory]` 
is unspecified
- The `$HOME/.my.cnf` file will be created for you by the install script if it 
is missing.
- If the install directory is new: `source $HOME/.bashrc`
- Install on both servers before attempting to use.

To update:
```
cd <location of the hpapdb install directory>
git pull
./install [install directory]
```

To use:

Type `syncdb` at the shell prompt.

