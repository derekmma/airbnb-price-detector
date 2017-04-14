# UPDATE DATA FOR EACH LISTINGS
# Derek Mingyu MA, http://derek.ma, https://github.com/derekmma
# This R program will get listing urls for csv file and then
# grab latest price from Airbnb.com web app and 
# save to new columns, and then save the updated data frame to a new csv file

##### SETTING PART #####
#SET PATH TO CSV FILE
path <- ""

# SET ENVIRONMENT
# If you havnen't install these libs, please run following lines to install them
# install.packages("rvest")
# install.packages("httr")
# install.packages("xml2")
# install.packages("RSelenium")
# install.packages("stringr")
library(rvest)
library(httr)
library(xml2)
library(RSelenium)
library(stringr)

##### SOURCE PART #####

# FUNCTION: VISIT SEARCH PAGES AND GRAB URL INFORMATION
roomInfo <- function(sublink,remDr) {
  base <- "https://www.airbnb.com"
  url <- paste(base, sublink, sep = '')
  remDr$navigate(url)
  roomNameSrc <- remDr$findElement(value = "//div[@id = 'listing_name']")
  roomName <- roomNameSrc$getElementText()
  roomPriceSrc <- remDr$findElement(value = "//meta[@itemprop = 'price']")
  roomPrice <- roomPriceSrc$getElementAttribute("content")
  roomPriceTotalSrc <- remDr$findElement(value = "//td[@class='text-right']/span[@class = 'text_5mbkop-o_O-size_small_1gg2mc-o_O-weight_bold_153t78d-o_O-inline_g86r3e']")
  roomPriceTotal <- roomPriceTotalSrc$getElementText()
  regexp <- "[[:digit:]]+"
  roomName <- roomName[[1]]
  roomPrice <- roomPrice[[1]]
  roomPriceTotal <- str_extract(roomPriceTotal[1], regexp)
  c(roomName,roomPrice,roomPriceTotal)
}

# GET DATA FOR EACH CITY AND COMBINE
rD <- rsDriver()
remDr <- rD[["client"]]
for (city in cities){
  cityListings <- 
    getInitialRoomUrlList(city,dateCheckIn,dateCheckOut,numSample)
  listings <- rbind(listings,cityListings)
}

# EXPORT CSV
write.csv(listings, file = "listings_update.csv")