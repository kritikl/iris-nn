set designs {
    {iris_q44_top  q44}
    {iris_q88_top  q88}
    {iris_q1616_top q1616}
}

foreach item $designs {
    set top    [lindex $item 0]
    set suffix [lindex $item 1]

    puts "\n=== $top ==="

    set_property top $top [current_fileset]
    update_compile_order -fileset sources_1

    # Force non-incremental
    set_property AUTO_INCREMENTAL_CHECKPOINT 0 [get_runs synth_1]
    set_property incremental_checkpoint {} [get_runs synth_1]

    reset_run synth_1
    launch_runs synth_1 -jobs 4
    wait_on_run synth_1

    open_run synth_1
    report_utilization -file "utilization_${suffix}.rpt"
    report_timing_summary -file "timing_${suffix}.rpt"
    puts "Saved utilization_${suffix}.rpt"
    puts "Saved timing_${suffix}.rpt"
}

puts "\nDone"
