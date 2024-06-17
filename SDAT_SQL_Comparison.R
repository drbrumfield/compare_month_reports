##load necessary libraries====
library(rio)
library(dplyr)
library(magrittr)
library(openxlsx)
library(stringr)
library(dataCompareR)
library(compareDF)

source("C:/Users/sbrumfield/OneDrive - Howard County/Documents/GitHub Repos/bbmR/R/export_excel.R")

##load data files to compare====
##note: commonly the first row of the SDAT file if the SQL Server Import Wizard has first row has column headers checked

new <- read.delim("M:/SDAT downloads/Jul 2024/txt_Real_Update.txt", header = FALSE, sep = "\t") %>%
  ##convert data type
  mutate(V2 = as.character(V1),
         ##create unique key for each row
         V1 = str_sub(V2, start = 1, end = 10))

old <- read.delim("M:/SDAT downloads/2023/Sept 2023/Moore/assr14ho.txt", header = FALSE, sep = "\t") %>%
  ##convert data type
  mutate(V2 = as.character(V1),
         ##create unique key for each row
         V1 = str_sub(V2, start = 1, end = 10))

test <- anti_join(new, old)

##transmute data for compatibility=====

new_cols <- new %>%
  ##use PDR guide to split columns by character position in text file
  mutate(Key = str_squish(str_sub(V2, start = 1, end = 114)),
         Account = str_squish(str_sub(V2, start = 5, end = 16)),
         District = str_squish(str_sub(V2, start = 3, end = 4)),
         Occupancy = str_squish(str_sub(V2, start = 21, end = 21)),
         Owner = str_squish(str_sub(V2, start = 22, end = 89)),
         Address = str_squish(str_sub(V2, start = 115, end = 207)),
         Map = str_squish(str_sub(V2, start = 403, end = 407)),
         Parcel = str_squish(str_sub(V2, start = 413, end = 417)),
         Description = str_squish(str_sub(V2, start = 208, end = 279)),
         Premise = str_squish(str_sub(V2, start = 280, end = 351)),
         Deed1 = str_squish(str_sub(V2, start = 352, end = 363)),
         Deed2 = str_squish(str_sub(V2, start = 364, end = 462)),
         ExemptCode = str_squish(str_sub(V2, start = 426, end = 428)),
         LandUse = str_squish(str_sub(V2, start = 429, end = 430)),
         Factors = str_squish(str_sub(V2, start = 463, end = 474)),
         FieldCard = str_squish(str_sub(V2, start = 475, end = 486)),
         Sales1 = str_squish(str_sub(V2, start = 487, end = 617)),
         Sales2 = str_squish(str_sub(V2, start = 618, end = 748)),
         Sales3 = str_squish(str_sub(V2, start = 749, end = 879)),
         Exemptions = str_squish(str_sub(V2, start = 880, end = 966)),
         BaseCycle = str_squish(str_sub(V2, start = 967, end = 1018)),
         PriorAssessment = str_squish(str_sub(V2, start = 1019, end = 1045)),
         CurrentCycle = str_squish(str_sub(V2, start = 1046, end = 1097)),
         CurrentAssessment = str_squish(str_sub(V2, start = 1098, end = 1151)),
         PriorCycle = str_squish(str_sub(V2, start = 1152, end = 1187)),
         PriorAssess3 = str_squish(str_sub(V2, start = 1188, end = 1214)),
         NewConstruction = str_squish(str_sub(V2, start = 1215, end = 1331)),
         AssessmentCredit = str_squish(str_sub(V2, start = 1332, end = 1414)),
         Special = str_squish(str_sub(V2, start = 1415, end = 1568)),
         CAMA = str_squish(str_sub(V2, start = 1569, end = 1634)),
         Dwellings = str_squish(str_sub(V2, start = 1593, end = 1596)),
         TaxRoll = str_squish(str_sub(V2, start = 1635, end = 1722)),
         Filler1 = str_squish(str_sub(V2, start = 1723, end = 1884)),
         AddCAMA = str_squish(str_sub(V2, start = 1885, end = 1911)),
         Filler2 = str_squish(str_sub(V2, start = 1912, end = 1929)),
         Parent = str_squish(str_sub(V2, start = 1930, end = 2000))) 

