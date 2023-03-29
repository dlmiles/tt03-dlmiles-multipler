#!/usr/bin/python3
import os
import sys
import inspect
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles
from cocotb.wavedrom import trace
from cocotb.binary import BinaryValue

waves = None

def signal_autodetect_name(dut, *args):
    list = []
    for name in args:
        ele = design_element(dut, name)
        if ele is not None:
            list.append(name)
    return list

def signal_autodetect(dut, *args):
    list = []
    for name in args:
        ele = design_element(dut, name)
        if ele is not None:
            list.append(ele)
    return list

# Move to utils.wavedrom ?
#@cocotb.before()
def wavedrom_init(dut):
    global waves
    list = []
    list += signal_autodetect(dut, 'clk', 'fakeclk')	# fakeclk: (for comb/async)
    list += signal_autodetect(dut, 'rst', 'reset', 'rstn', 'resetn', 'reset_n')
    list += signal_autodetect(dut, 'input', 'io_in', 'io_input', 'in', 'inputs', 'in7')
    list += signal_autodetect(dut, 'output', 'io_out', 'io_output', 'out', 'outputs', 'out8')
    list += signal_autodetect(dut, 'x', 'y', 'p')
    list += signal_autodetect(dut, 'inputs', 'outputs')
    for n in list:
        dut._log.info("AUTO {}".format(n._name))
    #waves = trace(dut.clk, dut.rst, dut.x, dut.y, dut.p, dut.inputs, dut.outputs, clk=dut.clk)
    #waves = trace(dut.clk, dut.in7, dut.out8, dut.inputs, dut.outputs, clk=dut.clk)
    waves = trace(*list, clk=dut.clk)
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

def funcname():
    return inspect.currentframe().f_back.f_code.co_name

skip_test_count_true = 0
skip_test_count_false = 0
def check_skip_test(dut, name=None):
    global skip_test_count_true
    global skip_test_count_false

    if name is None and skip_test_count_true > 0 and skip_test_count_false == 0:
        raise Exception("All tests skipped ({}/{})".format(skip_test_count_true+1, skip_test_count_true+skip_test_count_false+1))

    # github-action sets this
    if 'CI' in os.environ and os.environ['CI'] == 'true':
        # deny default ?  get list of allow from envvar ?
        if name == "negedge_carry_look_ahead":
            skip_test_count_false += 1
            return False
        # allowed
        dut._log.warning("SKIPPING: {}".format(name))
        skip_test_count_true += 1
        #raise TestComplete("SKIPPED: {}".format(name))
        return True
    # default
    skip_test_count_false += 1
    return False


def try_integer(v):
    if type(v) is int:
        return v
    if v.is_resolvable:
        return v.integer
    return v

def try_binary(v, width=None):
    if type(v) is BinaryValue:
        return v
    if type(v) is str:
        return v
    if width is None:
        return BinaryValue(v)
    else:
        return BinaryValue(v, n_bits=width)


my_assert_count_pass = 0
my_assert_count_fail = 0

def my_assert(v):
    global my_assert_count_pass
    global my_assert_count_fail
    try:
        assert v
        my_assert_count_pass += 1
    except:
        my_assert_count_fail += 1
        pass

def my_assert_summary(dut):
    global my_assert_count_pass
    global my_assert_count_fail
    if my_assert_count_pass > 0 or my_assert_count_fail > 0:
        dut._log.info("my_assert_count_pass={}".format(my_assert_count_pass))
        if my_assert_count_fail > 0:
            dut._log.error("my_assert_count_fail={}".format(my_assert_count_fail))
            raise Exception("my_assert_count_fail > 0".format())
        else:
            dut._log.info("my_assert_count_fail={}".format(my_assert_count_fail))

# Useful when you want a particular format, but only if it is a number
#  try_decimal_format(valye, '3d')
def try_decimal_format(v, fmt=None):
    if fmt is not None and type(v) is int:
        fmtstr = "{{}}".format(fmt)
        return fmtstr.format(v)
    return "{}".format(v)

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
# FIXME read data from mulu_m7q7.txt
#
@cocotb.test()
async def test_mulu_m7q7(dut):
    if check_skip_test(dut, funcname()):
        return
    # FIXME can apply this with annotatation and apply interceptor pattern around ?
    with wavedrom_init(dut) as wave:
        await do_test_mulu_m7q7(dut)
        wavedrom_dumpj(dut)

