# GET INITIAL LISTINGS LIST
# Derek Mingyu MA, http://derek.ma, https://github.com/derekmma
# This R program will get listing urls for cities according to
# the natural searching results from Airbnb.com web app

# CAUTION: becuase of low loading speed, some data may be NA
# SOL: please try again and adjust records by manually

##### SETTING PART #####

# SET PARAMETER
# 1- City Lists
#   need be exactly the city name used in Airbnb
#   which can obtain this by search on Airbnb.com and observe the query url
cities <- c("Hong-Kong",
           "Shanghai--China",
           "Beijing--China",
           "Chengdu--Sichuan--China",
           "New-York--NY--United-States",
           "London--United-Kingdom",
           "Tokyo--Japan")
# 2- Check In and Out Date
dateCheckIn <- "2017-05-01"
dateCheckOut <- "2017-05-02"

# 3- Number of Listings For Each City
#   total sample size: num*num(cities)
numSample <- 200

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
getInitialRoomUrlList <- function(city, checkInDate, checkOutDate, num){
  #each round can get 18 results
  numRound <- num%/%18 + 1
  roomsLink <- vector(mode="character", length=0)
  for (round in 1:numRound){
    base1 <- "https://www.airbnb.com/s/"
    base2 <- "/homes?allow_override%5B%5D=&checkin="
    base3 <- "&checkout="
    base4 <- "&section_offset="
    temp1 <- paste(base1, city, sep = '')
    temp2 <- paste(temp1, base2, sep = '')
    temp3 <- paste(temp2, checkInDate, sep = '')
    temp4 <- paste(temp3, base3, sep = '')
    temp5 <- paste(temp4, checkOutDate, sep = '')
    if (round == 1){
      queryurl <- temp5
    }else{
      temp6 <- paste(temp5, base4, sep = '')
      queryurl <- paste(temp6, round-1, sep = '')
    }
    #remDr$navigate(queryurl)
    #src <- remDr$findElement(value = "//a[@class = 'linkContainer_55zci1']")
    #thisPageResult <- sapply(src, function(x) x$getElementAttribute('href'))
    
    session <- read_html(queryurl)
    thisPageResult <- session %>%
      html_nodes(".linkContainer_55zci1")%>%
      html_attr("href")
    roomsLink <- as.vector(rbind(roomsLink,thisPageResult)) 
  }
  result <- data.frame(url = roomsLink[1:num],
                       name = NA,
                       city = city,
                       checkInDate = checkInDate, 
                       checkOutDate = checkOutDate)
  result
}

# GET DATA FOR EACH CITY AND COMBINE
listings <- data.frame(matrix(ncol = 5, nrow = 0))
colnames(listings) <- c("url","name","city","checkInDate","checkOutDate")
for (city in cities){
  cityListings <- 
    getInitialRoomUrlList(city,dateCheckIn,dateCheckOut,numSample)
  listings <- rbind(listings,cityListings)
}

# EXPORT CSV
write.csv(listings, file = "listings.csv")