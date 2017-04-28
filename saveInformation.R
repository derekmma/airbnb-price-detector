# UPDATE DATA FOR EACH LISTINGS
# Derek Mingyu MA, http://derek.ma, https://github.com/derekmma
# This R program will get listing urls for csv file and then
# grab latest price from Airbnb.com web app and 
# save to new columns, and then save the updated data frame to a new csv file

##### SETTING PART #####
#SET PATH TO CSV FILE
path <- "/Users/derek/Google Drive/Proj/airbnb-price-detector/listings.csv"
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
  
  numOfReviews <- tryCatch({
    suppressMessages({
      numOfReviewsSrc <- remDr$findElement(value = "//span[@class='text_5mbkop-o_O-size_large_16mhv7y-o_O-inline_g86r3e']/span")
      temp1 <- numOfReviewsSrc$getElementText()[[1]]
      temp2 <- str_extract_all(temp1, regexp)
      paste(temp2[[1]], collapse = '')
    })
  }, 
  error = function(e) {
    NA
  })
  
  ratingAverage <- tryCatch({
    suppressMessages({
      ratingAverageSrc <- remDr$findElement(value="//div[@class='overallStarRating_stars_1cuccsz']/div[@class='star-rating-wrapper']")
      temp <- ratingAverageSrc$getElementAttribute("aria-label")[[1]]
      gsub('Average (.*) out of 5 stars','\\1',temp)
    })
  }, 
  error = function(e) {
    NA
  })
  
  ratingSrc <- tryCatch({
    suppressMessages({
      remDr$findElements(value="//div[@class='star-rating-wrapper']")
    })
  }, 
  error = function(e) {
    NA
  })
  
  if (length(ratingSrc)==0){
    ratingAccuracy <- NA
    ratingCommunication <- NA
    ratingCleanliness <- NA
    ratingLocation <- NA
    ratingCheckIn <- NA
    ratingValue <- NA
  }else{
    ratingAccuracy1 <- ratingSrc[[4]]$getElementAttribute("aria-label")
    ratingAccuracy <- gsub('Average (.*) out of 5 stars','\\1',ratingAccuracy1)
    
    ratingCommunication1 <- ratingSrc[[5]]$getElementAttribute("aria-label")
    ratingCommunication <- gsub('Average (.*) out of 5 stars','\\1',ratingCommunication1)
    
    ratingCleanliness1 <- ratingSrc[[6]]$getElementAttribute("aria-label")
    ratingCleanliness <- gsub('Average (.*) out of 5 stars','\\1',ratingCleanliness1)
    
    ratingLocation1 <- ratingSrc[[7]]$getElementAttribute("aria-label")
    ratingLocation <- gsub('Average (.*) out of 5 stars','\\1',ratingLocation1)
    
    ratingCheckIn1 <- ratingSrc[[8]]$getElementAttribute("aria-label")
    ratingCheckIn <- gsub('Average (.*) out of 5 stars','\\1',ratingCheckIn1)
    
    ratingValue1 <- ratingSrc[[9]]$getElementAttribute("aria-label")
    ratingValue <- gsub('Average (.*) out of 5 stars','\\1',ratingValue1)
  }

  
  capacitySrc <- tryCatch({
    suppressMessages({
      remDr$findElements(value="//div[@class='row row-condensed text-muted text-center hide-sm']/div/div/span")
    })
  }, 
  error = function(e) {
    NA
  })
  
  if(length(capacitySrc)==4){
    capacityRoomType <- capacitySrc[[1]]$getElementText()
    capacityNumGuests <- capacitySrc[[2]]$getElementText()
    capacityNumBedrooms <- capacitySrc[[3]]$getElementText()
    capacityNumBeds <- capacitySrc[[4]]$getElementText()
  }
  else if(length(capacitySrc)==3){
    capacityRoomType <- capacitySrc[[1]]$getElementText()
    capacityNumGuests <- capacitySrc[[2]]$getElementText()
    capacityNumBedrooms <- capacitySrc[[3]]$getElementText()
    capacityNumBeds <- NA
  }else if(length(capacitySrc)==2){
    capacityRoomType <- capacitySrc[[1]]$getElementText()
    capacityNumGuests <- capacitySrc[[2]]$getElementText()
    capacityNumBedrooms <- NA
    capacityNumBeds <- NA
  }else{
    capacityRoomType <- NA
    capacityNumGuests <- NA
    capacityNumBedrooms <- NA
    capacityNumBeds <- NA
  }
  
  amenitiesSrc <- tryCatch({
    suppressMessages({
      remDr$findElements(value="//div[@class='row amenities']/div[@class='col-md-9 expandable']/div[@class='expandable-content expandable-content-full']/div[@class='row']/div[@class='col-sm-6']/div/div[@class='space-1 bottom-spacing-2']/span/i")
    })
  }, 
  error = function(e) {
    NA
  })
  
  amenities<-c()
  
  for (env in amenitiesSrc){
    temp1 <- env$getElementAttribute("class")
    temp2 <- gsub('icon h3 icon-(.*)','\\1',temp1)
    amenities<-c(amenities,temp2)
  }
  
  if(is.element('parking', amenities)==TRUE){
    amenitiesParking <- 1
  }
  else{
    amenitiesParking <- 0
  }
  if(is.element('paw', amenities)==TRUE){
    amenitiesPets <- 1
  }
  else{
    amenitiesPets <- 0
  }
  if(is.element('fireplace', amenities)==TRUE){
    amenitiesFireplace <- 1
  }
  else{
    amenitiesFireplace <- 0
  }
  if(is.element('smoking', amenities)==TRUE){
    amenitiesSmoking <- 1
  }
  else{
    amenitiesSmoking <- 0
  }
  if(is.element('pool', amenities)==TRUE){
    amenitiesPool <- 1
  }
  else{
    amenitiesPool <- 0
  }
  if(is.element('hangers', amenities)==TRUE){
    amenitiesHangers <- 1
  }
  else{
    amenitiesHangers <- 0
  }
  if(is.element('cup', amenities)==TRUE){
    amenitiesBreakfast <- 1
  }
  else{
    amenitiesBreakfast <- 0
  }
  if(is.element('internet', amenities)==TRUE){
    amenitiesInternet <- 1
  }
  else{
    amenitiesInternet <- 0
  }
  if(is.element('elevator', amenities)==TRUE){
    amenitiesElevator <- 1
  }
  else{
    amenitiesElevator <- 0
  }
  if(is.element('meal', amenities)==TRUE){
    amenitiesKitchen <- 1
  }
  else{
    amenitiesKitchen <- 0
  }
  if(is.element('family', amenities)==TRUE){
    amenitiesFamily <- 1
  }
  else{
    amenitiesFamily <- 0
  }
  if(is.element('accessible', amenities)==TRUE){
    amenitiesAccessible <- 1
  }
  else{
    amenitiesAccessible <- 0
  }
  if(is.element('wifi', amenities)==TRUE){
    amenitiesWifi <- 1
  }
  else{
    amenitiesWifi <- 0
  }
  if(is.element('balloons', amenities)==TRUE){
    amenitiesEvents <- 1
  }
  else{
    amenitiesEvents <- 0
  }
  if(is.element('dryer', amenities)==TRUE){
    amenitiesDryer <- 1
  }
  else{
    amenitiesDryer <- 0
  }
  if(is.element('desktop', amenities)==TRUE){
    amenitiesDesktop <- 1
  }
  else{
    amenitiesDesktop <- 0
  }
  if(is.element('hot-tub', amenities)==TRUE){
    amenitiesHottub <- 1
  }
  else{
    amenitiesHottub <- 0
  }
  if(is.element('heating', amenities)==TRUE){
    amenitiesHeating <- 1
  }
  else{
    amenitiesHeating <- 0
  }
  if(is.element('laptop', amenities)==TRUE){
    amenitiesLaptop <- 1
  }
  else{
    amenitiesLaptop <- 0
  }
  if(is.element('hangers', amenities)==TRUE){
    amenitiesHangers <- 1
  }
  else{
    amenitiesHangers <- 0
  }
  if(is.element('doorman', amenities)==TRUE){
    amenitiesDoorman <- 1
  }
  else{
    amenitiesDoorman <- 0
  }
  if(is.element('gym', amenities)==TRUE){
    amenitiesGym <- 1
  }
  else{
    amenitiesGym <- 0
  }
  if(is.element('iron', amenities)==TRUE){
    amenitiesIron <- 1
  }
  else{
    amenitiesIron <- 0
  }
  if(is.element('hair-dryer', amenities)==TRUE){
    amenitiesHairdryer <- 1
  }
  else{
    amenitiesHairdryer <- 0
  }
  if(is.element('washer', amenities)==TRUE){
    amenitiesWasher <- 1
  }
  else{
    amenitiesWasher <- 0
  }
  if(is.element('essentials', amenities)==TRUE){
    amenitiesEssentials <- 1
  }
  else{
    amenitiesEssentials <- 0
  }
  if(is.element('shampoo', amenities)==TRUE){
    amenitiesShampoo <- 1
  }
  else{
    amenitiesShampoo <- 0
  }
  if(is.element('tv', amenities)==TRUE){
    amenitiesTv <- 1
  }
  else{
    amenitiesTv <- 0
  }
  if(is.element('air-conditioning', amenities)==TRUE){
    amenitiesAc <- 1
  }
  else{
    amenitiesAc <- 0
  }
  
  c(roomName,roomPrice,roomPriceTotal,numOfReviews,
    ratingAverage,ratingAccuracy,ratingCommunication,
    ratingCleanliness,ratingLocation,ratingCheckIn,ratingValue,
    capacityRoomType,capacityNumGuests,capacityNumBedrooms,capacityNumBeds,
    amenitiesParking,amenitiesPets,amenitiesFireplace,amenitiesSmoking,
    amenitiesPool,amenitiesHangers,amenitiesBreakfast,
    amenitiesInternet,amenitiesElevator,amenitiesKitchen,
    amenitiesFamily,amenitiesAccessible,amenitiesWifi,
    amenitiesEvents,amenitiesDryer,amenitiesDesktop,
    amenitiesHottub,amenitiesHeating,amenitiesLaptop,
    amenitiesHangers,amenitiesDoorman,amenitiesGym,
    amenitiesIron,amenitiesHairdryer,amenitiesWasher,
    amenitiesEssentials,amenitiesShampoo,amenitiesTv,
    amenitiesAc)
}


