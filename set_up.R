params <- list(
  #set start and end points
  #CLS, Proposal, TLS, FinRec, BoE, Cou, Adopted
  start_phase = "CLS",
  start_yr = 24,
  end_phase = "Prop",
  end_yr = 24,
  fy = 24,
  # most up-to-date line item and position files for planning year
  # verify with William for most current version
  line.start = "G:/Fiscal Years/Fiscal 2023/Projections Year/1. July 1 Prepwork/Appropriation File/Fiscal 2023 Appropriation File_Change_Tables.xlsx",
  line.end = "G:/Fiscal Years/Fiscal 2024/Planning Year/1. CLS/1. Line Item Reports/line_items_2022-11-2_CLS FINAL AFTER BPFS.xlsx",
  position.start = "G:/Fiscal Years/Fiscal 2024/Planning Year/2. Prop/2. Position Reports/PositionsSalariesOPCs_2022-11-16.xlsx",
  position.end = "G:/Fiscal Years/Fiscal 2024/Planning Year/1. CLS/2. Position Reports/PositionsSalariesOpcs_2022-11-2b_CLS FINAL AFTER BPFS.xlsx",
  # leave revenue file blank if not yet available; script will then just pull in last FY's data
  rev.start.month = 8,
  rev.end.month = 9,
  tax.start = NA,
  tax.end = NA
)

#libraries and functions ===================
.libPaths("C:/Users/sara.brumfield2/OneDrive - City Of Baltimore/Documents/r_library")
library(tidyverse)
library(dplyr)
library(magrittr)
library(rio)
library(assertthat)
library(httr)
library(jsonlite)
library(openxlsx)
library(readxl)
library(random)
library(stringr)
library(stringi)
library(arsenal)
library(dataCompareR)
library(devtools)
library(scales)
# install_git('https://github.com/capitalone/dataCompareR.git', branch = 'master',
#             subdir = 'dataCompareR', type = 'source', repos = NULL,
#             build_vignettes = TRUE)

devtools::load_all("G:/Analyst Folders/Sara Brumfield/_packages/bbmR")
source("G:/Budget Publications/automation/0_data_prep/bookDataPrep/R/change_table.R")
source("G:/Budget Publications/automation/0_data_prep/bookDataPrep/R/export.R")
source("G:/Budget Publications/automation/0_data_prep/bookDataPrep/R/import.R")
source("G:/Budget Publications/automation/0_data_prep/bookDataPrep/R/osos.R")
source("G:/Budget Publications/automation/0_data_prep/bookDataPrep/R/positions.R")
source("G:/Budget Publications/automation/0_data_prep/bookDataPrep/R/scorecard.R")
source("G:/Budget Publications/automation/0_data_prep/bookDataPrep/R/setup.R")

# set number formatting for openxlsx
options("openxlsx.numFmt" = "#,##0;(#,##0)")

##read in data =====================
cols <- c(paste0("FY", params$start_yr, " ", params$start_phase), 
          paste0("FY", params$end_yr, " ", params$end_phase), 
          paste0("FY", params$start_yr, " COU"),
          paste0("FY", params$start_yr, " All Positions File"))

line_item_start <- readxl::read_excel(path = params$line.start, sheet = "Details") %>%
  rename(`Service ID` = `Program ID`,
         `Service Name` = `Program Name`)

line_item_end <- readxl::read_excel(path = params$line.end, sheet = "Details") %>%
  rename(`Service ID` = `Program ID`,
         `Service Name` = `Program Name`)

position_start <- readxl::read_excel(path = params$position.start, sheet = "PositionsSalariesOPCs") %>%
  # rename(Status = `T CODE`) %>%
  # select(`JOB NUMBER`:`TOTAL COST`, -`OSO 207`, -`FUNDING`, -`PROJECTED SALARY`) %>%
  select(`JOB NUMBER`:`TOTAL COST`, -ADOPTED, -`OSO 101`, -`OSO 103`, -`OSO 161`, -`OSO 162`) %>%
  mutate(`CLASSIFICATION ID` = as.numeric(`CLASSIFICATION ID`),
         GRADE = str_remove(as.numeric(GRADE),  "^0+")) %>%
  mutate_at(vars(ends_with("ID")), as.numeric) %>%
  filter(!duplicated(`JOB NUMBER`))

colnames(position_start) = rename_upper_to_title(position_start)

position_end <- readxl::read_excel(path = params$position.end, sheet = "PositionsSalariesOPCs") %>%
  # rename(`SI ID Name` = `SI NAME`) %>%
  select(`JOB NUMBER`:`TOTAL COST`, -ADOPTED, -`OSO 101`, -`OSO 103`, -`OSO 161`, -`OSO 162`) %>%
  mutate(GRADE = str_remove(as.numeric(GRADE),  "^0+")) %>%
  mutate_at(vars(ends_with("ID")), as.numeric) %>%
  filter(!duplicated(`JOB NUMBER`) & Salary != 0)

colnames(position_end) = rename_upper_to_title(position_end)

pos_cols <- list( # dynamic col names based on FY
  base = list(
    salary = "Salary FY",
    opcs = "OPCs FY",
    total_cost = "Total Cost FY",
    service_id = "Service ID FY",
    service_name = "Service Name FY",
    class_id = "Classification ID FY",
    class_name = "Classification Name FY",
    fund_id = "Fund ID FY",
    fund_name = "Fund Name FY"))

pos_cols$projection <- pos_cols$base %>%
  map(function(x) paste0(x, params$start_yr, " ", params$start_phase)) %>%
  map(sym)

pos_cols$planning <- pos_cols$base %>%
  map(function(x) paste0(x, params$end_yr, " ", params$end_phase)) %>%
  map(sym)
