# RNA_Seq

# Change to the folder you downloaded the feature counts output
working_directory <- "C:/Users/korbi/Desktop/RNA_Seq_2024/work_local"
setwd(working_directory)

library("RColorBrewer")
library("ggplot2")

if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
#the following packages are part of the Bioconductor project and may be installed as follows:
#BiocManager::install("<package-name>")
library("GenomeInfoDb")
library("IRanges")
library("DESeq2")
library("pheatmap")
library("PoiClaClu")
library("biomaRt")        #N.B.: Rtools is needed for biomaRt
library("clusterProfiler")
library("org.Hs.eg.db")
library("AnnotationDbi")
library( "EnhancedVolcano" )


# Read count data
count_data <- readLines(paste0(working_directory, "/all_FeatureCounts.txt"))
# Drop first line
count_data <- count_data[-1]
# Make it a table
count_data_table <- read.table(text = count_data, header = TRUE)

# List of columns to exclude
columns_to_exclude <- c("Chr", "Start", "End", "Strand", "Length")
# Subset to keep only the relevant columns for DESeq2
countData_subset <- count_data_table[, !(colnames(count_data_table) %in% columns_to_exclude)]

# Rename complicated column names
samples_list <- gsub(".*\\.([^.]+)_sorted\\.bam", "\\1", colnames(countData_subset))
colnames(countData_subset) <- samples_list
## .*\\. matches everything before the last . before the desired name (e.g. "HER21").
## ([^.]+) captures the desired name (e.g. HER21).
## _sorted\\.bam ensures the capture stops before the _sorted.bam part.
## \\1 replaces the full match with the first captured group.

# Set the gene IDs as row names
rownames(countData_subset) <- countData_subset$Geneid

# Remove the geneid column as it's now part of the row names
countData_subset <- countData_subset[, -1]


samples_list_meta <- samples_list[-1]
samples_list_grouping <- sub("\\d$", "", samples_list_meta)

#create a lookup table
lookup_table <- data.frame(t(samples_list_grouping))
colnames(lookup_table) <- samples_list_meta
lookup_table_transposed <- as.data.frame(t(lookup_table))

#making sure the column names in colData matches the column names in countData_subset
all(colnames(countData_subset) %in% rownames(lookup_table_transposed))
# are they in the same order?
all(colnames(countData_subset) == rownames(lookup_table_transposed))
colnames(lookup_table_transposed) <- "origin"
# Convert the 'origin' column to a factor explicitly
lookup_table_transposed$origin <- as.factor(lookup_table_transposed$origin)

dds <- DESeqDataSetFromMatrix(countData = countData_subset,
                              colData = lookup_table_transposed,
                              design = ~origin)

#dds


# Set the reference level of 'origin' to 'Normal'
dds$origin <- relevel(dds$origin, ref = "Normal")

# running DESeq
# it will normalize each sample by the total number of reads in the library
dds <- DESeq(dds)
# add a contrast = c("TNBC","Normal")
# the smaller the p-value, the less chance ist that the difference between the groups is random)
res <- results(dds)
res
# check for the lowest adj p-value
# e.g. 0.01

#summary(res)
#resultsNames(dds)


## Visualize the data and quality control
# Extracting transformed values
vsd <- vst(dds, blind=TRUE)



# Principal component analysis of the samples
pca_results <- plotPCA(vsd, intgroup=c("origin"))
#pca_results
plotPCA(vsd, intgroup=c("origin"))

#One HER2 sample looks quite distant to its group, so we check for the euclidean
# distances for all samples, since the PCA is "just" a projection

#check the sample similarity
sampleDists <- dist(t(assay(vsd)))
sampleDists
sampleDistMatrix <- as.matrix( sampleDists )
sample_labels <- rownames(colData(vsd))
rownames(sampleDistMatrix) <- sample_labels
colnames(sampleDistMatrix) <- sample_labels
colors <- colorRampPalette( rev(brewer.pal(9, "BrBG")) )(255)

sample_annotations <- as.data.frame(colData(vsd)[, c("origin")])  # Extract relevant metadata
colnames(sample_annotations) <- "Origin"  # Rename for clarity

# Ensure rownames match the sampleDistMatrix
rownames(sample_annotations) <- sample_labels

pheatmap(sampleDistMatrix,
         clustering_distance_rows = sampleDists,
         clustering_distance_cols = sampleDists,
         col = colors,
         annotation_row = sample_annotations)

