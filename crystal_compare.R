##load necessary libraries====
library(rio)
library(dplyr)
library(magrittr)
library(openxlsx)
library(stringr)
library(compareDF)
library(assertthat)
library(tidyverse)

source("C:/Users/sbrumfield/OneDrive - Howard County/Documents/GitHub Repos/bbmR/R/export_excel.R")

# crystal generated ttx needs the quote = "" parameter to correctly gather all rows; otherwise some rows will be missing
crystal <- read.delim("T:/SHARED/MUNIS Archives/MUNIS Scanline Files/Scanline TTX Files/Scanline-02-27-2024.ttx", header = FALSE, 
                      skip = 8, col.names = c("Year", "Category", "Bill Number", "Account", "Name", "Name2", "Addr Line 1",
                                              "Addr line 2", "City", "State", "Zip", "TotalDue"), 
                      sep = "\t", quote = "") %>%
  # this is the only way to remove the trailing whitespace; trimws and str_trim don't work
  # TotalDue has commas in number format and trailing 0
  mutate(Account = gsub(pattern = "(\\s)", replacement = "", x = Account),
         TotalDue = gsub(pattern = "(0$)", replacement = "", x = TotalDue),
         TotalDue = gsub(pattern = ",", replacement = "", x = TotalDue))

python <- read.delim("T:/SHARED/MUNIS Archives/MUNIS Scanline Files/Scanline TTX Files/Scanlinev2-02-27-2024.ttx", header = FALSE, 
                     skip = 8, col.names = c("Year", "Category", "Bill Number", "Account", "Name", "Name2", "Addr Line 1",
                                             "Addr line 2", "City", "State", "Zip", "TotalDue"), 
                     sep = "\t", quote = "") %>%
  #convert data type
  mutate(TotalDue = as.character(TotalDue),
         TotalDue = case_when(TotalDue == "0" ~ "0.0",
                              TRUE ~ TotalDue),
         Account = gsub(pattern = "(\\s)", replacement = "", x = Account))


assert_that(nrow(python) == nrow(crystal))

##dplyr compare method====

notinold <- anti_join(python, crystal, by = c("Year", "Account", "Category", "Bill.Number"))
notinnew <- anti_join(crystal, python, by = c("Year", "Account", "Category", "Bill.Number"))

##return all rows from x without a match in y
diff1 <- anti_join(python, crystal, by = c("Year", "Account", "Category", "Bill.Number"))
diff2 <- anti_join(crystal, python, by = c("Year", "Account", "Category", "Bill.Number"))

alldiff <- rbind(diff1, diff2) %>%
  arrange(`Year`, `Account`, `Category`, `Bill.Number`)

##comparedf package ===

df <- compare_df(python, crystal,
                 change_markers = c("python", "crystal"))

comp_df <- df$comparison_df
create_output_table(df, change_col_name  = "Added/Removed", group_col_name = "Line Number", output_type = "html", file_name = "C:/Users/sbrumfield/OneDrive - Howard County/Documents/SDAT Comparisons/SDAT Sep-Dec 2023 Differences.html", limit = 7000)
create_output_table(df, change_col_name  = "Added/Removed", group_col_name = "Line Number", output_type = 'xlsx', file_name = "C:/Users/sbrumfield/OneDrive - Howard County/Documents/SDAT Comparisons/SDAT Sep 2023-Jan 2024 Dwellings.xlsx")
