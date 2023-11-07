## -----------------------------------------------------------------------------
## HEADER $Id: scan_configuration.fc.tcl,v 1.1 2022/10/11 17:33:38 hcchien Exp $
## HEADER_MSG Fusion Platform Methodology (FPM)
## HEADER_MSG Version 2020.09-SP2
## HEADER_MSG Copyright (c) 2020 Synopsys Inc. All rights reserved.
## HEADER_MSG Perforce Label: 
## -----------------------------------------------------------------------------

## -----------------------------------------------------------------------------
## DESCRIPTION:
## * scan config info
## -----------------------------------------------------------------------------

## -----------------------------------------------------------------------------
## Tool variables.
## -----------------------------------------------------------------------------
#

set_app_options -name dft.scan.enable_general_multimode_support -value true

set_app_options -name dft.test_default_period -value 100
set_app_options -name dft.test_default_delay -value 0
set_app_options -name dft.test_default_strobe -value 40

## -----------------------------------------------------------------------------
## Configuration and signal information.
## -----------------------------------------------------------------------------
## Each DFT_CONFIGURATION branch provides setup of test modes, dft signals, and 
## compression configuration. 
##
## Most of the following flows (with the exception of THIRDPARTY-CODEC_COREWRAP-MM_TP_SCAN) 
## utilize top level ports as DFT signals. These ports should either already exist in your 
## RTL, or have been created using the DFT_PORTS_FILE (dft_ports.tcl) script.
## Customization for block specifics:
## Users may need to user dft signal "hookup" from internal pins. This will require
## making a copy of this OOTB scan configuration file for use as a template for 
## block-specific customizations. Note that the THIRDPARTY-CODEC_COREWRAP-MM_TP_SCAN uses
## internal pins and offers some examples of the command syntax.

puts "RM-info: Configuring for DFT_CONFIGURATION = $DFT_CONFIGURATION"

