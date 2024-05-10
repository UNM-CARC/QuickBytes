# Introduction to Slurm Accounting at CARC

## What is Slurm accounting?

Slurm accounting allows us to track resource usage at CARC and use that information to make scheduling decisions. When a job is run, the resources (CPUs/RAM) used by that job are tracked and associated with an account. When a cluster is under heavy utilization, accounts with less historical resource usage will have their priority increased over accounts with higher historical resource usage.

## Accounting Commands
At CARC, accounts correspond to CARC projects. The account name is the project ID. `myaccounts` will show you all of the accounts you are a member of. Example:

```
[tredfear@xena]:~ $ myaccounts
      User    Account
---------- ----------
  tredfear    systems
  tredfear    1000001
```

To view more information about an account, you can use the command `sacctmgr show account <account_name>`. Example:

```
[tredfear@xena]:~ $ sacctmgr show account 1000001
   Account                Descr                  Org
---------- -------------------- --------------------
   1000001   hpc@unm sys admin              download
```
The Org column displays the username of the PI associated with the project.

## Choosing an account to associate with a job
There are 3 ways that a job can be associated with an account and they are checked in the following order:
1. --account=<account_name> specified in job submission script
2. ~/.default_slurm_account
3. Most recent account you are a part of

If any of these are specified, the scheduler will not proceed further down the list.

### --account
`--account` can be specified in either an `srun` command or in a `sbatch` submission script using the `#SBATCH` directive. This option takes precedence over every other method of account specification.

### ~/.default_slurm_account
If there exists a home file in your home directory called `.default_slurm_account` containing a valid account name, that account will be used any time you do not specifically use `--account`.

### Most recent project
If you do not specify `--account` in your submission script and there is no `~/.default_slurm_account` (or the account specified therein is not valid), your resource usage will be attributed to the newest project you are a part of. You can find out which project this is with the command `sacctmgr show user <username>`. Example:

```
[tredfear@xena]:~ $ sacctmgr show user tredfear
      User   Def Acct     Admin
---------- ---------- ---------
  tredfear    1000001      None
```
You can then use `sacctmgr show account` as specified above to find more information about this account.

More resources:  
http://www.physik.uni-leipzig.de/wiki/files/slurm_summary.pdf  
https://slurm.schedmd.com/fair_tree.html  
https://slurm.schedmd.com/sacctmgr.html  
https://slurm.schedmd.com/sacct.html
