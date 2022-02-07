# Filter tSNE for sup fig 1
CNVH = read.csv("~/documents/confirm_CPTAC-UCEC/Results/X4CNVH_NL5/out/tSNE_P_N.csv")
ref = read.csv("~/documents/confirm_CPTAC-UCEC/Labels.csv")

Se = ref[ref$histology_Serous == 1, ]
En = ref[ref$histology_Endometrioid == 1, ]

Se = CNVH[CNVH$slide %in% Se$Patient_ID, ]
En = CNVH[CNVH$slide %in% En$Patient_ID, ]
Se$True_label = as.factor(Se$True_label)
En$True_label = as.factor(En$True_label)

library(ggplot2)
library(gridExtra)
p1 = ggplot(data=En,aes_string(x='tsne1',y='tsne2',col='POS_score'))+
  scale_color_gradient2(high='red',mid='gray',low='steelblue',midpoint=0.5)+
  geom_point(alpha=1, size=1)+ scale_shape(solid = TRUE)+
  xlim(-60,60)+
  ylim(-60,60)+
  theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                     panel.grid.minor = element_blank(), 
                     axis.line = element_line(colour = "black"), legend.position='bottom')

p2 = ggplot(data=En,aes_string(x='tsne1',y='tsne2'))+
  geom_point(aes(col=True_label),alpha=0.2)+
  # scale_color_manual(values = c("#999999", "#E69F00", "#56B4E9", "#009E73",
  #                               "#F0E442", "#0072B2", "#D55E00", "#CC79A7"))+
  scale_color_manual(values = c("gray70", "red"))+
  xlim(-60,60)+
  ylim(-60,60)+
  theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                     panel.grid.minor = element_blank(), 
                     axis.line = element_line(colour = "black"), legend.position='bottom')

pdf(file='~/documents/confirm_CPTAC-UCEC/Figures/En.pdf', width=14,height=7)

grid.arrange(p1,p2,nrow=1)

dev.off()


