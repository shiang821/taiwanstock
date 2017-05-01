# 2017-04-30
library(magrittr)
library(RSelenium)
library(stringr)
library(dplyr)
library(lubridate)


# ----- 1. Terminal version -----
# terminal start

# config_data <- commandArgs(trailingOnly = TRUE)
# # select date_range
# start_date  <- config_data[1] %>% as.Date
# end_date    <- config_data[2] %>% as.Date
# date_index <- seq(start_date, end_date, by = "month")
# years <- str_sub(date_index, start = 1, end = 4) %>% as.integer %>% subtract(1911)
# months <- str_sub(date_index, start = 6, end = 7) %>% as.integer
# date_range <- data.frame(years, months, stringsAsFactors = FALSE)
#
# # select stock no
# stock_no <- config_data[3]
#
# # start the selenium server
# # start a chrome browser
# rD <- rsDriver()
# remDr <- rD[["client"]]
# # remDr$open(silent = TRUE)
#
# # target net
# url <- "http://www.twse.com.tw/ch/trading/exchange/STOCK_DAY/STOCK_DAYMAIN.php"
# remDr$navigate(url)
#
# # auto write stock number for web browser
# write_stock_no <- remDr$findElement(using = 'xpath', value = '//input[@name = "CO_ID"]')
# # write_stock_no$getElementAttribute('name')
# write_stock_no$sendKeysToElement(list(stock_no))
#
# for (i in 1:nrow(date_range)){
#   # select year for web browser
#   select_year <- remDr$findElement(using = 'xpath', value = '//select[@name = "query_year"]')
#   select_year$sendKeysToElement(list(sprintf("%s", date_range[i,"years"])))
#   Sys.sleep(1)
#
#   # select month for web browser
#   select_month <- remDr$findElement(using = 'xpath', value = '//select[@name = "query_month"]')
#   select_month$selectTag()$elements[[date_range[i,"months"]]]$clickElement()
#   Sys.sleep(1)
#
#   # click query button for web browser
#   click_query_button <- remDr$findElement(using = 'xpath', value = '//input[@name = "query-button"]')
#   click_query_button$clickElement()
#
#   # click download button for web browser
#   click_download_button <- remDr$findElement(using = 'xpath', value = '//button[@class = "dl-csv board"]')
#   click_download_button$clickElement()
#
#   sleep_sencond <- sample.int(n = 2, size = 1)
#   Sys.sleep(sleep_sencond)
# }
#
# # clear stock_no
# write_stock_no$clearElement()
#
# # close browser
# remDr$close()
#
# # stop the selenium server
# rD[["server"]]$stop()
# # rm(rD)
# # gc()

# terminal end


# ----- 2. Script version -----
# script start

# select date_range
start_date <- as.Date("2017-01-02")
end_date <- as.Date("2017-04-28")
date_index <- seq(start_date, end_date, by = "month")
years <- str_sub(date_index, start = 1, end = 4) %>% as.integer %>% subtract(1911)
months <- str_sub(date_index, start = 6, end = 7) %>% as.integer
date_range <- data.frame(years, months, stringsAsFactors = FALSE)

# select stock no
stock_no <- '2330'


# start the selenium server
# start a chrome browser
rD <- rsDriver()
remDr <- rD[["client"]]
# remDr$open(silent = TRUE)

# target net
url <- "http://www.twse.com.tw/ch/trading/exchange/STOCK_DAY/STOCK_DAYMAIN.php"
remDr$navigate(url)


# auto write stock number for web browser
write_stock_no <- remDr$findElement(using = 'xpath', value = '//input[@name = "CO_ID"]')
# write_stock_no$getElementAttribute('name')
write_stock_no$sendKeysToElement(list(stock_no))

# i <- 1

my_stock_data <- data.frame(NULL)
for (i in 1:nrow(date_range)){
  # select year for web browser
  select_year <- remDr$findElement(using = 'xpath', value = '//select[@name = "query_year"]')
  select_year$sendKeysToElement(list(sprintf("%s", date_range[i,"years"])))
  Sys.sleep(1)

  # select month for web browser
  select_month <- remDr$findElement(using = 'xpath', value = '//select[@name = "query_month"]')
  select_month$selectTag()$elements[[date_range[i,"months"]]]$clickElement()
  Sys.sleep(1)

  # click query button for web browser
  click_query_button <- remDr$findElement(using = 'xpath', value = '//input[@name = "query-button"]')
  click_query_button$clickElement()

  # 1. parser table for web browser
  paser_names <- remDr$findElement(using = 'xpath', value = '//*[@id="main-content"]/table/thead/tr[2]')
  col_names <- paser_names$getElementText()[[1]] %>% strsplit(., split = "\\s") %>% extract2(1)
  paser_tables <- remDr$findElement(using = 'xpath', value = '//*[@id="main-content"]/table/tbody')
  stock_data <- paser_tables$getElementText()[[1]] %>%
    gsub(pattern = "[,+]", replacement = "") %>%
    strsplit(., split = "\n") %>%
    extract2(1) %>%
    strsplit(., split = "\\s") %>%
    do.call(rbind, .) %>%
    set_colnames(col_names) %>%
    cbind(股票代號 = stock_no, .) %>%
    as.data.frame(stringsAsFactors = FALSE)

  # type.convert
  stock_data[, 3:ncol(stock_data)] <- stock_data %>%
    select(-c(股票代號, 日期)) %>%
    apply(., 2, as.numeric)


  # # 2. click download button for web browser
  # click_download_button <- remDr$findElement(using = 'xpath', value = '//button[@class = "dl-csv board"]')
  # click_download_button$clickElement()

  # merge
  my_stock_data <- rbind(my_stock_data, stock_data)

  sleep_sencond <- sample.int(n = 2, size = 1)
  Sys.sleep(sleep_sencond)
}

# clear stock_no
write_stock_no$clearElement()

# close browser
remDr$close()

# stop the selenium server
rD[["server"]]$stop()
# rm(rD)
# gc()

# script end
