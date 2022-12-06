params <- list(
  # prepare Scorecard PMs Excel files for distribution to agencies/auditors?
  sc_dist = FALSE,
  # prepare Agency Detail templates for distribution to analysts?
  agency_detail_dist = FALSE,
  # target FY for which budget book is being created, in YY format
  fy = 24,
  # in case we're using data from another phase for testing purposes in advance of budget season
  phase = 
    # "cls",
    "prop",
  # "tls",
  #"finrec",
  #"boe",
  # "cou",
  # update RDS files from latest database pulls (TRUE), or just grab the RDS files as is? (FALSE)
  get_new_data = TRUE,
  # most up-to-date line item and position files for planning year
  line.item = "G:/Fiscal Years/Fiscal 2024/Planning Year/2. Prop/1. Line Item Reports/line_items_2022-11-30.xlsx",
  position = "G:/Fiscal Years/Fiscal 2024/Planning Year/2. Prop/2. Position Reports/PositionsSalariesOpcs_2022-11-30.xlsx",
  # leave revenue file blank if not yet available; script will then just pull in last FY's data
  revenue = "G:/BBMR - Revenue Team/1. Fiscal Years/Fiscal 2023/Planning Year/Budget Publication/3. FY 2023 - Budget Publication - SOTA.xlsx"
)

set_cols <- function() {
  
  
  cols <- list()
  
  # names in files from BPFS
  cols$expend <- list(
    planning = sym(paste0("FY", params$fy, " Budget")),
    projection = sym(paste0("FY", params$fy - 1, " Budget")),
    prior = sym(paste0("FY", params$fy - 2, " Actual")),
    # names for the cols containing budget info
    fy = c(paste0("FY", (params$fy - 7):(params$fy - 2), " Actual"),
           paste0("FY", (params$fy - 1):params$fy,
                  c(" Adopted", paste0(" ", params$phase))))
  )
  
  # names cleaned up for presentation / publication
  cols$present <- list(
    planning = sym(paste0("Fiscal 20", params$fy, " Budget")),
    projection = sym(paste0("Fiscal 20", params$fy - 1, " Budget")),
    prior = sym(paste0("Fiscal 20", params$fy - 2, " Actual"))
  )
  
  # names from revenue team file
  cols$revenue <- list(
    planning = sym(paste0("FY", params$fy, " Estimate")),
    projection = sym(paste0("FY", params$fy - 1, " Budget")),
    prior = sym(paste0("FY", params$fy - 2, " Actual"))
  )
  
  if (params$get_new_data == TRUE) {
    saveRDS(cols, paste0(paths$data, "cols.Rds")) 
  }
  
  return(cols)
}
set_paths <- function(path_base = paste0("../../FY20", params$fy, "/"),
                      path_data = paste0(getwd(), "/outputs/fy", params$fy, "_", tolower(params$phase), "/")) {
  
  paths <- list(data = path_data)
  
  dir.create(paths$data)
  
  # pull paths for each chapter folder of prelim_exec_sota...
  paths$prelim_exec_sota  <- as.list(paste0(list.dirs(paste0(path_base, "0_automation_prelim_exec_sota"), recursive = FALSE), "/")) %>%
    # and set chapter names to easily reference each path
    magrittr::set_names(list.dirs(paste0(path_base, "0_automation_prelim_exec_sota"), recursive = FALSE, full.names = FALSE))
  
  # pull paths for each analyst folder of agency_detail...
  paths$agency_detail  <- as.list(paste0(list.dirs(paste0(path_base, "0_automation_agency_detail"), recursive = FALSE), "/")) %>%
    # and set analyst names to easily reference each path
    magrittr::set_names(list.dirs(paste0(path_base, "0_automation_agency_detail"), recursive = FALSE, full.names = FALSE))
  
  paths$agency_detail$manual_data <- paste0(path_base, "0_automation_agency_detail")
  
  # if (params$get_new_data == TRUE) {
  #   saveRDS(paths, paste0(paths$data, "paths.Rds")) 
  # }
  
  return(paths)
}


paths <- set_paths()

cols <- set_cols()

