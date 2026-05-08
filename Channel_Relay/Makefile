# Configuration area

# Full path to Python. For Windows this is typically
# C:\Python27\python.exe; if it is in your path you don't need to change it.
PYTHON=python3

# Full path to main.py in the optimizer. Depends on where it was unpacked.
OPTIMIZER=/opt/pyoptimizer/main.py

# Which preprocessor to use. Use 'gcpp' for GNU cpp (typical on Linux/OSX);
# use 'mcpp' for mcpp.
PREPROC_KIND=gcpp

# Full path to the preprocessor. Depends on where you have downloaded it.
# If the preprocessor is GNU cpp and it is in your path, leave it as cpp.
PREPROC_PATH=cpp

# Full path to the zip program (zip.exe for Windows). Depends on where you
# have downloaded it. If it is in your path you don't need to change it.
ZIP=zip

# Name of the zipped file to generate for SL
SLZIP=ChannelRelay.zip

# Name of the zipped file to generate for OpenSim
OSZIP=ChannelRelay-oss.zip

# End of configuration area


# Version being compiled (LSL string)
VERSION="1.0.1"


# Note some of these scripts don't strictly need to be optimized for memory.

OPTIMIZED=channel_relay.lslo

UNOPTIMIZED=

OPENSIM=

all: $(SLZIP)

clean:
	$(PYTHON) build-aux.py rm $(SLZIP) $(OSZIP) $(OPTIMIZED) $(OPENSIM)

optimized: $(OPTIMIZED)

opensim: $(OPENSIM)

$(SLZIP): $(OPTIMIZED) $(UNOPTIMIZED)
	$(PYTHON) build-aux.py rm $@
	$(ZIP) $@ $(OPTIMIZED) $(UNOPTIMIZED)

%.lslo %.lslt: %.lsl
	$(PYTHON) $(OPTIMIZER) -H -O addstrings,shrinknames,-extendedglobalexpr -p $(PREPROC_KIND) --precmd=$(PREPROC_PATH) $(OFLAGS) $< -o $@

$(OSZIP): $(OPENSIM)
	$(PYTHON) build-aux.py rm $@
	$(ZIP) $@ $(OPENSIM)

%.oss: %.lsl
	$(PYTHON) build-aux.py oss-process $< > $@

# Bash only, probably GNU make only
setvars:
	for name in $(addprefix ',$(addsuffix ',$(OPTIMIZED:.lslo=.lsl))) $(addprefix ',$(addsuffix ',$(UNOPTIMIZED))); do $(PYTHON) build-aux.py setvars "$$name" version='$(VERSION)' ; done

release: setvars all

.PHONY : all clean optimized opensim setvars release