async def do_test_mulu_m7q7(dut):
    cfg = mul_config_build(7, 7, False)
    mul_config_dump(cfg, dut._log.info, 'cfg.')

    report_resolvable(dut, 'initial ')
    #await wavedrom_sample()
    clock = try_clk(dut)
    await try_rst(dut)

    dut.in7.value = 0
    await ClockCycles(dut.clk, 1)

    report_resolvable(dut)
    data = {}

    for x in cfg.get('x_range'):
        # FIXME for code-debug-test remove for production sign-off
        #if x > 12 and x < 126:
        #    continue

        for y in cfg.get('y_range'):
            # FIXME for code-debug-test remove for production sign-off
            #if y > 12 and y < 126:
            #    continue

            data['have_op'] = True

            p_fall = dut.out8.value
            if p_fall.is_resolvable:
                p_fall_1 = p_fall >> 1
            else:
                dut._log.info("p_fall={}".format(p_fall))
                p_fall_1 = p_fall	# !is_resolvable
            data['p_fall'] = p_fall
            data['p_fall_1'] = p_fall_1

            dut.in7.value = y
            data['y_next'] = y

            await RisingEdge(dut.clk)

            p_rise = dut.out8.value
            if p_rise.is_resolvable:
                p_rise_1 = p_rise >> 1
            else:
                dut._log.info("p_rise={}".format(p_rise))
                p_rise_1 = p_rise	# !is_resolvable
            data['p_rise'] = p_rise
            data['p_rise_1'] = p_rise_1

            dut.in7.value = x
            data['x_next'] = x

            await FallingEdge(dut.clk)

            # shift down 1 as out8.bit1 is the product bit0
            if data['p_rise'].is_resolvable and data['p_fall'].is_resolvable:
                data['p'] = (data['p_rise_1'] << 7) | data['p_fall_1']
            else:
                data['p'] = "UNKNOWN"

            data['have_result'] = 'x' in data and 'y' in data   # we use inputs given, as we want to see bad outputs

            if data['have_result']:
                dut._log.info("x={0:3d} {1}  y={2:3d} {3}  =>  p={4} {5}  p_rise_hi={6:3d} {7}  p_fall_lo={8:3d} {9}".format(
                    data['x'], try_binary(data['x'], cfg['x_width']),
                    data['y'], try_binary(data['y'], cfg['y_width']),
                    try_decimal_format(data['p'], '5d'), try_binary(data['p'], cfg['p_width']),
                    data['p_rise_1'], try_binary(data['p_rise_1'], 7),
                    data['p_fall_1'], try_binary(data['p_fall_1'], 7)
                    ))
                data['have_result'] = False

                expectedValue_p = data['x'] * data['y']
                assert(data['p'] == expectedValue_p)

            if 'x_next' in data:
                data['x'] = data['x_next']
                del data['x_next']
            if 'y_next' in data:
                data['y'] = data['y_next']
                del data['y_next']
            data['have_op'] = 'x' in data and 'y' in data

    if True:	# indentation cheat
        if data['have_op']:
            p_fall = dut.out8.value
            if p_fall.is_resolvable:
                p_fall_1 = p_fall >> 1
            else:
                dut._log.info("p_fall={}".format(p_fall))
                p_fall_1 = p_fall	# !is_resolvable
            data['p_fall'] = p_fall
            data['p_fall_1'] = p_fall_1

            await RisingEdge(dut.clk)

            p_rise = dut.out8.value
            if p_rise.is_resolvable:
                p_rise_1 = p_rise >> 1
            else:
                dut._log.info("p_rise={}".format(p_rise))
                p_rise_1 = p_rise	# !is_resolvable
            data['p_rise'] = p_rise
            data['p_rise_1'] = p_rise_1


            # shift down 1 as out8.bit1 is the product bit0
            if data['p_rise'].is_resolvable and data['p_fall'].is_resolvable:
                data['p'] = (data['p_rise_1'] << 7) | data['p_fall_1']
            else:
                data['p'] = "UNKNOWN"

            data['have_result'] = 'x' in data and 'y' in data	# we use inputs given, as we want to see bad outputs

            if data['have_result']:
                dut._log.info("x={0:3d} {1}  y={2:3d} {3}  =>  p={4} {5}  p_rise_hi={6:3d} {7}  p_fall_lo={8:3d} {9}".format(
                    data['x'], try_binary(data['x'], cfg['x_width']),
                    data['y'], try_binary(data['y'], cfg['y_width']),
                    try_decimal_format(data['p'], '5d'), try_binary(data['p'], cfg['p_width']),
                    data['p_rise_1'], try_binary(data['p_rise_1'], 7),
                    data['p_fall_1'], try_binary(data['p_fall_1'], 7)
                    ))
                data['have_result'] = False

                expectedValue_p = data['x'] * data['y']
                assert(data['p'] == expectedValue_p)

            if 'x_next' in data:
                data['x'] = data['x_next']
                del data['x_next']
            if 'y_next' in data:
                data['y'] = data['y_next']
                del data['y_next']
            data['have_op'] = 'x' in data and 'y' in data


