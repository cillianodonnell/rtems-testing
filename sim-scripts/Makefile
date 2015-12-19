INSTALL_DIR=../bin
GDBSIM_SCRIPTS=bf537Stamp ezkit533 gdbarmsim jmr3904 lm32_evr \
  m32csim or1ksim psim sis erc32 leon2 leon3 simsh v850sim
SKYEYE_SCRIPTS=ant5206 bf537Stamp-skyeye csb337 csb350 csb360 edb7312 \
  ezkit533-skyeye gumstix rtl22xx smdk2410 leon2-skyeye

TSIM_SCRIPTS=erc32 leon2-tsim leon3-tsim
QEMU_SCRIPTS=pc386 qemuppc qemu-gumstix qemu-leon2 qemu-lm32_evr qemu-or1k \
  uC5282 lm3s6965 realview_pbx_a9_qemu realview_pbx_a9_qemu_smp \
  xilinx_zynq_a9_qemu

GENERATED_SCRIPTS=\
  ${GDBSIM_SCRIPTS} $(GDBSIM_SCRIPTS:%=%-gdb) \
  ${SKYEYE_SCRIPTS} $(SKYEYE_SCRIPTS:%=%-gdb) \
  ${TSIM_SCRIPTS} $(TSIM_SCRIPTS:%=%-gdb) \
  ${QEMU_SCRIPTS}

COMPILED_PROGRAMS=usleep
UNPROCESSED_SCRIPTS=nosim check_endof \
  rtems-gdb-macros-4.7 rtems-gdb-macros-4.8 rtems-gdb-macros-4.9 \
  rtems-gdb-macros-4.10 rtems-gdb-macros-4.11 rtems-gdb-macros-4.12

all: prep ${GENERATED_SCRIPTS} ${COMPILED_PROGRAMS} \
     ${UNPROCESSED_SCRIPTS} install

prep:
	test -d ${INSTALL_DIR} || mkdir ${INSTALL_DIR}

usleep: usleep.c
	$(CC) -o $@ $<

### QEMU BSPs
pc386: gdb-sim-run.in pc386.in
	./mkrun no i386 i386 pc386

qemuppc: gdb-sim-run.in qemuppc.in
	./mkrun no PowerPC powerpc qemuppc

qemu-gumstix: gdb-sim-run.in qemu-gumstix.in
	./mkrun no ARM arm qemu-gumstix

qemu-leon2: gdb-sim-run.in qemu-leon2.in
	./mkrun no SPARC sparc qemu-leon2

qemu-lm32_evr: gdb-sim-run.in qemu-lm32_evr.in
	./mkrun no LM32 lm32 qemu-lm32_evr

qemu-or1k: gdb-sim-run.in qemu-or1k.in
	./mkrun no OR1K or1k qemu-or1k

uC5282: gdb-sim-run.in uC5282.in
	./mkrun no M68K-Coldfire m68k uC5282

lm3s6965: gdb-sim-run.in lm3s6965.in
	./mkrun no ARM arm lm3s6965

realview_pbx_a9_qemu: gdb-sim-run.in realview_pbx_a9_qemu.in
	./mkrun no ARM arm realview_pbx_a9_qemu

realview_pbx_a9_qemu_smp: gdb-sim-run.in realview_pbx_a9_qemu_smp.in
	./mkrun no ARM arm realview_pbx_a9_qemu_smp

xilinx_zynq_a9_qemu: gdb-sim-run.in xilinx_zynq_a9_qemu.in
	./mkrun no ARM arm xilinx_zynq_a9_qemu

### Skyeye Simulator BSPs
ant5206: gdb-sim-run.in gdb-sim.in ant5206.in
	./mkrun yes M68K-Coldfire m68k ant5206

csb337: gdb-sim-run.in gdb-sim.in csb337.in
	./mkrun yes ARM arm csb337

csb350: gdb-sim-run.in gdb-sim.in csb350.in
	./mkrun yes MIPS mips csb350

csb360: gdb-sim-run.in gdb-sim.in csb360.in
	./mkrun yes M68K-Coldfire m68k csb360

