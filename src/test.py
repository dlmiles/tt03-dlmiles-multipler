#!/usr/bin/python3
import os
import sys
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles
from cocotb.wavedrom import trace
from cocotb.binary import BinaryValue

waves = None

# Move to utils.wavedrom ?
#@cocotb.before()
def wavedrom_init(dut):
    global waves
    # clk, fakeclk (for comb/async)
    # rst, reset, rstn, resetn, reset_n
    # input, io_in, io_input, in, inputs
    # output, io_out, io_output, out, outputs
    #a = [dut.clk, dut.rst, dut.x, dut.y, dut.p, input, output]
    # dut.io_in, dut.io_out
    waves = trace(dut.clk, dut.rst, dut.x, dut.y, dut.p, dut.inputs, dut.outputs, clk=dut.clk)
    return waves

def wavedrom_setup(dut):
    global waves
    waves = wavedrom_init(dut)
    return waves.__enter__()

def wavedrom_dumpj(dut):
    global waves
    filename = 'test_wavedrom.json'
    if waves is not None:
        dut._log.debug(waves.dumpj())
        dut._log.info("wavedrom_dumpj({})".format(filename))
        #waves.__exit__(0, 0, 0)
        waves.write(filename, header="", footer="", config="")
        waves = None
    # wavedrompy --input input.json --svg output.svg

async def wavedrom_sample():
    global waves
    if waves is not None:
        #waves.sample()
        await waves._monitor()
        pass


# Move to utils.multiply ?
def mul_config_build(x_width=None, y_width=None, has_sign=False):
    if x_width is None or y_width is None:
        error("mul_config_build(x_width,y_width) not set")

    cfg = {}
    cfg['has_sign'] = has_sign
    cfg['x_width'] = x_width
    cfg['y_width'] = y_width
    cfg['s_width'] = 1 if has_sign else 0
    cfg['p_width'] = x_width + y_width + cfg['s_width']

    if has_sign:
        cfg['x_min'] = -pow(2, x_width-1)
        cfg['x_max'] = pow(2, x_width-1) - 1
        cfg['y_min'] = -pow(2, y_width-1)
        cfg['y_max'] = pow(2, y_width-1) - 1
    else:
        cfg['x_min'] = 0
        cfg['x_max'] = pow(2, x_width) - 1
        cfg['y_min'] = 0
        cfg['y_max'] = pow(2, y_width) - 1

    cfg['x_range'] = range(cfg['x_min'], cfg['x_max']+1)	# inclusive .. exclusive
    cfg['y_range'] = range(cfg['y_min'], cfg['y_max']+1)
    return cfg


def mul_config_dump(cfg, logger=print, pfx=""):
    seen_set = {}
    keys = ['has_sign', 'x_width', 'y_width', 's_width', 'p_width', 'x_min', 'x_max', 'x_range', 'y_min', 'y_max', 'y_range']
    for k in keys:
        logger("{}{}={}".format(pfx, k, cfg.get(k)))
        seen_set[k] = True
    if cfg.get('x_range'):
        logger("{}x_range=[{} ... {}]".format(pfx, min(cfg['x_range']), max(cfg['x_range'])))
    if cfg.get('y_range'):
        logger("{}y_range=[{} ... {}]".format(pfx, min(cfg['y_range']), max(cfg['y_range'])))
    for k,v in cfg.items():	# catchall
        if k not in seen_set:
            logger("{}{}={}".format(pfx, k, v))




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
#    h.next()		# enumerate in consitent random order based on seed
# 
# TODO rerun with initialZ=0  initialZ=1  initialZ=RANDOM
#

#
#
# FIXME read data from muls_x3y3.txt
#
#@cocotb.test()
async def test_muls_x3y3(dut):
    report_resolvable(dut, 'initial ')
    clock = try_clk(dut)
    await try_rst(dut)

    width = dut.WIDTH.value
    xy_max = pow(2, width) - 1
    x_range = range(0, xy_max+1)
    x_range = range(0, xy_max+1)

    dut.x.value = 0
    dut.y.value = 0
    await ClockCycles(dut.clk, 1)

    report_resolvable(dut)

    for x in x_range:
        dut.x.value = x
        for y in y_range:
            dut.y.value = y
            await ClockCycles(dut.clk, 2)
            dut._log.info("x={0} y={1} => s={2} p={3} {4}".format(x, y,
                dut.s.value,
                dut.p.value, try_integer(dut.p.value)))
            assert dut.s.value.is_resolvable
            assert dut.p.value.is_resolvable
            assert dut.p.value.integer == (x * y)



#
#
# FIXME read data from mulu_x3y3.txt
#
#@cocotb.test()
async def test_mulu_x3y3(dut):
    # FIXME can apply this with annotatation and apply interceptor pattern around ?
    with wavedrom_init(dut) as wave:
        await do_test_mulu_x3y3(dut)
        wavedrom_dumpj(dut)

