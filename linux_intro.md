# Linux Tutorial

The goal of this tutorial is to familiarize you with the minimal set of commands needed to effectively negotiate the Unix operating system and file management system in an X11 windowing environment such as cygwin. At the end of this tutorial you will find a list of more advanced tools that you may wish to explore as you become familiar with Unix and its various flavors. These include the text editors vi and emacs, plotting packages (xmgr, gnuplot, xgrace), and image/file display packages (ghostscript, for postscript; acroread, for PDF files; and xv, for displaying .gif, .jpeg, and other image formats.)

In this tutorial, we use the generic term Unix to refer to any operating system (OS) based on the original Unix OS developed in the 1970s (1969 is typically cited as the year that Unix was “born.”) Although numerous flavors and variants of the OS have appeared in the intervening years, they are all based on the same underlying design, and preserve a core set of commands in common. What this means is that if you are familiar with any contemporary Unix-like system, you will be able to immediately work on any other Unix-like system, and it will be very easy for you to come up to speed on the idiosyncrasies of the new environment. Examples of Unix-based systems that you may have heard of include Linux, SGI IRIX, Mac OS X, Sun Solaris, and SunOS.

This tutorial provides step-by-step instructions for exploring the Unix-like operating systems running on UNM IT and CARC machines, such as linux.unm.edu and nano.alliance.unm.edu.

Commands that you should enter at the prompt (also file, directory, and application names) will appear in boldface. You may wish to take a look at the IT documentation for Linux and X Windows available at http://it.unm.edu/quickrefs/unix.html. Numerous "cheat sheets" for Linux and for editors such as vi (see below) can also be found online.

NOTE: The program that interprets your commands on a Unix-based computer is called the shell. Shells come in different varieties, such as csh (C shell), tsch (Tenex C shell), ksh (Korn shell), and bash (Bourne-Again Shell). Many of the basic commands are the same across shells, but there are also some important differences.

