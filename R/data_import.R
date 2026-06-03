# data_import.R
# Purpose: Access TÜİK official announcement and advertisement fee data via tuikr

library(tuikr)
library(httr)
library(readxl)
library(dplyr)
library(stringr)

# Retrieve table list from TÜİK (Theme 10 = Culture and Sports)
tables <- statistical_tables(theme = 10)

# Target table: row 8 - official announcement fees by month and type
url <- tables$table_url[8]

# Download with browser-like headers (TÜİK blocks plain bot requests)
resp <- GET(
  url,
  add_headers(
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36",
    "Referer"    = "https://veriportali.tuik.gov.tr/",
    "Accept"     = "application/json, text/plain, */*"
  ),
  timeout(15)
)

# Read Excel file from raw binary response
tmp <- tempfile(fileext = ".xls")
writeBin(content(resp, "raw"), tmp)
df_raw <- read_excel(tmp)

# Clean and build monthly time series
ay_sira      <- c("Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
                  "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık")
yil_satirlar <- which(str_detect(df_raw[[1]], "\\d{4}$") & !is.na(df_raw[[1]]))
ay_satirlar  <- which(str_detect(df_raw[[1]], paste(ay_sira, collapse = "|")) & !is.na(df_raw[[1]]))

ay_yil <- integer(length(ay_satirlar))
for (i in seq_along(ay_satirlar)) {
  onceki <- yil_satirlar[yil_satirlar < ay_satirlar[i]]
  if (length(onceki) > 0)
    ay_yil[i] <- as.integer(str_extract(df_raw[[1]][max(onceki)], "\\d{4}"))
}

temiz_df <- data.frame(
  yil          = ay_yil,
  ay_tr        = df_raw[[1]][ay_satirlar],
  toplam_bedel = as.numeric(df_raw[[2]][ay_satirlar])
)
temiz_df <- temiz_df[!is.na(temiz_df$toplam_bedel), ]
temiz_df$ay_no <- match(str_extract(temiz_df$ay_tr, paste(ay_sira, collapse = "|")), ay_sira)
temiz_df$tarih <- as.Date(paste(temiz_df$yil, temiz_df$ay_no, "01", sep = "-"))

ts_data <- ts(temiz_df$toplam_bedel, start = c(2018, 1), frequency = 12)
