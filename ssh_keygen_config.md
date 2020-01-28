# SSH keys and config file

Once you start computing you will be logging in to the CARC systems fairly often and having to type your username at the machine address will become tedious. In order to alleviate this tedium it is beneficial to generate ssh keys and a ssh config file. The ssh keys bypass the need to enter your password each time you log in, and the config file stores the addresses of all the machines you are logging in to. 

### SSH key generation
First, set up your ssh key. To do this type in the terminal prompt:

```bash
ssh-keygen
```
Just keep hitting enter until the program finishes. We recommend that you decline setting up a passphrase as this defeats the convenience of having a SSH key. Now that your SSH key has been generated you need to copy it to your home directory at CARC. To do, open terminal and type:

```bash
ssh-copy-id yourusername@machinename.alliance.unm.edu
```
Since your home directory is shared across all machines at CARC you only need to do this step once to enable ssh key access across all CARC machines. 

### SSH config file
To make logging in to CARC even easier we also recommend setting up a ssh config file which allows you to simply type `ssh machinename` instead of your username at the machine address. To set up this file simply copy the example below and save it to a text document in your `ssh` folder, which is found at `~/.ssh/`. Change the user to your CARC username and you are set to log in quickly and efficiently. You can add machines based on which ones you have access to. 

```bash
Host wheeler
    hostname wheeler-sn.alliance.unm.edu
    user CHANGEME
    port 22
Host galles
    hostname galles.alliance.unm.edu
    user CHANGEME
    port 22
Host xena
    hostname xena.alliance.unm.edu
    user CHANGEME
    ForwardX11 yes
    port 22sa
```


