import pandas as pd
import numpy as np
from datetime import datetime

#set start and end points
#CLS, Proposal, TLS, FinRec, BoE, Cou, Adopted
params = {"start_phase" : "Adopted",
"start_yr" : 23,
"end_phase" : "CLS",
"end_yr" : 24,
"fy" : 24,
#most up-to-date line item and position files for planning year
#verify with William for most current version
"line.start" : "G:/Fiscal Years/Fiscal 2023/Projections Year/1. July 1 Prepwork/Appropriation File/Fiscal 2023 Appropriation File_Change_Tables.xlsx",
"line.end" : "G:/Fiscal Years/Fiscal 2024/Planning Year/1. CLS/1. Line Item Reports/line_items_2022-11-2_CLS FINAL AFTER BPFS.xlsx",
"position.end" : "G:/Fiscal Years/Fiscal 2024/Planning Year/2. Prop/2. Position Reports/PositionsSalariesOPCs_2022-11-30.xlsx",
"position.start" : "G:/Fiscal Years/Fiscal 2024/Planning Year/1. CLS/2. Position Reports/PositionsSalariesOpcs_2022-11-2b_CLS FINAL AFTER BPFS.xlsx"}

position_start = pd.read_excel(params["position.start"], sheet_name = "PositionsSalariesOPCs")
position_start = position_start.drop_duplicates(subset = "JOB NUMBER", keep = "last")
position_start = position_start.drop(['ADOPTED', 'OSO 101', 'OSO 103', 'OSO 161', 'OSO 162'], axis = 1)
position_start = position_start.rename(columns = {"SI NAME":"SI ID NAME", "Salary":"SALARY"})
position_start = position_start.loc[:, "JOB NUMBER":"TOTAL COST"]
position_start = position_start.infer_objects()

# start_cols = list(position_start.columns)

# start_ID_cols = [s for s in start_cols if s.endswith("ID")]

position_end = pd.read_excel(params["position.end"], sheet_name = "PositionsSalariesOPCs")
position_end = position_end.drop_duplicates(subset = "JOB NUMBER", keep = "last")
position_end = position_end.drop(['ADOPTED', 'OSO 101', 'OSO 103', 'OSO 161', 'OSO 162'], axis = 1)
position_end = position_end.rename(columns = {"SI NAME":"SI ID NAME", "Salary":"SALARY"})
position_end = position_end.loc[:, "JOB NUMBER":"TOTAL COST"]
position_end = position_end.infer_objects()

position_start.compare(position_end)

result = position_start.merge(position_end, indicator = True, how = 'outer')

output = result.loc[lambda x : x['_merge'] != 'both'] 

# output = position_start.compare(other = position_end, align_axis = 1, result_names = ("start", "end"))