expend <- 
  list(
    line_item = readxl::read_excel(path = params$line.item, sheet = "Details", na = "NULL") %>%
      ##fix PROP to Prop
      rename(`FY24 Proposal` = `FY24 PROP`) %>%
      set_colnames(rename_cols(.)) %>%
      rename(!!cols$expend$projection := paste0("FY", params$fy - 1, " Adopted"),
             !!cols$expend$planning :=
               paste0("FY", params$fy, " ",
                      case_when(params$phase == "finrec" ~ "FinRec",
                                params$phase == "prop" ~ "Proposal",
                                TRUE ~ toupper(params$phase)))),
    historical = query_db(paste0("PLANNINGYEAR", params$fy), "BUDGETS_N_ACTUALS_CLEAN_DF") %>%
      # select(-ends_with("Name")) %>%
      collect() %>%
      set_names(rename_cols(.)) %>%
      mutate(fiscalyear = paste(gsub("^20", "FY", fiscalyear))) %>%
      pivot_wider(names_from = "fiscalyear", values_from = c("actual", "adopted"), values_fn = sum))

expend <- expend %>%
  map(mutate_at, vars(ends_with("ID")), as.character) %>%
  # fixes issues with losing the 0 at the front of cols that were initially numeric
  # this is important bc later, most OSOs are truncated to the first digit for the 'Tag'
  map(mutate,
      `Activity ID` = str_pad(`Activity ID`, 3, "left", "0")) %>%
  # `Agency ID` = case_when(
  #   `Service ID` %in% c("356", "893", "894", "895", "896") ~ "4381", # Homeless Services
  #   `Service ID` %in% c("109", "605", "741") ~ "4309", # MOCFS
  #   `Service ID` %in% c("189", "730") ~ "2600", # DGS
  #   `Service ID` == "727" ~ "7000",
  # TRUE ~ `Agency ID`)) %>%
  map(select, -ends_with("Name"), -contains("changevsadopted")) %>%
  # name changes between FYs cause issues with duplicate rows upon pivoting wider
  map(filter, !is.na(`Subobject ID`) & !is.na(`Service ID`)) %>%
  map(mutate_if, is.numeric, replace_na, 0)

expend$historical <- expend$historical %>%
  # for budget book,  keep only actuals from 2 FYs before planning year, budget for recent years
  # remove any cols related to planning or projection yr; take those from line item file
  # select(-matches(paste0("FY", c(params$fy - 1, params$fy), collapse = "|"))) %>%
  # remove agency here because service switches between agencies lead to duplicate rows
  group_by(`Service ID`, `Activity ID`, `Subactivity ID`,
           `Fund ID`, `Detailed Fund ID`, `Object ID`, `Subobject ID`) %>%
  summarize_if(is.numeric, sum, na.rm = TRUE)

##BUG===
expend$line_item <- expend$line_item %>%
  # remove agency here because service switches between agencies lead to duplicate rows
  group_by(`Service ID`, `Activity ID`, `Subactivity ID`,
           `Fund ID`, `Detailed Fund ID`, `Object ID`, `Subobject ID`, `Objective ID`, `Justification`) %>%
  #dropping ID columns???
  #group_by(Justification, .add = TRUE) %>%
  summarize_at(vars(starts_with("FY")), sum, na.rm = TRUE) %>%
  mutate(Justification = paste(Justification, collapse = "; "),
         Justification = gsub("NA; |NA", "", Justification),
         Justification = ifelse(Justification == "", NA, Justification))


