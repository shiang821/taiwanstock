# 2017-04-30
getStock.api <- function(date_range, stock){

  library(magrittr)
  library(RSelenium)
  library(stringr)
  library(dplyr)

  # select date_range
  start_date <- date_range[1] %>% as.Date
  end_date   <- date_range[2] %>% as.Date
  date_index <- seq(start_date, end_date, by = "month")
  years <- str_sub(date_index, start = 1, end = 4) %>% as.integer %>% subtract(1911)
  months <- str_sub(date_index, start = 6, end = 7) %>% as.integer
  dates_range <- data.frame(years, months, stringsAsFactors = FALSE)

  # select stock no
  stock_no   <- stock[1]

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

  my_stock_data <- data.frame(NULL)
  for (i in 1:nrow(dates_range)){
    # select year for web browser
    select_year <- remDr$findElement(using = 'xpath', value = '//select[@name = "query_year"]')
    select_year$sendKeysToElement(list(sprintf("%s", dates_range[i,"years"])))
    Sys.sleep(1)

    # select month for web browser
    select_month <- remDr$findElement(using = 'xpath', value = '//select[@name = "query_month"]')
    select_month$selectTag()$elements[[dates_range[i,"months"]]]$clickElement()
    Sys.sleep(1)

    # click query button for web browser
    click_query_button <- remDr$findElement(using = 'xpath', value = '//input[@name = "query-button"]')
    click_query_button$clickElement()

    # 1. paser table for web browser
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

    # merge
    my_stock_data <- rbind(my_stock_data, stock_data)

    sleep_sencond <- sample.int(n = 2, size = 1)
    Sys.sleep(sleep_sencond)
    }

  # my_stock_data <- my_stock_data %>% filter(日期 >= start_date, 日期 <= end_date)


  # clear stock_no
  # write_stock_no$clearElement()

  # close browser
  remDr$close()

  # stop the selenium server
  rD[["server"]]$stop()
  # rm(rD)
  # gc()
  return(my_stock_data)
}
