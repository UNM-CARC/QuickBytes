# POTCAR file

VASP `POTCAR` files are distributed under the VASP license and are not included in this QuickByte.

Before submitting the example job, licensed VASP users should create:

```text
vasp_assets/POTCAR
```

for the NaCl example by concatenating the matching PAW/PBE potentials for:

```text
Na_pv
Cl
```

The Slurm script copies `INCAR`, `POSCAR`, `KPOINTS`, and `POTCAR` from `vasp_assets` into a per-job run directory. The repository `.gitignore` excludes `vasp_assets/POTCAR` so licensed pseudopotential content is not accidentally committed.
