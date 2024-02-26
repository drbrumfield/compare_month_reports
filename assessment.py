import pandas as pd
import numpy as np
from datetime import datetime, date
from pandas.testing import assert_frame_equal

angie = pd.read_excel(r"\\hcdatastore\HCGOVDATA2\Finance\Bureau of Revenue\POLICIES & PROCEDURES\Bureau Chief\Reporting Requests FY23\2022 Tax Data 1.25.24 for RPBCC.xlsx", sheet_name = "Annual ")
sara = pd.read_excel(r"C:\Users\sbrumfield\OneDrive - Howard County\Documents\Munis\Assessments and Exemptions\2022 Tax Data from Sara.xlsx", sheet_name = "Annual")

sara2 = sara.drop(["YEAR"], axis = 1)
sara2 = sara2[['PARCEL NUMBER', 'BILL TYPE', 'CUSTOMER NUMBER', 'PROPERTY',
       'PROPERTY ADDRESS', 'PROPERTY ADDRESS 2', 'DEED', 'CLASS CODE',
       'AD VALOREM TAX', 'COUNTY TAX', 'FIRE TAX-METRO',
       'FRONT FOOT SEWER TAX', 'FRONT FOOT WATER TAX',
       'STATE BAY RESTORATION FEE', 'STATE PROPERTY TAX', 'TRASH FEE',
       'WATERSHED HARDSHIP CREDIT', 'LAND ASSESSMENT', 'COUNTY ASSESSMENT',
       'HOMESTEAD / RATE', 
       'COUNTY ASSESSMENT + HOMESTEAD / RATE', 'EXEMPTIONS',
       'STATE ASSESSMENT', 'STATE HOMESTEAD CREDIT', 'COUNTY HOMESTEAD CREDIT',
       'STATE HOMEOWNERS CREDIT', 'HOMEOWNER COUNTY CREDIT']]
sara2['PARCEL NUMBER'] = sara2['PARCEL NUMBER'].astype(int)
sara2['CUSTOMER NUMBER'] = sara2['CUSTOMER NUMBER'].astype(float)
sara2['STATE BAY RESTORATION FEE'] = sara2['STATE BAY RESTORATION FEE'].astype(float)
sara2['LAND ASSESSMENT'] = sara2['LAND ASSESSMENT'].astype(float)
sara2['STATE ASSESSMENT'] = sara2['STATE ASSESSMENT'].astype(float)
sara2['COUNTY ASSESSMENT'] = sara2['COUNTY ASSESSMENT'].astype(float)
sara2['EXEMPTIONS'] = sara2['EXEMPTIONS'].round(3)
sara2['COUNTY HOMESTEAD CREDIT'] = sara2['COUNTY HOMESTEAD CREDIT'].abs()
sara2['CLASS CODE'] = sara2['CLASS CODE'].str.rstrip()

angie2 = angie.dropna(subset=['Parcel'])
angie2['Parcel'] = angie2['Parcel'].astype(int)
angie2 = angie2[['Parcel', 'Bill Type', 'Customer Number', 'Property',
       'Property Address', 'Property Address 2', 'Deed', 'Class Code',
       'AD VALOREM', ' COUNTY TAX', 'FIRE TAX-METRO', 'FRONT FOOT SEWER',
       'FRONT FOOT WATER', 'STATE BAY RESTOR FEE', 'STATE PROPERTY TAX',
       'TRASH FEE', 'WATERSHED PROTECTION', 'LAND ASSESSMENT',
       'COUNTY ASSESSMENT', 'County plus Homestead 1/25/24', 'EXEMPTIONS',
       'STATE ASSESSMENT', '1/25/2024', 
       'HOMESTEAD STATE CREDIT', 
       'HOMESTEAD COUNTY CREDIT', 'HOMEOWNER STATE CREDIT',
       'HOMEOWNER COUNTY CREDIT']]
angie2['EXEMPTIONS'] = angie2['EXEMPTIONS'].round(3)
angie2 = angie2.rename(columns = {"Parcel":'PARCEL NUMBER', 
'Customer Number': 'CUSTOMER NUMBER', 
'Class Code':'CLASS CODE', 
' COUNTY TAX':'COUNTY TAX', 
r'1/25/2024':r'HOMESTEAD / RATE', 
r'County plus Homestead 1/25/24':r'COUNTY ASSESSMENT + HOMESTEAD / RATE',
'AD VALOREM':'AD VALOREM TAX',
'HOMESTEAD COUNTY CREDIT':'COUNTY HOMESTEAD CREDIT'})
angie3= angie2[['PARCEL NUMBER', 'CLASS CODE', 'AD VALOREM TAX', 'FIRE TAX-METRO','COUNTY TAX', 'LAND ASSESSMENT', 'STATE ASSESSMENT', 
       'COUNTY ASSESSMENT',  'COUNTY HOMESTEAD CREDIT', 'EXEMPTIONS']]
     
sara3 = sara2[['PARCEL NUMBER', 'CLASS CODE', 'AD VALOREM TAX', 'FIRE TAX-METRO', 'COUNTY TAX', 'LAND ASSESSMENT', 'STATE ASSESSMENT', 
       'COUNTY ASSESSMENT', 'COUNTY HOMESTEAD CREDIT', 'EXEMPTIONS']]
     
cols = list(sara3.columns)

result = angie3.merge(sara3, how = "outer", indicator = True, on = cols, suffixes = ("_Angie", "_Sara"))
     
check = result[(result['PARCEL NUMBER'] == 1157574)]

    
output = result.copy()
output = result.loc[lambda x : x['_merge'] != 'both']

output["Phase"] = output["_merge"].replace({"left_only":"Angie", "right_only":"Sara"})

output = output.drop(labels = ["_merge"], axis = 1)

label = output.pop("Phase")
output.insert(0, "Phase", label)
output = output.sort_values(by = ["PARCEL NUMBER", 'Phase'])

output.to_excel("outputs/2022 Tax Data Comparison Mismatches.xlsx", index = False)
