# Gcc Bash Completion

This is a gcc bash completion function that uses the same `gcc --completion="str"` 
command as the original function for word completion.
so there is no difference in the results.
just added a few features.

For example, you can search for completion words using `*`, `?`, `[...]` glob characters
while writing command line.

```sh
bash$ gcc -save-temps -*alias*[tab]
. . .
-Wattribute-alias=
--warn-attribute-alias=
-Wstrict-aliasing
-Wno-strict-aliasing
--warn-strict-aliasing
--warn-no-strict-aliasing
-Wstrict-aliasing=
--warn-strict-aliasing=
. . .                       # "q"
[tab][tab]                  # [tab][tab] to exit to the prompt.

---------------------------------------------------------

bash$ gcc -save-temps -*alias*[tab]
. . .
-fno-strict-aliasing
--strict-aliasing
. . .                          # "q"
[backspace]fno-stric[tab]      # one backspace key is needed.
or
[backspace]-strict-ali[tab]    # one "-" char in front is hidden.

----------------------------------------------------------

bash$ gcc -save-temps -Wl,-z,[tab]
bndplt                    lam-u57-report=           nostart-stop-gc
call-nop=                 lazy                      notext
cet-report=               loadfltr                  nounique
. . .
```


## Installation

Copy contents of gcc-bash-completion.sh to ~/.bash_completion  
open new terminal and try auto completion !


> please leave an issue above if you have any problems using this script.
