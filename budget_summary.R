##current line items
input <-import("G:/Fiscal Years/Fiscal 2024/Planning Year/2. Prop/1. Line Item Reports/line_items_2022-11-16.xlsx", which = "Details")

data <- input %>%
  mutate(Fund = case_when(`Fund ID` == 1001 ~ "General Fund",
                          TRUE ~ "All Other Funds")) %>%
  group_by(`Agency Name`, Fund) %>%
  summarise(`FY23 Adopted` = sum(`FY23 Adopted`, na.rm = TRUE),
            `FY24 CLS` = sum(`FY24 CLS`, na.rm = TRUE),
            `FY24 Request` = sum(`FY24 PROP`, na.rm = TRUE)) %>%
  pivot_wider(id_cols = `Agency Name`, names_from = Fund, values_from = c(`FY23 Adopted`, `FY24 CLS`, `FY24 Request`))

##prior actuals
fy22 <- import("G:/Fiscal Years/Fiscal 2022/Projections Year/2. Monthly Expenditure Data/Month 12_June Projections/Expenditure 2022-06_Run7.xlsx",
               which = "CurrentYearExpendituresActLevel") %>%
  mutate(Fund = case_when(`Fund ID` == 1001 ~ "General Fund",
                          TRUE ~ "All Other Funds")) %>%
  group_by(`Agency Name`, Fund) %>%
  summarise(`FY22 Actuals` = sum(`BAPS YTD EXP`, na.rm = TRUE)) %>%
  pivot_wider(id_cols = `Agency Name`, names_from = Fund, values_from = `FY22 Actuals`) %>%
  filter(!is.na(`Agency Name`)) %>%
  rename(`FY22 General Fund` = `General Fund`, `FY22 All Other Funds` = `All Other Funds`)

##join line items
output <- data %>% left_join(fy22, by = "Agency Name") %>%
  relocate(`FY22 General Fund`, .after = `Agency Name`) %>%
  relocate(`FY22 All Other Funds`, .after = `FY22 General Fund`)