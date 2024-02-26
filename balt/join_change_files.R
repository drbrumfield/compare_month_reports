data <- list(
  
  mar15 = import("G:/Fiscal Years/Fiscal 2024/Planning Year/3. TLS/2. Position Reports/PositionsSalariesOPCs_2023-03-15.xlsx",
                 which = "PositionsSalariesOPCs") %>%
    filter(`FUND ID` == 1001) %>%
    group_by(`AGENCY ID`, `AGENCY NAME`, `PROGRAM ID`, `PROGRAM NAME`, `ACTIVITY ID`, `ACTIVITY NAME`) %>%
    summarise(`Mar15` = n()),
  
  mar7 = import("G:/Fiscal Years/Fiscal 2024/Planning Year/3. TLS/2. Position Reports/PositionsSalariesOPCs_2023-03-07_TLS_New.xlsx",
                which = "PositionsSalariesOPCs") %>%
    filter(`FUND ID` == 1001) %>%
    group_by(`AGENCY ID`, `AGENCY NAME`, `PROGRAM ID`, `PROGRAM NAME`, `ACTIVITY ID`, `ACTIVITY NAME`) %>%
    summarise(`Mar7` = n()),
  
  mar2 = import("G:/Fiscal Years/Fiscal 2024/Planning Year/3. TLS/2. Position Reports/PositionsSalariesOPCs_2023-03-02.xlsx",
                which = "PositionsSalariesOPCs") %>%
    filter(`FUND ID` == 1001) %>%
    group_by(`AGENCY ID`, `AGENCY NAME`, `PROGRAM ID`, `PROGRAM NAME`, `ACTIVITY ID`, `ACTIVITY NAME`) %>%
    summarise(`Mar2` = n()))

result <- full_join(data$mar2, data$mar7, by = c("AGENCY ID", "AGENCY NAME", "PROGRAM ID", "PROGRAM NAME", "ACTIVITY ID", "ACTIVITY NAME")) %>% 
  full_join(data$mar15, by = c("AGENCY ID", "AGENCY NAME", "PROGRAM ID", "PROGRAM NAME", "ACTIVITY ID", "ACTIVITY NAME")) %>%
  mutate(`Match Mar2?` = case_when(`Mar2` == `Mar15` ~ "Yes",
                                   TRUE ~ "No"))

export_excel(result, "Position Comparison", "outputs/Mar Position Comparison for Laura.xlsx")