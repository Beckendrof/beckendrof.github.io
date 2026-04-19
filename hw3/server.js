require('dotenv').config();
const express = require('express');
const cors = require('cors');
const axios = require('axios');
const app = express();

app.use(cors({
    origin: 'http://localhost:4200'
}));

app.use(express.static("./dist/ebay"));

const MongoClient = require('mongodb').MongoClient;
const url = process.env.MONGO_URI;
app.post('/wishlistPost', express.json(), async (req, res) => {
    const client = await MongoClient.connect(url);
    try {
        const db = client.db('wishlist');
        const collection = db.collection('ebay-wishlist');

        const result = await collection.insertOne(req.body);
        res.json({ message: 'Post created' });
    } catch (err) {
        console.error('wishlistPost error:', err.message);
        res.status(500).json({ error: 'An error occurred' });
    } finally {
        await client.close();
    }
});

app.get('/wishlistGet', async (req, res) => {
    try {
        const client = await MongoClient.connect(url);
        const db = client.db('wishlist');
        const collection = db.collection('ebay-wishlist');
        const posts = await collection.find({}).toArray();
        client.close();
        res.json(posts);
    } catch (err) {
        res.status(500).json({ error: 'An error occurred' });
    }
});

const { ObjectId } = require('mongodb');

app.delete('/wishlistDel', async (req, res) => {
    try {
        const postId = req.query.q;
        if (!postId || !ObjectId.isValid(postId)) {
            return res.status(400).json({ error: 'Invalid ID' });
        }
        const client = await MongoClient.connect(url);
        const db = client.db('wishlist');
        const collection = db.collection('ebay-wishlist');
        const objectIdPostId = new ObjectId(postId);

        const result = await collection.deleteOne({ _id: objectIdPostId });
        client.close();
        res.json({ message: 'Post deleted successfully' });
    } catch (err) {
        res.status(500).json({ error: 'An error occurred' });
    }
});


// Axios instance with the eBay API configuration
const ebayAxiosInstance = axios.create({
    baseURL: 'https://svcs.ebay.com/services/search/FindingService/v1',
    params: {
        'OPERATION-NAME': 'findItemsAdvanced',
        'SERVICE-VERSION': '1.0.0',
        'SECURITY-APPNAME': process.env.EBAY_CLIENT_ID,
        'RESPONSE-DATA-FORMAT': 'JSON',
        'REST-PAYLOAD': '',
        'paginationInput.entriesPerPage': 50,
        'paginationInput.pageNumber': 1,
    },
});

// Create an Express route to make the API request
app.get('/getSimilarItems', async (req, res) => {
    try {
        const response = await axios.get("https://svcs.ebay.com/MerchandisingService", {
            params: {
                'OPERATION-NAME': "getSimilarItems",
                'SERVICE-NAME': "MerchandisingService",
                'SERVICE-VERSION': "1.1.0",
                'CONSUMER-ID': process.env.EBAY_CLIENT_ID,
                'RESPONSE-DATA-FORMAT': "JSON",
                'REST-PAYLOAD': "",
                itemId: req.query.q,
                maxResults: "20",
            },
        });

        const similarItems = response.data;

        res.json(similarItems);
    } catch (error) {
        console.error('getSimilarItems error:', error.message);
        res.status(500).json({ error: 'An error occurred' });
    }
});

app.get('/searchImage', async (req, res) => {
    try {
        const apiKey = process.env.GOOGLE_API_KEY;
        const cx = process.env.GOOGLE_CX;
        const query = encodeURIComponent(req.query.q || '');
        const num = 8;
        const imgSize = 'huge';
        const searchType = 'image';

        const apiUrl = `https://www.googleapis.com/customsearch/v1?q=${query}&cx=${cx}&imgSize=${imgSize}&num=${num}&searchType=${searchType}&key=${apiKey}`;

        const response = await axios.get(apiUrl);

        res.json(response.data);
    } catch (error) {
        console.error('searchImage error:', error.message);
        res.status(500).json({ error: 'Failed to fetch data from the Google API' });
    }
});

app.get('/search', async (req, res) => {
    const { keyword, ...queries } = req.query;

    try {
        const response = await ebayAxiosInstance.get('', {
            params: {
                ...ebayAxiosInstance.defaults.params,
                'keywords': keyword,
                ...queries,
            },
        });

        const responseData = response.data;

        const transformedData = transformEbayApiResponse(responseData);
        res.json(transformedData);
    } catch (error) {
        console.error('search error:', error.message);
        res.status(500).json({ error: 'An error occurred while fetching data from eBay.' });
    }
});

