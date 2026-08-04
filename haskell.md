## Haskell at CARC

Haskell is a strongly typed functional language. In this QuickByte you will learn how to use the GHCUP module to install ghc versions and run a simple stack program in haskell.

### Stack setup on Hopper

1) `module load ghcup`

2) `ghcup install ghc 9.10.1`

`ghcup` is the Glasglow haskell compiler upgrader. You can download as many ghc versions as you want, and they will be stored in your home directory under the `~/.ghcup/ghc/` directory.

> **Note:** this `ghcup install` step gives you a standalone GHC toolchain on your PATH-adjacent `~/.ghcup/bin` — it's useful if you want to run `ghc`/`ghci` directly. However, **`stack` does not use this GHC**. As shown below, `stack` manages its own, separate GHC install, chosen automatically based on the Stackage snapshot resolver picked when you ran `stack new`/`stack init` — not whatever version you installed with `ghcup`. Don't be surprised if the GHC version stack ends up using is different from the one you just installed; that's expected.

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

`stack build` will download and build its own GHC toolchain for the project the first time you run it (separate from anything you installed with `ghcup` — see the note above), then compile the `matrix` dependency and your executable. This can take several minutes the first time.

now that your program has been compiled, you can search for the location the executable file was created. Note the GHC version embedded in the path is whatever GHC **stack** resolved for the project's Stackage snapshot — as of this writing that's `ghc-9.10.3`, not the `9.10.1` installed via `ghcup` in step 2, and not the `9.6.5` an older run of this tutorial saw. Expect this version number to keep drifting over time as Stackage's default snapshot updates; what matters is that it's consistent between the `find` and `run` commands below, not that it matches any particular number:

	[hfricke@hopper matmul]$ find . -type f -name matmul-exe
	./.stack-work/install/x86_64-linux-tinfo6-libc6-pre232/<snapshot-hash>/9.10.3/bin/matmul-exe
	./.stack-work/dist/x86_64-linux-tinfo6-libc6-pre232/ghc-9.10.3/build/matmul-exe/matmul-exe

And now we can run our program (either of the two paths found above works — they're the same build):

	[hfricke@hopper matmul]$ ./.stack-work/dist/x86_64-linux-tinfo6-libc6-pre232/ghc-9.10.3/build/matmul-exe/matmul-exe
	┌                 ┐
	│ -18 -16 -14 -12 │
	│  14   8   2  -4 │
	│  46  32  18   4 │
	│  78  56  34  12 │
	└                 ┘

*This quickbyte was fully re-run end-to-end on Hopper on 8/3/2026, verbatim as documented above (`module load ghcup` → `ghcup install ghc 9.10.1` → `stack new matmul new-template` → editing `app/Main.hs` and `package.yaml` exactly as shown → `stack build`). The build succeeded and produced the exact matrix output shown above. The only change from the previous version of this doc is the GHC version shown in the example paths, corrected to match what was actually observed, along with the explanatory note about why it doesn't match the `ghcup install` version.*