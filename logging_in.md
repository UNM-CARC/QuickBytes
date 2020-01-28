#Logging in

In order to use log in to CARC systems and start computing you will need a terminal that can log in to remote systems using Secure Shell (SSH). If you are using a Linux or Mac machine you are in luck as they come bundled with a terminal that is ready to use. The terminal application packaged with your OS is great, but if you would like something with a bit more customization, utility, and flexibility there are other free options available. Below are a couple of options that CARC recommends. Note that iTerm2 is Mac only.


* iTerm2
* Hyper


If you are using Windows it is a little more complicated as there is no native SSH built in to the Windows platform that will communicate with the Linux CARC systems and you will have to download a terminal emulator. Below are some of our recommendations. Note that Git for windows does not come with a terminal emulator and that still needs to be downloaded separately. 


* Cmder
* Babun
* Git for windows (with bash) + Hyper (terminal emulator)


Now that you have your terminal open you can log in. To do this type the following from the terminal prompt:

```bash
ssh yourusername@machinename.alliance.unm.edu
```

Where yourusername is the username that CARC provided in your account letter, and machinename is the name of the system you are logging in to; Xena, Wheeler, Gibbs for example. If this is your first-time logging in you will likely be prompted to accept your computer as a new authorized host, go ahead and accept that. You will then be prompted to type your password. Use the password provided in your account letter.