old_cols <- old %>%
  ##use PDR guide to split columns by character position in text file
  mutate(Key = str_squish(str_sub(V2, start = 1, end = 114)),
         Account = str_squish(str_sub(V2, start = 5, end = 16)),
         District = str_squish(str_sub(V2, start = 3, end = 4)),
         Occupancy = str_squish(str_sub(V2, start = 21, end = 21)),
         Owner = str_squish(str_sub(V2, start = 22, end = 89)),
         Address = str_squish(str_sub(V2, start = 115, end = 207)),
         Map = str_squish(str_sub(V2, start = 403, end = 407)),
         Parcel = str_squish(str_sub(V2, start = 413, end = 417)),
         Description = str_squish(str_sub(V2, start = 208, end = 279)),
         Premise = str_squish(str_sub(V2, start = 280, end = 351)),
         Deed1 = str_squish(str_sub(V2, start = 352, end = 363)),
         Deed2 = str_squish(str_sub(V2, start = 364, end = 462)),
         ExemptCode = str_squish(str_sub(V2, start = 426, end = 428)),
         LandUse = str_squish(str_sub(V2, start = 429, end = 430)),
         Factors = str_squish(str_sub(V2, start = 463, end = 474)),
         FieldCard = str_squish(str_sub(V2, start = 475, end = 486)),
         Sales1 = str_squish(str_sub(V2, start = 487, end = 617)),
         Sales2 = str_squish(str_sub(V2, start = 618, end = 748)),
         Sales3 = str_squish(str_sub(V2, start = 749, end = 879)),
         Exemptions = str_squish(str_sub(V2, start = 880, end = 966)),
         BaseCycle = str_squish(str_sub(V2, start = 967, end = 1018)),
         PriorAssessment = str_squish(str_sub(V2, start = 1019, end = 1045)),
         CurrentCycle = str_squish(str_sub(V2, start = 1046, end = 1097)),
         CurrentAssessment = str_squish(str_sub(V2, start = 1098, end = 1151)),
         PriorCycle = str_squish(str_sub(V2, start = 1152, end = 1187)),
         PriorAssess3 = str_squish(str_sub(V2, start = 1188, end = 1214)),
         NewConstruction = str_squish(str_sub(V2, start = 1215, end = 1331)),
         AssessmentCredit = str_squish(str_sub(V2, start = 1332, end = 1414)),
         Special = str_squish(str_sub(V2, start = 1415, end = 1568)),
         CAMA = str_squish(str_sub(V2, start = 1569, end = 1634)),
         Dwellings = str_squish(str_sub(V2, start = 1593, end = 1596)),
         TaxRoll = str_squish(str_sub(V2, start = 1635, end = 1722)),
         Filler1 = str_squish(str_sub(V2, start = 1723, end = 1884)),
         AddCAMA = str_squish(str_sub(V2, start = 1885, end = 1911)),
         Filler2 = str_squish(str_sub(V2, start = 1912, end = 1929)),
         Parent = str_squish(str_sub(V2, start = 1930, end = 2000))) 

##dplyr compare method====

notinold <- anti_join(new_cols, old_cols, by = c("V1", "Dwellings"))
notinnew <- anti_join(old_cols, new_cols, by = c("V1", "Dwellings"))

##return all rows from x without a match in y
diff1 <- anti_join(new_cols, new_cols, by = c("Key", "Dwellings"))
diff2 <- anti_join(new_cols, new_cols, by = c("Key", "Dwellings"))

alldiff <- rbind(diff1, diff2)

##comparedf package ===