#            assert dut.p.value.is_resolvable
#            if dut.p.value.integer != (x * y):
#                dut._log.warning("x={0} y={1} => p={2} {3} != {4}".format(x, y,
#                dut.p.value, try_integer(dut.p.value),
#                (x * y)))
#            assert dut.p.value.integer == (x * y)




#
#
# FIXME read data from muls_m3y3.txt
#
@cocotb.test()
async def test_muls_m3y3(dut):
    if check_skip_test(dut, funcname()):
        return
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
# FIXME read data from mulu_m3q3.txt
#
@cocotb.test()
async def test_mulu_m3q3(dut):
    if check_skip_test(dut, funcname()):
        return
    # FIXME can apply this with annotatation and apply interceptor pattern around ?
    with wavedrom_init(dut) as wave:
        await do_test_mulu_m3q3(dut)
        wavedrom_dumpj(dut)

async def do_test_mulu_m3q3(dut):
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
# FIXME read data from mulu_m2q2.txt
#
@cocotb.test()
async def test_mulu_m2q2(dut):
    if check_skip_test(dut, funcname()):
        return
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
#
#
# FIXME read data from carry_look_ahead.txt
#
@cocotb.test()
async def test_carry_look_ahead(dut):
    if check_skip_test(dut, funcname()):
        return
    report_resolvable(dut, 'initial ')
    clock = try_clk(dut)
    await try_rst(dut)

    width = dut.WIDTH.value
    ab_base = pow(2, width)
    ab_max = ab_base - 1
    a_range = range(0, ab_max+1)
    b_range = range(0, ab_max+1)
    dut._log.info("PARAMS width={} ab_base={} ab_max={} a_range={} b_range={}".format(
        width, ab_base, ab_max, a_range, b_range
    ))

    dut.a.value = 0
    dut.b.value = 0
    dut.y.value = 0
    await ClockCycles(dut.clk, 1)

    report_resolvable(dut)

    for y in (0, 1):
        dut.y.value = y
        for a in a_range:
            dut.a.value = a
            for b in b_range:
                dut.b.value = b
                await ClockCycles(dut.clk, 1)

                total = a + b + y
                expectedValue_s = total % ab_base
                expectedValue_c = 0 if(total <= ab_max) else 1

                dut._log.info("a={0} b={1} y={2} => c={3} s={4} {5}{6}".format(a, b, y,
                    dut.c.value,
                    dut.s.value, try_integer(dut.s.value),
                    '+' if(dut.c.value) else ''))
                assert dut.s.value.is_resolvable
                assert dut.c.value.is_resolvable
                assert dut.s.value == expectedValue_s
                assert dut.c.value == expectedValue_c


#
#
# FIXME read data from carry_look_ahead.txt
#
@cocotb.test()
async def negedge_carry_look_ahead(dut):
    if check_skip_test(dut, funcname()):
        return
    # FIXME can apply this with annotatation and apply interceptor pattern around ?
    with wavedrom_init(dut) as wave:
        await do_negedge_carry_look_ahead(dut)
        wavedrom_dumpj(dut)

