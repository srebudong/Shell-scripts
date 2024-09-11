#!/bin/bash
# last modified: 2024-08-31
# desc: 重置网卡


function filter_ip {
  # 正则表达式模式
  local pattern='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
  # 匹配输入的IP地址
  if [[ $1 =~ $pattern ]]; then
    echo "true"
  else
    return 1
  fi
}

function renew_eth {
  # 重置网卡
	eth_name=$(nmcli c s|awk  /^e/'{print $1}')
  eth_id=$(nmcli c s|awk  /^e/'{print $2}')
  nmcli con delete uuid ${eth_id} 
  nmcli con add type ethernet ifname ${eth_name} con-name ${eth_name} 
  nmcli con up ${eth_name}
  
  # 配置ip
  nmcli con mod ${eth_name} ipv4.addresses ${ipaddr}/${prefix}
  nmcli con mod ${eth_name} ipv4.gateway $gateway
  nmcli con mod ${eth_name} ipv4.method manual
  nmcli con mod ${eth_name} ipv4.dns "${dns}"
  nmcli con up ${eth_name}
}


function renew_uuid {
  echo renew uuid
  # 删除MachineID
  rm -rf /etc/machine-id
  # 重新生成
  systemd-machine-id-setup
}

[ $# -ne 4 ] && echo -e "Usage: $0 ip/prefix gateway dns\nExample: $0 192.168.0.10/24 192.168.0.254 8.8.8.8" && exit 1

ipaddr=$1
prefix=$2
gateway=$3
dns=$4

filter_ip ${ipaddr} || (echo "[ERROR 0]:无效的ip/prefix" && exit 1)
filter_ip ${gateway} || (echo "[ERROR 0]:无效的gateway" && exit 1)
filter_ip ${dns} || (echo "[ERROR 0]:无效的dns" && exit 1)
echo "ipaddr: ${ipaddr} prefix: ${prefix} gateway: ${gateway} dns: ${dns}"
#renew_eth || (echo "[ERROR 1]:重置网卡失败" && exit 1)
#renew_uuid || (echo "[ERROR 2]:重置uuid失败" && exit 2)
#reboot
