*xrun_svlog_probe.tcl*
```database -open waves -into waves.shm -event -default
probe -create [scope -tops] \
    -all -depth all -database waves
run
exit```