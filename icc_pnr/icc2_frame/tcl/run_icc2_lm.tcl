# ****** create tech only NDM ******
create_workspace ibex_top.mw_technology_only -technology icc2_frame/data/TF/ibex_top.mw.tf -flow normal
source icc2_frame/data/TCL/ibex_top.mw_update_technology.tcl
commit_workspace -force
catch {sh mv ibex_top.mw_technology_only.ndm icc2_frame/ndm}

# ****** create frame only NDM ******
create_workspace ibex_top.mw_frame_only -technology icc2_frame/data/TF/ibex_top.mw.tf -flow frame
import_icc_fram icc2_frame/data/LEF/tcbn28hpcplusbwp30p140.tar.gz
check_workspace
commit_workspace -force
catch {sh mv ibex_top.mw_frame_only.ndm icc2_frame/ndm}

# ****** merge .db files with frame only NDM ******
set_app_options -name lib.logic_model.auto_remove_timing_only_designs -value true
create_workspace ibex_top.mw_merge_db -flow exploration
read_ndm -view frame icc2_frame/ndm/ibex_top.mw_frame_only.ndm

# Please complete the following set_pvt_configuration command
# set_pvt_configuration -clear_filter all -process_labels {} -process_numbers {} -voltages {} -temperatures {}

# Please complete the following read_db command
# read_db {}

group_libs
write_workspace -f exploration.tcl
check_workspace
commit_workspace -force
catch {sh mv *.ndm icc2_frame/ndm}

write_lef -include cell -write_additional_viarule test.lef

