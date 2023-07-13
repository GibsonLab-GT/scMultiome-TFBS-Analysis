#!/opt/anaconda3/bin/Rscript

library(circlize)
library(gt)
library(paletteer)
library(readr)
library(tidyverse)

# To Run:
# Rscript ./circos_plotter.R <adjacency_matrix.txt> 

args = commandArgs(trailingOnly=TRUE)
adj_mat_df <- read.delim(args[1])

### 1.0 Create Adj. Matrix Input for Circos Plot ###
# 1.1 Sort by DEGs_Log2FC, Remove DEGs_Log2FC column
sorted_adj_mat_df <- adj_mat_df[order(adj_mat_df$avg_log2FC),]
preadj_mat <- sorted_adj_mat_df
preadj_mat <- preadj_mat[,!(names(preadj_mat) %in% "avg_log2FC")]
adj_mat <- preadj_mat %>% remove_rownames %>% column_to_rownames(var="DEG")

# 1.2 convert df to matrix
adj_mat <- data.matrix(adj_mat, rownames.force = NA)

### 2.0 Initialize Colors for GEX ###
# 2.1 Keep DEGs_Log2FC as separate vector:
predegs_log2fc <- data.frame(sorted_adj_mat_df$DEG, sorted_adj_mat_df$avg_log2FC)
degs_log2fc <- predegs_log2fc %>% remove_rownames %>% column_to_rownames(var="sorted_adj_mat_df.DEG")

# 2.2 Create color palette
min_val <- min(degs_log2fc$sorted_adj_mat_df.avg_log2FC)
max_val <- max(degs_log2fc$sorted_adj_mat_df.avg_log2FC)

val <- max(abs(min_val), abs(max_val))

min_range <- -1*ceiling(val*10)/10
max_range <- ceiling(val*10)/10

col_fun <- colorRamp2(c(min_range, 0, max_range), c("blue4", "grey99", "red4"))
genecols <- col_fun(degs_log2fc$sorted_adj_mat_df.avg_log2FC)

# 2.3 Assign colors
# assign gradient to genes
names(genecols) <- rownames(degs_log2fc)
# assign one color to tfs
tfs <- c()
for (i in 1:length(colnames(adj_mat))){
  tfs <- append(tfs,"darkolivegreen")
}
names(tfs) <- colnames(adj_mat)
# concatenate gene and tf color assignments
grid.col <- c(genecols, tfs) 

### 3.0 Plot Circos Plot ###
pdf(file = "circos_plot.pdf", width = 13, height = 13)
circos.par(start.degree = 90)
# 3.1 Draw Plot
chordDiagram(adj_mat,
             big.gap = 10, # gap between TFs and genes
             transparency = 0.3,
             grid.col = grid.col,
             annotationTrack = "grid",
             preAllocateTracks = list(
               track.margin = c(mm_h(2), 0)),
             reduce = -5,
             #direction.type = "diffHeight+arrows",
             #link.arr.col = "gray28",
             directional = -1 # direction; column to rows
)
# 3.2 Add TF and Gene Names

### Use this for DETFs; n = 11 genes
circos.trackPlotRegion(track.index = 1, panel.fun = function(x, y) {
  xlim = get.cell.meta.data("xlim")
  sector.index = get.cell.meta.data("sector.index")
  ylim = get.cell.meta.data("ylim")
  xplot = get.cell.meta.data("xplot")
  sector.name = get.cell.meta.data("sector.index")
  
  #text direction (dd) and adjusmtents (aa)
  theta = circlize(mean(xlim), 1.3)[1, 1] %% 360
  print(sector.name)
  print(theta)
  dd <- ifelse(theta < 91 || theta > 265, "clockwise", "reverse.clockwise")
  aa = c(1, 0.5)
  if(theta < 91 || theta > 265) aa = c(0,0.5)
  circos.text(mean(xlim), ylim[1], labels=sector.name, facing = dd, cex=1.2,  adj = aa)
}, bg.border = NA)

### 4.0 Add Legend ###
# 4.1 Set Color Gradient
lgd_ = rep(NA, 25)
lgd_[c(1, 13, 25)] = c(max_range, "0", min_range)
# 4.2 Title
legend(x = 0.82, y = 1.06,
       c("",""),
       border = NA,
       y.intersp = 0.2,
       cex = 1.2, text.font = 2,
       box.lty = 0,
       title = "GEX Log2FC",
       title.adj = 0.7
)
# 4.3 Plot Color Scale Gradient
legend(x = 0.81, y = 1,
       legend = lgd_,
       fill = colorRampPalette(colors = c("red4", "grey99", "blue4"))(25),
       border = NA,
       y.intersp = 0.2,
       cex = 1.2, text.font = 1,
       box.lty = 0,
       title = "",
       title.adj = 1.2
)
dev.off()
