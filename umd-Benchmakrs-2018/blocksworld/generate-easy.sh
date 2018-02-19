#! /bin/bash

export PATH=../../generators/blocksworld/:$PATH

# DON'T DO THAT ! -> cp ../../generators/blocksworld/domain.pddl ./

function make-bw {
   blocksworld -c $2 -C $3 -g $4 $1 `bwstates -s 2 -n $5` \
   > $1-c$2-C$3-g$4-n$5.pddl
}

#cmd    pXX  c  C  g  n
make-bw p1   1  1  1  3
make-bw p2   1  1  1  4
make-bw p3   1  1  1  4
make-bw p4   1  1  1  5
make-bw p5   1  1  1  5
make-bw p6   1  1  1  6
make-bw p7   1  1  1  6
make-bw p8   1  1  1  7
make-bw p9  1  1  1  7
make-bw p10  1  1  1  8
make-bw p11  1  1  1  8
make-bw p12  1  1  1  9
make-bw p13  1  1  1  9
make-bw p14  1  1  1 10
make-bw p15  1  1  1 10

rm -f generate.sh~
