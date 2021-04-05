# Data summary table
library(ComplexHeatmap)
library(dplyr)
library(fastDummies)
library(tidyr)
library(circlize)

label = read.csv("~/documents/confirm_CPTAC-UCEC/Labels.csv")
label$histology = label$histology_Endometrioid + label$histology_Serous*2 + label$histology_Mixed*3
label$histology = gsub(0, NA, label$histology)
label$histology = gsub(1, 'endometrioid', label$histology)
label$histology = gsub(2, 'serous', label$histology)
label$histology = gsub(3, 'mixed', label$histology)

label$subtype = label$subtype_CNV.L + label$subtype_CNV.H*2 + label$subtype_MSI.H*3 + label$subtype_POLE*4
label$subtype = gsub(0, NA, label$subtype)
label$subtype = gsub(1, 'CNV-L', label$subtype)
label$subtype = gsub(2, 'CNV-H', label$subtype)
label$subtype = gsub(3, 'MSI', label$subtype)
label$subtype = gsub(4, 'POLE', label$subtype)

label = label[,-which(names(label) %in% c("histology_0NA", "histology_Endometrioid", "histology_Serous", "histology_Mixed", "subtype_CNV.L", "subtype_CNV.H", "subtype_MSI.H", "subtype_POLE"))]

slides = read.csv("~/documents/confirm_CPTAC-UCEC/Slides_sum.csv")
label = inner_join(label, slides, by="Patient_ID")

write.csv(label, "~/documents/confirm_CPTAC-UCEC/HM_table.csv", row.names=FALSE)

# Heatmap
label = read.csv('~/documents/confirm_CPTAC-UCEC/HM_table.csv')

get_color = function(colors,factor){
  levels=levels(factor)
  print(levels)
  res = colors[unique(as.numeric(sort(factor)))]
  res = res[!is.na(res)]
  names(res) = levels
  print(res)
  return(res)
}

rownames(label)=as.character(label$Patient_ID)
binaries = c('gray90', 'gray10')

label[,28:29] = lapply(label[,28:29],
                               function(x)as.factor(x))
ColSide=list()

ColSide[['histology']]=get_color(colors=c('#7fc97f','#beaed4','#fdc086'),
                               factor=label$histology)

ColSide[['subtype']]=get_color(colors=c('#1b9e77','#d95f02', '#7570b3', '#e7298a'),
                                 factor = label$subtype)

ColSide[['age']]=colorRamp2(breaks=range(label$age, na.rm=T), 
                             colors=c('#fee5d9', '#fb6a4a'))

ColSide[['BMI']]=colorRamp2(breaks=range(label$BMI, na.rm=T),
                                           colors=c("#eff3ff","#2171b5"))

ColSide[['slides']]=colorRamp2(breaks=range(label$slides, na.rm=T),
                                   colors=c("#fcfbfd", "#3f007d"))


ca = HeatmapAnnotation(df = label[order(label$subtype, label$histology),c(29, 28, 2, 3, 30)], na_col ='white',
                       which = 'column',
                       annotation_name_gp = gpar(fontsize =12,fontface='bold'),
                       annotation_height = unit(rep(0.5,length(ColSide)), "inch"),
                       border = F,
                       gap = unit(rep(0,length(ColSide)), "inch"),
                       annotation_legend_param = list(title_gp = gpar(fontsize = 12,fontface = 'bold'),
                                                      labels_gp = gpar(fontsize = 12),
                                                      direction='vertical',
                                                      #nrow =2, ncol=10,
                                                      grid_width= unit(0.3,'inch'),
                                                      grid_height = unit(0.3,'inch')
                       ),
                       col = ColSide,
                       show_annotation_name =T)

ph = as.matrix(t(label[,4:27]))

plot_heatmap=Heatmap(ph[,order(label$subtype, label$histology)], col = colorRamp2(c(0, 1), binaries), 
                     top_annotation = ca, cluster_columns = F, cluster_rows = F, show_heatmap_legend = F, show_column_names = F)

out_dir = '~/documents/confirm_CPTAC-UCEC/'
pdf(file = paste(out_dir,'label_summary.pdf',sep='/'),
    width =20, height =7, bg='white')
draw(plot_heatmap, annotation_legend_side = "bottom", merge_legend = TRUE)
graphics.off()

