#!/usr/bin/env bash

# CPU and MB

sensors | \
  egrep "PHY Temperature|MAC Temperature|temp1|Tctl|Tccd1|Tccd2" | \
  sed 's/°C//g' | \
  sed -E 's/\(.*?\)//g' | \
  sed 's/ Temperature/_Temperature/g' | \
  sed 's/://g' | \
  awk 'BEGIN{
      print("# TYPE temperature gauge");
      print("# HELP temperature Component Temperature");
    }
    {
    print("temperature{sensor=\""$1"\"} " $2);
  }' | \
  curl --data-binary @- http://192.168.2.183:9091/metrics/job/temperature_cpu/instance/pve


# Disks

TMP=/tmp/hdd.$$

{
  echo "# TYPE temperature gauge"
  echo "# HELP temperature Compponent Temperature"
  for i in sda sdb sdc sdd sde sdf sdg sdh
  do
    smartctl -x /dev/$i |  grep "194 Temperature_Celsius" | \
      awk -v hdd=$i '{
        print("temperature{sensor=\""hdd"\"} " $8);
      }'
  done
} > $TMP

curl --data-binary @$TMP http://192.168.2.183:9091/metrics/job/temperature_disk/instance/pve

[[ -f "$TMP" ]] && rm -rf "$TMP"
