## Setting Up PyTorch using Xena
### SSH in to Xena
To connect to the Xena machine, you will need to use the secure shell command below with your username in place of $USERNAME. This will prompt you for your password. When typing your password, you will not get any visual feedback. If you have issues with connecting to the machine, please reach out to the CARC helpdesk. 
```
ssh $USERNAME@xena.alliance.unm.edu
```

### Create the Condarc File
To create the Condarc file that you will need, run the code below:
```
nano .condarc
```
This creates a blank file using the nano text editor. 

In the condarc file you just created, paste the following then change the $USERNAME prompt to your username.
```
auto_activate_base: false
channels:
  - conda-forge
  - bioconda
  - defaults
envs_dirs:
  - /users/$USERNAME/.conda/envs
pkgs_dirs:
  - /users/$USERNAME/.conda/pkgs
```
Notice that at the bottom of the screen below, nano lists options for how users can interact with the open file. 

<img width="719" alt="Screenshot 2023-08-29 at 11 01 54 PM" src="https://github.com/UNM-CARC/QuickBytes/assets/130007104/c647a39d-c6d8-437f-917d-f9e1cee8d7e5">

To save the lines of code you just pasted into the file, hold down the control key and press 'O'. This "writes out" or saves the text. You can then exit the text editor by holding down the command key and pressing 'X'. To confirm that the file has been edited and contains the correct code, run the command. 

```
cat .condarc 
```

The following text should appear on your command line rather than opening the file in nano.
```
auto_activate_base: false
channels:
  - conda-forge
  - bioconda
  - defaults
envs_dirs:
  - /users/{YOUR USERNAME HERE}/.conda/envs
pkgs_dirs:
  - /users/{YOUR USERNAME HERE}/.conda/pkgs
```
If you do not see this text appear, walk through the creation of the condarc file again.

## Navigate to the PyTorch1.9-K40-Compatible directory

Run the following code to change directories into the PyTorch1.9-K40-Compatible directory. 
```
cd /projects/shared/pytorch/PyTorch1.9-K40-Compatible

```
This will change your command prompt to reflect the updated directory. If the command prompt does not reflect that you are in the PyTorch1.9-K40-Compatible directory, you will run into issues in later steps. 

```
Updated command prompt:
[(username)@(hostname) PyTorch1.9-K40-Compatible]$
```

### Create the Conda Environment
Now that you are in the correct directory, you'll create your python environment. To create a python environment, you first need to load the miniconda3 module with the following command: (No output should print from this command)
```
module load miniconda3
```
You can then create the python environment by running the following command: 
```
conda env create -f torch-1.9.0+cu11.1-K40.yml
```
WHAT DOES THIS DO - run on CS machine

## Activate the Conda Environment

Once the environment is created, you will need to activate it before you start the pytorch installation. Activate the environment by running the following: 
```
conda activate pytorch-1.9-cuda-11-K40
```
This command will add a prefix to your command prompt that indicates which environment you are in. Your command line prompt should take the form of: 
```
(pytorch-1.9-cuda-11-K40)[(username)@(hostname) PyTorch1.9-K40-Compatible]$
```
## Pip installation 
To install pytorch, run the following command:
```
pip3 install --user torch-1.9.0+cu11.1-cp39-cp39-linux_x86_64.whl
```
After the installation is complete, we can confirm that the torch install was sucessful in JupyterHub. 