async def do_test_mulu_x3y3(dut):
    cfg = mul_config_build(3, 3, False)
    mul_config_dump(cfg, dut._log.info, 'cfg.')

    report_resolvable(dut, 'initial ')
    #await wavedrom_sample()
    clock = try_clk(dut)
    await try_rst(dut)

    #width = 3
    #xy_max = pow(2, width) - 1
    #x_range = range(0, xy_max+1)
    #y_range = range(0, xy_max+1)

    dut.x.value = 0
    dut.y.value = 0
    await ClockCycles(dut.clk, 1)

    report_resolvable(dut)

    for x in cfg.get('x_range'):
        dut.x.value = x
        for y in cfg.get('y_range'):
            dut.y.value = y
            await ClockCycles(dut.clk, 2)
            dut._log.info("x={0} y={1} => p={2} {3}".format(x, y,
                dut.p.value, try_integer(dut.p.value)))
            assert dut.p.value.is_resolvable
            if dut.p.value.integer != (x * y):
                dut._log.warning("x={0} y={1} => p={2} {3} != {4}".format(x, y,
                dut.p.value, try_integer(dut.p.value),
                (x * y)))
            assert dut.p.value.integer == (x * y)


#
#
# FIXME read data from mulu_x2y2.txt
#
#@cocotb.test()
async def test_mulu_x2y2(dut):
    report_resolvable(dut, 'initial ')
    clock = try_clk(dut)
    await try_rst(dut)

    width = 2
    xy_max = pow(2, width) - 1
    x_range = range(0, xy_max+1)
    y_range = range(0, xy_max+1)

    dut.x.value = 0
    dut.y.value = 0
    await ClockCycles(dut.clk, 1)

    report_resolvable(dut)

    for x in x_range:
        dut.x.value = x
        for y in y_range:
            dut.y.value = y
            await ClockCycles(dut.clk, 2)
            dut._log.info("x={0} y={1} => p={2} {3}".format(x, y,
                dut.p.value, try_integer(dut.p.value)))
            assert dut.p.value.is_resolvable
            if dut.p.value.integer != (x * y):
                dut._log.warning("x={0} y={1} => p={2} {3} != {4}".format(x, y,
                dut.p.value, try_integer(dut.p.value),
                (x * y)))
            assert dut.p.value.integer == (x * y)


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
#@cocotb.test()
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

    for y in (0, 1):
        dut.y.value = y
        for a in a_range:
            dut.a.value = a
            for b in b_range:
                dut.b.value = b
                await ClockCycles(dut.clk, 2)
                dut._log.info("a={0} b={1} y={2} => c={3} s={4} {5}{6}".format(a, b, y,
                    dut.c.value, dut.s.value,
                    dut.s.value.integer,
                    '+' if(dut.c.value) else ''))
                assert dut.s.value.is_resolvable
                assert dut.c.value.is_resolvable


# twos-compliment test
#@cocotb.test()
async def test_twos(dut):
    report_resolvable(dut, 'initial ')
    clock = try_clk(dut)
    await try_rst(dut)

    width = dut.WIDTH.value
    i_max = pow(2, width) - 1	# also mask
    i_range = range(0, i_max+1)

    dut.i.value = 0
    await ClockCycles(dut.clk, 1)

    report_resolvable(dut)

    for i in i_range:
        dut.i.value = i
        await ClockCycles(dut.clk, 2)
        expected_value = -i & i_max
        dut._log.info("i={0} {1:2d} => o={2} {3:2d}  (-{4})={5}".format(BinaryValue(i, n_bits=width), i,
            dut.o.value, try_integer(dut.o.value),
            i,
            expected_value))
        assert dut.o.value.is_resolvable
        assert dut.o.value == expected_value
        #assert dut.outputs.value.is_resolvable


# ones-compliment test
@cocotb.test()
async def test_ones(dut):
    report_resolvable(dut, 'initial ')
    clock = try_clk(dut)
    await try_rst(dut)

    width = dut.WIDTH.value
    i_max = pow(2, width) - 1	# also mask
    i_range = range(0, i_max+1)

    dut.i.value = 0
    await ClockCycles(dut.clk, 1)

    report_resolvable(dut)

    for i in i_range:
        dut.i.value = i
        await ClockCycles(dut.clk, 2)
        expected_value = ~i & i_max
        dut._log.info("i={0} {1:2d} => o={2} {3:2d} neg({4})={5}".format(BinaryValue(i, n_bits=width), i,
            dut.o.value, try_integer(dut.o.value),
            i,
            expected_value));
        assert dut.o.value.is_resolvable
        assert dut.o.value == expected_value
        #assert dut.outputs.value.is_resolvable
