## Installing Deep Learning Library in Xena ##

This step by step tutorial will guide you through installing deep learning and Machine learning tools in the Xena Server.

### Setting up the conda environment for installation ###

1. Firstly load the Anaconda module to use the conda command.

	 	module load anaconda3

2. Create the Conda Environment with a name.
 
	 	conda create --name <env_name> python==3.6

3. Verify the installation of the environment.

		conda info --envs	


4. Load the environment.

	 	source activate <env_name> 


5. Install the deep learning Packages (You can install one 	of these or as per your need.)
	
	a.  **Tensorflow**: Install GPU version of the 	tensorflow 	for better performance

		 conda install -c anaconda tensorflow-gpu

	b.  **Keras**  GPU Version 

		 conda install -c anaconda keras-gpu  

	c.   **Pytorch**

		 conda install pytorch torchvision -c pytorch

6. Install additional Machine Learning packages
	
	i.  **OpenCV**

		 conda install -c conda-forge opencv 

	ii. **numpy,pandas, matpotlib , scikit-learn**

		 conda install numpy pandas matplotlib scikit-learn 
