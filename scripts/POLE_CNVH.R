# Double CNV-H and POLE
library(dplyr)

CNVH = read.csv("~/documents/confirm_CPTAC-UCEC/Results/X4CNVH_NL5/out/Test_slide.csv")
POLE = read.csv("~/documents/confirm_CPTAC-UCEC/Results/F2POLE_NL5/out/Test_slide.csv")

colnames(CNVH) = c("slide", "BMI", "CNVH_NEG_score", "CNVH_POS_score", "CNVH_True_label", "CNVH_Prediction")
colnames(POLE) = c("slide", "BMI", "POLE_NEG_score", "POLE_POS_score", "POLE_True_label", "POLE_Prediction")
CNVH = CNVH[, c("slide", "CNVH_NEG_score", "CNVH_POS_score", "CNVH_True_label", "CNVH_Prediction")]
POLE = POLE[, c("slide", "POLE_NEG_score", "POLE_POS_score", "POLE_True_label", "POLE_Prediction")]

jj = inner_join(CNVH, POLE, by=c('slide'))
write.csv(jj, "~/documents/confirm_CPTAC-UCEC/Results/X4CNVH_NL5_F2POLE_NL5.csv")

jj.x = jj[jj$CNVH_Prediction == 'CNV.H' & jj$POLE_POS_score > 0.7,]
write.csv(jj.x, "~/documents/confirm_CPTAC-UCEC/Results/CNVH_POLE_07.csv")

jj.y = jj[jj$CNVH_Prediction == 'CNV.H' & jj$POLE_POS_score > 0.75,]
write.csv(jj.y, "~/documents/confirm_CPTAC-UCEC/Results/CNVH_POLE_075.csv")