// Function to transform eBay API response into the desired format
function transformEbayApiResponse(responseData) {
    if (!responseData || !responseData.findItemsAdvancedResponse) {
        return [];
    }

    const findItemsAdvancedResponse = responseData.findItemsAdvancedResponse[0];

    if (!findItemsAdvancedResponse || !findItemsAdvancedResponse.searchResult) {
        return [];
    }

    const searchResult = findItemsAdvancedResponse.searchResult[0];

    if (!searchResult || !searchResult.item) {
        return [];
    }

    const items = searchResult.item;

    const transformedData = items.map(item => ({
        condition: item.condition[0].conditionId[0] || 'N/A',
        itemURL: item.viewItemURL[0] || 'N/A',
        shippingCost: item.shippingInfo[0]?.shippingServiceCost[0]?.__value__ || 'N/A',
        shippingLocations: item.shippingInfo[0]?.shipToLocations[0] || 'N/A',
        handlingTime: item.shippingInfo[0]?.handlingTime || 'N/A',
        expeditedShipping: item.shippingInfo[0]?.expeditedShipping[0] || 'N/A',
        oneDayShipping: item.shippingInfo[0]?.oneDayShippingAvailable[0] || 'N/A',
        returnAccepted: item.returnsAccepted[0] || 'N/A',
        ItemId: item.itemId ? item.itemId[0] : 'N/A',
        Image: item.galleryURL ? item.galleryURL[0] : 'N/A',
        Title: item.title ? item.title[0] : 'N/A',
        Price: item.sellingStatus[0].currentPrice ? item.sellingStatus[0].currentPrice[0].__value__ : 'N/A',
        Shipping: getShippingCost(item),
        Zip: item.postalCode ? item.postalCode[0] : 'N/A',
    }));

    return transformedData;
}


function getShippingCost(item) {
    if (item.shippingInfo[0].shippingServiceCost) {
        const cost = parseFloat(item.shippingInfo[0].shippingServiceCost[0].__value__);
        return cost === 0 ? 'Free Shipping' : `$${cost}`;
    }
    return 'N/A';
}

app.get('/productDetails', async (req, res) => {
    const client_id = process.env.EBAY_CLIENT_ID;
    const client_secret = process.env.EBAY_CLIENT_SECRET;
    const ItemID = req.query.itemId;

    class OAuthToken {
        constructor(client_id, client_secret) {
            this.client_id = client_id;
            this.client_secret = client_secret;
        }

        getBase64Encoding() {
            const sample_string = `${this.client_id}:${this.client_secret}`;
            const base64_string = btoa(sample_string);
            return base64_string;
        }

        async getApplicationToken() {
            const url = 'https://api.ebay.com/identity/v1/oauth2/token';
            const headers = {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Authorization': `Basic ${this.getBase64Encoding()}`,
            };
            const data = new URLSearchParams({
                'grant_type': 'client_credentials',
                'scope': 'https://api.ebay.com/oauth/api_scope',
            });

            try {
                const response = await axios.post(url, data, { headers });
                return response.data.access_token;
            } catch (error) {
                throw error;
            }
        }
    }

    const endpoint = 'https://open.api.ebay.com/shopping?';
    const oauth_utility = new OAuthToken(client_id, client_secret);
    try {
        const application_token = await oauth_utility.getApplicationToken();
        const headers = {
            'X-EBAY-API-IAF-TOKEN': application_token,
        };

        const params = {
            'callname': 'GetSingleItem',
            'version': '967',
            'responseencoding': 'JSON',
            'siteid': '0',
            'ItemID': ItemID,
            'IncludeSelector': 'Details,ItemSpecifics',
        };

        const ebayResponse = await axios.get(endpoint, { params, headers });
        res.json(ebayResponse.data);
    } catch (error) {
        res.status(500).json({ error: 'An error occurred while fetching eBay product details' });
    }
});

app.get('/autocomplete', async (req, res) => {

    try {
        const response = await axios.get('https://api.geonames.org/postalCodeSearchJSON?', {
            params: {
                postalcode_startsWith: req.query.q,
                maxRows: '5',
                country: 'US',
                username: process.env.GEONAMES_USERNAME,
            },
        });

        const responseData = response.data;
        const postalCodes = responseData.postalCodes.map(entry => entry.postalCode)
        res.json(postalCodes)
    } catch (error) {
        console.error('autocomplete error:', error.message);
        res.status(500).json({ error: 'An error occurred while fetching postal codes' });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
