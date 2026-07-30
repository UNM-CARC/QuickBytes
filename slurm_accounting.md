# Introduction to Slurm Accounting at CARC

## What Is Slurm Accounting?

Slurm accounting allows CARC to track resource usage and use that information to make scheduling decisions.

When a job runs, the resources consumed by that job (such as CPUs and memory) are tracked and associated with a Slurm account. At CARC, accounts correspond to CARC projects.

When a cluster is under heavy utilization, projects with lower historical resource usage may receive higher scheduling priority than projects with higher historical resource usage.

---

## Accounting Commands

You can view the accounts you belong to using the `myaccounts` command.

Example:

```bash
[yourUsername@easley ~]$ myaccounts
```
```
   Account      Description            PI 
---------- -------------------- ---------- 
yourIdNumber       yourIdNumber   yourIdNumber
```

The account name corresponds to the project ID.

To view additional information about an account, use:

```bash
sacctmgr show account <account_name>
```

Example:

```bash
[yourUsername@easley ~]$ sacctmgr show account yourIdNumber
```
```bash
Account          Descr                  Org
yourIdNumber     hpc@unm sys admin      download
```

The **Org** column displays the username of the PI associated with the project.

---

## Choosing an Account for a Job

There are three ways a job can be associated with an account. Slurm checks them in the following order:

1. `--account=<account_name>` specified during job submission
2. `~/.default_slurm_account`
3. Your default account (typically the most recently assigned project)

Once a valid account is found, Slurm stops checking subsequent options.

---

### 1. `--account`

The `--account` option can be specified either:

* Directly in an `srun` command, or
* In an `sbatch` submission script using the `#SBATCH` directive

Examples:

```bash
srun --account=yourIdNumber my_program
```

or

```bash
#SBATCH --account=yourIdNumber
```

This option takes precedence over all other methods of account selection.

---

### 2. `~/.default_slurm_account`

If a file named `.default_slurm_account` exists in your home directory and contains a valid account name, Slurm will use that account whenever `--account` is not specified.

Example:

```bash
echo "yourIdNumber" > ~/.default_slurm_account
```

You can view the current default account with:

```bash
cat ~/.default_slurm_account
```

---

### 3. Default Account

If you do not specify `--account` and there is no valid `~/.default_slurm_account`, Slurm will charge usage to your configured default account.

You can view your current default account with:

```bash
sacctmgr show user <username>
```

Example:

```bash
[yourUsername@easley ~]$ sacctmgr show user yourUsername
```
```bash
User            Def Acct       Admin
yourUsername    yourIdNumber   None
```

You can then inspect that account with:

```bash
sacctmgr show account yourIdNumber
```

---

*This QuickByte was validated on July 30, 2026.*
