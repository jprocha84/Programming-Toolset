#from ldap3 import Server, Connection
from ldap3 import Server, Connection, ALL, NTLM, SUBTREE, LDAPKeyError

#Connection to Global Catalog
server = Server('LDAP Server',port=3268 , get_info=ALL)
#Connect using my ID to Global Catalog
conn = Connection(server, user="domain\\user_id", password="password", authentication=NTLM, auto_bind=True)
#To review the available attributes
#server.schema


conn.search('dc=org, dc=com', '(displayname=Pepe Gomenz)', attributes=['*'],search_scope= SUBTREE)

for entry in conn.entries:    
    try:
        print entry['DisplayName']
        print entry['uid']
        print entry['mail']
        print entry['userPrincipalName']
        #Get Domain
        strPrincipalName = str(entry['userPrincipalName'])
        print strPrincipalName[strPrincipalName.find('@')+1:strPrincipalName.find('.')]
        
        print str(entry['memberOf']).find('OU=Tableau')
        
        print entry['objectclass']
    except LDAPKeyError:
        print "Error"
 
   
#entry = conn.entries[0]
#==============================================================================
# To print all attributes
# for attName in entry.entry_get_attribute_names():
#     try:
#         print attName
#         print entry[attName]
#     except UnicodeDecodeError:
#         print 'Cannot open'
#==============================================================================
