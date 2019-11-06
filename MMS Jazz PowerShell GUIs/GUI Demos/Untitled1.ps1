#Fiddler Demo 
$body = 'name=Stephen'

Invoke-RestMethod -Method Put `
    -Uri https://putsreq.com/xwhGP2EcOJG7ktcNtIyD?name=Stephen `
    -Body $body -Proxy http://127.0.0.1:8888