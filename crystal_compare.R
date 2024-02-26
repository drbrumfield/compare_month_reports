##load necessary libraries====
library(rio)
library(dplyr)
library(magrittr)
library(openxlsx)
library(stringr)
library(dataCompareR)
library(compareDF)

source("C:/Users/sbrumfield/OneDrive - Howard County/Documents/GitHub Repos/bbmR/R/export_excel.R")


crystal <- read.delim("T:/SHARED/MUNIS Archives/MUNIS Scanline Files/Scanline TTX Files/Processed/Scanline-02-26-2024.ttx", header = FALSE, 
                      skip = 8, col.names = c("Year", "Category", "Bill Number", "Account", "Name", "Name2", "Addr Line 1",
                                              "Addr line 2", "City", "State", "Zip", "TotalDue"), 
                      sep = "\t")

python <- read.delim("T:/SHARED/MUNIS Archives/MUNIS Scanline Files/Scanline TTX Files/Scanline-02-26-2024.ttx", header = FALSE, 
                     skip = 8, col.names = c("Year", "Category", "Bill Number", "Account", "Name", "Name2", "Addr Line 1",
                                             "Addr line 2", "City", "State", "Zip", "TotalDue"), 
                     sep = "\t") %>%
  #convert data type
  mutate(TotalDue = as.character(TotalDue),
         TotalDue = case_when(TotalDue == "0" ~ "0.00",
                              TRUE ~ TotalDue))


##dplyr compare method====

notinold <- anti_join(python, crystal)
notinnew <- anti_join(crystal, python)

##return all rows from x without a match in y
diff1 <- anti_join(python, crystal)
diff2 <- anti_join(crystal, python)

alldiff <- rbind(diff1, diff2)

##comparedf package ===

df <- compare_df(python, crystal)

comp_df <- df$comparison_df
create_output_table(df, change_col_name  = "Added/Removed", group_col_name = "Line Number", output_type = "html", file_name = "C:/Users/sbrumfield/OneDrive - Howard County/Documents/SDAT Comparisons/SDAT Sep-Dec 2023 Differences.html", limit = 7000)
create_output_table(df, change_col_name  = "Added/Removed", group_col_name = "Line Number", output_type = 'xlsx', file_name = "C:/Users/sbrumfield/OneDrive - Howard County/Documents/SDAT Comparisons/SDAT Sep 2023-Jan 2024 Dwellings.xlsx")
