#Makefile for zad7988_controller
#Compiles the design in 64-bits mode and creates a 64-bits executable for simulating in 64-bits mode.
#By default, vcs overwrites the Makefile between compilations.  
#Enables dumpling to FSDB/VPD.	
# specifies the name of the executable file that is the product of compilation.
# default file name is simv.
#specifies a file that contains a lot of pathnames to source files and compile-time options.
#-P "${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab ${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a" \

DEST=run_me_before_verdi

VCS_FLAGS= \
	-full64 \
	-Mupdate \
	-debug_access+all \
	-v2005 \
	-sverilog \
	-R \
	-o $(DEST).bin \
	ZFIFO_Sync.v ZFIFO_Sync_TB.v
#	-f $(DEST).flist 

#Default rule.
all: compile

compile:
	vcs ${VCS_FLAGS}
	./$(DEST.bin) 

clean:
	rm -rvf $(DEST).bin	
	rm -rvf csrc
	rm -rvf $(DEST).bin.daidir
	rm -rvf *.fsdb *.logr
	rm -rvf verdiLog
	rm -rvf novas.conf  novas_dump.log  ucli.key
