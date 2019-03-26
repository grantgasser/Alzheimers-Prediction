# Alzheimer's Diagnosis
Research Project by Grant Gasser under advisement of [Dr. Joshua Patrick](https://www.baylor.edu/statistics/index.php?id=941853 "Joshua Patrick")

![ADNI Picture](http://adni.loni.usc.edu/wp-content/themes/freshnews-dev-v2/images/ADNI_logo_vector.png "ADNI")

## Summary of Alzheimer's Disease
Alzheimer's disease (AD) is a progressive neurodegenerative disease. Though best known for its role in declining memory function, symptoms also include: difficulty thinking and reasoning, making judgements and decisions, and planning and performing familiar tasks. It may also cause alterations in personality and behavior. The cause of AD is not well understood. There is thought to be a significant hereditary component. For example, a variation of the APOE gene, APOE e4, increases risk of Alzheimer's disease. Pathologically, AD is associated with [amyloid beta plaques](https://www.google.com/search?hl=en&authuser=0&biw=1500&bih=687&tbm=isch&sa=1&ei=kf95XM7aDqq4jwS8gLq4Dw&q=amyloid+plaques&oq=amyloid+plaques&gs_l=img.3..35i39j0l7.4609.6096..6209...0.0..0.53.317.7......1....1..gws-wiz-img.GSgXEP-kU3g) and [neurofibrillary tangles](https://www.google.com/search?hl=en&authuser=0&tbm=isch&q=amyloid+plaques&chips=q:amyloid+plaques,g_1:neurofibrillary+tangles:g4CvXoEy7h0%3D&usg=AI4_-kTMw9QaPmdY4wGL4xAlH9TlVhV6-w&sa=X&ved=0ahUKEwjtrcviyOLgAhWI5YMKHSUWCAIQ4lYIKigB&biw=1500&bih=687&dpr=1).

### Diagnosis
Onset of the disease is slow and early symptoms are often dismissed as normal signs of aging. A diagnosis is typically given based on history of illness, cognitive tests, medical imaging, and blood tests.

### Treatment
There is no medication that stops or reverses the progression of AD. There are two types of drugs that attempt to treat the cognitive symptoms:
* Acetylcholinesterase Inhibitors that work to prevent the breakdown of acetylcholine, a neuorotransmitter critical in memory and cognition. 
* Memantine (Namenda), which works to inhibit NMDA receptors in the brain.

These medications can slightly slow down the progression of the disease.

### Prevention
It is thought that frequent mental and physical exercise may reduce risk.

---

## Project Motivation
The Alzheimer's Association estimates nearly 6 million Americans suffer from the disease and is the 6th leading cause of death in the US. The estimated cost of AD was $277 billion in the US in 2018. They estimate *early and accurate* diagnoses could save up to $7.9 trillion in medical and care costs over the next 30 years. 

Sources: [Mayo Clinic](https://www.mayoclinic.org/diseases-conditions/alzheimers-disease/symptoms-causes/syc-20350447 "Mayo Clinic - Alzheimer's Disease"), [Alzheimer's Association](https://www.alz.org/alzheimers-dementia/facts-figures), [Wikipedia](https://en.wikipedia.org/wiki/Alzheimer's_disease)


### Project Description: 
Using data provided by the [ADNI Project](http://adni.loni.usc.edu/), it is our goal to develop a computer model that assists in the diagnosis of the disease. We will try multiple models recently popularized in machine learning (neural networks, SVM's, Random Forests) and more traditional statistical models such as multinomial regression, ordinal regression, and decision trees. 

---
## Methods

### Ordinal Regression (Ranking Learning) in R (CN < LMCI < AD)
* File: [ordinal.R](https://github.com/grantgasser/Alzheimers-Prediction/blob/master/ordinal.R)
* Features/Predictor Variables Used: AGE (Age at baseline), PTGENDER (Sex), PTEDUCAT (Years of Education), PTRACCAT (Race), APOE4 (APOE4) genotype, MMSE (MMSE score), Imputed_genotype (Challenge specific designation, TRUE=has imputed genotypes)
* Labels: (CN, LMCI, AD)

* There are six scenarios:

| Prediction    | Actual        |
| ------------- |:-------------:|
| CN     | LMCI |
| CN     | AD      |
| LMCI | CN      |

**Results:** 70% accuracy (110/157)
* If y is {LMCI, AD} and prediction = CN, it is a False Negative. If y = CN and prediction is {LMCI, AD}, it is a False Positive.
* Main problem with the model is False Negatives. As pointed out at the end of the script, when the model makes incorrect predictions, it often predicts Cognitively Normal (CN) when a patient has Limited Mild Conitive Impairment (LMCI) or Alzheimer's (AD). Roughly 50% of the errors were False Negatives.
* This leads to a model with low sensitivity.

**Propsed Solution:** Only predict CN if CN > some threshold as opposed to predicting max(P(CN), P(LMCI), P(AD)).   

**Note:** The model assumes the diagnoses provided are correct. Since a diagnosis cannot be verified until autopsy, there is essentially no ground truth in this data set.
