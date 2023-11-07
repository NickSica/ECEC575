## -----------------------------------------------------------------------------
## HEADER $Id: dft_ports.tcl,v 1.1 2022/10/11 17:33:37 hcchien Exp $
## HEADER_MSG Fusion Platform Methodology (FPM)
## HEADER_MSG Version 2020.09-SP1
## HEADER_MSG Copyright (c) 2020 Synopsys Inc. All rights reserved.
## HEADER_MSG Perforce Label: 
## -----------------------------------------------------------------------------

## DESCRIPTION:
## * misc post elaboration processing
## -----------------------------------------------------------------------------

## -----------------------------------------------------------------------------
## Add DFT ports
## -----------------------------------------------------------------------------

# Depending on DFT_CONFIGURATION, create the required test mode signals, test modes, and assign mode encoding

puts "RM-info: Working on DFT_CONFIGRUATION = $DFT_CONFIGURATION"
switch $DFT_CONFIGURATION {

  FC-CODEC_COREWRAP_TP_SCAN {

    if { [ get_ports -quiet snps_test_mode*  ] == {} } {
    # Test mode ports for Test Encoding
      create_port snps_test_mode_0 -direction in
      create_port snps_test_mode_1 -direction in
      create_port snps_test_mode_2 -direction in
      create_port snps_test_mode_3 -direction in
    }

    # Create scan ports for internal chains
    # Scan signals
    # Pick up internal scan chain count from "variables.tcl" DFT_INTERNAL_SCAN_CHAIN_COUNT variable
    for { set i 1 } { $i <= ${DFT_INTERNAL_SCAN_CHAIN_COUNT} } { incr i } {
      if { [ get_ports -quiet snps_scan_in_$i ] == {} } {
        create_port snps_scan_in_$i -direction in
      }
      if { [ get_ports -quiet snps_scan_out_$i ] == {} } {
        create_port snps_scan_out_$i -direction out
      }
    }
    
    # Scan Enable for internal chains
    if { [ get_ports -quiet snps_scan_shift_en ] == {} } {
      create_port snps_scan_shift_en -direction in
    }
    # # If needed, Scan Enable for Clock Gating cells
    # if { [ get_ports -quiet snps_scan_shift_en_cg ] == {} } {
    #   create_port snps_scan_shift_en_cg -direction in
    # }

    # Signals for Codec
    # DFTMAX Ultra: clocks for codec
    # Use same clock for compressor and decompressor
    # User can choose to use existing clock signals
    create_port snps_comp_clk -direction in
    
    # If you also enable Shift Power Control (SPC), create SPC-related signals
    
    # if { [ get_ports -quiet snps_spc_disable ] == {} } {
    #   create_port snps_spc_disable -direction in
    # }
    # 
    # # Assume 1 SPC-in, 1 SPC-out
    # for { set i 1 } { $i <= 1 } { incr i } {
    #   if { [ get_ports -quiet snps_spc_in$i ] == {} } {
    #     create_port snps_spc_in_$i -direction in
    #   }
    #   if { [ get_ports -quiet snps_spc_out$i ] == {} } {
    #     create_port snps_spc_out_$i -direction out
    #   }
    # }
    
    # Pipelined scan data signals
    # Can use existing clock, or can use a dedicated clock
    # This will be shared with both head pipeline and tail pipeline
##    create_port snps_pipelined_scan_clock
    
    # Core wrapper signals
    
    # Assume 4 input/output for wrapper chains
    # Pick up core wrapper chain count from "variables.tcl" DFT_WRAPPER_CHAIN_COUNT variable
    # Check if you perfer separate Input and Output core wrapper chains
    for { set i 1 } { $i <= ${DFT_WRAPPER_CHAIN_COUNT} } { incr i } {
      if { [ get_ports -quiet snps_core_wrap_scan_in_$i ] == {} } {
        create_port snps_core_wrap_scan_in_$i -direction in
      }
      if { [ get_ports -quiet snps_core_wrap_scan_out_$i ] == {} } {
        create_port snps_core_wrap_scan_out_$i -direction out
      }
    }
    
    # Wrapper Chain Shift Enable
    if { [ get_ports -quiet snps_core_wrap_shift_en ] == {} } {
      create_port snps_core_wrap_shift_en -direction in
    }
    
    # Alternatively, user may choose separate input and output wrapper shift enable
    ## if { [ get_ports -quiet snps_core_wrap_input_shift_en ] == {} } {
    ##   create_port snps_core_wrap_input_shift_en -direction in
    ## }
    ## if { [ get_ports -quiet snps_core_wrap_output_shift_en ] == {} } {
    ##   create_port snps_core_wrap_output_shift_en -direction in
    ## }
    
    # Test Point signals
    # Test mode port for Test Points
    create_port snps_test_mode_tp -direction in
    # Test Point clocks
    create_port snps_test_point_clk -direction in
    
  }

  THIRDPARTY-CODEC_COREWRAP-MM_TP_SCAN {

    puts "RM-error: The DFT_CONFIGURATION \"THIRDPARTY-CODEC_COREWRAP-MM_TP_SCAN\" is not directly operational. Make a local copy to customize"

    # NOTE: This configuration is provided as a template but depends on block specifics. Make a copy of this and the scan_configuration.fc.tcl file
    # and configure DFT_PORTS_FILE and DFT_SETUP_FILE to use the customized version.

    # # Note: for a design containing third-party codec, test mode, scan in, scan out and other DFT signals should already be available
    # #   so there is no need to run create_port command to create additional top level ports for DFT
    # # In case you still need to create ports for DFT, use the following commands

    # if { [ get_ports -quiet snps_test_mode*  ] == {} } {
    # # Test mode ports for Test Encoding
    #   create_port snps_test_mode_0 -direction in
    #   create_port snps_test_mode_1 -direction in
    #   create_port snps_test_mode_2 -direction in
    # }

    # # Create scan ports for internal chains

    # # Scan signals
    # # Pick up internal scan chain count from "variables.tcl" DFT_INTERNAL_SCAN_CHAIN_COUNT variable
    # for { set i 1 } { $i <= ${DFT_INTERNAL_SCAN_CHAIN_COUNT} } { incr i } {
    #   if { [ get_ports -quiet snps_scan_in_$i ] == {} } {
    #     create_port snps_scan_in_$i -direction in
    #   }
    #   if { [ get_ports -quiet snps_scan_out_$i ] == {} } {
    #     create_port snps_scan_out_$i -direction out
    #   }
    # }
    # 
    # # Scan Enable for internal chains
    # if { [ get_ports -quiet snps_scan_shift_en ] == {} } {
    #   create_port snps_scan_shift_en -direction in
    # }
    # # If needed, Scan Enable for Clock Gating cells
    # if { [ get_ports -quiet snps_scan_shift_en_cg ] == {} } {
    #   create_port snps_scan_shift_en_cg -direction in
    # }

    # 
    # # Core wrapper signals
    # 
    # # Assume 4 input/output for wrapper chains
    # # Pick up core wrapper chain count from "variables.tcl" DFT_WRAPPER_CHAIN_COUNT variable
    # # Check if you perfer separate Input and Output core wrapper chains
    # for { set i 1 } { $i <= ${DFT_WRAPPER_CHAIN_COUNT} } { incr i } {
    #   if { [ get_ports -quiet snps_core_wrap_scan_in_$i ] == {} } {
    #     create_port snps_core_wrap_scan_in_$i -direction in
    #   }
    #   if { [ get_ports -quiet snps_core_wrap_scan_out_$i ] == {} } {
    #     create_port snps_core_wrap_scan_out_$i -direction out
    #   }
    # }
    # 
    # # Wrapper Chain Shift Enable
    # if { [ get_ports -quiet snps_core_wrap_shift_en ] == {} } {
    #   create_port snps_core_wrap_shift_en -direction in
    # }
    # 
    # # Alternatively, user may choose separate input and output wrapper shift enable
    # ## if { [ get_ports -quiet snps_core_wrap_input_shift_en ] == {} } {
    # ##   create_port snps_core_wrap_input_shift_en -direction in
    # ## }
    # ## if { [ get_ports -quiet snps_core_wrap_output_shift_en ] == {} } {
    # ##   create_port snps_core_wrap_output_shift_en -direction in
    # ## }
    # 
    # # Test Point signals
    # # Test mode port for Test Points
    # create_port snps_test_mode_tp -direction in
    # # Test Point clocks
    # create_port snps_test_point_clk -direction in
    

  }


  TP_SCAN {

    # Create scan ports for internal chains
    # Scan signals
    # Pick up internal scan chain count from "variables.tcl" DFT_INTERNAL_SCAN_CHAIN_COUNT variable
    for { set i 1 } { $i <= ${DFT_INTERNAL_SCAN_CHAIN_COUNT} } { incr i } {
      if { [ get_ports -quiet snps_scan_in_$i ] == {} } {
        create_port snps_scan_in_$i -direction in
      }
      if { [ get_ports -quiet snps_scan_out_$i ] == {} } {
        create_port snps_scan_out_$i -direction out
      }
    }
    
    # Scan Enable for internal chains
    if { [ get_ports -quiet snps_scan_shift_en ] == {} } {
      create_port snps_scan_shift_en -direction in
    }
    # If needed, Scan Enable for Clock Gating cells
    if { [ get_ports -quiet snps_scan_shift_en_cg ] == {} } {
      create_port snps_scan_shift_en_cg -direction in
    }
    
    # Test Point signals
    # Note: this test mode signal is to switch between function and test
    if { [ get_ports -quiet snps_test_mode*  ] == {} } {
      create_port snps_test_mode_tp -direction in
    }
    # Test point clocks
    create_port snps_test_point_clk -direction in

  }

  SCAN {

    # Create scan ports for internal chains
    # Scan signals
    # Pick up internal scan chain count from "variables.tcl" DFT_INTERNAL_SCAN_CHAIN_COUNT variable
    for { set i 1 } { $i <= ${DFT_INTERNAL_SCAN_CHAIN_COUNT} } { incr i } {
      if { [ get_ports -quiet snps_scan_in_$i ] == {} } {
        create_port snps_scan_in_$i -direction in
      }
      if { [ get_ports -quiet snps_scan_out_$i ] == {} } {
        create_port snps_scan_out_$i -direction out
      }
    }
    
    # Scan Enable for internal chains
    if { [ get_ports -quiet snps_scan_shift_en ] == {} } {
      create_port snps_scan_shift_en -direction in
    }
    # If needed, Scan Enable for Clock Gating cells
    if { [ get_ports -quiet snps_scan_shift_en_cg ] == {} } {
      create_port snps_scan_shift_en_cg -direction in
    }

  }

  default {
    puts "RM-error: invalid DFT_CONFIGURATION specified : $DFT_CONFIGURATION"  
  }
}

## -----------------------------------------------------------------------------
## End of File
## -----------------------------------------------------------------------------
