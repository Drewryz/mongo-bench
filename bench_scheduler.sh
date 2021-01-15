threads=(50 100 150 200 250 300 350 400 450)
mongostat_bin=/home/odin/yangzaorang/mongodb-linux-x86_64-rhel70-4.2.7/bin/mongostat
mongostat_port=55272
top_pids=12913
ycsb_bin=/home/odin/yangzaorang/ycsb-0.17.0/bin/ycsb
ycsb_workloads=/home/odin/yangzaorang/ycsb-0.17.0/workloads/mongo_demo_y
now=$(date "+%Y%m%d-%H%M%S")
mkdir ${now}
for(( i=0;i<${#threads[@]};i++)) do
    echo "${threads[i]} threads start"
    bench_dir=${now}/${threads[i]}
    ./mongo_bench.sh start ${bench_dir} ${mongostat_bin} ${mongostat_port} ${top_pids} ${ycsb_bin} ${ycsb_workloads} ${threads[i]}
    ./mongo_bench.sh stop
done
