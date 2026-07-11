enable sleep

histlen=5
interval=5

gpupath="/sys/devices/pci0000:00/0000:00:01.1/0000:01:00.0/0000:02:00.0/0000:03:00.0"
mbpath="/sys/devices/platform/nct6687.2592"
cpupath="/sys/devices/pci0000:00/0000:00:18.3"

intake="$mbpath"/hwmon/hwmon*/pwm5
outtake="$mbpath"/hwmon/hwmon*/pwm3
gputemp="$gpupath"/hwmon/hwmon*/temp2_input
cputemp="$cpupath"/hwmon/hwmon*/temp3_input

minspeed=55
maxspeed=128
mintemp=55

if [[ $(cat "$gpupath"/vendor) != 0x1002 ]] || [[ $(cat "$gpupath"/device) != 0x731f ]]; then
  echo 'GPU path changed, quitting...'
  exit 1
fi

if [[ $(cat "$cpupath"/vendor) != 0x1022 ]] || [[ $(cat "$cpupath"/device) != 0x14e3 ]]; then
  echo 'CPU path changed, quitting...'
  exit 1
fi

if ! [[ -d "$mbpath" ]]; then
  echo 'Motherboard sensors not found, quitting...'
  exit 1
fi

autoctl() {
  echo 99 > ${intake}_enable
  echo 99 > ${outtake}_enable
}

trap autoctl EXIT

avg() {
  local len=$#
  local sum=0
  local i
  for i; do
    sum=$(( sum + i ))
  done
  echo $(( sum / len ))
}

echo 1 > ${intake}_enable
echo 1 > ${outtake}_enable

hist=()

while true; do
  currg=$(( $(cat $gputemp) / 1000 ))
  currc=$(( $(cat $cputemp) / 1000 ))
  max=$(( currg > currc ? currg : currc ))
  hist=( ${hist[@]} $max )
  if [[ ${#hist[@]} -gt $histlen ]]; then
    hist=( ${hist[@]: -$histlen} )
  fi
  temp=$(avg ${hist[@]})
  speed=$(( temp >= mintemp ? (minspeed + (maxspeed - minspeed) * (temp - mintemp) / (100 - mintemp)) : minspeed ))
  echo $speed > $intake
  echo $speed > $outtake
  sleep $interval
done
