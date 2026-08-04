# Transferring data

### Where is your data?

Your home directory, `/users/your-user-name/`, is shared across all CARC machines, meaning that once your data has been uploaded to your home directory, it is accessible regardless of which machine you are logged in to.

### Graphical User Interface (GUI) options

There are several options available for data transfer that employ a GUI for ease of use. Several options are listed below, linked to the homepage for each piece of software, with documentation on how to use it.

* [FileZilla](https://filezilla-project.org/)
* [WinSCP](https://winscp.net/eng/index.php)
* [Fetch](https://fetchsoftworks.com/)
* [CyberDuck](https://cyberduck.io/)

FileZilla is available for both Windows and Unix systems, whereas WinSCP is Windows-only and Fetch is macOS-only. GUI-based programs are very user-friendly and well-suited to those who are less comfortable with the Linux command-line interface. Unfortunately, the programs listed above, and other GUI-based programs, use File Transfer Protocol (FTP), which has a relatively low transfer speed and is best suited to smaller file sizes.

### Command-line interface (CLI) options

For larger files, it is recommended that you use one of several programs implemented as a command-line interface. These programs have several benefits over their GUI-based counterparts, including higher transfer speeds and the ability to resume a transfer if it is interrupted, without having to restart from the beginning. Below are two popular options with example commands and links for more advanced usage.

#### Secure Copy (SCP)

Transfer from local machine to CARC:
```bash
scp /your-file your-username@easley.alliance.unm.edu:target-directory/
```

Transfer from CARC to local machine:
```bash
scp your-username@easley.alliance.unm.edu:your-file /target-directory/
```

#### Remote Sync (RSYNC)

Transfer from local machine to CARC:
```bash
rsync -vhatP /your-file your-username@easley.alliance.unm.edu:target-directory
```

Transfer from CARC to local machine:
```bash
rsync -vhatP your-username@easley.alliance.unm.edu:your-file /target-directory/
```

The `-vhatP` flags instruct rsync to print the progress of the transfer verbosely and in a human-readable format.

As you can see, the syntax for these two programs is very similar; however, the options for advanced usage are unique to each one. The examples above cover only basic data transfers — refer to the links provided, or use `man programname` for the CLI options, to optimize each tool for maximum data transfer efficiency and speed.

*This quickbyte was validated on 6/22/2026*
