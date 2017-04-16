# UPDATE DATA FOR EACH LISTINGS
# Derek Mingyu MA, http://derek.ma, https://github.com/derekmma
# This R program will get listing urls for csv file and then
# grab latest price from Airbnb.com web app and 
# save to new columns, and then save the updated data frame to a new csv file

##### SETTING PART #####
#SET PATH TO CSV FILE
path <- "/Users/derek/Google Drive/Proj/airbnb-price-detector/listings_2017-04-15.csv"
date <- Sys.Date()

# SET ENVIRONMENT
# If you havnen't install these libs, please run following lines to install them
# install.packages("rvest")
# install.packages("httr")
# install.packages("xml2")
# install.packages("RSelenium")
# install.packages("stringr")
# install.packages("dplyr")
library(rvest)
library(httr)
library(xml2)
library(RSelenium)
library(stringr)
library(dplyr)

##### SOURCE PART #####

# FUNCTION: GRAB INFORMATION FOR A LISTING
roomInfo <- function(sublink,remDr) {
  base <- "https://www.airbnb.com"
  url <- paste(base, sublink, sep = '')
  remDr$navigate(url)
  regexp <- "(\\d)+"
  
  roomName <- tryCatch({
    suppressMessages({
      roomNameSrc <- remDr$findElement(value = "//div[@id = 'listing_name']")
      roomNameSrc$getElementText()
    })
  }, 
  error = function(e) {
    NA
  })
  
  roomPrice <- tryCatch({
    suppressMessages({
      roomPriceSrc <- remDr$findElement(value = "//span[@class = 'priceAmountWrapper_17axpax']")
      temp1 <- roomPriceSrc$getElementText()[[1]]
      temp2 <- str_extract_all(temp1, regexp)
      paste(temp2[[1]], collapse = '')
    })
  }, 
  error = function(e) {
    NA
  })
  
  if (is.na(roomPrice)){
    roomPrice <- tryCatch({
      suppressMessages({
        roomPriceSrc <- remDr$findElement(value = "//meta[@itemprop = 'price']")
        temp1 <- roomPriceSrc$getElementAttribute("content")[[1]]
        temp2 <- str_extract_all(temp1, regexp)
        paste(temp2[[1]], collapse = '')
      })
    }, 
    error = function(e) {
      NA
    })
  }
  
  roomPriceTotal <- tryCatch({
    suppressMessages({
      roomPriceTotalSrc <- remDr$findElement(value = "//td[@class='text-right']/span[@class = 'text_5mbkop-o_O-size_small_1gg2mc-o_O-weight_bold_153t78d-o_O-inline_g86r3e']")
      temp1 <- roomPriceTotalSrc$getElementText()[[1]]
      temp2 <- str_extract_all(temp1, regexp)
      paste(temp2[[1]], collapse = '')
    })
  }, 
  error = function(e) {
    NA
  })
  
  c(roomName,roomPrice,roomPriceTotal)
}


# GET DATA FOR CSV and ADD COLUMNS
listings <- read.csv(path, stringsAsFactors = FALSE)
listings <- listings[,-1]
listings[[paste0("price_",date)]] <- NA
listings[[paste0("totalPrice_",date)]] <- NA
# START SERVER
rD <- rsDriver()
remDr <- rD[["client"]]
colPrice <- paste("price",date,sep="_")
colTotalPrice <- paste("totalPrice",date,sep="_")
for (i in 1:nrow(listings)){
  info <- roomInfo(listings[i,"url"],remDr)
  print(info)
  listings[i,"name"] <- info[1]
  listings[i,colPrice] <- info[2]
  listings[i,colTotalPrice] <- info[3]
}
rD[["server"]]$stop()

# EXPORT CSV
temp <- paste("listings",date,sep="_")
fileName <- paste0(temp,".csv")
write.csv(listings, file = fileName)
