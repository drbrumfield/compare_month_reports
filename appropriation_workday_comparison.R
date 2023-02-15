

appropriation <- import("G:/Fiscal Years/Fiscal 2023/Projections Year/1. July 1 Prepwork/Appropriation File/Fiscal 2023 Appropriation File_With_Positions_WK_Accounts.xlsx",
             which = "FY23 All Positions File")

workday <- import("G:/Analyst Folders/Sara Brumfield/monthly_reports/1_monthly_positions/inputs/Positions 2023-02.xlsx", skip = 4, guess_max = 10000)

df1 <- appropriation %>%
  select(`Position ID`, `Classification ID`, `Classification Name`, Funding, `Workday Fund ID`, `Workday Grant ID - New`, `Workday Special Purpose ID`,
         `Workday Cost Center ID`, Grade, `Budgeted Salary`, `Total Budgeted Cost`) %>%
  mutate(`Position ID` = as.character(`Position ID`)) %>%
  rename(Class_Name_Approp = `Classification Name`, Class_ID_Approp = `Classification ID`, Budget_Status_Approp = Funding, Fund_Approp = `Workday Fund ID`,
         Grant_Approp = `Workday Grant ID - New`, Special_Approp = `Workday Special Purpose ID`,
         Cost_Center_Approp = `Workday Cost Center ID`, Grade_Approp = Grade,
         Salary_Approp = `Budgeted Salary`, Total_Approp = `Total Budgeted Cost`, Grade_Approp = Grade)

df2 <- workday %>% 
  select(`Position ID`, `Position Staffing Status`, `Classification (Job Code)`, `Classification (Job Profile)`, `Workday Org Assignment - Cost Center`,
         `Workday Org Assignment - Fund ID`, `Workday Org Assignment - Grant or Special Fund`, `Worker Total Base Pay`, `Grade (Compensation Grade)`) %>%
  rename(Budget_Status_WD = `Position Staffing Status`, Class_Name_WD = `Classification (Job Profile)`, Class_ID_WD = `Classification (Job Code)`,
         Cost_Center_WD = `Workday Org Assignment - Cost Center`, Grant_WD = `Workday Org Assignment - Grant or Special Fund`,
         Fund_WD = `Workday Org Assignment - Fund ID`, Salary_WD = `Worker Total Base Pay`, Grade_WD = `Grade (Compensation Grade)`)

comparison <- full_join(df1, df2, by = "Position ID") %>%
  separate(Cost_Center_WD, into = c("Cost_Center_WD", "Cost_Center_Name_WD"), sep = 9) %>%
  relocate(Class_Name_WD, .after = Class_Name_Approp) %>%
  relocate(Class_ID_WD, .after = Class_ID_Approp) %>%
  relocate(Fund_WD, .after = Fund_Approp) %>%
  relocate(Grant_WD, .after = Grant_Approp) %>%
  relocate(Grade_WD, .after = Grade_Approp) %>%
  relocate(Budget_Status_WD, .after = Budget_Status_Approp) %>%
  relocate(Cost_Center_WD, .after = Cost_Center_Approp) %>%
  mutate(`Class ID Change?` = ifelse(Class_ID_WD == Class_ID_Approp, "No Change","Changed"),
         `Fund Source Change?` = ifelse(Fund_WD == Fund_Approp, "No Change","Changed"),
         `Pay Grade Change?` = ifelse(Grade_WD == Grade_Approp, "No Change","Changed"),
         `Status Change?` = case_when((Budget_Status_Approp == "Funded" & Budget_Status_WD %in% c("Open", "Filled")) |
                                        (Budget_Status_Approp == "Salary Saved" & Budget_Status_WD == "Frozen") |
                                        (Budget_Status_Approp == "Abolished" & Budget_Status_WD == "Closed") ~ "No Change",
                                      TRUE ~ "Changed"),
         `New Position?` = ifelse(is.na(Class_ID_Approp), "Yes", "No"),
         `Removed Position?` = ifelse(is.na(Class_ID_WD), "Yes", "No"),
         `Cost Center Change?` = ifelse(Cost_Center_WD == Cost_Center_Approp, "No Change", "Changed"),
         `Any Change?` = case_when(`Class ID Change?` == "Changed" | `Fund Source Change?` == "Changed" | `Pay Grade Change?` == "Changed" | `Status Change?` == "Changed" |
                                     `New Position?` == "Yes" |  `Removed Position?` == "Yes" ~ "Changed",
                                   TRUE ~ "No Change")) %>%
  relocate(`Class ID Change?`, .after = Class_ID_WD) %>%
  relocate(`Fund Source Change?`, .after = Fund_WD) %>%
  relocate(`Pay Grade Change?`, .after = Grade_WD) %>%
  relocate(`Status Change?`, .after = Budget_Status_WD) %>%
  relocate(`New Position?`, .before = `Position ID`) %>%
  relocate(`Removed Position?`, .after = `New Position?`)%>%
  relocate(`Cost Center Change?`, .after = Cost_Center_WD) %>%
  relocate(`Any Change?`, .before = `New Position?`) %>%
  relocate(Cost_Center_Name_WD, .after = Cost_Center_WD)

export_excel(comparison, "Comparison", "outputs/FY23 Appropriated Positions - Workday Comparison.xlsx")

##compare w/ FY23 Position Budget load in Workday

eib <- import("C:/Users/sara.brumfield2/Downloads/Position Budget Sep 30 2022 2023-02-15 15_06 EST.xlsx") %>% 
  separate(Position, into = c("Position A", "Position", "Worker"), sep = "-") %>%
  separate(`Position A`, into = c("Position ID", "Title"), sep = " ") %>%
  select(`Position ID`, `Compensation Budget`, `Fringe Benefit Budget`)
  # mutate(`Position ID` = case_when(grepl("DUP", substr(Position, 1, 8)) ~ substr(Position, 1, 8),
  #                                  TRUE ~ substr(Position, 1, 5)))
data <- import("outputs/FY23 Appropriated Positions - Workday Comparison.xlsx", which = "Comparison") %>% mutate(`Position ID` = as.character(`Position ID`)) %>%
  full_join(eib, 
            by = "Position ID") %>%
  mutate(`In EIB Load?` = case_when(is.na(`Compensation Budget`) ~ "Missing",
                                    TRUE ~ "Present")) %>%
  relocate(`In EIB Load?`, .before = `Any Change?`)

dupes = data[duplicated(data$`Position ID`),]

export_excel(data, "Comparison", "outputs/FY23 Appropriated Positions - FY23 Budget Load Comparison.xlsx")

##add in classification ID
class <- comparison %>% select(`Position ID`, Class_ID_Approp, Class_ID_WD)%>% mutate(`Position ID` = as.numeric(`Position ID`))
df <- import("outputs/FY23 Appropriated Positions - Workday Comparison.xlsx", which = "Comparison") %>%
  left_join(class, by = "Position ID")

export_excel(df, "Comparison", "outputs/FY23 Appropriated Positions - Workday Comparison.xlsx")