switch $DFT_CONFIGURATION {

  FC-CODEC_COREWRAP_TP_SCAN {

    # DFT signals
    # Define Test Mode signals
    set_dft_signal -type TestMode -port snps_test_mode_0 -view spec 
    set_dft_signal -type TestMode -port snps_test_mode_1 -view spec 
    set_dft_signal -type TestMode -port snps_test_mode_2 -view spec 
    set_dft_signal -type TestMode -port snps_test_mode_3 -view spec 

    define_test_mode snps_scan   -usage scan             -encoding {snps_test_mode_0 1 snps_test_mode_1 0 snps_test_mode_2 0 snps_test_mode_3 0}
    define_test_mode snps_comp   -usage scan_compression -encoding {snps_test_mode_0 0 snps_test_mode_1 1 snps_test_mode_2 0 snps_test_mode_3 0}
    define_test_mode snps_wrp_if -usage wrp_if           -encoding {snps_test_mode_0 0 snps_test_mode_1 0 snps_test_mode_2 1 snps_test_mode_3 0}
    define_test_mode snps_wrp_of -usage wrp_of           -encoding {snps_test_mode_0 0 snps_test_mode_1 0 snps_test_mode_2 0 snps_test_mode_3 1}

    reset_test_mode

    # Existing clocks in the design to be used for Test DRC
    foreach clk $DFT_CLOCK_LIST {
      puts "RM-info: set_dft_signal -type ScanClock -port $clk -timing {45 55} -view existing_dft"
      set_dft_signal -type ScanClock -port $clk -timing {45 55} -view existing_dft
    }
    
    # Existing asynchronous set/reset signals in the design to be used for Test DRC
    foreach item $DFT_RESET_INFO {
      set signal [lindex $item 0]
      set sense [lindex $item 1]
      puts "RM-info: set_dft_signal -type Reset -active_state $sense -port $signal -view existing_dft"
      set_dft_signal -type Reset -active_state $sense -port $signal -view existing_dft
    }
    
    # Other existing constant signals that are needed for Test DRC
    foreach item $DFT_CONSTANT_INFO {
      set signal [lindex $item 0]
      set sense [lindex $item 1]
      puts "RM-info: set_dft_signal -type Constant -active_state $sense -port $signal -view existing_dft"
      set_dft_signal -type Constant -active_state $sense -port $signal -view existing_dft
    }
    
    # Scan In/Out signal for scan stitching 
    set_dft_signal -type ScanDataIn -port snps_scan_in_* -view spec -test_mode {snps_scan snps_comp snps_wrp_if}
    set_dft_signal -type ScanDataOut -port snps_scan_out_* -view spec -test_mode {snps_scan snps_comp snps_wrp_if}
    
    # Scan Enable signals
    set_dft_signal -type ScanEnable -port snps_scan_shift_en -view spec 
    # If necessary, specify Scan Enable signal to connect to Clock Gating cells. By default the same signal will be used for
    #   Scan registers and Clock Gating cells
    # set_dft_signal -type ScanEnable -port snps_scan_shift_en -view spec -usage scan
    # set_dft_signal -type ScanEnable -port snps_scan_shift_en_cg -view spec -usage clock_gating

    # Compresssion: Codec clock signal for streaming compression (DFTMAX Ultra)
    # You can choose an existing or a dedicated clock signal (like this example)
    set_dft_signal -type ScanClock -port snps_comp_clk -timing {45 55} -view existing_dft
    
    # Core Wrapper In/Out signals
    # Check that if you want these availbale in wrp_if mode 
    set_dft_signal -type ScanDataIn -port snps_core_wrap_scan_in_* -view spec -test_mode {snps_wrp_if snps_wrp_of}
    set_dft_signal -type ScanDataOut -port snps_core_wrap_scan_out_* -view spec -test_mode {snps_wrp_if snps_wrp_of}
     
    # Wrapper shift enable
    set_dft_signal -type wrp_shift -port snps_core_wrap_shift_en -view spec -test_mode {snps_wrp_if snps_wrp_of}
    # Specify the following if you have separate input and output wrapper shift enable
    # set_dft_signal -type wrp_shift -port snps_core_wrap_input_shift_en -view spec -test_mode {snps_wrp_of}
    # set_dft_signal -type wrp_shift -port snps_core_wrap_output_shift_en  -view spec -test_mode {snps_wrp_of}
    
    # Test Mode signal for test points
    # Note this switches between Functional and test
    set_dft_signal -type TestMode -port snps_test_mode_tp -view spec
    # Clock signal for test points
    # 
    
    # Configuring Codec inserton
    # Note that Codec insertion requires access to TestMAX DFT product
    # Use DFT_INTERNAL_SCAN_CHAIN_COUNT and DFT_COMPRESSION_SCAN_CHAIN_COUNT from variables.tcl
    set cmd "set_scan_compression_configuration \
       -input ${DFT_INTERNAL_SCAN_CHAIN_COUNT} \
       -output ${DFT_INTERNAL_SCAN_CHAIN_COUNT} \
       -chain_count ${DFT_COMPRESSION_SCAN_CHAIN_COUNT} \
       -test_mode snps_comp"
    puts "RM-info: $cmd"
    eval $cmd
    
    # If enable Shift Power Control, specify the necessary signals. Also you will need to specify set_scan_path for the SPC chain
    # Use DFT_INTERNAL_SCAN_CHAIN_COUNT and DFT_COMPRESSION_SCAN_CHAIN_COUNT from variables.tcl
    ## set_scan_compression_configuration \
    ##    -input ${DFT_INTERNAL_SCAN_CHAIN_COUNT} \
    ##    -output ${DFT_INTERNAL_SCAN_CHAIN_COUNT} \
    ##    -chain_count ${DFT_COMPRESSION_SCAN_CHAIN_COUNT} \
    ##    -test_mode snps_comp \
    ##    -spc_disable snps_spc_disable 
    
    
    # For DFTMAX Ultra, specify -streaming true and specify clock signal for codec
    # Use DFT_INTERNAL_SCAN_CHAIN_COUNT and DFT_COMPRESSION_SCAN_CHAIN_COUNT from variables.tcl
    ## set_scan_compression_configuration \
    ##    -streaming enable \
    ##    -input ${DFT_INTERNAL_SCAN_CHAIN_COUNT} \
    ##    -output ${DFT_INTERNAL_SCAN_CHAIN_COUNT} \
    ##    -chain_count ${DFT_COMPRESSION_SCAN_CHAIN_COUNT} \
    ##    -clock snps_comp_clk \
    ##    -test_mode snps_comp
    
    # Configuring Core Wrapping
    # Global configuration
    set_wrapper_configuration -mix_cells true  -test_mode snps_wrp_if
    set_wrapper_configuration -mix_cells true  -test_mode snps_wrp_of
    # Assume core wrapper chain counts needed for snps_wrp_if and snps_wrp_of modes
    set_wrapper_configuration -chain_count ${DFT_WRAPPER_CHAIN_COUNT} -test_mode snps_wrp_if
    set_wrapper_configuration -chain_count ${DFT_WRAPPER_CHAIN_COUNT} -test_mode snps_wrp_of
    
    # Configuring test points
    # Globally enable test points
    set_dft_configuration -testability enable
    # Recommend random resistant, untestable logic and user-defined test points
    # other options available are -max_test_points  and -test_points_per_scan_cell
    # Tool defaults to 8 test points per scan cell. Paste the following option to each command and adjust
    #  -test_points_per_scan_cell 8
    set_testability_configuration -target random_resistant \
      -clock_signal clk \
      -control_signal snps_test_mode_tp 

    
    set_testability_configuration -target untestable_logic \
      -clock_signal clk \
      -control_signal snps_test_mode_tp 


    rm_source -file $DFT_TEST_POINT_FILE -optional -print DFT_TEST_POINT_FILE

    # Configuring Scan
    # Chain counts for each scan mode
    set_scan_configuration -chain_count ${DFT_INTERNAL_SCAN_CHAIN_COUNT} -clock_mixing mix_clocks -test_mode snps_scan
    set_scan_configuration -chain_count ${DFT_INTERNAL_SCAN_CHAIN_COUNT} -clock_mixing mix_clocks -test_mode snps_wrp_if
    
    # Configuring Scan
    # Control mixing of clocks and power domains for wrapper chains. 
    set_scan_configuration -clock_mixing mix_clocks -test_mode snps_wrp_of
    set_scan_configuration -power_domain_mixing true -test_mode snps_wrp_of
    
  }
  THIRDPARTY-CODEC_COREWRAP-MM_TP_SCAN {

    puts "RM-error: The DFT_CONFIGURATION \"THIRDPARTY-CODEC_COREWRAP-MM_TP_SCAN\" is not directly operational. Make a local copy to customize"

    # NOTE: This configuration is provided as a template but depends on block specifics, like internal pins. Make a copy of this and the dft_ports.tcl file
    # and configure DFT_PORTS_FILE and DFT_SETUP_FILE to use the customized version.

    # # Usage of internal pins flow
    # # Note: for a design containing third-party codec, most DFT signals originate from an internal pin.
    # #  You will need to enable the DFT internal pin flow using the set_dft_drc_configuration -internal_pins enable option
    # 
    # set_dft_drc_configuration -internal_pins enable
    # 
    # # DFT signals
    # # Define Test Mode signals that originate from a hierarchical pin
    # set_dft_signal -type TestMode -hookup_pin  <hierarchical_block>/snps_test_mode_0 -view spec 
    # set_dft_signal -type TestMode -hookup_pin  <hierarchical_block>/snps_test_mode_1 -view spec 
    # set_dft_signal -type TestMode -hookup_pin  <hierarchical_block>/snps_test_mode_2 -view spec 
    # 
    # define_test_mode snps_scan   -usage scan   -encoding {<hierarchical_block>/snps_test_mode_0 1 <hierarchical_block>/snps_test_mode_1 0 <hierarchical_block>/snps_test_mode_2 0 }
    # define_test_mode snps_comp   -usage wrp_if -encoding {<hierarchical_block>/snps_test_mode_0 0 <hierarchical_block>/snps_test_mode_1 1 <hierarchical_block>/snps_test_mode_2 0 }
    # define_test_mode snps_wrp_of -usage wrp_of -encoding {<hierarchical_block>/snps_test_mode_0 0 <hierarchical_block>/snps_test_mode_1 0 <hierarchical_block>/snps_test_mode_2 1 }
    # reset_test_mode
    # 
    # # Note: DFT_MODES_LIST can be derived from "all_test_mode" command
    # #    set DFT_MODES_LIST [list snps_scan snps_comp snps_wrp_if snps_wrp_of]

    # # Existing clocks in the design to be used for Test DRC
    # set_dft_signal -type ScanClock -port clk -timing {45 55} -view existing_dft
    # # Use the following if you have a clock signal that originates from a hierarchical block
    # set_dft_signal -type ScanClock -hookup_pin <hierarchical_block>/clk -timing {45 55} -view existing_dft
    # 
    # # Existing asynchronous set/reset signals in the design to be used for Test DRC
    # set_dft_signal -type Reset -active_state 0 -port reset_n -view existing_dft
    # # Use the following if you have a set/reset signal that originates from a hierarchical block
    # set_dft_signal -type Reset -active_state 0 -hookup_pin <hierarchical_block>/reset_n -view existing_dft
    # 
    # # Other existing constant signals that are needed for Test DRC
    # set_dft_signal -type Constant -active_state 1 -port scan_mode -view existing_dft
    # # Use the following if you have a Constant signal that originates from a hierarchical block
    # set_dft_signal -type Constant -active_state 1 -port <hierarchical_block>/scan_mode -view existing_dft
    # 
    # 
    # # Scan In and Scan Out signals for scan chains
    # # Define scan in and scan out signals that originate from a hierarchical block
    # set_dft_signal -type ScanDataIn -hookup_pin <hierarchical_block>/snps_scan_in_* -view spec -test_mode {snps_scan snps_comp}
    # set_dft_signal -type ScanDataOut -hookup_pin <hierarchical_block>/snps_scan_out_* -view spec -test_mode {snps_scan snps_comp}
    # 
    # 
    # # Scan Enable signals
    # # Define scan enable signals that originate from a hierarchical block
    # set_dft_signal -type ScanEnable -hookup_pin <hierarchical_block>/snps_scan_shift_en -view spec 
    # # If necessary, specify Scan Enable signal to connect to Clock Gating cells. By default the same signal will be used for
    # #   Scan registers and Clock Gating cells
    # # set_dft_signal -type ScanEnable -hookup_pin <hierarchical_block>/snps_scan_shift_en -view spec -usage scan
    # # set_dft_signal -type ScanEnable -hookup_pin <hierarchical_block>/snps_scan_shift_en_cg -view spec -usage clock_gating
    # 
    # 
    # # Core Wrapper chain Input Output signals
    # # Usually core wrapper input and output signals are only needed in wrp_of usage, snps_wrp_of mode
    # # Check that if you want these available in snps_comp mode (i.e. have wrapper chains active during compression mode)
    # set_dft_signal -type ScanDataIn -hookup_pin <hierarchical_block>/snps_core_wrap_scan_in_* -view spec -test_mode {snps_comp snps_wrp_of}
    # set_dft_signal -type ScanDataOut -hookup_pin <hierarchical_block>/snps_core_wrap_scan_out_* -view spec -test_mode {snps_comp snps_wrp_of}
    #  
    # # Wrapper shift enable
    # set_dft_signal -type wrp_shift -hookup_pin <hierarchical_block>/snps_core_wrap_shift_en -view spec -test_mode {snps_wrp_of}
    # # Specify the following if you have separate input and output wrapper shift enable
    # set_dft_signal -type input_wrp_shift -port <hierarchical_block>/snps_core_wrap_input_shift_en -view spec -test_mode {snps_wrp_of}
    # set_dft_signal -type output_wrp_shift -port <hierarchical_block>/snps_core_wrap_output_shift_en  -view spec -test_mode {snps_wrp_of}
    # 
    # # Test Mode signal for test points
    # # Note this switches between Functional and test
    # set_dft_signal -type TestMode -port snps_test_mode_tp -view spec 
    # # Clock signal for test points
    # # Define this as Scan clock
    # set_dft_signal -type ScanClock -port snps_test_point_clk -view existing_dft -timing {45 55}
    # # 
    # 
    # 
    # # settings for each DFT capability
    # 
    # # Configuring Core Wrapping
    # # Global configuration
    # # Enable maximize_reuse
    # set_wrapper_configuration -reuse_threshold 0
    # # Test mode-specific
    # # mix cells is default false; only enable mix cells if you want to optimize chain count/balancing later
    # # set_wrapper_configuration -mix_cells true -test_mode snps_comp
    # # set_wrapper_configuration -mix_cells true -test_mode snps_wrp_of
    # # Assume core wrapper chain counts needed for snps_comp and snps_wrp_of modes
    # set_wrapper_configuration -chain_count ${WRAPPER_CHAIN_COUNT} -test_mode snps_comp
    # set_wrapper_configuration -chain_count ${WRAPPER_CHAIN_COUNT} -test_mode snps_wrp_of
    # 
    # 
    # 
    # # Configuring test points
    # # Globally enable test points feature
    # set_dft_configuration -testability enable
    # 
    # 
    # # Recommend random resistant, untestable logic and user-defined test points
    # # other options available are -max_test_points  and -test_points_per_scan_cell
    # # Tool defaults to 8 test points per scan cell. Paste the following option to each command and adjust
    # #  -test_points_per_scan_cell 8
    # # Note that insertion of random resistant and untestable logic test points require access to TestMAX Advisor product
    # set_testability_configuration -target random_resistant \
    # -clock_signal snps_test_point_clk \
    # -control_signal snps_test_mode_tp 
    # 
    # 
    # set_testability_configuration -target untestable_logic \
    # -clock_signal snps_test_point_clk \
    # -control_signal snps_test_mode_tp 
    # 
    # 
    # rm_source -file $DFT_TEST_POINT_FILE -optional -print DFT_TEST_POINT_FILE
    # 
    # 
    # 
    # # Configuring Scan
    # # Control mixing of clocks and power domains for wrapper chains. 
    # set_scan_configuration -clock_mixing mix_clocks -test_mode wrp_of
    # set_scan_configuration -power_domain_mixing true -test_mode wrp_of
    # 
    # # Chain counts for scan modes
    # set_scan_configuration -chain_count ${INTERNAL_SCAN_CHAIN_COUNT} -clock_mixing mix_clocks -test_mode snps_scan
    # set_scan_configuration -chain_count ${INTERNAL_SCAN_CHAIN_COUNT} -clock_mixing mix_clocks -test_mode snps_wrp_if
    
    


  }
  TP_SCAN {

    # Existing clocks in the design to be used for Test DRC
    foreach clk $DFT_CLOCK_LIST {
      set_dft_signal -type ScanClock -port $clk -timing {45 55} -view existing_dft
    }
    
    # Existing asynchronous set/reset signals in the design to be used for Test DRC
    foreach item $DFT_RESET_INFO {
      set signal [lindex $item 0]
      set sense [lindex $item 1]
      set_dft_signal -type Reset -active_state $sense -port $signal -view existing_dft
    }
    
    # Other existing constant signals that are needed for Test DRC
    foreach item $DFT_CONSTANT_INFO {
      set signal [lindex $item 0]
      set sense [lindex $item 1]
      set_dft_signal -type Constant -active_state $sense -port $signal -view existing_dft
    }
    
    # Scan In/Out signal for scan stitching 
    set_dft_signal -type ScanDataIn -port snps_scan_in_* -view spec -test_mode {snps_scan snps_comp snps_wrp_if}
    set_dft_signal -type ScanDataOut -port snps_scan_out_* -view spec -test_mode {snps_scan snps_comp snps_wrp_if}
    
    
    # Scan Enable signals
    set_dft_signal -type ScanEnable -port snps_scan_shift_en -view spec 
    # If necessary, specify Scan Enable signal to connect to Clock Gating cells. By default the same signal will be used for
    #   Scan registers and Clock Gating cells
    # set_dft_signal -type ScanEnable -port snps_scan_shift_en -view spec -usage scan
    # set_dft_signal -type ScanEnable -port snps_scan_shift_en_cg -view spec -usage clock_gating
    

    # Test Mode signal for test points
    # Note this switches between Functional and test
    set_dft_signal -type TestMode -port snps_test_mode_tp -view spec 
    # Clock signal for test points
    # Define this as Scan clock
    set_dft_signal -type ScanClock -port snps_test_point_clk -view existing_dft -timing {45 55}
    # 
    
    
    # Configuring test points
    # Globally enable test points feature
    set_dft_configuration -testability enable
    
    
    # Recommend random resistant, untestable logic and user-defined test points
    # other options available are -max_test_points  and -test_points_per_scan_cell
    # Tool defaults to 8 test points per scan cell. Paste the following option to each command and adjust
    #  -test_points_per_scan_cell 8
    # Note that insertion of random resistant and untestable logic test points require access to TestMAX Advisor product
    set_testability_configuration -target random_resistant \
    -clock_signal snps_test_point_clk \
    -control_signal snps_test_mode_tp 
    
    
    set_testability_configuration -target untestable_logic \
    -clock_signal snps_test_point_clk \
    -control_signal snps_test_mode_tp 
    
    
    rm_source -file $DFT_TEST_POINT_FILE -optional -print DFT_TEST_POINT_FILE

    # Configuring Scan
    # For lower level blocks, suggest not to mix clocks, and perform clock mixing at top level
    # set_scan_configuration -clock_mixing no_mix
    # Chain count taken from DFT_INTERNAL_SCAN_CHAIN_COUNT variable
    set_scan_configuration -chain_count ${DFT_INTERNAL_SCAN_CHAIN_COUNT} 
    
  }
  SCAN {

    # Existing clocks in the design to be used for Test DRC
    foreach clk $DFT_CLOCK_LIST {
      set_dft_signal -type ScanClock -port $clk -timing {45 55} -view existing_dft
    }
    
    # Existing asynchronous set/reset signals in the design to be used for Test DRC
    foreach item $DFT_RESET_INFO {
      set signal [lindex $item 0]
      set sense [lindex $item 1]
      set_dft_signal -type Reset -active_state $sense -port $signal -view existing_dft
    }
    
    # Other existing constant signals that are needed for Test DRC
    foreach item $DFT_CONSTANT_INFO {
      set signal [lindex $item 0]
      set sense [lindex $item 1]
      set_dft_signal -type Constant -active_state $sense -port $signal -view existing_dft
    }
    
    # Scan In/Out signal for scan stitching 
    set_dft_signal -type ScanDataIn -port snps_scan_in_* -view spec
    set_dft_signal -type ScanDataOut -port snps_scan_out_* -view spec
    
    
    # Scan Enable signals
    set_dft_signal -type ScanEnable -port snps_scan_shift_en -view spec 
    # If necessary, specify Scan Enable signal to connect to Clock Gating cells. By default the same signal will be used for
    #   Scan registers and Clock Gating cells
    # set_dft_signal -type ScanEnable -port snps_scan_shift_en -view spec -usage scan
    # set_dft_signal -type ScanEnable -port snps_scan_shift_en_cg -view spec -usage clock_gating
    
    # Configuring Scan
    # For lower level blocks, suggest not to mix clocks, and perform clock mixing at top level
    # set_scan_configuration -clock_mixing no_mix
    # Chain count taken from DFT_INTERNAL_SCAN_CHAIN_COUNT variable
    set_scan_configuration -chain_count ${DFT_INTERNAL_SCAN_CHAIN_COUNT} 

  }
  default {
    puts "RM-error: invalid DFT_CONFIGURATION specified : $DFT_CONFIGURATION"
  }
}

## -----------------------------------------------------------------------------
## End of File
## -----------------------------------------------------------------------------
