# X11 Forwarding

X11 Forwarding allows any graphical user interface to open on your local machine while the software itself is being run on a CARC cluster compute node. This QuickByte will show you how to set up and use X11 forwarding.

## On a Mac

macOS does not include an X11 server, so you will need to install [XQuartz](https://www.xquartz.org) before using X11 forwarding. You can install it in one of two ways:

**Option 1 — Download the installer** from [xquartz.org](https://www.xquartz.org) and run the `.dmg` package.

**Option 2 — Install via Homebrew** (if you have Homebrew installed):

```bash
brew install --cask xquartz
```

After installing, log out and back in before using X11 forwarding.

> **Note:** If you are on the latest version of macOS, check the [XQuartz releases page](https://github.com/XQuartz/XQuartz/releases) to confirm your macOS version is supported before installing.

## On a PC (Windows)

Download and install [MobaXterm](https://mobaxterm.mobatek.net). It combines an SSH client, X server, and file transfer client into one application and handles X11 forwarding automatically — no additional configuration required. The free Home Edition is sufficient for CARC use.

## Step by Step Example of X11 Forwarding with MATLAB

### 1. Log in to Easley with X11 forwarding enabled

For Mac, launch XQuartz, then open a terminal from the 'applications' menu. Use the `-Y` flag when connecting via SSH to enable trusted X11 forwarding:

```bash
ssh -Y username@easley.alliance.unm.edu
```

> **Note:** `-Y` (trusted forwarding) is recommended over `-X` (untrusted forwarding) as it works more reliably across different system configurations, but if one doesn't work, try the other. Also note that X11 forwarding requires a native terminal with XQuartz (Mac) or MobaXterm (Windows) — it will not work from the OOD web terminal at ood.alliance.unm.edu.

If you get the error `"/usr/bin/xauth: file /users/user/.Xauthority does not exist"`, run:

```bash
touch ~/.Xauthority
```

Then log out and back in before continuing.

### 2. Start an interactive session with X11 forwarding

```bash
srun --x11 --pty bash
```

> **Note:** `srun --x11` requires `DISPLAY` to already be set in your shell (i.e. you must have connected with `ssh -Y`/`-X` first, as in step 1) — if you run it from a plain SSH session without X11 forwarding, you'll get `srun: error: No DISPLAY variable set, cannot setup x11 forwarding.` That error means your local terminal isn't forwarding X11, not that anything is wrong with Slurm.

### 3. Load and launch MATLAB

Once you have been assigned a node, load the MATLAB module and start MATLAB. The GUI should automatically open on your local machine.

```bash
module load matlab
matlab
```

### 4. Use the MATLAB GUI

Use the MATLAB GUI to load your add-on or run your application as you normally would.

### 5. Exit when finished

When you are finished, close the GUI by clicking the X. Then, exit the interactive session to release the node for other users:

```bash
exit
```

## Video Tutorial

A CARC QuickByte video on X11 forwarding is available here:
https://www.youtube.com/watch?v=-5ic9JWHuqI&list=PLvr5gRBLi7VAzEB_t5aXOLHLfdIu2s1hZ&index=12

If you have any trouble at any point, please reach out to us at help@carc.unm.edu

*This quickbyte was validated on 8/3/2026: `ssh -Y` to Easley correctly forwards a `DISPLAY` (confirmed via a real XQuartz session), `srun --x11 --pty bash` is accepted by Slurm and forwards a fresh `DISPLAY` to the compute node, `module load matlab` succeeds there, and MATLAB launches cleanly (prints its banner and runs a test command) with no early fatal errors. Whether the MATLAB window actually renders on your local screen could not be confirmed by this validation pass, since it was run from an environment with no way to view a display — that step still depends on your own local X server (XQuartz/MobaXterm) working correctly.*
