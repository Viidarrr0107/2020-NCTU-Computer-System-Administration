## Wireguard

```sh
sudo pkg update
pkg search wireguard
sudo pkg install wireguard

sudo vim /usr/local/etc/wg0.conf # see appendix/wg0.conf
sudo sysrc wireguard_enable=YES
sudo sysrc wireguard_interfaces="wg0"
cat /etc/rc.conf

sudo service wireguard start
sudo wg show
ifconfig

sudo tcpdump -nni wg0 icmp # ping from judge
```