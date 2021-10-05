#### SSH keys can provide relief to users.

*   Are you tired of typing in strong passwords over and over again to connect 
    machines you use?
*   Using SSH keys allows you to connect and move files between your accounts on 
    various systems without the use of a password.
*   SSH generates a private and public key.
*   The public key can be put on the machines you wish to communicate with.
*   SSH will then connect to those machines with keys instead of your standard 
    password.

#### Let's get started

*   The following commands will create a pair of keys for your cluster login 
    from which you'll be connecting to **remote_system**.

```
my_system$ ssh-keygen -t rsa
```

#### Generating public/private rsa key pair.

*   **ssh-keygen** will prompt you for the file where you wish to save your 
    private key.
*   This is the key that will only be on your machine and not given out to 
    others.
*   It will be called **id_rsa**.
*   The file should be located in the **.ssh** directory inside your home 
    directory.
*   If you are user **pete**:

```
Enter file in which to save the key `(/home/pete/.ssh/id_rsa):
```

*   Next, it will prompt for the passphrase you wish to use.
*   This is basically the password for your key.
*   Just press the **ENTER** key through the passphrase prompts.

```
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/pete/.ssh/id_rsa.
Your public key has been saved in /home/pete/.ssh/id_rsa.pub.
The key fingerprint is:
XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX pete@my_system
```

*   Now if you list the contents of your **.ssh** directory you should see your 
    private and public key.

```
my_system$ ls .ssh
id_rsa id_rsa.pub
```

*   Now that you have generated your keys you need to put your public keys in 
    the authorized keys file on all the machines you wish to connect to using 
    **ssh**.
*   In this example, I will use a machine called **remote_system.**
*   If you are username is the same on both systems then you do not have to use 
    pete@ in the destination.

```
my_system$ ssh-copy-id  pete@remote_system
```

*   **ssh-copy-id** will prompt you for the password to the remote machine.
*   On the machine you started with, in our example, **my_system**, try to SSH 
    to the remote machine.
*   It should no longer prompt you to enter your password.
*   This also means that the commands **ssh**, **scp**, **sftp** and any command 
    that can use ssh connections (_ie:_ **_rsync_**), will not prompt for a 
    password.
