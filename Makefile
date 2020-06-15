# after cruncher finishes, sets $01 to val $37
#CRUNCHERARGS=-x0x0801 -c64 -g0x37 -fshort
# all banks are RAM (no rom)
CRUNCHERARGS=-x0x0801 -c64 -g0x37 -fshort

EMULATORARGS=

all: compile crunch run

clean:
	rm -rf build

build/megathrust-full.prg: src/main.asm
	-mkdir build
	java -jar compiler/KickAss.jar -vicesymbols -o build/megathrust-full.prg src/main.asm

build/megathrust.prg: build/megathrust-full.prg
	cruncher/pucrunch $(CRUNCHERARGS) build/megathrust-full.prg build/megathrust.prg

run: build/megathrust.prg
	emulator/x64 $(EMULATORARGS) build/megathrust.prg
