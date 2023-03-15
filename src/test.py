#!/usr/bin/python3
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles

# TODO make a config_build(x_width=2, y_width=2, has_sign=False)
# TODO make config_dump()
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


def try_integer(v):
    if v.is_resolvable:
        return v.integer
    return v

def try_name(v):
    if v._name:
        return v._name
    return v

def report_resolvable(dut, pfx = None):
    if pfx == None:
        pfx = ""
    for design_element in dut:
        if isinstance(design_element, cocotb.handle.ModifiableObject):
            dut._log.info("{}DUT.{} = {}".format(pfx, design_element._name, design_element.value))
        else:
            dut._log.info("{}DUT.{} = {}".format(pfx, try_name(design_element), type(design_element)))
    pass


def design_element(dut, name):
    for design_element in dut:
        if design_element._name == name:
            return design_element
    return None

def design_element_exists(dut, name):
    return design_element(dut, name) is not None

def try_clk(dut):
    if design_element_exists(dut, 'clk'):
        clock = Clock(dut.clk, 10, units="us")		# 100 KHz
        dut._log.info("DUT.clk exists, setting up clock: {}".format(clock))
        cocotb.start_soon(clock.start())
        return clock
    return None

async def try_rst(dut):
    if design_element_exists(dut, 'rst'):
        dut._log.info("DUT.rst={} asserting for {} {} active-{}".format(1, 10, "ticks", "high"))
        dut.rst.value = 1
        if design_element_exists(dut, 'clk'):
            await ClockCycles(dut.clk, 10)
        else:
            await Timer(10, units="us")
        dut._log.info("DUT.rst={} deasserting reset".format(0))
        dut.rst.value = 0
        return dut.rst
    return None

#
# TODO knock out a python API looking like this for the data
#
# h = load_file('foo.txt')
# h.check_parameters(dut)
# while(h.hasMore):
#    h.setValue(dut)
#    h.next()
# h.reset()
# h.randomSeed()	# print
# wile(h.hasMore):
#    h.setValue(dut)
#    h.next()
# 


#
#
# FIXME read data from muls_x3y3.txt
#
#@cocotb.test()
async def test_muls_x3y3(dut):
    clock = try_clk(dut)
    await try_rst(dut)
    report_resolvable(dut)

    for x in x_range:
        dut.x.value = x
        for y in y_range:
            dut.y.value = y
            await ClockCycles(dut.clk, 2)
            dut._log.info("x={0} y={1} => s={2} p={3} {4} rdy={5}".format(x, y, dut.s.value, dut.p.value, try_integer(dut.p.value), dut.rdy.value))
            assert dut.s.value.is_resolvable
            assert dut.p.value.is_resolvable
            assert dut.rdy.value.is_resolvable





#
#
# FIXME read data from mulu_x2y2.txt
#
#@cocotb.test()
async def test_mulu_x2y2(dut):
    report_resolvable(dut, 'initial ')
    clock = try_clk(dut)
    await try_rst(dut)

    dut.x.value = 0
    dut.y.value = 0
    await ClockCycles(dut.clk, 2)
    report_resolvable(dut)

    for x in x_range:
        dut.x.value = x
        for y in y_range:
            dut.y.value = y
            await ClockCycles(dut.clk, 2)
            dut._log.info("x={0} y={1} => p={2} {3}".format(x, y, dut.p.value, try_integer(dut.p.value)))
            assert dut.p.value.is_resolvable


#@cocotb.test()
async def test_halfadder(dut):
    report_resolvable(dut, 'initial ')
    clock = try_clk(dut)
    await try_rst(dut)

    width = dut.WIDTH.value
    ab_max = pow(2, width) - 1
    a_range = range(0, ab_max+1)
    b_range = range(0, ab_max+1)
    
    dut.a.value = 0
    dut.b.value = 0
    await ClockCycles(dut.clk, 1)

    report_resolvable(dut)

    for a in a_range:
        dut.a.value = a
        for b in b_range:
            dut.b.value = b
            await ClockCycles(dut.clk, 2)
            dut._log.info("x={0} y={1} => s={2} {3} c={4} {5}{6}".format(a, b,
                dut.s.value, try_integer(dut.s.value),
                dut.c.value, try_integer(dut.c.value),
                '+' if(dut.c.value) else ''))
            assert dut.s.value.is_resolvable
            assert dut.c.value.is_resolvable

#
#
# FIXME read data from fulladder.txt
#
@cocotb.test()
async def test_fulladder(dut):
    report_resolvable(dut, 'initial ')
    clock = try_clk(dut)
    await try_rst(dut)

    width = dut.WIDTH.value
    ab_max = pow(2, width) - 1
    a_range = range(0, ab_max+1)
    b_range = range(0, ab_max+1)

    dut.a.value = 0
    dut.b.value = 0
    await ClockCycles(dut.clk, 1)

    report_resolvable(dut)

    for ci in (0, 1):
        dut.ci.value = ci
        for a in a_range:
            dut.a.value = a
            for b in b_range:
                dut.b.value = b
                await ClockCycles(dut.clk, 2)
                dut._log.info("a={0} b={1} ci={2} => co={3} s={4} {5}{6}".format(a, b, ci,
                    dut.co.value, dut.s.value,
                    dut.s.value.integer,
                    '+' if(dut.co.value) else ''))
                assert dut.s.value.is_resolvable
                assert dut.co.value.is_resolvable