#check for the distances within each group
# Unique groups
grouping <- as.character(lookup_table[1, ])
groups <- unique(grouping)
# Function to calculate within-group mean distances, SD, SEM
calculate_group_stats <- function(group, dist_matrix, group_labels) {
  group_indices <- which(group_labels == group)
  group_distances <- dist_matrix[group_indices, group_indices]
  upper_tri <- group_distances[upper.tri(group_distances)]
  
  mean_distance <- mean(upper_tri)
  sd_distance <- sd(upper_tri)
  sem_distance <- sd_distance / sqrt(length(upper_tri))
  
  list(mean = mean_distance, sd = sd_distance, sem = sem_distance)
}
# Data frame creation
group_stats <- do.call(rbind, lapply(groups, function(group) {
  stats <- calculate_group_stats(group, sampleDistMatrix, grouping)
  data.frame(Group = group, Mean_Distance = stats$mean, SD = stats$sd, SEM = stats$sem)
}))

# View result
# print(group_stats)
# Barplot
bp <- barplot(group_stats$Mean_Distance,
              names.arg = group_stats$Group,
              main = "Within-Group Mean Distances with Error Bars",
              col = "skyblue",
              ylim = c(0, max(group_stats$Mean_Distance + group_stats$SEM) * 1.1),
              ylab = "Mean Distance",
              xlab = "Group")

# Add error bars (SEM)
arrows(x0 = bp, y0 = group_stats$Mean_Distance - group_stats$SEM,
       x1 = bp, y1 = group_stats$Mean_Distance + group_stats$SEM,
       angle = 90, code = 3, length = 0.1, col = "black")

# Poisson distances, they also take the variance of the counts into account:

poisd <- PoissonDistance(t(counts(dds)))
samplePoisDistMatrix <- as.matrix( poisd$dd )
# Extract samplename
rownames(samplePoisDistMatrix) <- rownames(colData(dds))
# Set column names to match row names (same sample names)
colnames(samplePoisDistMatrix) <- rownames(colData(dds))


pheatmap(samplePoisDistMatrix,
         clustering_distance_rows = poisd$dd,
         clustering_distance_cols = poisd$dd,
         col = colors)

# Since we only have 3 samples per group, the within-group distances are acceptable
# We continue with the PCA results and don't exclude HER22 - the one with the biggest distance

# Extract the PCA results
pca_data <- plotPCA(vsd, intgroup = c("origin"), returnData = TRUE)

# PCA results are stored in pca_data. It contains the coordinates of the samples in PCA space.
head(pca_data)  # This gives the first few rows with PCA1, PCA2, and the associated sample info

# To see the gene loadings, you can use the prcomp function on the variance-stabilized data
pca_results <- prcomp(assay(vsd))  # Perform PCA on the transformed data

# Access the loadings (i.e., how each gene contributes to the PCs)
loadings <- pca_results$rotation

# View the first few loadings (genes contributing to PCA1 and PCA2)
# this shows the PCAs not the genes - need to re-tinker on that one
head(loadings)

### Contrasting out the comparisons of the 3 tumor subgroups
#contrast

## TNBC_VS_HER2
res_TNBC_vs_HER2 <- results(dds, contrast=c("origin","TNBC","HER2"), alpha= 0.05)
## Adding gene names
res_TNBC_vs_HER2$ensembl <- sapply( strsplit( rownames(res_TNBC_vs_HER2), split="\\+" ), "[", 1 )
ensembl = useMart( "ensembl", dataset = "hsapiens_gene_ensembl" )
genemap <- getBM( attributes = c("ensembl_gene_id", "entrezgene_id", "hgnc_symbol"),
                  filters = "ensembl_gene_id",
                  values = res_TNBC_vs_HER2$ensembl,
                  mart = ensembl )
idx <- match( res_TNBC_vs_HER2$ensembl, genemap$ensembl_gene_id )
res_TNBC_vs_HER2$entrez <- genemap$entrezgene[ idx ]
res_TNBC_vs_HER2$hgnc_symbol <- genemap$hgnc_symbol[ idx ]
head(res_TNBC_vs_HER2,4)

# Numbers of genes up or downregulated
summary(res_TNBC_vs_HER2)
# filtering out the genes with adjusted p-value < 0.05
sum( res_TNBC_vs_HER2$padj < 0.05, na.rm=TRUE )
resSig_TNBC_vs_HER2 <- res_TNBC_vs_HER2[ which(res_TNBC_vs_HER2$padj < 0.05 ), ]
summary(resSig_TNBC_vs_HER2)
# significant genes with the strongest down-regulation
head( resSig_TNBC_vs_HER2[ order( resSig_TNBC_vs_HER2$log2FoldChange ), ] )
# with the strongest upregulation
tail( resSig_TNBC_vs_HER2[ order( resSig_TNBC_vs_HER2$log2FoldChange ), ] )

