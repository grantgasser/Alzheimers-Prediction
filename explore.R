## Grant Gasser
## Created 2/26/2019

## Exploratory analysis on ADNI data Q3

#### DATA DESCRIPTION ####
'''
directory.id	Id assigned to imaging directories. Not from LONi data
Subject (PTID)	Participant ID
RID	Participant roster ID
Image.Data.ID	MRI ID
Modality	Image type
Visit	1=screening scan
Acq.Date	MRI date
DX.bl	Diagnosis at baseline
EXAMDATE	Examination Date
AGE	Age at baseline
PTGENDER	Sex
PTEDUCAT	Years of Education
PTETHCAT	Ethnicity
PTRACCAT	Race
APOE4	APOE4 genotype
MMSE	MMSE score
imputed_genotype	Challenge specific designation, TRUE=has imputed genotypes
APOE Genotype	APOE allele 1 and allele 2 genotypes
Dx Codes for Submission	The LMCI in the ADNI data is equivalent to MCI in test. This column just converts LMCI->MCI
'''

#Read and view data
list.files('AD_Challenge_Training_Data_Clinical_Updated_7.22.2014')

dat = read.csv('AD_Challenge_Training_Data_Clinical_Updated_7.22.2014/ADNI_Training_Q3_APOE_CollectionADNI1Complete 1Yr 1.5T_July22.2014.csv')
head(dat)

dim(dat)
num_rows = dim(dat)[1]

#What type of variables?
str(dat)

#APOE4 and imputed_genotype should be factor variables
dat$APOE4 = factor(dat$APOE4)
dat$imputed_genotype = factor(dat$imputed_genotype)

#Labels: AD (Alzheimer's), LMCI (Limited Mild Cognitive Impairment), CN (Cognitively Normal)
Y = dat$DX.bl
summary(Y)

#make sure Y is ordinal
Y = factor(Y, levels=c('CN', 'LMCI', 'AD'), ordered=TRUE)
head(Y)

#May try to fit ordinal regression considering cognitive state as a spectrum CN -> LMCI -> AD

#Train-test split: 75% train (471), 25% test (157)
num_test = num_rows/4
num_train = num_rows - num_test

#Pick variables 10:18 for training data
train = dat[1:num_train, 10:18]
test = dat[num_train+1:num_rows, 10:18]
y_train = Y[1:num_train]
y_test = Y[num_train+1]
head(train)
dim(train)

str(train)

## FIT ORDINAL REGRESSION 
library(MASS)

ordinal.fit = polr(y_train ~ ., data=train, Hess=TRUE) #error message seems to imply some vars dropped due to multicollinearity
summary(ordinal.fit) #AIC = 586

#NOTE: polr dropped 


test = data.frame(test)
predictions = predict(ordinal.fit, newdata=test)
