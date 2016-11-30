#!/bin/bash
test $# -lt 1 && echo "usage: $0 <newscriptname>" && exit 1
if test ! -e $1; then echo '#!/bin/bash' > $1 ; vim $1
else
   echo "$1 : File Already Exists"
fi
