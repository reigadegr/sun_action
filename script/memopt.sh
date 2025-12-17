sudo apt update
sudo apt-get install linux-modules-extra-"$(uname -r)"
echo linux-modules-extra-"$(uname -r)"
sudo -E sysctl vm.swappiness=1
sudo -E sysctl vm.min_free_kbytes=32768
sudo -E sysctl vm.watermark_scale_factor=100
sudo -E sysctl vm.watermark_boost_factor=15000
sudo -E sysctl vm.overcommit_memory=1
sudo -E sysctl vm.page-cluster=0
sudo -E modprobe zram
echo "0" | sudo -E tee /sys/class/block/zram0/mem_limit
echo "zstd" | sudo -E tee /sys/class/block/zram0/comp_algorithm
echo "$(awk 'NR==1{print $2*1000}' </proc/meminfo)" | sudo -E tee /sys/class/block/zram0/disksize
sudo -E mkswap /dev/zram0
sudo -E swapon -p 100 /dev/zram0
echo "Y" | sudo -E tee /sys/kernel/mm/lru_gen/enabled
echo "1000" | sudo -E tee /sys/kernel/mm/lru_gen/min_ttl_ms
echo "1" | sudo -E tee /sys/kernel/mm/swap/vma_ra_enabled
