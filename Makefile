CLEAN=rm
CLEANARGS=-f
BUILDPATH=build
BUILD=megathrust.prg
SOURCEPATH=src
SOURCE=main.asm
COMPILERPATH=compiler
COMPILER=acme
COMPILERREPORT=buildreport
COMPILERSYMBOLS=symbols
COMPILERARGS=-r $(BUILDPATH)/$(COMPILERREPORT) --vicelabels $(BUILDPATH)/$(COMPILERSYMBOLS) --msvc --color --format cbm -v3 --outfile
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
	$(COMPILERPATH)/$(COMPILER) $(COMPILERARGS) $(BUILDPATH)/$(BUILD) $(SOURCEPATH)/$(SOURCE)

crunch:
	$(CRUNCHERPATH)/$(CRUNCHER) $(CRUNCHERARGS) $(BUILDPATH)/$(BUILD) $(BUILDPATH)/$(BUILD)

run:
	$(EMULATORPATH)/$(EMULATOR) $(EMULATORARGS) $(BUILDPATH)/$(BUILD)
