## Haskell at CARC

Haskell is a strongly typed functional language. In this QuickByte, you will learn how to use the GHCup module to install GHC versions and run a simple Stack program in Haskell.

## Stack setup on Hopper

Once logged in, load the GHCup module

`module load ghcup`

After loading the module, install the recommended version of GHC with:

`ghcup install ghc`

If you need a specific version of GHC, install the version with:

`ghcup install ghc <version number>`

`ghcup` is the Glasgow Haskell Compiler upgrader. You can download as many GHC versions as you want, and they will be stored in your home directory under the `~/.ghcup/ghc/` directory. Each version of GHC only needs to be installed once and doesn't require constant installations every user session.

## Running a simple Stack program in Haskell

First, create a new Stack project

`stack new matmul new-template`

Once the project is created, change into the "matmul" directory with:

`cd matmul`

Then, edit the main source file with your preferred text editor:

`vim app/Main.hs`

The following code creates and multiplies two 4x4 matrices:

	module Main (main) where

	import Data.Matrix

	main :: IO ()

	m1, m2 :: Matrix Int
	test :: Matrix Int

	m1 = matrix 4 4 $ \(i,j) -> 2*i - j
	m2 = matrix 4 4 $ \(i,j) -> 2*i - j

	test = multStd m1 m2

	main = do
        putStrLn (show test)

Using your preferred text editor, add the dependency on the matrix package to the project

`vim package.yaml`

Add `- matrix` under dependencies in the executables section so that you have the following portion in your `package.yaml` file:

```
executables:
  matmul-exe:
    main:                Main.hs
    source-dirs:         app
    ghc-options:
    - -threaded
    - -rtsopts
    - -with-rtsopts=-N
    dependencies:
    - matmul
    - matrix
```

Build the project with:

`stack build`

For future reference, the name of the executable depends on the section under `executables:` in `package.yaml` (In this case, it's `matmul-exe:`). Now that your program has been compiled, you can run it with:

`stack exec matmul-exe`

You shoud get an output similar to:

	┌                 ┐
	│ -18 -16 -14 -12 │
	│  14   8   2  -4 │
	│  46  32  18   4 │
	│  78  56  34  12 │
	└                 ┘
