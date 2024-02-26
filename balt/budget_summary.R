##//BUDGET SUMMARY FOR SERVICE PROPOSALS//

##current line items ======
input <-import("G:/Fiscal Years/Fiscal 2024/Planning Year/2. Prop/1. Line Item Reports/line_items_2023-01-25.xlsx", which = "Details")

data <- input %>%
  mutate(Fund = case_when(`Fund ID` == 1001 ~ "General Fund",
                          TRUE ~ "All Other Funds")) %>%
  group_by(`Program ID`, Fund) %>%
  summarise(`FY23 Adopted` = sum(`FY23 Adopted`, na.rm = TRUE),
            `FY24 CLS` = sum(`FY24 CLS`, na.rm = TRUE),
            `FY24 Request` = sum(`FY24 PROP`, na.rm = TRUE)) %>%
  pivot_wider(id_cols = `Program ID`, names_from = Fund, values_from = c(`FY23 Adopted`, `FY24 CLS`, `FY24 Request`))

##prior actuals
fy22 <- import("G:/Fiscal Years/Fiscal 2022/Projections Year/2. Monthly Expenditure Data/Month 12_June Projections/Expenditure 2022-06_Run7.xlsx",
               which = "CurrentYearExpendituresActLevel") %>%
  mutate(Fund = case_when(`Fund ID` == 1001 ~ "General Fund",
                          TRUE ~ "All Other Funds")) %>%
  group_by(`Program ID`, Fund) %>%
  summarise(`FY22 Actuals` = sum(`BAPS YTD EXP`, na.rm = TRUE)) %>%
  pivot_wider(id_cols = `Program ID`, names_from = Fund, values_from = `FY22 Actuals`) %>%
  filter(!is.na(`Program ID`)) %>%
  rename(`FY22 General Fund` = `General Fund`, `FY22 All Other Funds` = `All Other Funds`)

##join line items
output <- data %>% left_join(fy22, by = "Program ID") %>%
  relocate(`FY22 General Fund`, .after = `Program ID`) %>%
  relocate(`FY22 All Other Funds`, .after = `FY22 General Fund`)

##positions!! =======
positions <- readRDS("G:/Budget Publications/automation/0_data_prep/outputs/fy24_prop/positions.Rds")

positions$cls <- readRDS("G:/Budget Publications/automation/0_data_prep/outputs/fy24_cls/positions.Rds") %>%
  extract2("planning")

positions <- positions %>%
  map(group_by, `Service ID`, `Fund Name`) %>%
  map(count)

positions <- positions$planning %>%
  rename(`FY24 Positions - PROP` = n) %>%
  left_join(positions$cls %>%
              rename(`FY24 Positions - CLS` = n)) %>%
  left_join(positions$projection %>%
              rename(`FY23 Positions` = n)) %>%
  left_join(positions$prior %>%
              rename(`FY22 Positions` = n))

  

##save for scorecard proposals =======
saveRDS(output, file = "G:/Analyst Folders/Sara Brumfield/planning_year/2b_proposal_compilation/inputs/budget_summary.Rds")