###########################################################################
### Extraction
###########################################################################

##Go to Layout Window, Route -> Extract RC, it opens up a new window as shown below, click ok. Alternatively, you can run this script on the ICC shell:

extract_rc  -coupling_cap  -routed_nets_only  -incremental

##write parasitic to a file for delay calculations tools (e.g PrimeTime).
write_parasitics -output ./$output_dir/${top}_extracted.spef -format SPEF

##Write Standard Delay Format (SDF) back-annotation file
write_sdf ./$output_dir/${top}_extracted.sdf

##Write out a script in Synopsys Design Constraints format
write_sdc ./$output_dir/${top}_extracted.sdc

##Write out a hierarchical Verilog file for the current design, extracted from layout
write_verilog ./$output_dir/${top}_extracted.v

##Save the cel and report timing
report_clock_tree -summary > $reports_dir/extracted_clock_tree.rpt
report_timing > $reports_dir/extracted_timing_summary.rpt
report_power > $reports_dir/extracted_power.rpt
report_timing -max_paths 50 -delay max > $reports_dir/extracted.setup.rpt
report_timing -max_paths 50 -delay min > $reports_dir/extracted.hold.rpt

save_mw_cel -as extracted

