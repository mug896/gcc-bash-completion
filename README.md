# Gcc Bash Completion

This is a gcc bash completion function that uses the same `gcc --completion="str"` 
command as the original function for generating completion words.
so there is no difference in the results.
just added a few features.

```sh
# This script requires the external command 'fsf' to use.
# Therefore, first install the 'fsf' command as follows.

bash$ sudo apt install fsf
```

For example, you can try to search for completion words using the glob characters 
`*`, `?`, `[...]` while writing the command line like this:

```sh

bash$ gcc -save-temps -*alias*[tab]

bash$ gcc -save-temps -*[tab]

----------------------------------------------------------

bash$ gcc -save-temps -Wl,-z,[tab]
bndplt                    lam-u57-report=           nostart-stop-gc
call-nop=                 lazy                      notext
cet-report=               loadfltr                  nounique
. . .

----------------------------------------------------------

bash$ gcc -Q -O2 --help=[tab]
common        optimizers    separate      undocumented  
joined        params        target        warnings
```


## Installation

Copy contents of gcc-bash-completion.sh to ~/.bash_completion  
open new terminal and try auto completion !


> please leave an issue above if you have any problems using this script.