## NonTNBC_VS_HER2
res_NonTNBC_vs_HER2 <- results(dds, contrast=c("origin","NonTNBC","HER2"), alpha= 0.05)
## Adding gene names
res_NonTNBC_vs_HER2$ensembl <- sapply( strsplit( rownames(res_NonTNBC_vs_HER2), split="\\+" ), "[", 1 )
genemap <- getBM( attributes = c("ensembl_gene_id", "entrezgene_id", "hgnc_symbol"),
                  filters = "ensembl_gene_id",
                  values = res_NonTNBC_vs_HER2$ensembl,
                  mart = ensembl )
idx <- match( res_NonTNBC_vs_HER2$ensembl, genemap$ensembl_gene_id )
res_NonTNBC_vs_HER2$entrez <- genemap$entrezgene[ idx ]
res_NonTNBC_vs_HER2$hgnc_symbol <- genemap$hgnc_symbol[ idx ]
head(res_NonTNBC_vs_HER2,4)

# Numbers of genes up or downregulated
summary(res_NonTNBC_vs_HER2)
# filtering out the genes with adjusted p-value < 0.05
sum( res_NonTNBC_vs_HER2$padj < 0.05, na.rm=TRUE )
resSig_NonTNBC_vs_HER2 <- res_NonTNBC_vs_HER2[ which(res_NonTNBC_vs_HER2$padj < 0.05 ), ]
summary(resSig_NonTNBC_vs_HER2)
# significant genes with the strongest down-regulation
head( resSig_NonTNBC_vs_HER2[ order( resSig_NonTNBC_vs_HER2$log2FoldChange ), ] )
#  with the strongest upregulation
tail( resSig_NonTNBC_vs_HER2[ order( resSig_NonTNBC_vs_HER2$log2FoldChange ), ] )

## NonTNBC_VS_TNBC
res_NonTNBC_vs_TNBC <- results(dds, contrast=c("origin","NonTNBC","TNBC"), alpha= 0.05)
## Adding gene names
res_NonTNBC_vs_TNBC$ensembl <- sapply( strsplit( rownames(res_NonTNBC_vs_TNBC), split="\\+" ), "[", 1 )
genemap <- getBM( attributes = c("ensembl_gene_id", "entrezgene_id", "hgnc_symbol"),
                  filters = "ensembl_gene_id",
                  values = res_NonTNBC_vs_TNBC$ensembl,
                  mart = ensembl )
idx <- match( res_NonTNBC_vs_TNBC$ensembl, genemap$ensembl_gene_id )
res_NonTNBC_vs_TNBC$entrez <- genemap$entrezgene[ idx ]
res_NonTNBC_vs_TNBC$hgnc_symbol <- genemap$hgnc_symbol[ idx ]
head(res_NonTNBC_vs_TNBC,4)

# Numbers of genes up or downregulated
summary(res_NonTNBC_vs_TNBC)
# filtering out the genes with adjusted p-value < 0.05
sum( res_NonTNBC_vs_TNBC$padj < 0.05, na.rm=TRUE )
resSig_NonTNBC_vs_TNBC <- res_NonTNBC_vs_TNBC[ which(res_NonTNBC_vs_TNBC$padj < 0.05 ), ]
summary(resSig_NonTNBC_vs_TNBC)
# significant genes with the strongest down-regulation
head( resSig_NonTNBC_vs_TNBC[ order( resSig_NonTNBC_vs_TNBC$log2FoldChange ), ] )
#  with the strongest upregulation
tail( resSig_NonTNBC_vs_TNBC[ order( resSig_NonTNBC_vs_TNBC$log2FoldChange ), ] )

## TNBC_VS_Normal (this was done to just have an idea how the difference between cancer and normal could look; the data was not used in the report)
res_TNBC_vs_Normal <- results(dds, contrast=c("origin","TNBC","Normal"), alpha= 0.05)
## Adding gene names
res_TNBC_vs_Normal$ensembl <- sapply( strsplit( rownames(res_TNBC_vs_Normal), split="\\+" ), "[", 1 )
genemap <- getBM( attributes = c("ensembl_gene_id", "entrezgene_id", "hgnc_symbol"),
                  filters = "ensembl_gene_id",
                  values = res_TNBC_vs_Normal$ensembl,
                  mart = ensembl )
idx <- match( res_TNBC_vs_Normal$ensembl, genemap$ensembl_gene_id )
res_TNBC_vs_Normal$entrez <- genemap$entrezgene[ idx ]
res_TNBC_vs_Normal$hgnc_symbol <- genemap$hgnc_symbol[ idx ]
head(res_TNBC_vs_Normal,4)

