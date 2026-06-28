# Transferring data

### Where is your data?

Your home directory, `/users/your-user-name/`, is shared across all CARC machines, meaning that once your data has been uploaded to your home directory, it is accessible regardless of which machine you are logged in to. Refer to our [CARC Systems documentation page](#) for details on CARC systems.

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

##### Using rsync on Windows

Windows does not include `rsync` by default. Two commonly used options are **MobaXterm** and **MSYS2**. Both provide a Unix-like command-line environment that allows you to run the same `rsync` commands shown above.

---

###### Option 1: MobaXterm

MobaXterm already includes `rsync`, so no additional installation is required.

##### Step 1: Download MobaXterm

Download the Home Edition from the MobaXterm website. Extract the downloaded ZIP file and launch MobaXterm.

##### Step 2: Configure your home directory

By default, MobaXterm stores its home directory in an internal location that is difficult to access from Windows Explorer. Configuring a persistent home directory allows you to work directly from a folder such as **Documents**.

1. Open **Settings → Configuration → General**.
2. Next to **Persistent home directory**, click the yellow folder icon.
3. Browse to a folder you want to use, for example:

```
C:\Users\yourname\Documents
```

4. Click **OK** and restart MobaXterm.

After restarting, `~` refers to the folder you selected.

##### Step 3: Open a local terminal

Click **Start local terminal**. All `rsync` commands should be entered into this terminal.

##### Step 4: Transfer files

Transfer from your local computer to CARC:

```bash
rsync -vhatP ~/your-folder/ your-username@easley.alliance.unm.edu:target-directory/
```

Transfer from CARC to your local computer:

```bash
rsync -vhatP your-username@easley.alliance.unm.edu:your-folder/ ~/local-folder/
```

---

###### Option 2: MSYS2

MSYS2 provides a Unix-like command-line environment for Windows and allows `rsync` to be installed using its package manager.

##### Step 1: Install MSYS2

Download MSYS2 and install it using the default installation settings (`C:\msys64`). When installation finishes, the MSYS2 terminal will open automatically.

##### Step 2: Update MSYS2

Run:

```bash
pacman -Syu
```

If the terminal closes after the update, reopen **MSYS2 UCRT64** from the Start Menu and run the command again.

##### Step 3: Install rsync

Run:

```bash
pacman -S rsync
```

Type **Y** when prompted to install the required packages.

##### Step 4: Understanding Windows paths

MSYS2 uses Linux-style paths.

For example:

```
C:\Users\yourname\Documents
```

becomes

```
/c/Users/yourname/Documents
```

Use this format whenever specifying local files in an `rsync` command.

##### Step 5: Transfer files

Transfer from your local computer to CARC:

```bash
rsync -vhatP /c/Users/yourname/your-folder/ your-username@easley.alliance.unm.edu:target-directory/
```

Transfer from CARC to your local computer:

```bash
rsync -vhatP your-username@easley.alliance.unm.edu:your-folder/ /c/Users/yourname/local-folder/
```

---

##### Additional rsync tips

The following options are commonly used with `rsync`:

* `-v` displays the names of files as they are transferred.
* `-h` displays file sizes in a human-readable format.
* `-a` enables archive mode and preserves directory structure and file attributes.
* `-t` preserves file modification times.
* `-z` compresses data during transfer, which can improve performance.
* `-P` displays transfer progress and allows interrupted transfers to be resumed.

If a transfer is interrupted, simply run the same command again. `rsync` skips files that have already been transferred and resumes where it left off.

To exclude files from a transfer, use the `--exclude` option:

```bash
rsync -vhatP --exclude="*.tmp" ~/your-folder/ your-username@easley.alliance.unm.edu:target-directory/
```

When copying directories, note the difference a trailing slash makes:

```bash
# Copies the contents of my-folder into target-directory/
rsync -vhatP ~/my-folder/ user@server:target-directory/

# Copies my-folder itself into target-directory/
rsync -vhatP ~/my-folder user@server:target-directory/
```

Whether you are using MobaXterm or MSYS2, always use forward slashes (`/`) when specifying file paths in `rsync` commands.


As you can see, the syntax for these two programs is very similar; however, the options for advanced usage are unique to each one. The examples above cover only basic data transfers — refer to the links provided, or use `man programname` for the CLI options, to optimize each tool for maximum data transfer efficiency and speed.

*This quickbyte was validated on 6/28/2026*
