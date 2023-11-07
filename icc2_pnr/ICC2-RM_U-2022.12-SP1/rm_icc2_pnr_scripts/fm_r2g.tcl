## -----------------------------------------------------------------------------
## HEADER $Id: fm_r2g.tcl,v 1.2 2022/11/15 20:15:01 djyen Exp $
## HEADER_MSG Fusion Platform Methodology (FPM)
## HEADER_MSG Version 2020.09-SP5
## HEADER_MSG Copyright (c) 2021 Synopsys Inc. All rights reserved.
## HEADER_MSG Perforce Label: 
## -----------------------------------------------------------------------------

source ./rm_utilities/procs_global.tcl
rm_source -file ./rm_setup/design_setup.tcl
rm_source -file ./rm_setup/icc2_pnr_setup.tcl
rm_source -file ./rm_setup/fm_setup.tcl
rm_source -file ./rm_setup/header_fm.tcl
if { [info exists env(RM_VARFILE)] } {
  if { [file exists $env(RM_VARFILE)] } {
    rm_source -file $env(RM_VARFILE)
  } else {
    puts "RM-error: env(RM_VARFILE) specified but not found"
  }
}

## Synopsys Auto Setup Mode
set_app_var synopsys_auto_setup true

rm_source -file $TCL_USER_LIBRARY_SETUP_SCRIPT -optional -print TCL_USER_LIBRARY_SETUP_SCRIPT

rm_source -file $FM_APP_VAR_SETTINGS -optional -print FM_APP_VAR_SETTINGS

#################################################################################
## Read in the libraries
#################################################################################
set fm_link_library ${FM_LINK_LIBRARY}
foreach tech_lib "${fm_link_library}" {
  read_db -technology_library ${tech_lib}
}

if { $FM_SVF_FILES != "" } {
  puts "RM-info: set_svf $FM_SVF_FILES"
  set_svf $FM_SVF_FILES
}

if { $FM_REF_NDM_BLOCK=="" && $FM_REF_NETLIST=="" } {

  ## Read RTL design

  switch ${RTL_SOURCE_FORMAT} {
    sverilog {
      puts "RM-info: read_sverilog -r ${RTL_SOURCE_FILES} -work_library WORK"
      read_sverilog -r ${RTL_SOURCE_FILES} -work_library WORK
    }
    verilog {
      puts "RM-info: read_verilog -r ${RTL_SOURCE_FILES} -work_library WORK"
      read_verilog -r ${RTL_SOURCE_FILES} -work_library WORK
    }
    vhdl {
      puts "RM-info: read_vhdl -r ${RTL_SOURCE_FILES} -work_library WORK"
      read_vhdl -r ${RTL_SOURCE_FILES} -work_library WORK
    }
    script {
      # The following setting allows the read script to be found in the search path
      set_app_var sh_source_uses_search_path true
      rm_source -file ${FM_RTL_READ_SCRIPT}
    }
    default {
      puts "RM-error: Unknown RTL_SOURCE_FORMAT(${RTL_SOURCE_FORMAT})"
      exit
    }
  }

  ## Read child block power models
  foreach power_model $FM_REFERENCE_POWER_MODELS {
    puts "RM-info: read_power_model -r $power_model"
    read_power_model -r $power_model
  }
  
  set container "r"
  rm_source -file $FM_RETENTION_MODEL_FILE -optional -print FM_RETENTION_MODEL_FILE

  puts "RM-info: CONTAINER Reference built from RTL"
  puts "RM-info: set_top r:/WORK/${DESIGN_NAME} $FM_SET_TOP_RTL_ARGS"
  eval set_top r:/WORK/${DESIGN_NAME} $FM_SET_TOP_RTL_ARGS
  
  #################################################################################
  # For a UPF MV flow, read in the UPF file for the Reference Design
  #################################################################################
  
  if { ${UPF_MODE} != "none" } {
    set upf_files ${UPF_FILE}
    if { [ file exists [ which ${FM_UPF_UPDATE_SUPPLY_SET_FILE} ] ] } {
      lappend upf_files "${FM_UPF_UPDATE_SUPPLY_SET_FILE}"
    }
    puts "RM-info: load_upf -r \"${upf_files}\""
    load_upf -r "${upf_files}"
  }

} else {

  if { $FM_REF_NDM_BLOCK != "" } {
    puts "RM-info: read_ndm -r $FM_REF_NDM -block $DESIGN_NAME/$FM_REF_NDM_BLOCK"
    read_ndm -r $FM_REF_NDM -block $DESIGN_NAME/$FM_REF_NDM_BLOCK
  } else {
    puts "RM-info: read_verilog -r $FM_REF_NETLIST"
    read_verilog -r $FM_REF_NETLIST
  }

  ## Read child block power models
  foreach power_model $FM_REFERENCE_POWER_MODELS {
    puts "RM-info: read_power_model -r $power_model"
    read_power_model -r $power_model
  }

  set_top r:/WORK/${DESIGN_NAME}

  if { $FM_REF_NDM_BLOCK == "" } {
    switch ${UPF_MODE} {
      prime {
        puts "RM-info: load_upf -r $FM_REF_UPF_FILE"
        load_upf -r $FM_REF_UPF_FILE
      }
      golden {
        puts "RM-info: load_upf -r -strict_check false -target dc_pg_netlist $FM_REF_UPF_FILE -supplemental $FM_REF_SUPPLEMENTAL_UPF_FILE"
        load_upf -r -strict_check false -target dc_pg_netlist $FM_REF_UPF_FILE -supplemental $FM_REF_SUPPLEMENTAL_UPF_FILE
      }
      none {
        ## NOP
      }
    }
  }
}