# Numbers of genes up or downregulated
summary(res_TNBC_vs_Normal)
# filtering out the genes with adjusted p-value < 0.05
sum( res_TNBC_vs_Normal$padj < 0.05, na.rm=TRUE )
resSig_TNBC_vs_Normal <- res_TNBC_vs_Normal[ which(res_TNBC_vs_Normal$padj < 0.05 ), ]
summary(resSig_TNBC_vs_Normal)
# significant genes with the strongest down-regulation
head( resSig_TNBC_vs_Normal[ order( resSig_TNBC_vs_Normal$log2FoldChange ), ] )
#  with the strongest upregulation
tail( resSig_TNBC_vs_Normal[ order( resSig_TNBC_vs_Normal$log2FoldChange ), ] )


# Export the results of the contrast and filtering
write.csv( as.data.frame(resSig_TNBC_vs_HER2), file="results_TNBC_vs_HER2_padj_0.05.csv" )
write.csv( as.data.frame(resSig_NonTNBC_vs_HER2), file="results_NonTNBC_vs_HER2_padj_0.05.csv" )
write.csv( as.data.frame(resSig_NonTNBC_vs_TNBC), file="results_NonTNBC_vs_TNBC_padj_0.05.csv" )
write.csv( as.data.frame(resSig_TNBC_vs_Normal), file="results_TNBC_vs_Normal_padj_0.05.csv" )



## Enhanced volcano to show up- and down-regulated genes


# TNBC_VS_HER2
EnhancedVolcano(resSig_TNBC_vs_HER2,
                lab = resSig_TNBC_vs_HER2$hgnc_symbol,
                x = 'log2FoldChange',
                y = 'padj',
                title = 'TNBC vs HER2',
                pointSize = 2.0,
                labSize = 3.0,
                colAlpha = 2,
                legendPosition = 'None',
                legendLabSize = 12,
                legendIconSize = 4.0,
                drawConnectors = TRUE,
                widthConnectors = 0.5)

# NonTNBC_VS_HER2
EnhancedVolcano(resSig_NonTNBC_vs_HER2,
                lab = resSig_NonTNBC_vs_HER2$hgnc_symbol,
                x = 'log2FoldChange',
                y = 'padj',
                title = 'NonTNBC vs HER2',
                pointSize = 3.0,
                labSize = 4.0,
                colAlpha = 2,
                legendPosition = 'None',
                legendLabSize = 12,
                legendIconSize = 4.0,
                drawConnectors = TRUE,
                widthConnectors = 0.5)
# NonTNBC_VS_TNBC
EnhancedVolcano(resSig_NonTNBC_vs_TNBC,
                lab = resSig_NonTNBC_vs_TNBC$hgnc_symbol,
                x = 'log2FoldChange',
                y = 'padj',
                title = 'NonTNBC vs TNBC',
                pointSize = 3.0,
                labSize = 4.0,
                colAlpha = 2,
                legendPosition = 'None',
                legendLabSize = 12,
                legendIconSize = 4.0,
                drawConnectors = TRUE,
                widthConnectors = 0.5)

# Comparison of selected genes
CDKN2A <- plotCounts(dds, "ENSG00000147889", intgroup = c("origin"), returnData = TRUE)
boxplot(count ~ origin, data = CDKN2A, main = "Expression of CDKN2A")

ESR1 <- plotCounts(dds, "ENSG00000091831", intgroup = c("origin"), returnData = TRUE)
boxplot(count ~ origin, data = ESR1, main = "Expression of ESR1")

SNORA53 <- plotCounts(dds, "ENSG00000212443", intgroup = c("origin"), returnData = TRUE)
boxplot(count ~ origin, data = SNORA53, main = "Expression of SNORA53")

## GO overrepresentation analysis
# NonTNBC_VS_HER2
geneListAll_NonTNBC_VS_HER2 <- rownames(res_NonTNBC_vs_HER2)
geneList_NonTNBC_VS_HER2 <- rownames(resSig_NonTNBC_vs_HER2)

ego <- enrichGO(gene         = geneList_NonTNBC_VS_HER2,
                universe      = geneListAll_NonTNBC_VS_HER2,
                OrgDb         = org.Hs.eg.db,
                keyType       = "ENSEMBL",
                ont           = "BP",
                pAdjustMethod = "BH",
                pvalueCutoff  = 0.1,
                qvalueCutoff  = 0.1,
                readable      = TRUE)
head(ego, 3)  
dotplot(ego) + ggtitle("GO terms NonTNBC VS HER2")

## The R session was documented as follows:
#sessionInfo()
#writeLines(capture.output(sessionInfo()), "R_session_info.txt")
