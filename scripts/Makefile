##////////////////////////////////////////////////////////////////////
##                                                                  //
##  File name : gen_summary.pl                                      //
##  Author    : G. Andres Mancera                                   //
##  Course    : Advanced Verification with SystemVerilog OOP        //
##              Testbench - UCSC Silicon Valley Extension           //
##                                                                  //
##////////////////////////////////////////////////////////////////////
# Makefile usage
#
help:
	@echo "======================================================================";
	@echo "Usage:";
	@echo "  > make regress          - run all tests & generate summary";
	@echo "  > make summary          - generate summary";
	@echo "  > make coverage         - run regress and generate coverage report";
	@echo "  > make test_index       - run individual test [see list below]";
	@echo "  > make clean            - run CLEAN script";
	@echo "";
	@echo "    -----------------------------------------";
	@echo "    test_index      test_name";
	@echo "    -----------------------------------------";
	@echo "    t1              bringup_loopback";
	@echo "    t2              missing_eop";
	@echo "    t3              missing_sop";
	@echo "    t4              oversize_packet";
	@echo "    t5              undersize_packet";
	@echo "    t6              zero_ipg_packet";
	@echo "======================================================================";


# Makefile variables
#####################
VCS_CMD_RAND    = vcs -full64 +vcs+lic+wait -sverilog -R -override_timescale=1ps/1ps +ntb_random_seed_automatic
COV_OPTIONS     = -cm line+cond+branch+fsm+tgl -cm path -lca -cm_log ./coverage.log -cm_dir ./COVERAGE
DESIGN_FILES    = ../rtl/verilog/*.v +incdir+../rtl/include
TESTBENCH_FILES = ../testbench/xge_mac_interface.sv ../testbench/testbench.sv


# Makefile targets
#####################
regress: all_tests summary

all_tests: t1 t2 t3 t4 t5 t6

# Bogus targets -> map to real testnames
t1:bringup_loopback
t2:missing_eop
t3:missing_sop
t4:oversize_packet
t5:undersize_packet
t6:zero_ipg_packet

bringup_loopback:
	${VCS_CMD_RAND} ${DESIGN_FILES} ${TESTBENCH_FILES} ../testcases/$@/testcase.sv -l ../testcases/$@/vcs.log

missing_eop:
	${VCS_CMD_RAND} ${DESIGN_FILES} ${TESTBENCH_FILES} ../testcases/$@/testcase.sv -l ../testcases/$@/vcs.log

missing_sop:
	${VCS_CMD_RAND} ${DESIGN_FILES} ${TESTBENCH_FILES} ../testcases/$@/testcase.sv -l ../testcases/$@/vcs.log

oversize_packet:
	${VCS_CMD_RAND} ${DESIGN_FILES} ${TESTBENCH_FILES} ../testcases/$@/testcase.sv -l ../testcases/$@/vcs.log

undersize_packet:
	${VCS_CMD_RAND} ${DESIGN_FILES} ${TESTBENCH_FILES} ../testcases/$@/testcase.sv -l ../testcases/$@/vcs.log

zero_ipg_packet:
	${VCS_CMD_RAND} ${DESIGN_FILES} ${TESTBENCH_FILES} ../testcases/$@/testcase.sv -l ../testcases/$@/vcs.log

coverage:
	${VCS_CMD_RAND} ${DESIGN_FILES} ${TESTBENCH_FILES} ${COV_OPTIONS} ../testcases/bringup_loopback/testcase.sv -l ../testcases/bringup_loopback/vcs.log
	${VCS_CMD_RAND} ${DESIGN_FILES} ${TESTBENCH_FILES} ${COV_OPTIONS} ../testcases/missing_eop/testcase.sv -l ../testcases/missing_eop/vcs.log
	${VCS_CMD_RAND} ${DESIGN_FILES} ${TESTBENCH_FILES} ${COV_OPTIONS} ../testcases/missing_sop/testcase.sv -l ../testcases/missing_sop/vcs.log
	${VCS_CMD_RAND} ${DESIGN_FILES} ${TESTBENCH_FILES} ${COV_OPTIONS} ../testcases/oversize_packet/testcase.sv -l ../testcases/oversize_packet/vcs.log
	${VCS_CMD_RAND} ${DESIGN_FILES} ${TESTBENCH_FILES} ${COV_OPTIONS} ../testcases/undersize_packet/testcase.sv -l ../testcases/undersize_packet/vcs.log
	${VCS_CMD_RAND} ${DESIGN_FILES} ${TESTBENCH_FILES} ${COV_OPTIONS} ../testcases/zero_ipg_packet/testcase.sv -l ../testcases/zero_ipg_packet/vcs.log
	urg -lca -dir ./COVERAGE.vdb

summary:
	perl gen_summary.pl | tee summary.log

clean:
	rm -rf ../testcases/*/vcs.log \
	csrc \
	simv* \
	summary.log \
	ucli.key \
	vcdplus.vpd \
	*DVE* \
	*INCA* \
	transcript \
	work \
	vc_hdrs.h \
	coverage.log \
	COVERAGE.vdb \
	urgReport
