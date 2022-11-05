# Gcc Bash Completion

This is a gcc bash completion function that uses the same `gcc --completion="str"` 
command as the original function for word completion.
so there is no difference in the results.
just added a few features.

For example, you can search for completion words using `*`, `?`, `[...]` glob characters
while writing command line.

```sh
bash$ gcc -save-temps -f*array*[tab]
-fcheck-array-temporaries
-fno-check-array-temporaries
-fchkp-flexible-struct-trailing-arrays
-fno-chkp-flexible-struct-trailing-arrays
-fchkp-narrow-to-innermost-array
-fcoarray=
-fmax-array-constructor=
-fprefetch-loop-arrays
-fno-prefetch-loop-arrays
-frepack-arrays
-fno-repack-arrays
-fstack-arrays
-fno-stack-arrays
[-f] ~~~~~~~~~~~~~~~~~~~~~~~~~

bash$ gcc -save-temps -Wl,-z,[tab]
bndplt                    lam-u57-report=           nostart-stop-gc
call-nop=                 lazy                      notext
cet-report=               loadfltr                  nounique
. . .
```

You can see the command usage with this video.

[![](https://mug896.github.io/img/gcc-bash-completion.png)](https://mug896.github.io/img/gcc-bash-completion.mp4)

If the search pattern returns empty results,
press tab twice to exit to the prompt and start over

```sh
. . .
-fno-nonnull-objects
--nonnull-objects
--no-nonnull-objects
[-] ~~~~~~~~~~~~~~~~~~~~~~~~~
*null*empty*
[-] ~~~~~~~~~~~~~~~~~~~~~~~~~
  [tab][tab]

bash$ gcc -save-temps -*zero*null*[tab] 
```

## Installation

Copy contents of gcc-bash-completion.sh to ~/.bash_completion  
open new terminal and try auto completion !


> please leave an issue above if you have any problems using this script.
