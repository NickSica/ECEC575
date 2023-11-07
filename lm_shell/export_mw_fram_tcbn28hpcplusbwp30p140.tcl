if {[catch {
  export_icc2_frame -library /home/tech/TSMC28/TSMCHOME/digital/Back_End/milkyway/tcbn28hpcplusbwp30p140_110a/cell_frame_VHV_0d5_0/tcbn28hpcplusbwp30p140 -output_directory /home/sica/ECEC575/lm_shell/tsmc28
} ret_code]} {
  exit 1
}
exit [expr !$ret_code]
