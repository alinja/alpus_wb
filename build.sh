
echo -e "-- alpus_wb32_all.vhd is generated by build.sh from individual files\n" > alpus_wb32_all.vhd
cat alpus_wb32_pkg.vhd alpus_wb32_master_select.vhd alpus_wb32_pipeline_bridge.vhd >> alpus_wb32_all.vhd