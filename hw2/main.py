import os
from flask import Flask, render_template, request, send_from_directory
from ebay_oauth_token import OAuthToken
import requests
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__)
client_id = os.environ.get('EBAY_CLIENT_ID')
client_secret = os.environ.get('EBAY_CLIENT_SECRET')

@app.route('/')
def home():
    return send_from_directory('static', 'index.html')

@app.route('/search', methods=['GET'])
def search():
    #Query parameters
    query_parameters = request.args
    itemfilters = {}
    for key, value in query_parameters.items():
        if key in ['keyword', 'sortOrder']: continue
        else :
            itemfilters[key] = value
    #API call
    response = call(query_parameters.get('keyword'), query_parameters.get('sortOrder'), itemfilters)
    return response

def call(keyword, sortOrder, item_filters):

    endpoint = 'https://svcs.ebay.com/services/search/FindingService/v1'

    params = {
        'OPERATION-NAME': 'findItemsAdvanced',
        'SERVICE-VERSION': '1.0.0',
        'SECURITY-APPNAME': client_id,
        'RESPONSE-DATA-FORMAT': 'JSON',
        'REST-PAYLOAD': '',
        'keywords': keyword,
        'sortOrder': sortOrder,

        'paginationInput.entriesPerPage': 10,
        'paginationInput.pageNumber': 1,
    }

    # Add item filters
    params.update(item_filters)

    # print(params)
    response = requests.get(endpoint, params=params)

    if response.status_code == 200: return(response.json())
    else: print("error")

@app.route('/searchItem', methods=['GET'])
def searchItem():
    ItemID = request.args.get('itemid')

    #API call
    response = getItem(ItemID)
    return response


def getItem(ItemID):
    endpoint = 'https://open.api.ebay.com/shopping?'

    # Create an instance of the OAuthUtility class
    oauth_utility = OAuthToken(client_id, client_secret)

    # Get the application token
    application_token = oauth_utility.getApplicationToken()

    headers = {
        'X-EBAY-API-IAF-TOKEN': application_token
    }

    params = {
        'callname': 'GetSingleItem',
        'version': '967',
        'responseencoding': 'JSON',
        'siteid': '0',
        'ItemID': ItemID,
        'IncludeSelector':  'Details, ItemSpecifics'
    }

    response = requests.get(endpoint, params=params, headers=headers)
    return(response.json())


if __name__ == '__main__':
    app.run(debug=False)
