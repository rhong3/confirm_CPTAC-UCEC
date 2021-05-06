# Plot ROCs barplots
library(readr)
library(ggplot2)
library(ggpubr)
library(gridExtra)
library(dplyr)
summ <- read_csv("~/documents/confirm_CPTAC-UCEC/Results/Statistics_confirmatory.csv")
summ = summ[,c("Feature",	"Architecture",	"Tiles", 'Patient_ROC.95.CI_lower', 'Patient_ROC', 'Patient_ROC.95.CI_upper', 
                       'Tile_ROC.95.CI_lower', 'Tile_ROC', 'Tile_ROC.95.CI_upper')]
subtypels = c('his', 'CNVH', 'SL', 'CNVL', 'MSI', 'POLE')
NL = "NL5"
mode = "subtype"
summ = summ[(summ$Feature %in% subtypels) & (summ$Tiles == NL), c("Feature",	"Architecture",	'Patient_ROC.95.CI_lower', 'Patient_ROC', 'Patient_ROC.95.CI_upper', 
                                                                   'Tile_ROC.95.CI_lower', 'Tile_ROC', 'Tile_ROC.95.CI_upper')]
unq_features = unique(summ$Feature)
summ_out = setNames(data.frame(matrix(ncol = 8, nrow = 0)), c("Feature",	"Architecture",	'Patient_ROC.95.CI_lower', 'Patient_ROC', 'Patient_ROC.95.CI_upper', 
                                                             'Tile_ROC.95.CI_lower', 'Tile_ROC', 'Tile_ROC.95.CI_upper'))
for (ff in unq_features){
  summ_sub = summ[summ$Feature == ff, ]
  summ_sub = summ_sub[which.max(summ_sub$Patient_ROC), ]
  summ_out = rbind(summ_out, summ_sub)
}

summ_out$Feature = paste(summ_out$Feature, summ_out$Architecture, sep='_')

# Default bar plot
ps <- ggplot(summ_out, aes(x=reorder(Feature, -Patient_ROC), y=Patient_ROC)) + 
  geom_bar(stat="identity", color="black", 
           position=position_dodge()) +
  geom_errorbar(aes(ymin=Patient_ROC.95.CI_lower, ymax=Patient_ROC.95.CI_upper), width=.2,
                position=position_dodge(.9)) +
  geom_text(aes(label=round(Patient_ROC, 3)), vjust=-0.6, size=5) +labs(title="Per Patient AUROC", x="", y = "")+ylim(0,1)+
  theme_classic() +
  scale_fill_manual(values=c("#808080")) + theme(plot.title = element_text(hjust = 0.5), axis.text.x = element_text(angle = 45, hjust = 1, size=15, face="bold"))

pt <- ggplot(summ_out, aes(x=reorder(Feature, -Tile_ROC), y=Tile_ROC)) + 
  geom_bar(stat="identity", color="black", 
           position=position_dodge()) +
  geom_errorbar(aes(ymin=Tile_ROC.95.CI_lower, ymax=Tile_ROC.95.CI_upper), width=.2,
                position=position_dodge(.9)) +
  geom_text(aes(label=round(Tile_ROC, 3)), vjust=-0.6, size=5) +labs(title="Per Tile AUROC", x="", y = "", size=5)+ylim(0,1)+
  theme_classic() +
  scale_fill_manual(values=c("#808080")) + theme(plot.title = element_text(hjust = 0.5), axis.text.x = element_text(angle = 45, hjust = 1, size=15, face="bold"))

pdf(file=paste("~/documents/confirm_CPTAC-UCEC/Results/ROC_plot_patient_", mode, "_", NL, ".pdf", sep=''),
    width=5,height=5)
grid.arrange(ps,nrow=1, ncol=1)
dev.off()

pdf(file=paste("~/documents/confirm_CPTAC-UCEC/Results/ROC_plot_tile_", mode, "_", NL, ".pdf", sep=''),
    width=5,height=5)
grid.arrange(pt,nrow=1, ncol=1)
dev.off()

