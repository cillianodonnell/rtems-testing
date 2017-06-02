# NOTE: This is not the fanciest Makefile I have ever written. ;)

all:
	make -C sim-scripts
	make -C merge-helpers
	make -C rtems-test-template
#	make -C coverity

install:
	make -C sim-scripts install
	make -C merge-helpers install
	make -C rtems-test-template install
#	make -C coverity install

clean:
	make -C sim-scripts clean
	make -C merge-helpers clean
	make -C rtems-test-template clean
#	make -C coverity clean
	rm -rf bin

up:
	cvs up -Pd 2>&1 | grep -v ^cvs
