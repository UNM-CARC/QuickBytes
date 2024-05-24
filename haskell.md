## Haskell at CARC

Haskell is a strongly typed functional language. In this QuickByte you will learn how to setup Haskell at CARC and create a simple matrix multiplication project using stack.


On Wheeler:

First we will install and load the stack environment:

1) `module load miniconda3`

2) `conda create -n haskell stack -c conda-forge`

3) `source activate haskell`

Or, alternatively, load the spack module:

`module load haskell-stack-stable-gcc-4.8.5-exczvin`

*Please note* that you should choose one method for using Haskell-Stack, Anaconda or the installed module, as you can run into
compatability issues switching between methods.

Now create a new stack project:

4) `stack new matmul new-template`

5) `cd matmul`

Edit the main source file with your preferred text editor:

6) `emacs app/Main.hs`

The following code creates and multiplies two 4x4 matrices:


--------------------------
``` haskell
module Main where

import Lib
import Data.Matrix

main :: IO ()

m1 = matrix 4 4 $ \(i,j) -> 2*i - j
m2 = matrix 4 4 $ \(i,j) -> 2*i - j

test = multStd m1 m2

main = do
     putStrLn (show test)
```
--------------------------


Add the dependency on the matrix package to the project:

7) `emacs package.yaml`

8) Add "- matrix" under dependencies in the executables section so it reads:

```	
	dependencies:		
		- matmul
		- matrix
```

Build your project:

9) `stack build`

Run your compiled program:

```
(haskell) mfricke@wheeler-sn:~/matmul$
.stack-work/install/x86_64-linux/lts-13.17/8.6.4/bin/matmul-exe
┌                 ┐
│ -18 -16 -14 -12 │
│  14   8   2  -4 │
│  46  32  18   4 │
│  78  56  34  12 │
└                 ┘
```
