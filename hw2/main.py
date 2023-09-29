from flask import Flask, render_template, request, send_from_directory
import requests

endpoint = 'https://svcs.ebay.com/services/search/FindingService/v1'

app = Flask(__name__)

@app.route('/')
def home():
    return send_from_directory('static', 'index.html')

@app.route('/search', methods=['GET'])
def search():
    #Query parameters
    query_parameters = request.args

    #Item Filters
    item_filters = {}
    item_filter_counter = 0
    for key, value in query_parameters.items():
        if key not in ('keyword', 'sortOrder'):
            item_filters[f'itemFilter({item_filter_counter}).name'] = key
            item_filters[f'itemFilter({item_filter_counter}).value'] = value
            item_filter_counter += 1

    #API call
    response = call(query_parameters.get('keyword'), query_parameters.get('sortOrder'), item_filters)

    return response

def call(keyword, sortOrder, item_filters):
    params = {
        'OPERATION-NAME': 'findItemsAdvanced',  
        'SERVICE-VERSION': '1.0.0',
        'SECURITY-APPNAME': 'AbhinavP-hw2-PRD-a932e5ad5-0a4da37f',
        'RESPONSE-DATA-FORMAT': 'JSON',
        'REST-PAYLOAD': '',
        'keywords': keyword,
        'sortOrder': sortOrder,

        'paginationInput.entriesPerPage': 10,
        'paginationInput.pageNumber': 1,
    }

    # Add item filters 
    params.update(item_filters)
    response = requests.get(endpoint, params=params)

    if response.status_code == 200: return(response.json())
    else: print("error")

if __name__ == '__main__':
    app.run(debug=True)