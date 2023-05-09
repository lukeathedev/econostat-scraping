# install.packages("rvest", repos = "http://cran.us.r-project.org")

library(httr)
library(rvest)
library(stringr)

httr::set_config(httr::user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36")) 

date <- as.integer(Sys.time())

doc <- httr::GET("https://www.supermuffato.com.br/arroz", 
          set_cookies(`smd_has-channel`      = "true",
                      `smd_has-channel_name` = "Londrina%20-%20Madre")) %>% read_html

products <- doc %>% html_elements("div.prd-list-item-holder.has-stock")

names <- products %>% html_elements(".prd-list-item-name") %>% html_text2()
weights <- str_match(names, "[\\d]+[.]*kg")

prices <- products %>% html_elements("div.prd-list-item-price") %>% html_text2()
prices <- scan(text=str_match(prices, "[\\d]+[\\,\\.][\\d]+"), dec=",")

products_df <- data.frame(
  rep(date, length(names)),
  unlist(names),
  unlist(prices)
)

names(products_df) <- c("data", "nome", "preco_rs")
write.csv(products_df, file="./arroz1_muffato_madre.csv", fileEncoding="UTF-8", row.names = F)