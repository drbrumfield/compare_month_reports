##more readable output than Python script##
.libPaths("C:/Users/sara.brumfield2/OneDrive - City Of Baltimore/Documents/r_library")
library(tidyverse)
library(dplyr)
library(magrittr)
library(dataCompareR)
library(arsenal)
library(rio)
devtools::load_all("G:/Analyst Folders/Sara Brumfield/_packages/bbmR")

##data sets
# bpfs = query_db("PLANNINGYEAR24", "BUDGETS_N_ACTUALS_CLEAN_DF") %>%
#   select(-adopted, -ends_with("Name")) %>%
#   collect() %>%
#   set_names(rename_cols(.)) %>%
#   mutate(fiscalyear = paste(gsub("^20", "FY", fiscalyear), "Actual")) %>%
#   pivot_wider(names_from = "fiscalyear", values_from = "actual", values_fn = sum) %>%
#   select(ends_with("ID"), `FY22 Actual`) %>%
#   filter(!is.na(`FY22 Actual`)) %>%
#   group_by(`Agency ID`, `Service ID`, `Activity ID`, `Fund ID`, `Object ID`, `Subobject ID`) %>%
#   summarise_at(vars(`FY22 Actual`), sum, na.rm = TRUE) %>%
#   mutate_at(vars(group_cols()), as.numeric) %>%
#   mutate(`Subobject ID` = as.numeric(`Subobject ID`)) %>%
#   distinct() %>%
#   arrange(`Agency ID`, `Service ID`, `Activity ID`, `Fund ID`, `Object ID`, `Subobject ID`)
# 
# bpfs_total = sum(bpfs$`FY22 Actual`, na.rm = TRUE)
# export_excel(bpfs, "FY22 Actuals BPFS", "inputs/FY22 Actuals BPFS.xlsx")

# baps = import("inputs/BAPS Actual_FY22_V2.xlsx", which = "CurrentYearExpendituresActLevel") %>%
#   select(ends_with("ID"), `BAPS YTD EXP`) %>%
#   rename(`FY22 Actual` = `BAPS YTD EXP`, `Service ID` = `Program ID`) %>%
#   filter(!is.na(`FY22 Actual`) & !is.na(`Subobject ID`)) %>%
#   arrange(`Agency ID`, `Service ID`, `Activity ID`, `Fund ID`, `Object ID`, `Subobject ID`)
#   # group_by(`Agency ID`, `Service ID`, `Activity ID`, `Fund ID`, `Object ID`, `Subobject ID`) %>%
#   # summarise_at(vars(`FY22 Actual`), sum, na.rm = TRUE) 

# baps_total = sum(baps$`FY22 Actual`, na.rm = TRUE)
# export_excel(baps, "FY22 Actuals BAPS", "inputs/FY22 Actuals BAPS.xlsx")

today <- import("C:/Users/sara.brumfield2/OneDrive - City Of Baltimore/_Code/monthly_reports/compare_month_reports/inputs/FY25 CLS Final 11-16.xlsx", which = "Combined") %>%
  select(Agency = `CC4Agency`, Service = `CC5Service`, Fund, `FY2025 OPG CLS Final`) %>%
  mutate(Fund = as.character(Fund)) %>%
  group_by(`Agency`, `Service`, Fund) %>%
  summarise(`FY25 CLS` = sum(`FY2025 OPG CLS Final`, na.rm = TRUE)) %>%
  mutate(`FY25 CLS` = as.integer(`FY25 CLS`))

nov_1 <- import("C:/Users/sara.brumfield2/OneDrive - City Of Baltimore/_Code/monthly_reports/compare_month_reports/inputs//PowerApp Budget Data Nov17.csv") %>%
  mutate(`FY25 CLS` = gsub("[\\$,]", "", `FY25 CLS`),
    `FY25 CLS` = as.numeric(`FY25 CLS`),
    Fund = as.character(Fund)) %>%
  group_by(Agency, Service, Fund) %>%
  summarise(`FY25 CLS` = sum(`FY25 CLS`, na.rm = TRUE)) %>%
  mutate(`FY25 CLS` = as.integer(`FY25 CLS`))

df <- today %>% full_join(nov_1, by = c("Agency", "Service", "Fund"), suffix = c("_nov16", "_nov1")) %>%
  mutate(Diff = `FY25 CLS_nov16`-`FY25 CLS_nov1`) %>%
  filter(Diff != 0 & Diff != -1)

