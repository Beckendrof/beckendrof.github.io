document.getElementById('searchForm').addEventListener('submit', function (e) {
    e.preventDefault();

    const button = document.getElementById('showMoreButton');
    const keyword = document.getElementById('keyword').value;
    const maxPriceInput = document.getElementById('maxPrice').value;
    const minPriceInput = document.getElementById('minPrice').value;
    const checkboxes = document.querySelectorAll('input[name="condition"]:checked');
    const seller = document.getElementById('returnAccepted');
    const free = document.getElementById('freeShipping');
    const expeditedShipping = document.getElementById('expeditedShipping');
    const sortBy = document.getElementById('sortBy');
    const queryString = document.getElementById('keyword').value;

    //Check if 'Price' input is correct
    if (!isValidPrice(maxPriceInput, minPriceInput)) {
        return;
    }

    //Construct URL
    const generatedURL = constructURL(queryString, minPriceInput, maxPriceInput, checkboxes, seller, free, expeditedShipping, sortBy)
    const outerResults = document.querySelector('.outer-results');

    //Ajax Request
    fetch(generatedURL)
        .then(response => response.json())
        .then(data => {
            displayItems(data, keyword, outerResults, button); //display results
        })
        .catch(error => console.error('Error:', error));

    //Show More Button
    let showMore = false;
    showMoreButton.addEventListener('click', function () {
        const allResults = outerResults.querySelectorAll('.results');

        if (showMore) {
            allResults.forEach((result, index) => {
                if (index >= 3) {
                    result.style.display = 'none';
                }
            });
            showMoreButton.textContent = 'Show More';
        } else {
            allResults.forEach(result => {
                result.style.display = 'flex';
            });
            showMoreButton.textContent = 'Show Less';
        }
        showMore = !showMore;
    });
});

function isValidPrice(maxPrice, minPrice) {
    if (maxPrice < 0 || minPrice < 0) {
        // Display an error message for the price
        alert('Price Range Values cannot be negative! Please try a value greater than or equal to 0.0');
        return false;
    } else if (maxPrice < minPrice && maxPrice) {
        alert("Oops! Lower price limit cannot be greater than upper price limit! Please try again.")
        return false
    } else {
        return true
    }
}

function updateSearchTitleNoResults(outerResults) {
    const searchTitle = document.querySelector('.search-title');
    searchTitle.innerHTML = '';

    // Create a paragraph element for the "No results found" message
    const noResultsParagraph = document.createElement('p');
    noResultsParagraph.textContent = 'No results found';
    noResultsParagraph.style.fontWeight = 'bold';
    noResultsParagraph.style.marginTop = '20px'; // Customize styling as needed

    // Append the "No results found" message to the searchTitle element
    searchTitle.appendChild(noResultsParagraph);

    outerResults.innerHTML = '';
    showMoreButton.style.display = 'none';
}

