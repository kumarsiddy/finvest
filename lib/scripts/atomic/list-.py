import requests

url = "https://sandbox.api.atomicvest.com/assets/-/search"

payload = { 
        "bond": {
            "bond_type": "treasury"
        }
    }

headers = {
    "accept": "application/json",
    "content-type": "application/json",
    "Atomic-ID": "r2QfeMrV6WJjNU60VelKoHaY3cnYN9"
}

response = requests.post(url, json=payload, headers=headers)

print(response.text)