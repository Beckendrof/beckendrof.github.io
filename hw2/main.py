from flask import Flask, render_template, request
import requests

endpoint = 'https://svcs.ebay.com/services/search/FindingService/v1'

app = Flask(__name__)

@app.route("/")
def home():
    return render_template('home.html')

@app.route('/search')
def search():
    data = request.args.get('keyword')
    response = call(data)
    totalResultsFound = response["findItemsAdvancedResponse"][0]["paginationOutput"][0]["totalEntries"][0]
    results = response['findItemsAdvancedResponse'][0]['searchResult'][0]["item"]
    # Assume the response is a list of items. Adjust as necessary

    extractedData = []

    for item in results:
        imageURL = item["galleryURL"][0]
        title = item["title"][0]
        category = item["primaryCategory"][0]["categoryName"][0]
        ebayLink = item["viewItemURL"][0]
        condition = item["condition"][0]["conditionDisplayName"][0]
        topRated = "Top Rated" if item["topRatedListing"][0] == "true" else "Not Top Rated"
        price = float(item["sellingStatus"][0]["convertedCurrentPrice"][0]["__value__"])

        try:
            shippingCost = float(item["shippingInfo"][0]["shippingServiceCost"][0]["__value__"])
        except:
            shippingCost = 0.00

        # imageToDisplay = "topRatedImage.jpg" if topRated else imageURL

        # Format the price string
        priceString = f"Price: ${price:.2f}"
        if shippingCost >= 0.01:
            priceString += f" (+ ${shippingCost:.2f} for shipping)"

        extractedData.append({
            "imageURL": imageURL,
            "title": title,
            "category": category,
            "ebayLink": ebayLink,
            "condition": condition,
            "topRated": topRated,
            "price": price,
        })

        print(extractedData[0]['imageURL'])

    return render_template('search.html', results=extractedData, totalResultsFound=totalResultsFound, keyword=data)

def call(keyword):
    params = {
        'OPERATION-NAME': 'findItemsAdvanced',  
        'SERVICE-VERSION': '1.0.0',
        'SECURITY-APPNAME': 'AbhinavP-hw2-PRD-a932e5ad5-0a4da37f',
        'RESPONSE-DATA-FORMAT': 'JSON',
        'REST-PAYLOAD': '',
        'keywords': keyword,

        'paginationInput.entriesPerPage': 10,
        'paginationInput.pageNumber': 1
    }

    response = requests.get(endpoint, params=params)

    if response.status_code == 200: return(response.json())
    else: print("error")

if __name__ == '__main__':
    app.run(debug=True)