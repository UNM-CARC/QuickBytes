## Haskell at CARC

Haskell is a strongly typed functional language. In this QuickByte you will learn how to use the GHCUP module to install ghc versions and run a simple stack program in haskell.

### Stack setup on Hopper

1) `module load ghcup`

2) `ghcup install ghc 9.10.1`

`ghcup` is the Glasglow haskell compiler upgrader. You can download as many ghc versions as you want, and they will be stored in your home directory under the `~/.ghcup/ghc/` directory.

Now create a new stack project:

4) `stack new matmul new-template`

5) `cd matmul`

Edit the main source file with your preferred text editor:

6) `vim app/Main.hs`

The following code creates and multiplies two 4x4 matrices:

	module Main where

	import Lib
	import Data.Matrix

	main :: IO ()

	m1 = matrix 4 4 $ \(i,j) -> 2*i - j
	m2 = matrix 4 4 $ \(i,j) -> 2*i - j

	test = multStd m1 m2

	main = do
		putStrLn (show test)

Add the dependency on the matrix package to the project:

7) `vim package.yaml`

8) Add `- matrix` under dependencies in the executables section so it reads:


		dependencies:		
			- matmul
			- matrix


Build your project:

9) `stack build`

now that your program has been compiled, you can search for the location the executable file was created;

	[rdscher@hopper matmul]$ find . -type f -name matmul-exe
	./.stack-work/dist/x86_64-linux/ghc-9.6.5/build/matmul-exe/matmul-exe

And now we can run our program;

	[rdscher@hopper matmul]$ ./.stack-work/dist/x86_64-linux/ghc-9.6.5/build/matmul-exe/matmul-exe
	┌                 ┐
	│ -18 -16 -14 -12 │
	│  14   8   2  -4 │
	│  46  32  18   4 │
	│  78  56  34  12 │
	└                 ┘

*This quickbyte was validated on 6/10/2024*