async def do_negedge_carry_look_ahead(dut):
    report_resolvable(dut, 'initial ')
    clock = try_clk(dut)
    await try_rst(dut)

    if design_element_exists(dut, 'WIDTH'):
        width = dut.WIDTH.value
    elif design_element_exists(dut, 'carry_look_ahead'):
        width = dut.carry_look_ahead.WIDTH.value
    else:
        width = 7	## FIXME
    ab_base = pow(2, width)
    ab_max = ab_base - 1
    a_range = range(0, ab_max+1)
    b_range = range(0, ab_max+1)
    dut._log.info("PARAMS width={} ab_base={} ab_max={} a_range={} b_range={}".format(
        width, ab_base, ab_max, a_range, b_range
    ))

    dut.in7.value = 0
    await ClockCycles(dut.clk, 1)

    report_resolvable(dut)
    data = {}

    await FallingEdge(dut.clk)

    for y in [0]:		# y=1 not supported no input port
        for a in a_range:
            for b in b_range:
                data['have_op'] = True

                dut.in7.value = b
                data['b_next'] = b

                await RisingEdge(dut.clk)

                dut.in7.value = a
                data['a_next'] = a

                await FallingEdge(dut.clk)

                if dut.out8.value.is_resolvable:
                    data['s'] = dut.out8.value.integer >> 1
                    data['c'] = dut.out8.value.integer & 1
                else:
                    data['s'] = 'UNKNOWN'
                    data['c'] = 'UNKNOWN'

                data['have_result'] = 'a' in data and 'a' in data   # we use inputs given, as we want to see bad outputs

                if data['have_result']:
                    total = a + b + y
                    expectedValue_s = total % ab_base
                    expectedValue_c = 0 if(total <= ab_max) else 1

                    dut._log.info("a={0:3d} {1}  b={2:3d} {3}  y={4}  => c={5} s={6}{7} {8}".format(
                        data['a'], try_binary(data['a'], width),
                        data['b'], try_binary(data['b'], width),
                        y,	# no input port for this
                        try_decimal_format(data['c']),
                        try_decimal_format(data['s'], '3d'),
                        '+' if(data['c']) else ' ',
                        try_binary(data['s'], width)
                        ))
                    my_assert(data['s'] != 'UNKNOWN')
                    my_assert(data['c'] != 'UNKNOWN')
                    my_assert(data['s'] == expectedValue_s)
                    my_assert(data['c'] == expectedValue_c)

                if 'a_next' in data:
                    data['a'] = data['a_next']
                    del data['a_next']
                if 'b_next' in data:
                    data['b'] = data['b_next']
                    del data['b_next']
                data['have_op'] = 'a' in data and 'b' in data


    if True:	# indentation cheat
        if True:	# indentation cheat2
            if data['have_op']:
                await RisingEdge(dut.clk)

                if dut.out8.value.is_resolvable:
                    data['s'] = dut.out8.value.integer >> 1
                    data['c'] = dut.out8.value.integer & 1
                else:
                    data['s'] = 'UNKNOWN'
                    data['c'] = 'UNKNOWN'

                data['have_result'] = 'a' in data and 'a' in data   # we use inputs given, as we want to see bad outputs

                if data['have_result']:
                    total = a + b + y
                    expectedValue_s = total % ab_base
                    expectedValue_c = 0 if(total <= ab_max) else 1

                    dut._log.info("a={0:3d} {1}  b={2:3d} {3}  y={4}  => c={5} s={6}{7} {8}".format(
                        data['a'], try_binary(data['a'], width),
                        data['b'], try_binary(data['b'], width),
                        y,	# no input port for this
                        try_decimal_format(data['c']),
                        try_decimal_format(data['s'], '3d'),
                        '+' if(data['c']) else ' ',
                        try_binary(data['s'], width)
                        ))
                    my_assert(data['s'] != 'UNKNOWN')
                    my_assert(data['c'] != 'UNKNOWN')
                    my_assert(data['s'] == expectedValue_s)
                    my_assert(data['c'] == expectedValue_c)

                if 'a_next' in data:
                    data['a'] = data['a_next']
                    del data['a_next']
                if 'b_next' in data:
                    data['b'] = data['b_next']
                    del data['b_next']
                data['have_op'] = 'a' in data and 'b' in data


#
#
# FIXME read data from fulladder.txt
#
@cocotb.test()
async def test_fulladder(dut):
    if check_skip_test(dut, funcname()):
        return
    report_resolvable(dut, 'initial ')
    clock = try_clk(dut)
    await try_rst(dut)

    width = dut.WIDTH.value
    ab_base = pow(2, width)
    ab_max = ab_base - 1
    a_range = range(0, ab_max+1)
    b_range = range(0, ab_max+1)
    dut._log.info("PARAMS width={} ab_base={} ab_max={} a_range={} b_range={}".format(
        width, ab_base, ab_max, a_range, b_range
    ))

    dut.a.value = 0
    dut.b.value = 0
    dut.y.value = 0
    await ClockCycles(dut.clk, 1)

    report_resolvable(dut)

    for y in (0, 1):
        dut.y.value = y
        for a in a_range:
            dut.a.value = a
            for b in b_range:
                dut.b.value = b
                await ClockCycles(dut.clk, 1)

                total = a + b + y
                expectedValue_s = total % ab_base
                expectedValue_c = 0 if(total <= ab_max) else 1

                dut._log.info("a={0} b={1} y={2} => c={3} s={4} {5}{6}".format(a, b, y,
                    dut.c.value,
                    dut.s.value, try_integer(dut.s.value),
                    '+' if(dut.c.value) else ''))
                assert dut.s.value.is_resolvable
                assert dut.c.value.is_resolvable
                assert dut.s.value == expectedValue_s
                assert dut.c.value == expectedValue_c




@cocotb.test()
async def test_halfadder(dut):
    if check_skip_test(dut, funcname()):
        return
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

# twos-compliment test
@cocotb.test()
async def test_twos(dut):
    if check_skip_test(dut, funcname()):
        return
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
    if check_skip_test(dut, funcname()):
        return
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

@cocotb.test(stage=sys.maxsize)
async def everything_skipped_test(dut):
    check_skip_test(dut)
    my_assert_summary(dut)
