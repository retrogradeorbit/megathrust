CLEAN=rm
CLEANARGS=-f
BUILDPATH=build
BUILD=megathrust.prg
SOURCEPATH=src
SOURCE=main.asm

CRUNCHERPATH=cruncher
CRUNCHER=pucrunch
# after cruncher finishes, sets $01 to val $37
#CRUNCHERARGS=-x0x0801 -c64 -g0x37 -fshort

# all banks are RAM (no rom)
CRUNCHERARGS=-x0x0801 -c64 -g0x37 -fshort
EMULATORPATH=emulator
EMULATOR=x64
EMULATORARGS=

all: compile crunch run

clean:
	$(CLEAN) $(CLEANARGS) $(BUILDPATH)

compile:
	-mkdir $(BUILDPATH)
	java -jar compiler/KickAss.jar -vicesymbols -o build/megathrust.prg src/main.asm

crunch:
	$(CRUNCHERPATH)/$(CRUNCHER) $(CRUNCHERARGS) $(BUILDPATH)/$(BUILD) $(BUILDPATH)/$(BUILD)

run:
	$(EMULATORPATH)/$(EMULATOR) $(EMULATORARGS) $(BUILDPATH)/$(BUILD)
