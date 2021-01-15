#!/bin/bash

# 这个脚本用于mongo压测用。记录mongostat日志，mongos top信息， 以及ycsb输出结果
# 参数：
# 停止/启动命令
# 工作目录--日志输出目录
# mongostat路径
# mongostat监控端口
# top监控pid
# ycsb路径
# ycsb压测脚本路径
# ycsb压测线程数
# ./mongo_bench.sh start/stop out_dir mongostat_path mongostat_port top_pids ycsb_path ycsb_workloads_path ycsb_threads
# ./mongo_bench.sh start testxx /home/odin/yangzaorang/mongodb-linux-x86_64-rhel70-4.2.7/bin/mongostat 55272 12913 /home/odin/yangzaorang/ycsb-0.17.0/bin/ycsb /home/odin/yangzaorang/ycsb-0.17.0/workloads/mongo_demo_y 1

if [ "$1" = "stop" ]; then
    # !!! 停止mongostat, 这里会kill掉本机所有的mongostat进程 !!!
    pids=`ps -ef | grep mongostat | grep -v grep | awk '{print $2}'`
    if [ -n "$pids" ]; then
        echo $pids | xargs kill
    fi
    # !!! 停止ycsb，这里会kill掉本机所有的ycsb进程 !!!
    pids=`ps -ef | grep ycsb | grep -v grep | awk '{print $2}'`
    if [ -n "$pids" ]; then
        echo $pids | xargs kill
    fi
    # !!! 停止top监控，这里会kill掉本机所有的top进程 !!!
    pids=`ps -ef | grep 'top -p' | grep -v grep | awk '{print $2}'`
    if [ -n "$pids" ]; then
        echo $pids | xargs kill
    fi
    echo 'stop success'
    exit
fi

if [ "$1" != "start" ]; then
    echo 'did you input start paramter?'
    exit
fi

res_dir=$2
mkdir ${res_dir}
if [ $? != 0 ]; then
    echo "cannot make ${res_dir} dir"
    exit
fi
cd ${res_dir}

# 启动mongostat并记录mongostat输出结果
mongostat_bin=$3
mongostat_port=$4
mongostat_out=mongostat.log
${mongostat_bin} --port ${mongostat_port} --discover > ${mongostat_out} 2>&1 &
if [ $? != 0 ]; then
    echo "cannot run mongostat"
    exit
fi

# 记录top信息
mongo_pid=$5
top_out=top.log
top -p ${mongo_pid} -b -d 1 > ${top_out} 2>&1 &
if [ $? != 0 ]; then
    echo "cannot run top"
    exit
fi

# 启动ycsb并记录ycsb输出结果
ycsb_bin=$6
ycsb_workloads=$7
ycsb_threads=$8
ycsb_out=ycsb_out.log
${ycsb_bin} run mongodb -s -P ${ycsb_workloads} -threads ${ycsb_threads} > ${ycsb_out} 2>&1
if [ $? != 0 ]; then
    echo "cannot run ycsb"
    exit
fi
