# Transferring data

### Where is your data?

Your home directory, `/users/your-user-name/`, is shared across all CARC machines, meaning that once your data has been uploaded to your home directory it is accessible regardless of which machine you are logged in to. Refer to our documentation page on CARC for details on CARC systems.

### Graphical User Interface (GUI) options

There are several options available for data transfer that employ a GUI for ease of use. Several options are listed below and are linked to the homepage for the software with documentation on how to use it.

* [FileZilla](https://filezilla-project.org/)
* [WinSCP](https://winscp.net/eng/index.php)
* [Fetch](https://fetchsoftworks.com/)
* [CyberDuck](https://cyberduck.io/)

FileZilla is available for both Windows and Unix systems, whereas WinSCP is Windows only, and Fetch is MacOS only. GUI-based programs are very user friendly and well-suited to those that are less comfortable in Linux Command-line interface. Unfortunately, the programs listed above, and other GUI-based programs, employ File Transfer Protocol (FTP), which has a relatively low transfer speed and is suitable for smaller file sizes.

### Command-line interface (CLI) options

For larger files it is recommended you use one of several programs implemented in a command-line interface. These programs have several benefits over their GUI-based counterparts, including higher transfer speeds and the ability to continue a transfer if it is interrupted without having to restart from the beginning. Below are several popular options with example commands and links for more advanced usage.

#### Secure Copy (SCP)

Transfer from local machine to CARC:

```bash
scp /your-file your-username@wheeler.alliance.unm.edu:target-directory/
```

Transfer from CARC to local machine:

```bash
scp your-username@wheeler.alliance.unm.edu:your-file /target-directory/
```

#### Remote Sync (RSYNC)

Transfer from local machine to CARC

```bash
rsync -vhatP /your-file your-username@wheeler.alliance.unm.edu:target-directory
```
Transfer from CARC to local machine

```bash
rsync -vhatP your-username@wheeler.alliance.unm.edu:your-file /target-directory/
```

The `-vhatP` flag are instructions to rsync print out the progress of the transfer verbosely and human-readable.

#### BaBar Copy (BBCP)

Transfer from local machine to CARC

```bash
bbcp /your-file your-username@wheeler.alliance.unm.edu:target-directory/
```

Transfer from CARC to local machine

```bash
bbcp your-username@wheeler.alliance.unm.edu:your-file /target-directory/
```

As you can see, the syntax for using the various programs is very similar, however, the options for advanced usage are unique to each program. The examples provided above are for very basic data transfers, but you should refer to the links provided, or for the CLI options use the command `man programname`, in order to optimize each for maximum data transfer efficiency and speed. The necessity for transfer optimization increases as file size increases.