# GET DATA FOR CSV and ADD COLUMNS
# if you run this program from the beginning, set startCount to 1
# otherwise set startCount to the record it stops
amenitiesProperties <- c(
  'amenitiesParking','amenitiesPets','amenitiesFireplace',
  'amenitiesSmoking','amenitiesPool','amenitiesHangers',
  'amenitiesBreakfast','amenitiesInternet','amenitiesElevator',
  'amenitiesKitchen','amenitiesFamily','amenitiesAccessible',
  'amenitiesWifi','amenitiesEvents','amenitiesDryer',
  'amenitiesDesktop','amenitiesHottub','amenitiesHeating',
  'amenitiesLaptop','amenitiesHangers','amenitiesDoorman',
  'amenitiesGym','amenitiesIron','amenitiesHairdryer',
  'amenitiesWasher','amenitiesEssentials','amenitiesShampoo',
  'amenitiesTv','amenitiesAc'
)
otherInfo <- c(
  'numOfReviews','ratingAverage','ratingAccuracy','ratingCommunication',
  'ratingCleanliness','ratingLocation','ratingCheckIn','ratingValue',
  'capacityRoomType','capacityNumGuests','capacityNumBedrooms','capacityNumBeds'
)
startCount <- 2
if (startCount == 1){
  listings <- read.csv(path, stringsAsFactors = FALSE)
  listings <- listings[,-1]
  listings[["price"]] <- NA
  listings[["totalPrice"]] <- NA
  for(thisColName in otherInfo){
    listings[[thisColName]] <- NA
  }
  for(property in amenitiesProperties){
    listings[[property]] <- NA
  }
} else {
  rD[["server"]]$stop()
}
# START SERVER
rD <- rsDriver(browser="firefox")
remDr <- rD[["client"]]
colPrice <- "price"
colTotalPrice <- "totalPrice"

for (i in startCount:nrow(listings)){
  info <- roomInfo(listings[i,"url"],remDr)
  print(i)
  #print(info)
  listings[i,"name"] <- info[1]
  listings[i,colPrice] <- info[2]
  listings[i,colTotalPrice] <- info[3]
  count <- 4
  for(thisColName in otherInfo){
    listings[i,thisColName] <- info[count]
    count <- count + 1
  }
  for(property in amenitiesProperties){
    listings[i,property] <- info[count]
    count <- count + 1
  }
}
rD[["server"]]$stop()

# EXPORT CSV
temp <- paste("listings",date,sep="_")
fileName <- paste0(temp,".csv")
fileName1 <- "listingsInfo.csv"
write.csv(listings, file = fileName1)
