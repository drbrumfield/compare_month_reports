##ECC comparison w/ Workday
library(writexl)

ecc <- import("C:/Users/sara.brumfield2/Downloads/ECC PROJECTS ONLY- FROM LOG.xlsx") %>%
  mutate(`Position ID` = as.character(`Position #`))

wd <- import("outputs/Positions as of 2023-03-01.xlsx", which = "FY23 All Positions") %>%
  rename(`Workday Pay Grade` = `New Grade`)

dupes = wd$`Position ID`[duplicated(wd$`Position ID`)]
wd_deduped = wd %>% filter(is.na(`Workday Duplicate Position ID`))


approp <- import("G:/Fiscal Years/Fiscal 2023/Projections Year/1. July 1 Prepwork/Appropriation File/Fiscal 2023 Appropriation File_With_Positions_WK_Accounts.xlsx",
                 which = "FY23 All Positions File") %>%
  mutate(`Position ID` = as.character(`Position ID`))

join <- ecc %>% left_join(approp, by = "Position ID", suffix = c("_ECC", "_Approp")) %>%
  left_join(wd_deduped, by = "Position ID", suffix = c("_ECC", "_WD")) %>%
  select(- `Position #`)


# export_excel(join, "FY23 Positions", "C:/Users/sara.brumfield2/Downloads/ECC Position Comparison.xlsx")

write_xlsx(join, "C:/Users/sara.brumfield2/Downloads/ECC Position Comparison.xlsx")

# write.xlsx(join, "C:/Users/sara.brumfield2/Downloads/ECC Position Comparison.xlsx")
