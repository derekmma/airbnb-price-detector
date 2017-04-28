# Airbnb Price Detector

Derek Mingyu MA  
[derek.ma](http://derek.ma)  
[derek.ma/airbnb-price-detector](http://derek.ma/airbnb-price-detector)

This is a series of R programs that enables users to create initial listings URLs and update these listings' prices automatically. You can also use this R programs to grab different comprehensive information about listings on Airbnb.

## Data Source

Price and Listings information is grabbed from Airbnb web app.

## Set Up

A few libraries are needed. Please run the following codes to install them if you haven't

```
install.packages("rvest")
install.packages("httr")
install.packages("xml2")
install.packages("RSelenium")
install.packages("stringr")
install.packages("dplyr")
```

## Function1: Create Initial Listings on Airbnb

Use the R program `getInitialListings.R` to get initial listings with url, city and check in/out date:

* [`getInitialListings.R`](https://github.com/derekmma/airbnb-price-detector/blob/master/getInitialListings.R)

Following parameters need be declared at the beginning of the file:

#### `cities`
* cities that you would like to get listings
* please use the city code that Airbnb
* you can find the city code through make a query from Airbnb official web app and observe the query url

#### `dateCheckIn`
* the check in date
* please follow the format: "YYYY-MM-DD"

#### `dateCheckOut`
* the check out date
* please follow the format: "YYYY-MM-DD"

#### `numSample`
* sample size for _each_ city

Then a csv file called `listings.csv` will be exported to the root directory.

Output is a csv that contain url, city and check in/out date. 

## Function2: Update Prices of Different Days

Input a initial listings table and get prices and total prices of listings:

* [`updateListings.R`](https://github.com/derekmma/airbnb-price-detector/blob/master/updateListings.R)

Run `updateListings.R` and claim the previous file path at the beginning of the program.

Then the program will open corresponding pages for each listings imported from the csv file by _Firefox_.

The program will update the `name` for each listings and add two new columns to the data frame which are:

#### `price_YYYY-MM-DD`

* This is the basic price for one night
* Sometimes is `NA`, which is because the program cannot grab this information automatically
* There are two approaches to grab this information which are both included in the program, so that the error rate can be decreased
* `YYYY-MM-DD` is the date when you run this program

#### `totalPrice_YYYY-MM-DD`

* This is the price including room prices, service fee and cleaning fee
* Sometimes it can be `NA`, the reason is the same as the `price_YYYY-MM-DD` above.

Finally, a new file called `listings_YYYY-MM-DD.csv` will be saved to your root directory where `YYYY-MM-DD` is the date you run the program. The exported csv file can be used to run `updateListings.R` again.

## Function3: Grab Comprehensive Info of Listings

Run `getInformation.R` to get rating, review numbers, amenities information about the listings:

* [`getInformation.R`](https://github.com/derekmma/airbnb-price-detector/blob/master/getInformation.R)

## Sample I/O File

#### Function 1 Sample

* Input: no need
* Output: [`listings.csv`](https://github.com/derekmma/airbnb-price-detector/blob/master/sampleData_2/listings.csv)

#### Function 2 Sample

* Input: [`listings.csv`](https://github.com/derekmma/airbnb-price-detector/blob/master/sampleData_2/listings.csv)
* Output: [`listings_2017-04-18.csv`](https://github.com/derekmma/airbnb-price-detector/blob/master/sampleData_2/listings_2017-04-18.csv)

#### Function 3 Sample

* Input: [`listings_1.csv`](https://github.com/derekmma/airbnb-price-detector/blob/master/sampleData_1/listings_1.csv)
* Output: [`listingsInfo_1.csv`](https://github.com/derekmma/airbnb-price-detector/blob/master/sampleData_1/listingsInfo_1.csv)