bf537Stamp-skyeye: gdb-sim-run.in gdb-sim.in bf537Stamp-skyeye.in
	./mkrun yes Blackfin bfin bf537Stamp-skyeye

edb7312: gdb-sim-run.in gdb-sim.in edb7312.in
	./mkrun yes ARM arm edb7312

gumstix: gdb-sim-run.in gdb-sim.in gumstix.in
	./mkrun yes ARM arm gumstix

rtl22xx: gdb-sim-run.in gdb-sim.in rtl22xx.in
	./mkrun yes ARM arm rtl22xx

smdk2410: gdb-sim-run.in gdb-sim.in smdk2410.in
	./mkrun yes ARM arm smdk2410

ezkit533-skyeye: gdb-sim-run.in gdb-sim.in ezkit533-skyeye.in
	./mkrun yes Blackfin bfin ezkit533-skyeye

leon2-skyeye: gdb-sim-run.in gdb-sim.in leon2-skyeye.in
	./mkrun yes SPARC sparc leon2-skyeye

### TSIM Simulator BSPs
erc32-tsim: gdb-sim-run.in gdb-sim.in erc32-tsim.in tsim-support
	./mkrun yes SPARC sparc erc32-tsim

leon2-tsim: gdb-sim-run.in gdb-sim.in leon2-tsim.in tsim-support
	./mkrun yes SPARC sparc leon2-tsim

leon3-tsim: gdb-sim-run.in gdb-sim.in leon3-tsim.in tsim-support
	./mkrun yes SPARC sparc leon3-tsim

### GDB Simulator BSPs
bf537Stamp bf537Stamp-gdb: gdb-sim-run.in gdb-sim.in bf537Stamp.in
	./mkrun yes Blackfin bfin bf537Stamp

ezkit533 ezkit533-gdb: gdb-sim-run.in gdb-sim.in ezkit533.in
	./mkrun yes Blackfin bfin ezkit533

gdbarmsim gdbarmsim-gdb: gdb-sim-run.in gdb-sim.in gdbarmsim.in
	./mkrun yes ARM arm gdbarmsim

jmr3904 jmr3904-gdb: gdb-sim-run.in gdb-sim.in jmr3904.in
	./mkrun yes MIPS mipstx39 jmr3904

lm32_evr lm32_evr-gdb: gdb-sim-run.in gdb-sim.in lm32_evr.in
	./mkrun yes LM32 lm32 lm32_evr

m32csim m32csim-gdb: gdb-sim-run.in gdb-sim.in m32csim.in
	./mkrun yes M32C m32c m32csim

or1ksim or1ksim-gdb: or1ksim.in
	./mkrun yes OR1K or1k or1ksim

psim psim-gdb: gdb-sim-run.in gdb-sim.in psim.in
	./mkrun yes PowerPC powerpc psim

sis sis-gdb: gdb-sim-run.in gdb-sim.in sis.in
	./mkrun yes SPARC sparc sis

erc32 erc32-gdb: gdb-sim-run.in gdb-sim.in erc32.in
	./mkrun yes SPARC sparc erc32

leon2 leon2-gdb: gdb-sim-run.in gdb-sim.in leon2.in
	./mkrun yes SPARC sparc leon2

leon3 leon3-gdb: gdb-sim-run.in gdb-sim.in leon3.in
	./mkrun yes SPARC sparc leon3

simsh simsh-gdb: gdb-sim-run.in gdb-sim.in simsh.in
	./mkrun yes SuperH sh simsh

v850sim v850sim-gdb: gdb-sim-run.in gdb-sim.in v850sim.in
	./mkrun yes V850 v850 v850sim

clean:
	rm -f ${GENERATED_SCRIPTS} ${COMPILED_PROGRAMS}

install:
	for i in ${GENERATED_SCRIPTS} ${COMPILED_PROGRAMS} \
                 ${UNPROCESSED_SCRIPTS} ; do \
	  cp $${i} ${INSTALL_DIR}/$${i} ; \
	  chmod +x ${INSTALL_DIR}/$${i} ; \
	done

