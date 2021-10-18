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


5. Install the deep learning Packages (you can install one of these or as per your need)
	
	a.  **Tensorflow**: Install GPU version of the 	tensorflow for better performance

		 conda install -c anaconda tensorflow-gpu

	b.  **Keras**  GPU Version 

		 conda install -c anaconda keras-gpu  

	c.   **Pytorch** Non-GPU Version

		conda install pytorch torchvision -c pytorch
		 
	d.   **Pytorch** GPU Version

	First make sure that you have Python 3.7 installed in your current environment.
	
		conda create -n <env_name> python==3.7
	
	Next, activate your environment as per step 4 above. 
		
		source activate <env_name>
	
	Finally, install the following packages:

  		conda install /projects/shared/pytorch/PyTorch1.5-K40-Compatible/pytorch-1.5.0-py3.7_cuda10.1.243_cudnn7.6.3_0.tar.bz2
  		conda install cudatoolkit=10.1.243

	To verify that the K40s are available to your pytorch run the following python code:
	
		import torch
		from torch import nn, tensor
		from torch.cuda import device_count
		device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
		x=torch.rand(5,3)
		print(x)
		print("Is GPU Available?",torch.cuda.is_available()," CUDA device count:", torch.cuda.device_count(), "current_device:",torch.cuda.current_device())
		x = torch.tensor([1, 2, 3], device=device)
		y = torch.tensor([1,4,9]).to(device)
		print(x,y)
		print(x+y)

	Expected Output:

		tensor([[0.3220, 0.2174, 0.1226],
        		[0.7249, 0.8111, 0.8414],
        		[0.5974, 0.5169, 0.5242],
        		[0.1436, 0.5150, 0.5688],
        		[0.3298, 0.1289, 0.5349]])
		Is GPU Available? True  CUDA device count: 1  current_device: 0
		tensor([1, 2, 3], device='cuda:0') tensor([1, 4, 9], device='cuda:0')
		tensor([ 2, 6, 12], device='cuda:0')
		
6. Install additional Machine Learning packages
	
	i.  **OpenCV**

		 conda install -c conda-forge opencv 

	ii. **numpy,pandas, matpotlib , scikit-learn**

		 conda install numpy pandas matplotlib scikit-learn 