df <- compare_df(new_cols, old_cols, c("District", "Account", "Dwellings", "ExemptCode", "LandUse"), 
                 exclude = c("V2", "Map", "V1", "Owner", "Occupancy", "Parcel", "Premise", "Address", "Description", "Key", "Deed1","Deed2","Factors","FieldCard",        
                             "Sales1","Sales2","Sales3","Exemptions","BaseCycle","PriorAssessment", "CurrentCycle",
                             "CurrentAssessment", "PriorCycle",        "PriorAssess3", "NewConstruction",
                             "AssessmentCredit",  "Special",           "CAMA",              "TaxRoll",          
                             "Filler1",           "AddCAMA",           "Filler2",           "Parent"))

comp_df <- df$comparison_df
create_output_table(df, change_col_name  = "Added/Removed", group_col_name = "Line Number", output_type = "html", file_name = "C:/Users/sbrumfield/OneDrive - Howard County/Documents/SDAT Comparisons/SDAT Sep-Dec 2023 Differences.html", limit = 7000)
create_output_table(df, change_col_name  = "Added/Removed", group_col_name = "Line Number", output_type = 'xlsx', file_name = "C:/Users/sbrumfield/OneDrive - Howard County/Documents/SDAT Comparisons/SDAT Sep 2023-Jan 2024 Dwellings.xlsx")

##compareR package=====
# df = rCompare(test1 , test2, 
#               keys = c('Key', 'Address', 'Description', 'Premise', 'Deed1', 'Deed2', 'Factors', 'FieldCard', 'Sales1', 'Sales2', 'Sales3',
#                                  'Exemptions', 'BaseCycle', 'PriorAssessment', 'CurrentCycle', 'CurrentAssessment', 'PriorCycle', 'PriorAssess3',
#                                  'NewConstruction', 'AssessmentCredit', 'Special', 'CAMA', 'TaxRoll', 'AddCAMA'))
# 
# z = dataCompareR:::generateMismatchData(x = df, dfA = test1, dfB = test2)
# y = dataCompareR:::createMismatches(df, df$mismatches, keys = c('Key', 'Address', 'Description', 'Premise', 'Deed1', 'Deed2', 'Factors', 'FieldCard', 'Sales1', 'Sales2', 'Sales3',
#                                                                 'Exemptions', 'BaseCycle', 'PriorAssessment', 'CurrentCycle', 'CurrentAssessment', 'PriorCycle', 'PriorAssess3',
#                                                                 'NewConstruction', 'AssessmentCredit', 'Special', 'CAMA', 'TaxRoll', 'AddCAMA'))
# 
# 

##export using custom function====

export_excel(df = sep_cols, 
             tab_name = "Sep Data", 
             file_name = "C:/Users/sbrumfield/OneDrive - Howard County/Documents/SDAT Comparisons/SDAT Sep-Dec 2023 Differences.xlsx", 
             type = "new")

export_excel(df = dec_cols, 
             tab_name = "Dec Data", 
             file_name = "C:/Users/sbrumfield/OneDrive - Howard County/Documents/SDAT Comparisons/SDAT Sep-Dec 2023 Differences.xlsx", 
             type = "existing")

export_excel(df = notindec, 
             tab_name = "Sep Only", 
             file_name = "C:/Users/sbrumfield/OneDrive - Howard County/Documents/SDAT Comparisons/SDAT Sep-Dec 2023 Differences.xlsx", 
             type = "existing")

export_excel(df = notinsep, 
             tab_name = "Dec Only", 
             file_name = "C:/Users/sbrumfield/OneDrive - Howard County/Documents/SDAT Comparisons/SDAT Sep-Dec 2023 Differences.xlsx", 
             type = "existing")

export_excel(df = alldiff, 
             tab_name = "Differences", 
             file_name = "C:/Users/sbrumfield/OneDrive - Howard County/Documents/SDAT Comparisons/SDAT Sep-Dec 2023 Differences.xlsx", 
             type = "existing")

