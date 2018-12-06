# -*- coding: utf-8 -*-
"""

"""



import paramiko
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect('server', username='user', password='password')
stdin, stdout, stderr = ssh.exec_command("ls -l")
stdout.readlines()

ftp = ssh.open_sftp() 
ftp.get('SFILEDS_test.ds', 'SFILEDS_test.ds') 
ftp.close()


#VCAMS - Connection
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

ssh.connect('server', username='user', password='password')
stdin, stdout, stderr = ssh.exec_command("sudo su - superuser")
stdin, stdout, stderr = ssh.exec_command("pwd -P")
stdout.readlines()
stderr.readlines()

ssh.connect('server', username='user', password='password')
stdin, stdout, stderr = ssh.exec_command("ls -l")
stdout.readlines()


/usr/local/bea/wls81/domains/sbmEjbNode1
	- ls -ltr /usr/local/bea/wls81/domains/sbmEjbNode1/ETLI_LOGS
/usr/local/bea/wls81/domains/sbmEjbNode2
	- ls -ltr /usr/local/bea/wls81/domains/sbmEjbNode2/ETLI_LOGS
/usr/local/bea/wls81/domains/sbmEjbNode3
	- ls -ltr /usr/local/bea/wls81/domains/sbmEjbNode3/ETLI_LOGS
/usr/local/bea/wls81/domains/sbmEjbNode6
	- ls -ltr /usr/local/bea/wls81/domains/sbmEjbNode6/ETLI_LOGS

