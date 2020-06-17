# after cruncher finishes, sets $01 to val $37
#CRUNCHERARGS=-x0x0801 -c64 -g0x37 -fshort

# only 0x37 works
CRUNCHERARGS=-x0x0801 -c64 -g0x37 -fshort

EMULATORARGS=


all: process-images compile run

clean:
	rm -rf build

compile: build/megathrust.prg

build/megathrust-full.prg: src/main.asm
	-mkdir build
	java -jar compiler/KickAss.jar -vicesymbols -o build/megathrust-full.prg src/main.asm

build/megathrust.prg: build/megathrust-full.prg
	cruncher/pucrunch $(CRUNCHERARGS) build/megathrust-full.prg build/megathrust.prg

run: build/megathrust.prg
	x64 $(EMULATORARGS) build/megathrust.prg

run-full: build/megathrust-full.prg
	x64 $(EMULATORARGS) build/megathrust-full.prg

process-images:
	-mkdir data
	cd process && lein run

# debugger
# ll "build/main.vs"
# shl
# (C:$e5cf) break .start
# BREAK: 1  C:$0801  (Stop on exec)

#(C:$e5cf) g .start
#1 (Stop on  exec 0801)  000 009
#.C:0801  33 08       RLA ($08),Y    - A:00 X:00 Y:0A SP:f2 ..-...Z.   96019569

# step into (z), and step over (n)
