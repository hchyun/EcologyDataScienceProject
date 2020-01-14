import requests
url = 'https://www.neonscience.org/sites/default/files/NEONDomains_0.zip'
print("Downloading NEONDomains_0")
r = requests.get(url)

with open('NEONDomains_0.zip' , 'wb') as f:  
    f.write(r.content)