#0 transfer objects dropping from 150 FY21
#activities becoming NA when not in historical
#run modified function before join
match_name_to_id <- function (df, cols, incl.higher, fy = 23) 
{
  if (!hasArg(cols)) {
    cols <- c("Detailed Fund", "Service", "Activity", "Fund", 
              "Agency", "Object", "Subobject")
  }
  l <- list()
  for (i in c("Fund", "Agency", "Object", "Subobject")) {
    if (i %in% cols) {
      l[[i]] <- query_db(paste0("planningyear", 23), i) %>% 
        select(`:=`(!!paste(i, "ID"), ID), `:=`(!!paste(i, 
                                                        "Name"), NAME))
    }
  }
  for (i in c("Detailed Fund", "Service", "Activity", "Subactivity")) {
    if (i %in% cols) {
      higher <- switch(i, `Detailed Fund` = "Fund", Service = "Agency", 
                       Activity = "Program", Subactivity = "Activity")
      l[[i]] <- query_db(paste0("planningyear", fy), switch(i, 
                                                            `Detailed Fund` = "detailed_fund", Service = "program", 
                                                            Activity = "activity", Subactivity = "subactivity"))
      if (incl.higher == TRUE) {
        if (i == "Subactivity") {
          l[[i]] <- l[[i]] %>% select(`Subactivity ID` = ID, 
                                      `Subactivity Name` = NAME, `Activity ID` = ACTIVITY_ID, 
                                      `Service ID` = PROGRAM_ID)
        }
        else {
          l[[i]] <- l[[i]] %>% select(`:=`(!!paste(i, 
                                                   "ID"), ID), `:=`(!!paste(i, "Name"), NAME), 
                                      `:=`(!!paste(ifelse(higher == "Program", 
                                                          "Service", higher), "ID"), paste0(toupper(higher), 
                                                                                            "_ID")))
        }
      }
      else {
        l[[i]] <- l[[i]] %>% select(`:=`(!!paste(i, 
                                                 "ID"), ID), `:=`(!!paste(i, "Name"), NAME))
      }
    }
  }
  l <- map(l, collect)
  if ("Activity" %in% cols) {
    l$Activity %<>% mutate(`Activity ID` = str_pad(`Activity ID`, 
                                                   3, "left", "0"))
  }
  for (j in cols) {
    df %<>% left_join(l[[j]])
  }
  df %<>% select(one_of(paste(rep(cols, each = 2), c("ID", 
                                                     "Name"))), everything())
  return(df)
}
output <- expend$historical %>%
  full_join(expend$line_item,
            c("Service ID", "Activity ID", "Subactivity ID",
              "Fund ID", "Detailed Fund ID", "Object ID", "Subobject ID")) %>%
  match_name_to_id(
    cols = c("Service", "Agency", "Activity", "Subactivity",
             "Fund", "Detailed Fund", "Object", "Subobject"),
    incl.higher = TRUE) %>%
  relocate(`Objective ID`, .after = `Subobject Name`) %>%
  relocate(adopted_FY12, .after = actual_FY12) %>%
  relocate(adopted_FY13, .after = actual_FY13) %>%
  relocate(adopted_FY14, .after = actual_FY14) %>%
  relocate(adopted_FY15, .after = actual_FY15) %>%
  relocate(adopted_FY16, .after = actual_FY16) %>%
  relocate(adopted_FY17, .after = actual_FY17) %>%
  relocate(adopted_FY18, .after = actual_FY18) %>%
  relocate(adopted_FY19, .after = actual_FY19) %>%
  relocate(adopted_FY20, .after = actual_FY20) %>%
  relocate(adopted_FY21, .after = actual_FY21) %>%
  relocate(adopted_FY22, .after = actual_FY22) %>%
  relocate(adopted_FY23, .after = actual_FY23) %>%
  relocate(Justification, .after = `FY24 Budget`) %>%
  relocate(`Service ID`, .after = `Agency Name`) %>%
  relocate(`Service Name`, .after = `Service ID`) %>%
  rename(`FY24 Prop` = `FY24 Budget`,
         `FY12 Adopted` = adopted_FY12,
         `FY12 Actual` = actual_FY12,
         `FY23 Adopted` = adopted_FY23,
         `FY13 Actual` = actual_FY13,         `FY13 Adopted` = adopted_FY13,
         `FY14 Actual` = actual_FY14,         `FY14 Adopted` = adopted_FY14,
         `FY15 Actual` = actual_FY15,         `FY15 Adopted` = adopted_FY15,
         `FY16 Actual` = actual_FY16,         `FY16 Adopted` = adopted_FY16,
         `FY17 Actual` = actual_FY17,         `FY17 Adopted` = adopted_FY17,
         `FY18 Actual` = actual_FY18,         `FY18 Adopted` = adopted_FY18,
         `FY19 Actual` = actual_FY19,         `FY19 Adopted` = adopted_FY19,
         `FY20 Actual` = actual_FY20,         `FY20 Adopted` = adopted_FY20,
         `FY21 Actual` = actual_FY21,         `FY21 Adopted` = adopted_FY21,
         `FY22 Actual` = actual_FY22,         `FY22 Adopted` = adopted_FY22,
         `FY23 Actual` = actual_FY23) %>%
  select(-`FY23 Actual`, -`FY23 Budget`)
  

export_excel(output, "FY12-FY24 Prop", "G:/Fiscal Years/Historical Data/Multi-Year Data/Multi-Year Budget v Actuals_FY12-FY24 Prop.xlsx")