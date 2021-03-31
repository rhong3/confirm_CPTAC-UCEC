"""
CPTAC-UCEC confirmatory label prep

Created on 03/31/2021

@author: RH
"""

import openpyxl
import pandas as pd

meta = pd.read_excel("../data_freeze_v1.0/UCEC_confirmatory_meta_table_v1.0.xlsx", engine='openpyxl')
meta = meta.loc[meta['Group'] == "Tumor"][['Case_id', 'age', 'Histologic_Type', 'CNV_status',
                                           'POLE', 'MSI_status', 'medical_history/bmi']]
subtype = []
histology = []
for idx, row in meta.iterrows():
    if row['POLE'] == "Yes":
        subtype.append("POLE")
    elif row['MSI_status'] == "MSI-H":
        subtype.append("MSI.H")
    elif row['CNV_status'] == "CNV_H":
        subtype.append("CNV.H")
    elif row['CNV_status'] == "CNV_L":
        subtype.append("CNV.L")
    else:
        print(row, " Error!")
    if row['Histologic_Type'] == "Endometrioid carcinoma" or row['Histologic_Type'] == "Endometrioid adenocarcinoma":
        histology.append("Endometrioid")
    elif row['Histologic_Type'] == "Serous carcinoma":
        histology.append("Serous")
    elif row['Histologic_Type'] == "Mixed cell adenocarcinoma":
        histology.append("Mixed")
    else:
        histology.append("0NA")
meta['subtype'] = subtype
meta['histology'] = histology
meta = meta[['Case_id', 'age', 'medical_history/bmi', 'subtype', 'histology']]
meta.columns = ["Patient_ID", "age", "BMI", "subtype", "histology"]
meta = pd.get_dummies(meta, columns=["subtype", "histology"])


mutation = pd.read_csv("../data_freeze_v1.0/UCEC_confirmatory_WES_somatic_mutation_gene_level_V1.0.cbt", delimiter="\t")
mutation = mutation.transpose()
mutation.columns = mutation.iloc[0, :].tolist()
mutation = mutation.iloc[1:, :]
mutation = mutation[['ARID1A', 'ARID5B', 'ATM',	'BRCA2', 'CTCF', 'CTNNB1', 'EGFR',	'ERBB2', 'FAT1', 'FAT4', 'FBXW7',
                     'FGFR2', 'JAK1', 'KRAS', 'MLH1', 'MTOR', 'PIK3CA',	'PIK3R1', 'PIK3R2',	'PPP2R1A',
                     'PTEN', 'RPL22', 'TP53', 'ZFHX3']]
mutation['Patient_ID'] = mutation.index

meta_mut = pd.merge(meta, mutation, on=['Patient_ID'], how="inner")
meta_mut = meta_mut.drop_duplicates()

img = pd.read_csv("../cohort.csv")
img = img.loc[(img['Tumor'] == "UCEC") & (img['Tumor_normal'] == 1)][['Patient_ID', 'Slide_ID']]

img = img.loc[(img['Patient_ID'].isin(meta_mut['Patient_ID'].tolist()))]
sld_sum = pd.DataFrame(img['Patient_ID'].value_counts())
img.to_csv("../Slides.csv", index=False)
sld_sum.to_csv("../Slides_sum.csv", index=True)

meta_mut = meta_mut.loc[(meta_mut['Patient_ID'].isin(sld_sum.index.tolist()))]
meta_mut.to_csv("../Labels.csv", index=False)

print(len(meta_mut['Patient_ID'].unique()))
