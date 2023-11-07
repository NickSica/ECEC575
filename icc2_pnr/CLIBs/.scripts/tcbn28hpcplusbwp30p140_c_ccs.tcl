set NDM_LIBS {}
set FRAME_LIBS {/home/sica/ECEC575/icc_pnr/icc2_frame/ndm/ibex_top.mw_frame_only.ndm}
set LEF_FILES {}
set DB_FILES {/home/tech/TSMC28/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn28hpcplusbwp30p140_180a/tcbn28hpcplusbwp30p140tt0p9v25c_ccs.db /home/tech/TSMC28/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn28hpcplusbwp30p140_180a/tcbn28hpcplusbwp30p140ssg0p9v0c_ccs.db /home/tech/TSMC28/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn28hpcplusbwp30p140_180a/tcbn28hpcplusbwp30p140ffg0p99v0c_ccs.db}
set TECH_FILE "/home/tech/TSMC28/APR_Tech/Synopsys/tn28clpr002s1_1_9_1a/PRTF_ICC_28nm_Syn_V19_1a/tsmcn28_9lm6X1Z1UUTRDL.tf"

set_app_options -name lib.workspace.create_cached_lib -value true
#suppress_messages

set_app_options -name lib.workspace.allow_read_aggregate_lib -value true
create_workspace tcbn28hpcplusbwp30p140_c_ccs -scale_factor 10000
foreach frame $FRAME_LIBS {
  read_ndm $frame
}
read_db $DB_FILES
process_workspaces -check_options {-allow_missing} -force -directory CLIBs -output tcbn28hpcplusbwp30p140_c_ccs.ndm
