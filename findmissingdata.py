import pyodbc
import pandas as pd
import numpy as np
import os

conn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER=hwdsql02;DATABASE=TaxSpecialCharges;Trusted_Connection=yes')

cursor = conn.cursor()

query = """select distinct Parcel, ID, TaxID, OwnerOccupancyCd, OwnerName, OwnerName2,AddressLine1, City, State, Zipcode, LegalLine1, 
LegalLine2, PropAddNumber, LandUseCode, TransferDate, TotalAssessment, YearBuilt, TransYear
FROM
(select distinct ID, TaxID, OwnerOccupancyCd, OwnerName, OwnerName2, AddressLine1, City, State, Zipcode, LegalLine1, 
LegalLine2, PropAddNumber, LandUseCode, TransferDate, TotalAssessment, YearBuilt, substring(Real_Update_Import.TransferDate,5,4) AS 'TransYear', TaxDistrict + TaxID AS 'Parcel'
from Real_Update_Import) p"""

# pull in data from TaxSpecialCharges database, Real_Update_Import table where parcels are over 25 years old
result = pd.read_sql(query, conn)
result_short = result[["Parcel", "OwnerOccupancyCd", "City", "State", "Zipcode"]]

# pull in existing file to add city, state, zip and occupancy code to
df = pd.read_excel(r"C:\Users\sbrumfield\OneDrive - Howard County\Documents\Munis\Tax Sale & Liens\4.2.24 liens - to SDAT.xlsx")
#string pad for leading 0
df["PARCEL"] = df["PARCEL"]
#adjust data type for join
df["PARCEL"] = df["PARCEL"].astype(str).str.zfill(8)

# join datasets
join = df.merge(result_short, how = "left", left_on = "PARCEL", right_on = "Parcel")