function displayItems(data, keyword, outerResults, button) {
    const totalResults = data.findItemsAdvancedResponse[0].paginationOutput[0].totalEntries[0];
    const results = data.findItemsAdvancedResponse[0].searchResult[0].item;
    const page = document.getElementById("page")

    if (totalResults == 0) {
        // Update the search title with "No results found"
        updateSearchTitleNoResults(outerResults);
        return;
    }

    // search-title
    const searchTitle = document.querySelector('.search-title');
    searchTitle.innerHTML = '';
    const paragraph = document.createElement('p');

    paragraph.innerHTML = `<b><span id="totalResultsFound"></span> Results found for <i><span id="searchKeyword"></span></i></b>`;

    const hr = document.createElement('hr');

    searchTitle.appendChild(paragraph);
    searchTitle.appendChild(hr);

    const totalResultsFound = document.getElementById('totalResultsFound');
    totalResultsFound.textContent = totalResults;

    const searchKeyword = document.getElementById('searchKeyword');
    searchKeyword.textContent = keyword;

    // outer-results
    outerResults.innerHTML = '';

    results.forEach((item, index) => {
        const imageURL = item.galleryURL[0];
        const title = item.title[0];
        const category = item.primaryCategory[0].categoryName[0];

        let condition = '';
        try {
            condition = item.condition[0].conditionDisplayName[0];
        } catch (error) {
            condition = 'Unknown';
        }


        const price = parseFloat(item.sellingStatus[0].convertedCurrentPrice[0].__value__);

        let shippingCost = 0.00;
        try {
            shippingCost = parseFloat(item.shippingInfo[0].shippingServiceCost[0].__value__);
        } catch (error) {
            shippingCost = 0.00;
        }

        const priceString = `Price: $${price.toFixed(2)}${shippingCost >= 0.01 ? ` (+ $${shippingCost.toFixed(2)} for shipping)` : ''}`;

        const resultContainer = document.createElement('div');
        resultContainer.classList.add('results');
        resultContainer.setAttribute('item-id', item.itemId);


        const imageContainer = document.createElement('div');
        imageContainer.classList.add('image-container');

        const image = document.createElement('img');
        checkImage(image, imageURL)

        const resultDetails = document.createElement('div');
        resultDetails.classList.add('result-details');

        const titleContainer = document.createElement('p');
        titleContainer.innerHTML = `<strong>${title}</strong>`;

        const categoryContainer = document.createElement('p');
        categoryContainer.innerHTML = `Category: <i>${category}</i> <a href="${item.viewItemURL[0]}" target='_blank'><img class="redirect" id="redirect" src="https://csci571.com/hw/hw6/images/redirect.png"></a>`;

        const conditionContainer = document.createElement('p');
        conditionContainer.classList.add('condition-container');
        if (item.topRatedListing[0] === 'true') {
            conditionContainer.innerHTML = `Condition: ${condition} <div class="condition-parent"><img class="condition" src="https://csci571.com/hw/hw6/images/topRatedImage.png"></div>`;
        } else {
            conditionContainer.innerHTML = `Condition: ${condition}`;
        }

        const priceContainer = document.createElement('p');
        priceContainer.innerHTML = `<strong>${priceString}</strong>`;

        imageContainer.appendChild(image);
        resultDetails.appendChild(titleContainer);
        resultDetails.appendChild(categoryContainer);
        resultDetails.appendChild(conditionContainer);
        resultDetails.appendChild(priceContainer);

        resultContainer.appendChild(imageContainer);
        resultContainer.appendChild(resultDetails);

        outerResults.appendChild(resultContainer);

        // Create a click event listener for each result
        resultContainer.addEventListener('click', function (event) {
            if (event.target.id === "redirect") {
                return
            } else {
                // Access the Item ID from the data attribute
                const itemId = resultContainer.getAttribute('item-id');

                // Construct the Flask URL with the itemId
                let url = `/searchItem?itemid=${encodeURIComponent(itemId)}`; // Replace with your actual Flask endpoint

                // Fetch the data using the constructed URL
                fetch(url)
                    .then(response => response.json())
                    .then(data => {
                        // Handle the response data as needed
                        displayItem(data, priceString)
                        // Toggle the display of outerResults
                        togglePage(outerResults, searchTitle, button)
                    })
                    .catch(error => console.error('Error:', error));
            }
        });

        if (index >= 3) {
            resultContainer.style.display = 'none'; // Hide items after the first 3
        }
    });

    if (totalResults <= 3) {
        button.style.display = 'none'
    } else {
        button.style.display = 'block'
    }

    page.style.display = ""
}

function checkImage(image, imageURL) {
    if (imageURL == '') {
        image.src = 'data:image/png;base64,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'
    } else {
        image.src = imageURL
    }
}

