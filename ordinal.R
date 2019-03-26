## Grant Gasser
## Created 2/26/2019

## Ordinal Regression on ADNI Q3 Data

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
y_test = factor(y_test, levels=c('CN', 'LMCI', 'AD'), ordered=TRUE)
head(Y)

#Fit ordinal regression considering cognitive state as a spectrum CN < LMCI < AD

#Train-test split: 75% train (471), 25% test (157)
num_test = num_rows/4
num_train = num_rows - num_test

#Pick variables 10:18 for training data
train = dat[1:num_train, 10:18]
test = dat[(num_train+1):num_rows, 10:18]
y_train = Y[1:num_train]
y_test = Y[(num_train+1):num_rows]
head(train)
dim(train)

str(train)

## FIT ORDINAL REGRESSION 
library(MASS)
library(car)
library(glm.predict)

#Remove Ethnicity (PTETHCAT, doesn't provide much info) and APOE.Genotype variable (polr function can't handle the)
ordinal.fit = polr(y_train ~ .-PTETHCAT -APOE.Genotype, data=train, Hess=TRUE)
summary(ordinal.fit) #AIC = 583

test = data.frame(test)
predictions = predict(ordinal.fit, newdata=test)
predictions = factor(predictions, levels=c('CN', 'LMCI', 'AD'), ordered=TRUE)

#calculate accuracy of predictions
stopifnot(length(predictions) == length(y_test))
accuracy_vector = (predictions == y_test)
head(accuracy_vector)

num_correct = table(accuracy_vector)[2]
accuracy = num_correct / num_test 

#Accuracy = 70%

#This metric is not optimal though, as it does not consider the effect of false positives and false negatives.
#For example, it is much worse to diagnose someone as Cognitively Normal (CN) when in fact they have Alheimer's (AD) than it is
#to diagnose someone as Limited Mild Cognitively Impaired (LMCI) when they are Cognitively Normal (CN), along with many other cases.

# Look at common mistakes
incorrect_predictions = predictions[!accuracy_vector]
labels_incorrectly_predicted = y_test[!accuracy_vector]

#plot
barplot(prop.table(table(incorrect_predictions)))
barplot(prop.table(table(labels_incorrectly_predicted)))

#On incorrect predictions, predicted CN too often (~50% of the time) where CN was <10% of the actual correct labels for
#observations incorrectly predicted. Can be viewed as a False Negative and would be very bad to predict CN when a patient 
#has LMCI or AD. 

#Distribution of incorrect predictions: 48% CN, 40% LMCI, 12% AD
#Distribution of labels on incorrect predictions: 8% CN, 60% LMCI, 30% AD

#Main problem: False Negatives. Predicting CN and under-predicting LMCI and AD. 
