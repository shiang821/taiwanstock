# 2017-04-30
# 測試API腳本
library(magrittr)
library(httr)
library(jsonlite)

# opencpu server ip: 192.168.0.103:12345
# 套件名稱: getstockapi
# api名稱: getStock.api
# api位置
api_url <- 'http://192.168.0.102:12345/ocpu/library/getstockapi/R/getStock.api/json'

# 輸入&輸出資料皆為json格式
# 輸入參數
# 1. date_range: 開始日期與結束日期
# 2. stock: 股票編號
api_data <- httr::POST(url = api_url, 
                       body = list(date_range = c("2017-01-02", "2017-04-28"), stock = "2330"), 
                       encode = 'json')

# 取得股票數據
my_data <- api_data %>%
  content(., encoding = "UTF-8") %>%
  do.call(rbind,.) %>%
  as.data.frame(stringAsFactors = FALSE)
