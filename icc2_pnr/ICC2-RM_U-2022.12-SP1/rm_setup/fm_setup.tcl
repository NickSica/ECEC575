
## ############################################################# ##
## Formality Variables
## ############################################################# ##


set OUTPUTS_DIR   "./outputs_fm" ;# 

set REPORTS_DIR      "./rpts_fm" ;#

set FM_RTL_READ_SCRIPT       "" ;# Used when RTL_SOURCE_FORMAT is script

set FM_ECO_RTL_READ_SCRIPT   "" ;# Used for ECO when RTL read uses a script

set FM_APP_VAR_SETTINGS "fm_app_var_settings.tcl"       ;# Script to load user or project app_var adjustments. Optional.

set FM_POST_REFERENCE_ADJUST_SCRIPT ""                  ;# Script which is loaded just after the reference container is linked. Optional
                                                        ;# but useful for customizations associated with functional ecos.

set FM_POST_MATCH_ADJUST_SCRIPT ""                      ;# Script which is loaded just after container match. Optional but useful for
                                                        ;# costomized dont_verify commands or other functional eco needs.

set FM_MAX_CORES 4                                      ;# Specify FM max cores                                          

set FM_ALT_REFERENCE_DATA_DIR ""                        ;# Used for non-standard reference and svf content

set FM_REF_NETLIST ""                                   ;# Gate netlist to use as reference.         

set FM_SVF_FILES ""                                     ;# Gate netlist to use as reference.         

set FM_SUPPLEMENTAL_SEARCH_PATH ""                      ;# Add search paths beyond defaults.         

set FM_REF_UPF_FILE ""                                  ;# UPF for FM reference.                     

set FM_UPF_UPDATE_SUPPLY_SET_FILE ""                    ;# Additional UPF to re-attach switched supply nets

set FM_REF_SUPPLEMENTAL_UPF_FILE ""                     ;# Supplemental UPF for FM reference.        

set FM_REFERENCE_POWER_MODELS ""                        ;# Hierarchical power models for reference design

set FM_CONSTRAINTS_FILE ""                              ;# Use to apply any FM constraints prior to verify

set FM_IMP_NETLIST ""                                   ;# Gate netlist to use as implementation.    

set FM_IMP_NDM "$DESIGN_LIBRARY"                        ;# Set to use an NDM block for the implementation

set FM_IMP_NDM_BLOCK ""                                 ;# Set to use an NDM block for the implementation

set FM_REF_NDM "$DESIGN_LIBRARY"                        ;# Set to use an NDM block for the reference

set FM_REF_NDM_BLOCK ""                                 ;# Set to use an NDM block for the reference

set FM_IMP_UPF_FILE ""                                  ;# UPF for FM implementation.                

set FM_IMP_SUPPLEMENTAL_UPF_FILE ""                     ;# Supplemental UPF for FM implentation.     

set FM_IMPLEMENTATION_POWER_MODELS ""                   ;# Hierarchical power models for implementation design

set FM_LINK_LIBRARY ""                                  ;# db files required to support linking netlists

set FM_RETENTION_MODEL_FILE ""                          ;# Script to manage retention model setup in MV designs

set FM_GENERATE_POWER_MODEL true                        ;# Generate a power model after successful verificaiton for future hierarchical model

set FM_SET_TOP_RTL_ARGS  ""                             ;# Optional for adding set_top arguments when creating RTL container. E.g "-parameter {w1 = 4'h5 }"

set FM_ECO_GUIDANCE_FROM_SYN ""                         ;# Specify path to FM ECO guifance from Synthesis                                          

set FM_ECO_NETLIST ""                                   ;# Specify FM ECO netlist                                        

set FM_ECO_IMPLEMENTATION_SRC ""                        ;# Specify FM ECO implementation source                                          

set FM_ECO_NETLIST_FOR_NETLIST_FLOW ""                  ;# Point to the appropriate file or set null ( e.g. "" ) 

set FM_ECO_NETLIST_FOR_RTL_FLOW ""                      ;# Point to the appropriate file or set null ( e.g. "" ) 

set FM_ECO_ORIG_REF_NETLIST ""                          ;# Point to the appropriate file or set null ( e.g. "" ) 

set FM_ECO_ORIG_IMPL_NETLIST_FOR_NETLIST_FLOW ""        ;# Point to the appropriate file or set null ( e.g. "" ) 

set FM_ECO_ORIG_IMPL_NETLIST_FOR_RTL_FLOW ""            ;# Point to the appropriate file or set null ( e.g. "" ) 

set FM_ECO_ORIG_ECO_RTL_FILE_PAIRS ""                   ;# Specify FM ECO orig implementation netlist for RTL flow 

set FM_ECO_RTL_SOURCE_FILES ""                          ;# Specify FM ECO RTL source files                                       

set FM_ECO_REGION_FILE ""                               ;# Point to the appropriate file or set null ( e.g. "" ) 


