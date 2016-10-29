# collect and send data from xivo

This part of the project is around 3 differents supervision:

1. Switchboard
 we will use **collectd** graphite and graphana to create a real-time information board, usually on a **call center dashboard**.
 It can be also used by supervisors for fast and easy analysis of trends and statistics history.
 
 For now, the collectd is installed on the xivo server and send formatted data to graphite.
 
2. calls
 We connect to xivo and collect asterisk **call metrics** in **Carbon**.
 "calls" are internal calls
 "dahdi" are channels (calls passing by the dahdi module) 
 
3. server
 We retrieve the data generating by the default "monitoring" service from xivo
 and intend to retreive it under grafana and so have **server stats**
 
 # task list:
 1. swithboard
 - [ ] configure collectd on the supervisor server
 - [ ] test dialplan on a IVR
 - [ ] create custom dashboard
 2. calls
 - [ ] use carbon on the supervisor server
 - [ ] edit conf within the script
 - [ ] create custom dashboard
 3. server
 - [ ] retrieve xivo's rra
 - [ ] create custom dashboard
