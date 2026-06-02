# create_project.tcl - SM3 hash core for RK-ZYNQ7100-F (XC7Z100)
# Vivado 2023.1

create_project -force sm3_prj ./sm3_prj -part xc7z100ffg900-2
set_property target_language Verilog [current_project]

add_files -norecurse [glob ../rtl/*.sv]
add_files -norecurse -fileset sim_1 [glob ../sim/*.sv]
add_files -norecurse -fileset constrs_1 ../constr/sm3_prj1.xdc
add_files -norecurse [glob ../ip/*/*.xci]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "SM3 project created successfully."
