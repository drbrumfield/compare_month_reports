##more readable output than Python script##

##experiment code w/ dataCompareR package =====
# position_start %>% filter(duplicated(`Job Number`))
# 
# df = rCompare(position_end, position_start, keys = 'Job Number')
# 
# z = dataCompareR:::generateMismatchData(x = df, dfA = position_end, dfB = position_start)
# z = dataCompareR:::createMismatches(df, df$mismatches, keys = 'JOB.NUMBER')
# 
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
col_names = colnames(position_start)

df = anti_join(position_start, position_end, by = c(col_names))

# not_dupes = df %>% distinct()
# 
# dupes = anti_join(df, not_dupes, by = c(colnames(df)))

df = comparedf(position_end, position_start, by = "Job Number")
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
