'''
Name: checkPS.sh 

'''
Description: check PS logs for indication of continuous flapping, which can alter the result of audit.  This is done through system log analysis for Reachable Vault search counts.  Normal to see several of these entries but during flapping could span upto 2000+.
Default count: 200

Usage: 
  ./checkPS.sh --help
  Usage:  ./checkPS.sh <THRESHOLD COUNT>
  Issuing this command without parameters will use default COUNT of 200.

Examples:
[root@ccdn-vvim-02 testing]# ./checkPS.sh
Using default count of 200
Checking following vaults for flapping
ccdn-ps-wcdc-01 ccdn-ps-vn-01 ccdn-ps-mt-01
No issues detected, proceed with findDamaged script, EXIT STATUS 0


[root@ccdn-vvim-02 testing]# ./checkPS.sh 30
Using count 30
Checking following vaults for flapping
ccdn-ps-wcdc-01 ccdn-ps-vn-01 ccdn-ps-mt-01
Possible issue detected, check logfile ./checkPS.sh.out, EXIT STATUS 1


[root@ccdn-vvim-02 testing]# cat ./checkPS.sh.out
----------------------------------------------------------------------------------------------------------------------------------------------------
Possible issue detected ccdn-ps-mt-01
----------------------------------------------------------------------------------------------------------------------------------------------------
ccdn-ps-mt-01
Thu Nov 17 07:12:39 UTC 2016
count of Reachable Vault messages
38
top 5 vaults showing restart
      2 164(6)
      2 162(36)
      2 150(28)
      1 9554(36)
      1 9553(36)
----------------------------------------------------------------------------------------------------------------------------------------------------

