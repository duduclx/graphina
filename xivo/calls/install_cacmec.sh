# editing conf files
# getting xivoIP
echo "Please type your xivo server IP"
echo "something like 192.168.2.99"
echo "======================="
read -p "type here" IP

sed -e "s/xivoIP/$IP/g" conf/calls.py
sed -e "s/xivoIP/$IP/g" conf/dahdi.py

# getting xivouser
echo "Please type your graphite server IP"
echo "something like xivo"
echo "======================="
read -p "type here" USER

sed -e "s/xivouser/$IP/g" conf/calls.py
sed -e "s/xivouser/$IP/g" conf/dahdi.py

# getting xivosecret
echo "Please type your graphite server IP"
echo "something like password"
echo "======================="
read -p "type here" SECRET

sed -e "s/xivosecret/$IP/g" conf/calls.py
sed -e "s/xivosecret/$IP/g" conf/dahdi.py

# running python script
python calls.py
python dahdi.py
