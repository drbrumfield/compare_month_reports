##from BBMR Position File in Workday
input <- import("inputs/all positions 2022.xlsx", skip = 8) 
# 
# filled <- input %>%
#   rename(`Total Positions`=Count, Agency=`CF-agency`) %>%
#   filter(`Staffing Status` == "Filled") %>%
#   select(-`Staffing Status`) %>%
#   rowwise() %>%
#   mutate(`Position Count Start` = sum(`04/1962`:`11/2022`))

df <- input %>%
  mutate(`Fill Month` = month(`Worker Hire Date`),
         `Fill Year` = year(`Worker Hire Date`)) %>%
  filter(`Fund ID` == "1001" & `Adopted Budget Funding Status` == "Funded") %>%
  arrange(`Fill Year`, `Fill Month`)

vacant <- df %>%
  filter(`Position Staffing Status` == "Open") %>%
  group_by(Agency) %>%
  summarise(`Total Vacant Positions` = n())

frozen <- df %>%
  filter(`Position Staffing Status` == "Frozen") %>%
  group_by(Agency) %>%
  summarise(`Total Frozen Positions` = n())

closed <- df %>%
  filter(`Position Staffing Status` == "Closed") %>%
  group_by(Agency) %>%
  summarise(`Total Closed Positions` = n())

filled <- df %>%
  filter(`Position Staffing Status` == "Filled")

# total <- df %>%
#   group_by(Agency) %>%
#   summarise(`Total Positions` = n())

check <- df %>%
  group_by(Agency, `Position Staffing Status`) %>%
  summarise(count = n())
  
fill_start <- filled %>%
  filter(`Fill Year` < 2022 & `Position Staffing Status` == "Filled") %>%
  group_by(Agency) %>%
  summarise(`Position Count Start` = n())

pivot <- filled %>%
  filter(`Fill Year` == 2022 & `Position Staffing Status` == "Filled") %>%
  pivot_wider(id_cols = Agency, names_from = c(`Position Staffing Status`, `Fill Year`, `Fill Month`),
                                                                          values_from = `Position ID`, values_fn = length, values_fill = 0) %>%
  full_join(fill_start, by = "Agency")

trend <- pivot %>%
  rowwise() %>%
  mutate(Jan = sum(`Position Count Start`, Filled_2022_1, na.rm = TRUE),
          Feb = sum(Jan, Filled_2022_2, na.rm = TRUE),
         Mar = sum(Feb, Filled_2022_3, na.rm = TRUE),
         Apr =  sum(Mar, Filled_2022_4, na.rm = TRUE),
         May = sum(Apr, Filled_2022_5, na.rm = TRUE),
         Jun = sum(May, Filled_2022_6, na.rm = TRUE),
         Jul = sum(Jun, Filled_2022_7, na.rm = TRUE),
         Aug = sum(Jul, Filled_2022_8, na.rm = TRUE),
         Sep = sum(Aug, Filled_2022_9, na.rm = TRUE),
         Oct = sum(Sep, Filled_2022_10, na.rm = TRUE),
         Nov = sum(Oct, Filled_2022_11, na.rm = TRUE),
         Dec = sum(Oct, Filled_2022_12, na.rm = TRUE)) %>%
  select(-starts_with("Filled"))

agency <- trend %>%
  filter(!is.na(Agency)) %>%
  group_by(Agency) %>%
  summarise_if(is_numeric, sum, na.rm = TRUE) %>%
  rename(`Positions Filled as of 12/31/2021`=`Position Count Start`)

output <- agency %>% full_join(vacant, by = "Agency") %>%
  full_join(frozen, by = "Agency") %>%
  full_join(closed, by = "Agency") %>%
  # full_join(total, by = "Agency") %>%
  filter(!is.na(Agency)) %>%
  replace(is.na(.), 0) %>%
  rowwise() %>%
  mutate(`Total Positions` = sum(c_across(`Dec`:`Total Closed Positions`), na.rm = TRUE)) %>%
  ungroup()

export_excel(output, "As of Dec 31 2022", "outputs/Position Trends 2022.xlsx")