#! /bin/bash

export PATH=../../generators/boxworld/:$PATH

#usage: ./boxworld [-h]
#                  [-b box-count]
#                  [-c city-count]
#                  [-dc drive-cost]
#                  [-fc fly-cost]
#                  [-dr delivery-reward]
#                  [-tlc truck-load-cost]
#                  [-tuc truck-unload-cost]
#                  [-plc plane-load-cost]
#                  [-puc plane-unload-cost]
#                  [-gr goal-reward]
#                  [-dn domain name]
#                  [-pn problem name]

function make-bw {
   boxworld -pn box-$1 -b $2 -c $3 -dc $4 -fc $5 -dr $6 -gr $7 \
   > $1-b$2-c$3-dc$4-fc$5-dr$6-gr$7.pddl
}

#cmd    pXX  b  c dc fc  dr  gr
make-bw p1 2  4  1  1   1   1
make-bw p2 3  4  1  1   1   1
make-bw p3 3  4  1  1   1   1
make-bw p4 4 4  1  1   1   1
make-bw p5 4 4  1  1   1   1
make-bw p6 4 5  1  1   1   1
make-bw p7 4 5  1  1   1   1
make-bw p8 5 4  1  1   1   1
make-bw p9 5 4  1  1   1   1
make-bw p10 5 5 1  1   1   1
make-bw p11 5 5 1  1   1   1
make-bw p12 7 3 1  1   1   1
make-bw p13 7 3 1  1   1   1
make-bw p14 3 7 1  1   1   1
make-bw p15 6 6 1  1   1   1

rm -f generate.sh~
