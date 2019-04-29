import requests
url = 'https://www.neonscience.org/sites/default/files/NEONDomains_0.zip'
print("Downloading NEONDomains_0")
r = requests.get(url)

with open('NEONDomains_0.zip' , 'wb') as f:  
    f.write(r.content)

url = 'https://www.dropbox.com/sh/nt33at5wpvijkrp/AABVa1UtK-E6zKPOCv-1VdGba?dl=1'
print("Downloading data")
r = requests.get(url)

with open('data.zip', 'wb') as f:
	f.write(r.content)