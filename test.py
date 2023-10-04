import requests
import json

endpoint = 'https://open.api.ebay.com/shopping?'

def getItem(itemID):

    headers = {
        'X-EBAY-API-IAF-TOKEN': 'v^1.1#i^1#p^1#f^0#I^3#r^0#t^H4sIAAAAAAAAAOVYXWwUVRTu9s80CITfUqhxGSAxkJm9M7O73Rm6G5d2S0tKd+kuDa0Rcmfm7nbo7Mwwd7bbJSGphWxUTIgKIvJSIZoYg4gGTVAUfYLAi4li9EHhwRZIE8OPASEQZ6fbsq0EGroxTdyXzZx77rnf991z7j0zoL+yanW2OXt7tuOZ0sF+0F/qcNCzQFVlxZo5ZaVLK0pAgYNjsH9lf/lA2ZV6DJOKzrcjrGsqRs6+pKJi3jb6iZSh8hrEMuZVmESYN0U+GtzYyjMU4HVDMzVRUwhnS6OfgCyHaJqLM7QgeAXOY1nVsZgxzU/QQKQZX51Qx0mcm2M5axzjFGpRsQlV008wgGFJwJEsiNE+3kPzLEtxbrqLcHYgA8uaarlQgAjYcHl7rlGA9fFQIcbIMK0gRKAl2BQNB1saQ22xeldBrEBeh6gJzRSe+NSgScjZAZUUevwy2PbmoylRRBgTrsDoChOD8sExME8B35aagTAu+lghLko+jqNhUaRs0owkNB+PI2eRJTJuu/JINWUz8yRFLTWE7Ug0809tVoiWRmfub1MKKnJcRoafCK0LdgYjESIQFLplFfZGyO40Q0baG0nIsQzyQMlDAuiWIFsXz68xGiiv8KRFGjRVknN6YWebZq5DFmA0WRZ3gSyWU1gNG8G4mQNT4MeAMflYd1duP0c3MGV2q7ktRUlLA6f9+GTxx2ebpiELKRONR5g8YKtjVZSuyxIxedBOw3zm9GE/0W2aOu9ypdNpKs1SmpFwMQDQri0bW6NiN0payZH3zdU6lp88gZRtKiKyZmKZNzO6haXPSlMLgJogAm4fyzIgr/tEWIHJ1n8ZCji7JhZDsYpDEFiaRR6fBzGIqWOkYhRHIJ+frhwOJMAMmYRGDzJ1BYqIFK08SyWRIUs864kzrC+OSMnLxUk3F4+TgkfyknQcIYCQIIic739SI1PN8igSDWQWL82LkeLeDXJ4nc9HN3i0DV2dUbUnE5HQmu2ZENgBU7iN1UMdvnYt3RHGm/xTLYRHkm9QZEuZmLV+cQXI1fp0RWjWsImkadGLipqOIpoii5mZtcGsIUWgYWaiSFEsw7RIBnW9pYjHdDHoTf2EeDrKRb6Z/vtb6ZGscC5bZxar3HxsBYC6TOXuHUrUki4NWg1HzrTNRmz38NPhLVut6oxibZEcZStLoz0mZVOmcK9IGQhrKcNqr6lwru+KaT1Ita4y09AUBRkd9LRLOZlMmVBQ0Eyr6SIkuAxn2D1Lezkv4Dgfx06Ll2jfottm2pFUxFN4zFDOTqGPdk18oQ+U2D96wPE9GHB8U+pwgHqwil4BlleWbS4ve3Yplk1EyTBOYTmhWu+pBqJ6UEaHslG6oOQ2GD4sjjR/9HrPg/SOobW7Sgq/Jwy+DJaMf1GoKqNnFXxeALUPRyroudWzGRZwLKB9Hpplu8CKh6Pl9OLyhev3Zvff+Hyf9EF4Vu3l4d1orvTePTB73MnhqCgpH3CU6J7FmX3no/eW3F54+Jela68nYscuf7oo+/P1l9aEMyfP/7H8Knnz2kir5vlaifZtvnC289Crl3afkRxbrmw7dxBtdcE3j77NLtBuuf4ijtw6dDx9ujp75BV36/3V/tNKonYTVf3DC+nmvZXzvhw4ufKz197a4ye2uC6e29C5rP3dOcd7m46tlxJ7/TsTH1eH2oaqV25+Y96HQ8u+onYZp9wHTpwY3rnrTuja/Ls1NfXJkWOZ5/HBL378hDqrL6iqnfPnheHaqvdf9DY9dwn9ZLxzqiv04M6qb93cAIjdz1b2Dv7mOd6350bNzezVzP7EootDv2qn7pQd/Y7vvrv190C0IuM7M79m5O8Ho3v5DzAHZOjpEQAA'
    }

    params = {
        'callname': 'GetSingleItem',  
        'version': '967',
        'responseencoding': 'JSON',
        'siteid': '0',
        'ItemID': itemID,  
    }

    response = requests.get(endpoint, params=params, headers=headers)
    
    return(response.json())

# Test the function
results = getItem("175901174512")
print(results)