rm_source -file $FM_POST_REFERENCE_ADJUST_SCRIPT -optional -print FM_POST_REFERENCE_ADJUST_SCRIPT

#################################################################################
## Read in the Implementation Design from FC-RM results
#################################################################################

if { $FM_IMP_NDM_BLOCK != "" } {
  puts "RM-info: read_ndm -i $FM_IMP_NDM -block $DESIGN_NAME/$FM_IMP_NDM_BLOCK"
  read_ndm -i $FM_IMP_NDM -block $DESIGN_NAME/$FM_IMP_NDM_BLOCK
} else {
  puts "RM-info: read_verilog -i $FM_IMP_NETLIST"
  read_verilog -i $FM_IMP_NETLIST
}

## Read child block power models
foreach power_model $FM_IMPLEMENTATION_POWER_MODELS {
  puts "RM-info: read_power_model -i $power_model"
  read_power_model -i $power_model
}

## For when reference is RTL
if { $FM_REF_NDM_BLOCK=="" && $FM_REF_NETLIST=="" } {
  puts "RM-info: Loading Verilog retention models"
  set container "i"
  rm_source -file $FM_RETENTION_MODEL_FILE -optional -print FM_RETENTION_MODEL_FILE
}

set_top i:/WORK/${DESIGN_NAME}

#################################################################################
## For a UPF MV flow, read in the UPF file for the Implementation Design
#################################################################################

if { $FM_IMP_NDM_BLOCK == "" && ${UPF_MODE} != "none" } {
  switch ${UPF_MODE} {
    prime {
      puts "RM-info: load_upf -i $FM_IMP_UPF_FILE -target dc_netlist"
      load_upf -i $FM_IMP_UPF_FILE -target dc_netlist
    }
    golden {
      puts "RM-info: load_upf -i -strict_check false -target dc_netlist $FM_IMP_UPF_FILE -supplemental $FM_IMP_SUPPLEMENTAL_UPF_FILE"
      load_upf -i -strict_check false -target dc_netlist $FM_IMP_UPF_FILE -supplemental $FM_IMP_SUPPLEMENTAL_UPF_FILE
    }
    none {
      ## NOP
    }
  }
}

## Loading Formality COnstraints
rm_source -file $FM_CONSTRAINTS_FILE -optional -print "FM_CONSTRAINTS_FILE"

#################################################################################
## Note in using the UPF MV flow with Formality:
#
## By default Formality verifies low power designs with all UPF supplies
## constrained to their ON state.  For FC-RM,
## is it recommended to set this variable to false instead.

set_app_var verification_force_upf_supplies_on false

#################################################################################

#################################################################################
## Match compare points and report unmatched points
#################################################################################

match

report_unmatched_points > $REPORTS_DIR/${DESIGN_NAME}.fmv_unmatched_points.rpt

rm_source -file $FM_POST_MATCH_ADJUST_SCRIPT -optional -print FM_POST_MATCH_ADJUST_SCRIPT

#################################################################################
## Verify and Report
#
## If the verification is not successful, the session will be saved and reports
## will be generated to help debug the failed or inconclusive verification.
#################################################################################

if { ![ verify ] } {
  save_session -replace $REPORTS_DIR/${DESIGN_NAME}
  report_failing_points > $REPORTS_DIR/${DESIGN_NAME}.fmv_failing_points.rpt
  report_aborted > $REPORTS_DIR/${DESIGN_NAME}.fmv_aborted_points.rpt
  # Use analyze_points to help determine the next step in resolving verification
  # issues. It runs heuristic analysis to determine if there are potential causes
  # other than logical differences for failing or hard verification points.
  analyze_points -all > $REPORTS_DIR/${DESIGN_NAME}.fmv_analyze_points.rpt
  set fm_passed FALSE
} else {
  set fm_passed TRUE
}

## Save power models for use in hierarchical verification.
if { $FM_GENERATE_POWER_MODEL } {
  ## These alternate models reflect svf processing which may cause some linking issues
  write_power_model -r $OUTPUTS_DIR/$DESIGN_NAME.r -replace
  write_power_model -i $OUTPUTS_DIR/$DESIGN_NAME.i -replace
}

exit

## -----------------------------------------------------------------------------
## End of File
## -----------------------------------------------------------------------------
