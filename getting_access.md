# Getting Access: Accounts and Projects

This covers the two things you need before you can log in anywhere: a personal account, and a project to work under. If you haven't read **Welcome to CARC** yet, start there first for context on what CARC is.

## Two systems, two different jobs

CARC access runs through two separate websites that each do one thing:

- **Mokey** (mokey.alliance.unm.edu) — your personal account. Username, password, SSH keys, two-factor authentication. See the **CARC Cluster Allocation and Accounting Services** quickbyte for a walkthrough of Mokey's account features (password resets, 2FA, SSH keys) if you need to manage those later.
- **ColdFront** (coldfront.alliance.unm.edu) — projects. A project is your research group's space on CARC: it's tied to a PI (usually your advisor or the faculty member running the lab), and it's where compute/storage resources actually get requested and assigned.

Having a Mokey account by itself doesn't give you access to anything — you also need to be added to a project in ColdFront. Both steps matter.

## If you're a student or new lab member joining an existing group

Most established labs already have a CARC project. In that case:

1. **Create your account** at mokey.alliance.unm.edu, if you don't already have one. This works directly if you have a UNM affiliation (student, staff, faculty).
2. **Ask your PI to add you to their project** through ColdFront. Adding people to a project is the PI's job, not something you can do yourself — so this step means literally asking them, or whoever manages the lab's CARC access.
3. Once you've been added, you're ready to log in — see **Logging in**.

If you're **not** UNM-affiliated (an external collaborator), you can't self-register through Mokey. Instead, ask your UNM PI to submit an account request on your behalf.

## If you're a PI and need to create a new project

1. **Check eligibility.** PI status at CARC follows the same criteria as being a UNM Grant PI, as determined by the Office of the Vice President for Research. If you're already a funded PI at UNM, you qualify.
2. **Log into ColdFront** (coldfront.alliance.unm.edu) and create a new project there.
3. **Request resources for the project.** Compute and storage aren't automatic — you request what your project needs through ColdFront, and CARC assigns it.
4. **Add your students and collaborators** to the project in ColdFront, once each of them has their own Mokey account.

If anything in the ColdFront interface itself is unclear once you're in there, that's a good office-hours or help-ticket question — the process above covers what needs to happen, not a click-by-click tour of the site.

## Quick summary

| You are... | What you need |
|---|---|
| A student/collaborator with a PI who already has a project | A Mokey account, then ask your PI to add you in ColdFront |
| A non-UNM collaborator | Your UNM PI submits an account request for you |
| A PI starting a new project | Confirm eligibility, then create the project and request resources in ColdFront |

## Where to go next

Once you have both a Mokey account and you've been added to a project:

- **Logging in** covers connecting to the cluster for the first time.
- **Slurm on CARC Easley** covers the basics of partitions and checking what's available.
- **Example Slurm Scripts** walks through submitting your first job, hello-world and up.

*This quickbyte was validated on 8/11/2026*