export_excel(df, "Differences to App", "outputs/FY25 CLS Nov16 vs Budget App.xlsx")
diff_df <- dplyr::all_equal(today, nov_1)

##experiment code w/ dataCompareR package =====
# position_start %>% filter(duplicated(`Job Number`))
# 
df = rCompare(today, nov_1, keys = c('Agency', 'Service', 'Fund', 'FY25 CLS'))

z = dataCompareR:::generateMismatchData(x = df, dfA = baps, dfB = bpfs)
z = dataCompareR:::createMismatches(df, df$mismatches, keys = c('Agency.ID', 'Service.ID', 'Activity.ID', 'Fund.ID', 'Object.ID', 'Subobject.ID', 'FY22.Actual'))

# data = data.frame()
# for (item in df$mismatches) {
#   data = rbind(item, data)
# }
# 
# test <- data %>% 
#   mutate(valueA = as.numeric(valueA),
#          valueB = as.numeric(valueB)) %>%
#   group_by(JOB.NUMBER, variable) %>%
#   summarise_if(is.numeric, sum, na.rm = TRUE) %>%
#   pivot_wider(id_cols = JOB.NUMBER, names_from = variable, values_from = valueA, valueB)
# 
# 
# saveReport(df, reportName = "outputs/Positions_CLS_Adopted")

##dplyr anti_join() on all columns =====
col_names = colnames(bpfs)

df = anti_join(baps, bpfs, by = c(col_names))

not_dupes = df %>% distinct()

dupes = anti_join(df, not_dupes, by = c(colnames(df)))

df = comparedf(baps, bpfs)
summary = summary(df)

table = summary$diffs.table  

#convert table to dataframe
test = table %>% map_df(as_tibble)
df_table = as_tibble(as.data.frame(do.call(cbind, table)))
test = as_tibble(table)
test = rbindlist(table)
test = enframe(table)
test = data.frame(table)
test = data.frame(t(sapply(table,c)))

result = table %>% filter(unlist(values.x) != unlist(values.y) | var.x != var.y)

pivot <- table %>% pivot_wider(id_cols = `Job Number`, names_from = `var.x`, values_from = c(values.x, values.y))

col_order <- c("Job Number", 
               # "values.x_Classification ID",  "values.y_Classification ID",
               # "values.x_Classification Name", "values.y_Classification Name",
               # "values.x_Grade", "values.y_Grade",
               # "values.x_Program ID", "values.y_Program ID",
               # "values.x_Program Name", "values.y_Program Name",
               # "values.x_Activity Name", "values.y_Activity Name",
               # "values.x_Detailed Fund Name", "values.y_Detailed Fund Name",
               # "values.x_Status",               "values.y_Status", 
               # "values.x_Salary",             "values.y_Salary",
               "values.x_OSO 201",             "values.y_OSO 201",
               "values.x_OSO 202",             "values.y_OSO 202",
               "values.x_OSO 203",             "values.y_OSO 203",  
               "values.x_OSO 205", "values.y_OSO 205", 
               "values.x_OSO 210",  "values.y_OSO 210",
               "values.x_OSO 212",  "values.y_OSO 212",
               "values.x_OSO 213",   "values.y_OSO 213",
               "values.x_OSO 231",  "values.y_OSO 231",           
               "values.x_OSO 233",   "values.y_OSO 233",
               "values.x_OSO 235",        "values.y_OSO 235",     
               "values.x_Total Cost",  "values.y_Total Cost" ) 

pivot <- pivot %>%
  select(col_order) %>%
  arrange(`Job Number`) %>%
  rename_with(.cols = starts_with("values.x"), ~ gsub("values.x", "FY24 Prop", x = .x)) %>%
  rename_with(.cols = starts_with("values.y"), ~ gsub("values.y", "FY24 TLS", x= .x))


#map on agency, service
agency_start <- position_start %>%
  select(`Job Number`, `Agency ID`, `Agency Name`)

agency_end <- position_end %>%
  select(`Job Number`, `Agency ID`, `Agency Name`)

agencies <- full_join(agency_start, agency_end, by = c("Job Number", "Agency Name", "Agency ID")) %>% distinct()

check <- filter(agencies, duplicated(`Job Number`))

output <- agencies %>% right_join(pivot, by = "Job Number")

write.csv(output, "G:/Fiscal Years/Fiscal 2024/Planning Year/3. TLS/2. Position Reports/Position Changes FY24 Prop-FY24 TLS.csv", row.names = F)
