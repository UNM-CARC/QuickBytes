# Installing Perl Libraries to your home directory

Perl libraries can be installed to your home directory.

First, load a perl module.
Use `module spider perl` to view available perl modules on the cluster you are using.
In this example we will use a perl module available on the Hopper cluster.
```bash
$> module load module load intel/20.0.4
$> module load perl/5.32.0-sw3s
``` 

Next, start an interactive cpan shell:
```bash
$> perl -MCPAN -e shell
```

Direct cpan to your home directory:
```bash
cpan[1]> o conf makepl_arg INSTALL_BASE=~/perl5
```

Commit the changes to cpan:
```bash
cpan[1]> o conf commit
```

Exit cpan:

```bash
cpan[1]> exit
```

Now, you need to modify your environment variables.
This can be done in the terminal using the following four commands, but would need to be done once per login session before installing perl libraries.
Alternatively, you can add these commands to your `.bashrc` file to have them happen automatically upon logging in.
```bash
$> export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"
$> export PERL5LIB="$HOME/perl5/lib/perl5:$PERL5LIB"
$> export PATH="$HOME/perl5/bin:$PATH"
$> eval $(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)
```

You can now use the cpan commands to install perl modules/libraries:
```bash
$> cpan <library>
```

Some examples are:
```bash
$> cpan YAML
$> cpan Math::Utils
$> cpan Thread::Queue
```





