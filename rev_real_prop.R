# ##revenue real property tax comparison files
#

library(tidyverse)
library(lubridate)
library(rio)
library(magrittr)
library(readxlsb)
library(readxl)

# 
# start <- read_xlsb(path = "G:/BBMR - Revenue Team/2. Revenue Accounts/A001 - General Fund/001 - Real Property/Assessment Files/Fiscal 2023/1. July FY 2023.xlsb",
#                    sheet = "TAB_REALPROP1", range = "A:D, S, AA, AD, AG, AO, AQ")
# 
# end <- read_xlsb(path = "G:/BBMR - Revenue Team/2. Revenue Accounts/A001 - General Fund/001 - Real Property/Assessment Files/Fiscal 2023/9. November FY 2023.xlsb",
#                    sheet = "TAB_REALPROP_11072022")

raw <- list(
  jul = readxl::read_excel("G:/BBMR - Revenue Team/2. Revenue Accounts/A001 - General Fund/001 - Real Property/Assessment Files/Fiscal 2023/1. July FY 2023.xlsx",
                  sheet = "TAB_REALPROP1"),
  nov = readxl::read_excel("G:/BBMR - Revenue Team/2. Revenue Accounts/A001 - General Fund/001 - Real Property/Assessment Files/Fiscal 2023/9. November FY 2023.xlsx",
                           sheet = "TAB_REALPROP_11072022")
)

data <- raw %>%
  map(select, PIN,
      PINRELATE,
      BLOCKLOT,
      BLOCK,
      LOT,
      PERMHOME,
      FULLCASH,
      USEGROUP,
      ARTAXBAS,
      DISTSWCH,
      DIST_ID,
      STATETAX,
      CITY_TAX,
      SALEDATE,
      OWNER_1) %>%
  map(filter, !is.na(PIN))

df = comparedf(data$jul, data$nov, by = "PIN")
summary = summary(df)

table = summary$diffs.table  


result = table %>% filter(values.x != values.y | var.x != var.y)

pivot <- table %>% pivot_wider(id_cols = `PIN`, names_from = `var.x`, values_from = c(values.x, values.y))

col_order <- c()

output <- pivot %>%
  select(col_order) %>%
  arrange(`Job Number`) %>%
  rename_with(.cols = starts_with("values.x"), ~ gsub("values.x", "FY24 CLS", x = .x)) %>%
  rename_with(.cols = starts_with("values.y"), ~ gsub("values.y", "FY24 Prop", x= .x))

# joined <- data$jul %>%
#   full_join(data$nov, by = c("BLOCKLOT", "FULLADDR"),
#             suffix = c(" Jul", " Nov")) %>%
#   mutate_at(vars(c("USEGROUP Jul", "USEGROUP Nov")), str_trim) %>%
#   filter(`ARTAXBAS Jul` != `ARTAXBAS Nov` |
#            ((`USEGROUP Jul` != `USEGROUP Nov`) & (`USEGROUP Jul` == "E" | `USEGROUP Nov` == "E"))) %>%
#   export_excel("Assess Change", file.name = "Assess Change FY23 Jul to Nov.xlsx", "new")

# rename(`CCREDAMT Dec` = CCREDAMT, `ARTAXBAS Dec` = ARTAXBAS,
#        `CITY_TAX Dec` = CITY_TAX, `SALEDATE Dec` = `SALEDATE`) %>%
# mutate(`Base Change from Aug` = `ARTAXBAS Dec` - `ARTAXBAS Aug`,
#        `Tax Change from Aug` = `CITY_TAX Dec` - `CITY_TAX Aug`,
#        `Credit Change from Aug` = `CCREDAMT Dec` - `CCREDAMT Aug`, # ATC
#        `Base Change from Oct` = `ARTAXBAS Dec` - `ARTAXBAS Oct`,
#        `Tax Change from Oct` = `CITY_TAX Dec` - `CITY_TAX Oct`,
#        `Credit Change from Oct` = `CCREDAMT Dec` - `CCREDAMT Oct`,
#        `Transaction Status from Aug` = ifelse(
#          ((`Base Change from Aug` > 0 | `Base Change from Aug` < 0) &
#            `SALEDATE Aug` != `SALEDATE Dec`), TRUE, FALSE),
#        `Transaction Status from Aug` = ifelse(
#          ((`Base Change from Oct` > 0 | `Base Change from Oct` < 0) &
#             `SALEDATE Oct` != `SALEDATE Dec`), TRUE, FALSE)) %>%
# export_excel("Assess Change", file.name = paste0("Assess Change ", today(), ".xlsx"), "new")
# 
# summary.sum <- joined %>%
#   summarize(`Base Change from Aug` = sum(`Base Change from Aug`, na.rm = TRUE),
#             `Tax Change from Aug` = sum(`Tax Change from Aug`, na.rm = TRUE),
#             `Credit Change from Aug` = sum(`Credit Change from Aug`, na.rm = TRUE),
#             `Base Change from Oct` = sum(`Base Change from Oct`, na.rm = TRUE),
#             `Tax Change from Oct` = sum(`Tax Change from Oct`, na.rm = TRUE),
#             `Credit Change from Oct` = sum(`Credit Change from Oct`, na.rm = TRUE))
# 
# summary.count <- joined %>%
#   group_by(`Transaction Status from Aug`) %>%
#   count()