# Project Storage, Group Ownership, and BeeGFS Quotas

CARC Scratch project directories are located under paths like:

```text
/carc/scratch/projects/<pi_username><project_id>
```

These directories are on BeeGFS, where quotas are enforced by **group ownership**.

This can be confusing because a file can be physically located inside a project directory but still be charged against a user's personal quota if the file is owned by the wrong group.

The key point is:

> **Location does not determine quota usage. Group ownership does.**

---

## The common problem

A user copies files into a project directory and assumes the files now count against the project quota.

For example:

```text
/carc/scratch/projects/smith12345/data/
```

But if the files are owned by the user's personal group rather than the project group, BeeGFS may charge that storage to the user's personal group quota instead.

That can cause confusing quota errors such as:

> "I copied the data to the project directory, so why am I out of personal quota?"

The answer is usually:

> The files are in the right place, but they are owned by the wrong group.

---

## Users, groups, and file ownership

Every Linux file has:

1. A user owner
2. A group owner
3. Permissions

You can see these with:

```bash
ls -l
```

Example:

```text
-rw-r----- 1 jsmith smith12345 1048576 Jun 10 14:22 data.csv
```

This means:

```text
-rw-r-----   permissions
jsmith       user owner
smith12345   group owner
```

For BeeGFS project quota accounting, the important field is usually the **group owner**.

In this example, the file belongs to the `smith12345` group, so it should count against the `smith12345` project quota.

---

## Project group versus personal group

Suppose your project directory is:

```text
/carc/scratch/projects/smith12345
```

and the project group is:

```text
smith12345
```

A file like this is usually charged to the project quota:

```text
-rw-r----- 1 jsmith smith12345 1048576 Jun 10 14:22 data.csv
```

A file like this may be charged to the user's personal group quota:

```text
-rw-r----- 1 jsmith jsmith 1048576 Jun 10 14:22 data.csv
```

Both files can live in the same project directory. The difference is the group owner.

---

## Checking ownership

To check the ownership of files:

```bash
ls -l
```

To check the ownership of the current directory:

```bash
ls -ld .
```

To check the ownership of a project directory:

```bash
ls -ld /carc/scratch/projects/<pi_username><project_id>
```

Example:

```text
drwxrws--- 25 smith smith12345 4096 Jun 10 14:00 /carc/scratch/projects/smith12345
```

The group owner here is:

```text
smith12345
```

That is the project group users should normally expect files to use inside this project directory.

---

## Checking your groups

To see which groups your account belongs to:

```bash
id
```

or:

```bash
groups
```

Example:

```text
uid=12345(jsmith) gid=12345(jsmith) groups=12345(jsmith),67890(smith12345)
```

This user belongs to both:

```text
jsmith
smith12345
```

If you are not a member of the project group, you may not be able to create files with that group ownership.

---

## Permissions are not ownership

Linux permissions and Linux ownership are related, but they are not the same thing.

Permissions control who can read, write, or execute a file.

Ownership controls which user and group own the file.

Two files can have identical permissions but different group owners:

```text
-rw-r----- 1 jsmith jsmith     1048576 Jun 10 14:22 personal_file.dat
-rw-r----- 1 jsmith smith12345 1048576 Jun 10 14:22 project_file.dat
```

For BeeGFS quota purposes, the important difference is the group owner:

```text
jsmith
smith12345
```

Changing file permissions does not necessarily change quota accounting. If the group owner is wrong, the quota charge may be wrong.

---

## The setgid bit on project directories

Many shared project directories are configured with the setgid bit.

You can see this in the directory permissions:

```text
drwxrws---
```

The `s` in the group permission field means the directory has the setgid bit set.

This usually tells Linux:

> New files and directories created here should inherit the group ownership of the parent directory.

That helps project directories behave as shared spaces.

However, this is not foolproof.

Some copy tools, synchronization programs, editors, and applications may:

- preserve the source group
- explicitly set their own group
- create temporary files elsewhere and then move them into place
- use transfer behavior that bypasses the expected destination ownership

Because of this, users should always verify group ownership after large transfers.

