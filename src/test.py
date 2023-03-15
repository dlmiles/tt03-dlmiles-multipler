#!/usr/bin/python3
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

config_has_sign = False
x_width = 2
y_width = 2
s_width = 1 if config_has_sign else 0
p_width = x_width + y_width + s_width

if config_has_sign:
    x_min = -pow(2, x_width-1)
    x_max = pow(2, x_width-1) - 1
    y_min = -pow(2, y_width-1)
    y_max = pow(2, y_width-1) - 1
else:
    x_min = 0
    x_max = pow(2, x_width) - 1
    y_min = 0
    y_max = pow(2, y_width) - 1

print("config_has_sign={0}".format(config_has_sign))
print("x_width={0}".format(x_width))
print("y_width={0}".format(y_width))
print("s_width={0}".format(s_width))
print("p_width={0}".format(p_width))
print("x_min={0}".format(x_min))
print("x_max={0}".format(x_max))
print("y_min={0}".format(y_min))
print("y_max={0}".format(y_max))

x_range = range(x_min, x_max+1)
y_range = range(y_min, y_max+1)

#
#
# FIXME read data from muls_x3y3.txt
#
#@cocotb.test()
async def test_muls_x3y3(dut):
    dut._log.info("start")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    dut._log.info("reset")
    dut.rst.value = 1
    await ClockCycles(dut.clk, 10)
    dut.rst.value = 0

    dut._log.info("check all inputs")
    for x in x_range:
        dut.x.value = x
        for y in y_range:
            dut.y.value = y
            await ClockCycles(dut.clk, 2)
            dut._log.info("x={0} y={1} => s={2} p={3} {4} rdy={5}".format(x, y, dut.s.value, dut.p.value, dut.p.value.integer, dut.rdy.value))
            assert dut.s.value.is_resolvable
            assert dut.p.value.is_resolvable
            assert dut.rdy.value.is_resolvable


#
#
# FIXME read data from mulu_x2y2.txt
#
@cocotb.test()
async def test_mulu_x2y2(dut):
    dut._log.info("start")
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

#    if dut.rst:
#        dut._log.info("reset")
#        dut.rst.value = 1
#        await ClockCycles(dut.clk, 10)
#        dut.rst.value = 0

    dut.x.value = 0
    dut.y.value = 0

    dut._log.info("check all inputs")
    for x in x_range:
        dut.x.value = x
        for y in y_range:
            dut.y.value = y
            await ClockCycles(dut.clk, 2)
            dut._log.info("x={0} y={1} => p={2}".format(x, y, dut.p.value))
#            dut._log.info("x={0} y={1} => p={2} {3}".format(x, y, dut.p.value, dut.p.value.integer))
#            assert dut.p.value.is_resolvable


#
#
# FIXME read data from fulladder.txt
#
#@cocotb.test()
async def test_fulladder(dut):
    dut._log.info("start")
    # FIXME we're needing a clock but this is a combinational piece
    #  work out how to configure cocotb for that and remove clock and clk input pin
    clock = Clock(dut.clk, 10, units="us")
    cocotb.start_soon(clock.start())

    width = x_width
    ab_max = pow(2, x_width) - 1
    a_range = range(0, ab_max+1)
    b_range = range(0, ab_max+1)

    #dut._log.info("INITIAL OUTPUT s={0} co={1}".format(dut.s.value.binstr, dut.co.value.binstr))

    # Need to do this here to lose the 'z' states
    # There must be something wrong with the: await ClockCycles(dut.clk, 2) ?
#    dut.a.value = 0
#    dut.b.value = 0
#    dut.ci.value = 0

    for ci in (0, 1):
        dut.ci.value = ci
        for a in a_range:
            dut.a.value = a
            for b in b_range:
                dut.b.value = b
                await ClockCycles(dut.clk, 2)
                assert dut.s.value.is_resolvable
                assert dut.co.value.is_resolvable
                #dut._log.info("a={0} b={1} ci={2} => co={3} s={4} {5}{6}".format(a, b, ci,
                #    dut.co.value, dut.s.value,
                #    dut.s.value.integer,
                #    '+' if(dut.co.value) else ''))
