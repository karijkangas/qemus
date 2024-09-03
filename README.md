Debian 12 qemu virtual machines for Apple Silicon.


https://sigmaris.info/blog/2019/04/automating-debian-install-qemu/
https://adonis0147.github.io/post/qemu-socket-vmnet/
https://gitlab.com/qemu-project/qemu/-/issues/465

```
# set QEMUS_HOME
source env.sh
```


```
# set vms to dns for ip address
sudo tee -a /etc/bootptab > /dev/null << EOF
%%
# hostname      hwtype  hwaddr              ipaddr          bootfile
vm01            1       ca:fe:ba:be:00:01   192.168.56.4
vm02            1       ca:fe:ba:be:00:02   192.168.56.5
vm03            1       ca:fe:ba:be:00:03   192.168.56.6
vm04            1       ca:fe:ba:be:00:04   192.168.56.7
vm05            1       ca:fe:ba:be:00:05   192.168.56.8
vm06            1       ca:fe:ba:be:00:06   192.168.56.9
EOF

sudo /bin/launchctl unload -w /System/Library/LaunchDaemons/bootps.plist
sudo /bin/launchctl load -w -F /System/Library/LaunchDaemons/bootps.plist
```


```
# set vms ip addresses to hosts file for hostname
sudo tee -a /etc/hosts > /dev/null << EOF
192.168.56.4    vm01
192.168.56.5    vm02
192.168.56.6    vm03
192.168.56.7    vm04
192.168.56.8    vm05
192.168.56.9    vm06
EOF
```


```
#~/.ssh/config
Host 192.168.56.*
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null

Host vm01 vm02 vm03 vm04 vm05 vm06
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
```


```
brew install socket_vmnet
./run-socket-vmnet.sh    # let run in the background
```


```
# create base qemu image
./new-qemu-base.sh
./new-qemu-base.sh debian12-base 20G https://cdimage.debian.org/debian-cd/current/arm64/iso-cd/debian-12.7.0-arm64-netinst.iso

#type "exit" from UEFI Interactive Shell
#select Boot Manager | UEFI QEMU USB HARDDRIVE ...
#select Install
```


```
# create vm disks from base qemu image
./init.sh
./init.sh 02 debian12-base.qcow2 ovmf_vars.fd
```


```
# start virtual machines
./start.sh 01 512M
./start.sh 02 512M

```


```
# set authorised ssh key for vms
./set-ssh-key.sh kari ~/.ssh/id_ed25519.pub vm01 vm02
```


```
# finish install with ansible
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

ansible-vault create ./secrets/vault.yml

# become_password: *****

ansible-playbook playbook.yml --ask-vault-pass -e@./secrets/vault.yml
```


```
# test vms
ssh kari@vm01
ssh kari@vm02
```