---

## Fixing group ownership

If files are in the project directory but owned by the wrong group, the group can often be corrected with `chgrp`.

Example:

```bash
chgrp -R smith12345 mydata
```

This recursively changes the group owner of `mydata` to `smith12345`.

To fix files in the current directory:

```bash
chgrp -R smith12345 .
```

Then verify:

```bash
ls -l
```

Alternatively, you can change both the user and group owner at once with `chown`:

```bash
chown -R jsmith:smith12345 mydata
```

For most users, `chgrp` is usually the safer command to document because it changes only the group owner.

---

## Recommended transfer method: rsync

For Linux-to-Linux transfers, `rsync` is usually preferred.

Basic example:

```bash
rsync -av source/ /carc/scratch/projects/smith12345/data/
```

If the user has permission to set the group ownership, `rsync` can explicitly assign ownership during transfer:

```bash
rsync -av --chown=$USER:smith12345 source/ /carc/scratch/projects/smith12345/data/
```

Replace `smith12345` with the actual project group.

After transfer, verify:

```bash
ls -l /carc/scratch/projects/smith12345/data/
```

For large transfers, this is often safer than copying files and fixing ownership afterward.

---

## Warning about scp

`scp` is convenient, but it is not ideal for this quota problem.

In particular:

```text
scp does not have an --chown option
```

Files copied with `scp` may not end up with the expected project group ownership.

If you use `scp`, check the files afterward:

```bash
ls -l
```

If the group owner is wrong, fix it:

```bash
chgrp -R smith12345 .
```

For large project transfers, prefer `rsync` when possible.

---

## Copying files from Windows

Windows file systems do not use Linux user and group ownership in the same way.

When files are uploaded from Windows using tools such as:

- WinSCP
- FileZilla
- MobaXterm
- VS Code Remote SSH
- Globus, depending on endpoint configuration
- WSL with `rsync`

the resulting ownership is assigned on the Linux side.

That means Windows users should always verify ownership after upload:

```bash
ls -l
```

If files landed with the wrong group:

```bash
chgrp -R smith12345 mydata
```

For large or repeated transfers from Windows, the most reliable options are usually:

1. Use WSL and `rsync`
2. Use a transfer tool that allows post-transfer commands
3. Upload the files, then run `chgrp -R <project_group>` on the cluster

Example using WSL with `rsync`:

```bash
rsync -av --chown=$USER:smith12345 /mnt/c/Users/jsmith/data/ username@cluster:/carc/scratch/projects/smith12345/data/
```

If `--chown` is not permitted, transfer the files and then run `chgrp` on the cluster.

---

## Recommended user workflow

After copying data into project storage:

1. Go to the project directory.

```bash
cd /carc/scratch/projects/<pi_username><project_id>
```

2. Check ownership.

```bash
ls -l
```

3. Confirm that the group owner is the project group.

Good:

```text
-rw-r----- 1 jsmith smith12345 1048576 Jun 10 14:22 data.csv
```

Possibly wrong:

```text
-rw-r----- 1 jsmith jsmith 1048576 Jun 10 14:22 data.csv
```

4. Fix group ownership if needed.

```bash
chgrp -R smith12345 .
```

5. Check again.

```bash
ls -l
```

---

## Summary

Remember:

- BeeGFS project quotas are based on group ownership.
- A file can be inside a project directory but still count against the wrong quota.
- Use `ls -l` to check file ownership.
- Use `ls -ld` to check directory ownership.
- The important field is the group owner.
- Permissions and ownership are not the same thing.
- The setgid bit helps new files inherit the project group, but some tools can still produce unexpected ownership.
- `rsync --chown=$USER:<project_group>` is often the safest transfer method.
- `scp` does not provide a reliable way to set destination group ownership.
- Windows transfer tools may require a follow-up `chgrp`.
- When in doubt, check with `ls -l` before starting a large job.
- When using `chgrp`, make sure to copy your data in chunks where each chunk is smaller than your remaining personal scratch quota.
- You can always check your quotas with the `quotas` command.

*This quickbyte was validated on 7/30/2026*
