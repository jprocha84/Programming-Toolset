# -*- coding: utf-8 -*-
from openpyxl import load_workbook
from ldap3 import Server, Connection, ALL, NTLM, SUBTREE, LDAPKeyError

#LDAP Code
server = Server('server',port=3268 , get_info=ALL)
conn = Connection(server, user="domain_ldap\\id_ldap", password="password", authentication=NTLM, auto_bind=True)

#Excel
wb2 = load_workbook('C:/company/Research/company/Excel/inputFiles/Users List -  Select User Grou.xlsx')
type(wb2.get_sheet_names())


sheet = wb2.get_sheet_by_name(wb2.get_sheet_names()[0])

intRowNumber = 0
for iRow in sheet.rows: 
    intRowNumber = intRowNumber + 1    
    #print iRow[2].value
    strValue =  iRow[1].value
    if strValue is not None and strValue != '':
        conn.search('dc=gm, dc=com', '(uid=' + str(iRow[1].value) + ')', attributes=['mail'],search_scope= SUBTREE)        
        if conn.entries is not None:
            try:
                entry = conn.entries[0]
                print str(entry['mail'])
                sheet['E' + str(intRowNumber)]= str(entry['mail'])
                
            except LDAPKeyError:
                print 'Non mail'

wb2.save('C:/company/Research/company/Excel/inputFiles/Users List -  Select User Group.xlsx') 