function constructURL(queryString, minPriceInput, maxPriceInput, checkboxes, seller, free, expeditedShipping, sortBy) {
    let url = `/search?keyword=${encodeURIComponent(queryString)}&`;

    const conditionMapping = {
        new: 1000,
        used: 3000,
        veryGood: 4000,
        good: 5000,
        acceptable: 6000
    };

    const checkedConditions = Array.from(checkboxes).map(checkbox => conditionMapping[checkbox.getAttribute('id')]);

    const params = {};
    let argCount = 0;
    let value = 0;

    if (checkedConditions.length > 0) {
        params[`itemFilter(${argCount}).name`] = "Condition";

        for (const condition of checkedConditions) {
            params[`itemFilter(${argCount}).value(${value})`] = condition;
            value++;
        }

        argCount++;
    }

    for (const [key, value] of Object.entries(params)) {
        url += `${key}=${value}&`;
    }

    const sortByMapping = {
        "Best Match": "BestMatch",
        "Price: highest first": "CurrentPriceHighest",
        "Price + Shipping: highest first": "PricePlusShippingHighest",
        "Price + Shipping: lowest first": "PricePlusShippingLowest",
    }

    // Extract the names of the checked checkboxes and map them to values

    if (sortBy.value) {
        url += `sortOrder=${encodeURIComponent(sortByMapping[sortBy.value])}&`;
    }

    if (free.checked) {
        url += `itemFilter(${encodeURIComponent(argCount)}).name=FreeShippingOnly&itemFilter(${encodeURIComponent(argCount)}).value(0)=true&`;
        argCount++
    }

    if (expeditedShipping.checked) {
        url += `itemFilter(${encodeURIComponent(argCount)}).name=ExpeditedShippingType&itemFilter(${encodeURIComponent(argCount)}).value(0)=Expedited&`;
        argCount++
    }

    if (minPriceInput) {
        url += `itemFilter(${encodeURIComponent(argCount)}).name=MinPrice&itemFilter(${encodeURIComponent(argCount)}).value(0)=${encodeURIComponent(minPriceInput)}&`;
    argCount++
    }

    if (maxPriceInput) {
        url += `itemFilter(${encodeURIComponent(argCount)}).name=MaxPrice&itemFilter(${encodeURIComponent(argCount)}).value(0)=${encodeURIComponent(maxPriceInput)}&`;
    argCount++
    }

    if (seller.checked) {
        url += `itemFilter(${encodeURIComponent(argCount)}).name=ReturnsAcceptedOnly&itemFilter(${encodeURIComponent(argCount)}).value(0)=true&`;
        argCount++
    }

    // Remove the trailing "&" from the URL
    url = url.slice(0, -1);


    return url;
}

function displayItem(data, priceString) {
    const table = document.getElementById('itemDetails');
    const itemContainer = document.getElementById('itemContainer')
    const tbody = table.querySelector('tbody');

    itemContainer.style.display = "flex"
    tbody.innerHTML = ''

    // Create table rows and cells for each detail
    const details = [
        ['Photo', `<img src="${data.Item.PictureURL[0]}" alt="Item Photo" width='300px'>`],
        ['eBay Link', `<a href="${data.Item.ViewItemURLForNaturalSearch}" target="_blank">ebay Product Link</a>`],
        ['Title', data.Item.Title],
        ['Price', `${priceString.split("Price: ")[1]}`],
        ['Location', data.Item.Location],
        ['Seller', data.Item.Seller.UserID],
        ['Return Policy (US)', data.Item.ReturnPolicy.ReturnsAccepted],
    ];

    // Populate the table with details
    details.forEach(([label, value]) => {
        const row = tbody.insertRow();
        const cell1 = row.insertCell(0);
        const cell2 = row.insertCell(1);
        cell1.innerHTML = `<strong>${label}</strong>`;
        cell2.innerHTML = value;
    });

    // Populate ItemSpecifics dynamically
    data.Item.ItemSpecifics.NameValueList.forEach(item => {
        const row = tbody.insertRow();
        const cell1 = row.insertCell(0);
        const cell2 = row.insertCell(1);
        cell1.innerHTML = `<strong>${item.Name}</strong>`;
        cell2.textContent = item.Value;
    });
}

function togglePage() {
    const page = document.getElementById("page")
    const itemContainer = document.getElementById("itemContainer")
    const back = document.getElementById('back')

    page.style.display = "none"

    back.addEventListener('click', function () {
        page.style.display = 'flex'
        itemContainer.style.display = 'none'
    })
}

document.getElementById('searchForm').addEventListener('reset', function () {
    const page = document.getElementById("page")
    const itemContainer = document.getElementById("itemContainer")

    page.style.display = "none"
    itemContainer.style.display = "none"
})

