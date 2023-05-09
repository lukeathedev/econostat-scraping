# install.packages("rvest", repos = "http://cran.us.r-project.org")

library(httr)
library(rvest)
library(stringr)

# Apenas uma demonstração
# O ideal é utilizar RSelenium para websites que
# possuem conteúdo dinâmico (Javascript)

# Captamos os preços da primeira página de pesquisa por
# arroz no Muffato (Madre Leônia)

# Isso é feito a partir da inspeção dos elementos HTML
# do website

# TODO: tratamento de dados com ML / Analytics
# TODO: criação de tabelas SQL para padronização

# User agent para evitar detecção de bots
httr::set_config(httr::user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/108.0.0.0 Safari/537.36")) 

# Série temporal (unix timestamp)
date <- as.integer(Sys.time())

# Cookies definem qual endereço estamos utilizando (Muffato Madre)
doc <- httr::GET("https://www.supermuffato.com.br/arroz", 
          set_cookies(`smd_has-channel`      = "true",
                      `smd_has-channel_name` = "Londrina%20-%20Madre")) %>% read_html

products <- doc %>% html_elements("div.prd-list-item-holder.has-stock")

names <- products %>% html_elements(".prd-list-item-name") %>% html_text2()
# Regex para extrair peso (se tiver) do item (não funciona muito bem ainda)
weights <- str_match(names, "[\\d]+[.]*kg")
weights <- str_match(weights, "[\\d]+")

prices <- products %>% html_elements("div.prd-list-item-price") %>% html_text2()
# Regex para extrair parte numérica do preço e converter para int
prices <- scan(text=str_match(prices, "[\\d]+[\\,\\.][\\d]+"), dec=",")

products_df <- data.frame(
  rep(date, length(names)),
  unlist(names),
  unlist(weights),
  unlist(prices)
)

products_df[is.na(products_df)] = ""

names(products_df) <- c("data", "nome", "peso_kg", "preco_rs")
write.csv(products_df, file="./arroz1_muffato_madre.csv", fileEncoding="UTF-8", row.names = F)