## MSI by APM
library(dplyr)

tiles = read.table(file='~/documents/confirm_CPTAC-UCEC/Results/I5MSI_NL5/out/Test_tile.csv',header=T,sep=',')
slides = read.table(file='~/documents/confirm_CPTAC-UCEC/Results/I5MSI_NL5/out/Test_slide.csv',header=T,sep=',')
APM = read.table(file='Immune_label.csv',header=T,sep=',')
APM = APM[, c(1, 8)]
colnames(APM) = c('slide', 'APM')

tiles = inner_join(tiles, APM, by='slide')
tiles = tiles[, -8]
colnames(tiles)[8] = 'True_label'
tiles$True_label = gsub(1, 'MSI.H', tiles$True_label)
tiles$True_label = gsub(0, 'negative', tiles$True_label)

slides = inner_join(slides, APM, by='slide')
slides = slides[, -4]
colnames(slides)[5] = 'True_label'
slides$True_label = gsub(1, 'MSI.H', slides$True_label)
slides$True_label = gsub(0, 'negative', slides$True_label)

write.table(tiles, file='~/documents/confirm_CPTAC-UCEC/Results/I5MSI_APM/out/Test_tile.csv', row.names = F, sep=',')
write.table(slides, file='~/documents/confirm_CPTAC-UCEC/Results/I5MSI_APM/out/Test_slide.csv', row.names = F, sep=',')


