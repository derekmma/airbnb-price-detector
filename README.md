# Airbnb Price Detector

Derek Mingyu MA  
[derek.ma](http://derek.ma)  
[derek.ma/airbnb-price-detector](http://derek.ma/airbnb-price-detector)

This is a series of R programs that enables users to create initial listings URLs and update these listings' prices automatically. 

## Data Source

Price and Listings information is grabbed from Airbnb web app.

## How to Use?

### Step1: Set up R and related libraries

A few libraries are needed. Please run the following codes to install them if you haven't

```
install.packages("rvest")
install.packages("httr")
install.packages("xml2")
install.packages("RSelenium")
install.packages("stringr")
install.packages("dplyr")
```

### Step2: Download Codes

Please clone or download codes from GitHub. Two R programs are needed:

* [`getInitialListings.R`](https://github.com/derekmma/airbnb-price-detector/blob/master/getInitialListings.R)
* [`updateListings.R`](https://github.com/derekmma/airbnb-price-detector/blob/master/updateListings.R)

### Step3: Get Initial Listings

Please run `getInitialListings.R`. Following parameters need be declared at the beginning of the file:

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

A sample is shown here: [listings.csv](https://github.com/derekmma/airbnb-price-detector/blob/master/listings.csv).

### Step4: Get Updated Listings Info

Run `updateListings.R` and claim the previous file path at the beginning of the program.

A sample input data is shown here: [test.csv](https://github.com/derekmma/airbnb-price-detector/blob/master/test.csv).

Then the program will open corresponding pages for each listings imported from the csv file by _Google Chrome_.

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

A sample output file is shown here: [listings_2017-04-14](https://github.com/derekmma/airbnb-price-detector/blob/master/listings_2017-04-14.csv).


