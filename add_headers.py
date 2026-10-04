import json

with open('firebase.json', 'r') as f:
    data = json.load(f)

if 'hosting' in data:
    data['hosting']['headers'] = [
        {
            "source": "**/*.html",
            "headers": [
                { "key": "Cache-Control", "value": "no-cache, no-store, must-revalidate" }
            ]
        }
    ]

with open('firebase.json', 'w') as f:
    json.dump(data, f, indent=4)
