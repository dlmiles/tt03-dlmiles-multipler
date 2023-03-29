#!/bin/bash -e
#
#
#

make clean
make IMPL_ONES=1 TESTCASE=test_ones
echo "EXIT=$?"

make clean
make IMPL_TWOS=1 TESTCASE=test_twos
echo "EXIT=$?"

make clean
make IMPL_HALFADDER=1 TESTCASE=test_halfadder
echo "EXIT=$?"

make clean
make IMPL_FULLADDER=1 TESTCASE=test_fulladder
echo "EXIT=$?"

make clean
make IMPL_CARRY_LOOK_AHEAD=1 TESTCASE=test_carry_look_ahead
echo "EXIT=$?"

make clean
make IMPL_NEGEDGE_CARRY_LOOK_AHEAD=1 TESTCASE=test_negedge_carry_look_ahead
echo "EXIT=$?"

make clean
make IMPL_MULU_M2Q2=1 TESTCASE=test_mulu_m2q2
echo "EXIT=$?"

make clean
make IMPL_MULU_M3Q3=1 TESTCASE=test_mulu_m3q3
echo "EXIT=$?"

make clean
make IMPL_MULU_M7Q7=1 TESTCASE=test_mulu_m7q7
echo "EXIT=$?"

#make clean
#make IMPL_MULS_M2Q2=1 TESTCASE=test_muls_m2q2
echo "EXIT=$?"

#make clean
#make IMPL_MULS_M3Q3=1 TESTCASE=test_muls_m3q3
echo "EXIT=$?"