1.  Begin by ssh-ing into wheeler.alliance.unm.edu from an XTerm. Type in your username, followed by your nano password. (Note: you can also ssh into IT Linux machines by connecting to linux.unm.edu and using your UNM IT password (different from your CARC wheeler password).

2.  Note that when you login to a Unix machine, there is always a prompt. The default prompt is %, but sometimes it will appear as the machine name, followed by a number which tells you how many commands you have entered up to that point in the session, e.g. nano-3, neptune-16>, or vega-3. All commands in Unix are issued sequentially, each at a new prompt (there are ways to combine commands, but we won’t worry about this for now).

3.  If your password is new, you should change it immediately to one that is known only to you. If you have not done so already, type yppasswd at the Unix prompt, and follow the instructions. You can change your password as often as you like in this fashion.

4.  Verify your username by typing whoami. This command is useful in computer labs if you come across an unoccupied terminal that appears to be in use, and would like to know who is logged in. Also, it gives you an idea of the current user load on the machine.

5.  See who else is using the machine you are on by typing who.

6.  Reality check: type date.

7.  Check that you are in your home directory by typing pwd (print working directory).

8.  Create a new directory called Lab1 by using the mkdir command: mkdir Lab1.

9.  Type cd Lab1 (change directory) to move to this directory.

10.  Create two subdirectories, take1 and take2, and change directories to take1.  (NOTE: Any files or directories that you create remain on the Linux filesystem until you specifically choose to delete them. For example, if you login to linux.unm.edu from a second XTerm while still connected via the first, you will be able to see (and manipulate) all of your directories and files stored on the filesystem.)

11.  Brief text editor review. Two editors that are commonly used in the Unix environment are vi and emacs. emacs is more sophisticated, but requires more effort to master. If you want to try it out, type emacs at the Unix prompt, and follow the instructions to work through the tutorial. For right now, we will use vi. (Note: there are a number of useful online quick-references for vi. See, for example: http://it.unm.edu/quickrefs/vi.html).
To invoke the editor, type vi <filename>. (The notation “<filename>” just means “any filename you like.” For example, you might type vi genomes.txt). Note that in Unix, long filenames are deprecated; it is customary to use the suffix .txt to denote plain text files, and file- names may not include spaces. In lieu of spaces, it is common to use the underscore character “_”, or strategically placed capitals, thus: MyLongFilename.txt. Once you are in the editor, you can use the following commands:
i to insert text at cursor location. type i and then type your text; hit <Esc> (the “Esc” key on your keyboard) to stop entering text
a to add text at location of cursor (<Esc> to end text entry)
o to open a new line and begin inserting text (<Esc> to end text entry).  If you are not sure what state vi is in, it’s always safe to type <Esc> to reset.
j to move down a line 
k to move up a line 
D to delete from cursor location to end of line
dd to delete entire line
: to get into editor mode. From here you can type w (followed by the Enter key) to write your file (this will overwrite whatever file you said you were editing when you invoked vi),
q to quit vi; and q! to exit without writing over your file. Another very useful editor-mode command is to type u at the colon; this undoes your last command in case you made a mess of your editing.
Type <number>G in text-entry mode to go to line number <number>. $ refers to the last line in your file, so $G will take you to the last line in your file.
Also in text entry mode, type <Ctrl>-G (this is the Ctrl key on your keyboard, held down at the same time as the G key) to find out what line you are at.
12.  Now that you are expert at editing, create a new file called junk.txt containing the single line hello world. You may use vi or the Unix editor of your choice in order to do this.

13.  Copy junk.txt to junk2.txt using the cp command: cp junk.txt junk2.txt.

14.  Edit junk2.txt and add the line: Now is the time for all good men to come to the aid of their PARTY. (Yes, PARTY should be capitalized).

15.  Save the file and exit to the Unix prompt by typing :wq.

16.  Check which file contains the word party by doing a case-insensitive grep; type grep -i party *.txt. The asterisk is a wild-card character that matches both junk and junk2.

17.  Do a pwd; then get a listing of the files in the current directory by typing “ls .” --  ‘.’ is a shorthand for “the current directory.”

18.  See how much space is left on the disk where your directory resides by typing “df .”.

19.  Type man ls to access the Unix on-line manual page for the ls command. Find the option that will produce a long listing, and re-type the ls command using this option.

20.  One of the most important features of Unix is the ability to re-direct output. You can re-direct the output of your ls command to a file named list.txt by typing >list.txt on the same line as the ls command, and immediately afterwards. Try this now.

21.  Make sure that your re-direction worked by typing cat list.txt to look at the contents of list.txt.

22.  Another useful tool is the diff command, which allows you to compare the contents of two files, line by line. Do a diff junk.txt junk2.txt.

23.  The >> symbol allows you to append output to the end of a file. Repeat the diff command, followed by >>list.txt to append the output of diff to the list.txt file. Use cat list.txt to verify that the results are what you expected.

24.  Move junk2.txt one directory up by typing mv junk2.txt ..  ‘..’ is shorthand for “one directory up from where I am now.”

25.  Jump to your home directory by typing cd without any arguments.

26.  Go back to directory take1 by typing cd Lab1/take1.

27.  Now go back to your home directory by typing cd ../..

28.  Use the man page for ls again to find out how to display hidden (‘dot’) files, and do a long listing, including dotfiles, in your home directory.

29.  Change to directory Lab1, and remove directory take2 by typing by rmdir take2.

30.  Now try to remove directory take1 in the same way.

31.  The reason take1 could not be removed is that it still has a file in it. Change directories to take1 and do a rm junk.txt. Notice the different command for removing a file vs. removing a directory.

32.  Go back up one directory and remove directory take1.

33.  Change to your home directory and remove directory Lab1.

34.  Just for fun, type xeyes &. This will invoke an amusing, albeit useless, X Windows application. The & means that Unix has put the program running xeyes into background, so that it doesn’t tie up your Unix prompt while it continues to run the program. To end the xeyes program, jobs at the Unix prompt to see what Unix jobs you are currently executing. Let’s say that the number next to xeyes is [1]. To kill the program, type kill %1. Another (more useful) X program is xcalc. Try typing this at the prompt (don’t forget to put it in background using the & again) and using the calculator that comes up. There are a large number of Unix X-windows programs that you can explore at your leisure; look in the directory /usr/bin/X11 and try playing around with some of them.

35.  To logout, type exit at the prompt. You can kill any jobs executing before you logout, or they will get killed automatically when you logout. Note that Unix is a much more robust OS than Windows. There is virtually no way that you, as an ordinary user, can crash the operating system while others are using it. This is one of the many reasons why you will want to learn to use (and master) the Unix operating system environment, and why it is used on supercomputers and clusters at centers around the world.

Congratulations! You’ve survived the Unix tutorial. Here is a list of some particularly useful X windows tools included on many (not necessarily all, however) Unix installations. These are listed according to the Unix command used to invoke them. At your leisure, please take the time to explore some of them, and see that the appropriate GUI (Graphical User Interface) comes up correctly when they are invoked. Many of these applications are self-explanatory; simply start them up and try them out.

xmgr: plotting program
gnuplot: plotting program
xwd: X window dump (man xwd).
xv: Useful visualizer that can handle a wide range of graphics formats, and convert between them (.rgb, .xwd, .tiff, etc.).
xgrace: more advanced (sophisticated) plotting program
ghostview: postscript previewer.
acroread: Acrobat (PDF) previewer.
LaTeX: Scientific text formatting language, including previewing package. Far superior to Word for heavily mathematical documents. A LaTeX tutorial/reference book such as the one by Leslie Lamport is useful for getting started.
vi: Standard Unix line-editor. An introduction to vi was included as part of this Lab; see online reference there.
emacs, xemacs: A highly flexible editing environment, with special editing modes for particular file types (.F Fortran source code, .tex LaTeX files, etc.), facilities for multiple buffers, and much, much more. See Learning GNU Emacs (O’Reilly and Associates) or the emacs online help for a detailed tutorial. 