# export_excel(df = comp_df, 
#              tab_name = "Differences", 
#              file_name = "C:/Users/sbrumfield/OneDrive - Howard County/Documents/SDAT Comparisons/SDAT Sep-Dec 2023 Differences.xlsx", 
#              type = "existing")

##by district
districts <- new_cols %>%
  mutate(
    CurrentAssessmentPhaseIn = as.numeric(str_squish(str_sub(V2, start = 1098, end = 1106))),
    CurrentAssessmentTotal = as.numeric(str_squish(str_sub(V2, start = 1107, end = 1115))),
    AssessmentStateCredit = as.numeric(str_squish(str_sub(V2, start = 1313, end = 1321))),
    AssessmentCountyCredit = as.numeric(str_squish(str_sub(V2, start = 1304, end = 1312))),
    CurrentAssessmentCountyCredit = as.numeric(str_squish(str_sub(V2, start = 1359, end = 1367))),
    CurrentAssessmentStateCredit = as.numeric(str_squish(str_sub(V2, start = 1341, end = 1349))),
    TaxRollCountyAssessment = as.numeric(str_squish(str_sub(V2, start = 1639, end = 1647))),
    TaxRollStateAssessment = as.numeric(str_squish(str_sub(V2, start = 1648, end = 1656)))
  ) %>%
  select(District, CurrentAssessmentPhaseIn:TaxRollStateAssessment) %>%
  group_by(District) %>%
  summarise(across(CurrentAssessmentPhaseIn:TaxRollStateAssessment, sum, na.rm = TRUE))


##fifth district only
fifth <- new_cols %>%
  filter(`District` == "05") %>%
  mutate(CurrentAssessmentPhaseIn = str_squish(str_sub(V2, start = 1098, end = 1106)),
         CurrentAssessmentTotal = str_squish(str_sub(V2, start = 1107, end = 1115)),
         AssessmentStateCredit = str_squish(str_sub(V2, start = 1313, end = 1321)),
         AssessmentCountyCredit = str_squish(str_sub(V2, start = 1304, end = 1312)),
         CurrentAssessmentCountyCredit = str_squish(str_sub(V2, start = 1359, end = 1367)),
         CurrentAssessmentStateCredit = str_squish(str_sub(V2, start = 1341, end = 1349)),
         TaxRollCountyAssessment = str_squish(str_sub(V2, start = 1639, end = 1647)),
         TaxRollStateAssessment = str_squish(str_sub(V2, start = 1648, end = 1656)))

fifth$ID <- substr(fifth$V1, nchar(fifth$V1) - 6, nchar(fifth$V1))


taxroll <- import("C:/Users/sbrumfield/OneDrive - Howard County/Documents/Munis/Tax Rolls/2024 Initial Tax Roll.xlsx", which = "SQL Tax Roll") 

taxroll <- taxroll %>%
  mutate(ID = as.character(`PARCEL NUMBER`))

taxrollfifth <- taxroll[grep("^5", taxroll$ID), ]

fifth <- fifth %>%
  mutate(TaxRollCountyAssessment = as.numeric(TaxRollCountyAssessment) - as.numeric(CurrentAssessmentCountyCredit),
         TaxRollStateAssessment = as.numeric(TaxRollStateAssessment) - as.numeric(CurrentAssessmentStateCredit))

countydiff <- anti_join(fifth, taxrollfifth, by = c("ID", "TaxRollCountyAssessment" = "COUNTY ASSESSMENT"))

statediff <- anti_join(fifth, taxrollfifth, by = c("ID", "TaxRollStateAssessment" = "STATE ASSESSMENT"))

export_excel(df = fifth, 
             tab_name = "5th District", 
             file_name = "M:/SDAT downloads/Jul 2024/Fifth District Assessment Check.xlsx", 
             type = "new")

##isolate just changed records to be load in SDAT format (V2 col)