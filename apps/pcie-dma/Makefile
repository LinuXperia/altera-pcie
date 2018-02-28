# Build like:
#   make FPGA=gt
#

# FPGA device
FPGA         := gt

all: $(FPGA)-out/$(FPGA).sof

$(FPGA)-out/$(FPGA).sof:
	@mkdir -p $(FPGA)-out
	@echo "project_open -revision $(FPGA) $(FPGA)" > $(FPGA)-out/defs.tcl
	@echo "export_assignments"                     >> $(FPGA)-out/defs.tcl
	@echo "Config {"                         | tee    $(FPGA)-out/build.log
	@echo "  FPGA         = $(FPGA)"         | tee -a $(FPGA)-out/build.log
	@echo "}"                                | tee -a $(FPGA)-out/build.log
	LD_PRELOAD=../../ip/tools/isatty_hack.so quartus_sh --flow compile $(FPGA).qpf -c $(FPGA) | tee -a $(FPGA)-out/build.log

# Program the FPGA over JTAG
prog: $(FPGA)-out/$(FPGA).sof
	quartus_pgm --mode=JTAG -o 'p;gt-out/gt.sof'

# Program the flash
flash: $(FPGA)-out/$(FPGA).pof $(FPGA).cdf
	quartus_pgm $(FPGA).cdf

# Create flash-programming file
$(FPGA)-out/$(FPGA).pof: $(FPGA)-out/$(FPGA).sof $(FPGA).cof
	quartus_cpf -c $(FPGA).cof

clean: FORCE
	rm -rf *-out c5_pin_model_dump.txt db incremental_db

FORCE: