import requests
import json

def search_ebay(keyword):
    # Endpoint for the eBay Finding API's `findItemsAdvanced` call
    endpoint = 'https://svcs.ebay.com/services/search/FindingService/v1'

    # Parameters for the API call
    params = {
        'OPERATION-NAME': 'findItemsAdvanced',
        'SERVICE-VERSION': '1.0.0',
        'SECURITY-APPNAME': 'AbhinavP-hw2-PRD-a932e5ad5-0a4da37f',
        'RESPONSE-DATA-FORMAT': 'JSON',
        'REST-PAYLOAD': '',
        'keywords': keyword,

        'paginationInput.entriesPerPage': 2,
        'paginationInput.pageNumber': 1
    }

    # Make the API call
    response = requests.get(endpoint, params=params)

    # Parse the response
    if response.status_code == 200:
        return json.loads(response.content)
    else:
        return None

# Test the function
results = search_ebay('iphone')
print(results)