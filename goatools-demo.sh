#!/usr/bin/bash

# Download obo files
wget -c -nv -t 5 http://geneontology.org/ontology/go-basic.obo
wget -c -nv -t 5 http://www.geneontology.org/ontology/subsets/goslim_generic.obo

# GOenrichment analysis
find_enrichment.py ./data/at_stress_deg_list.txt ./data/at_all_gene_list.txt ./data/at_go_association.txt \
--pval=0.05 --method=fdr_bh --pval_field=fdr_bh \
--outfile=at_go_enrichment.tsv,at_go_enrichment.xlsx

# GOenrichment analysis with GOslim
map_to_slim.py --association_file=./data/at_go_association.txt go-basic.obo goslim_generic.obo > ./data/at_go_association_slim.txt
find_enrichment.py ./data/at_stress_deg_list.txt ./data/at_all_gene_list.txt ./data/at_go_association_slim.txt \
--pval=0.05 --method=fdr_bh --pval_field=fdr_bh \
--outfile=at_go_enrichment_slim.tsv,at_go_enrichment_slim.xlsx

# GOenrichment analysis per BP/CC/MF category
for category in BP CC MF
do
    find_enrichment.py ./data/at_stress_deg_list.txt ./data/at_all_gene_list.txt ./data/at_go_association.txt \
    --pval=0.05 --method=fdr_bh --pval_field=fdr_bh --ns=$category \
    --outfile=at_go_enrichment_$category.tsv,at_go_enrichment_$category.xlsx
done

# GOenrichment analysis output all results
find_enrichment.py ./data/at_stress_deg_list.txt ./data/at_all_gene_list.txt ./data/at_go_association.txt \
--pval=-1 --method=fdr_bh --pval_field=fdr_bh \
--outfile=at_go_enrichment_all.tsv,at_go_enrichment_all.xlsx

# Plot is-a relationship of specified GOterm
plot_go_term.py --term=GO:0009415 --output=response_to_water.jpg
plot_go_term.py --term=GO:0009415 --output=response_to_water_noparents.jpg --disable-draw-parents
plot_go_term.py --term=GO:0009415 --output=response_to_water_nochildren.jpg --disable-draw-children

# Plot relationship of multi specified GOterm
go_plot.py GO:0003304 GO:0061371 --outfile=multi_plot.png
go_plot.py GO:0003304 GO:0061371#ff0000 -r --outfile=multi_plot_all_relation.png

# Plot GOenrichment BP category Top10 GOterm result
grep GO: at_go_enrichment.tsv | grep BP | head -n 10 | cut -f 1 > go_enrichment_list.txt
go_plot.py --go_file=go_enrichment_list.txt --outfile=plot_go_enrichment_BP.png

# Plot GOenrichment BP category Top10 GOterm result with gradation color
echo -e "#ff2200\tGO:0009409\n#ff4400\tGO:0009628\n#ff6600\tGO:0006950\n#ff8800\tGO:0009266\n#ffaa00\tGO:0009415\n#ffbb00\tGO:0001101\n#ffcc00\tGO:0050896\n#ffdd00\tGO:0009414\n#ffee00\tGO:0010035\n#ffff00\tGO:0006970" \
> go_enrichment_color_list.txt
go_plot.py --go_file=go_enrichment_color_list.txt --outfile=plot_color_go_enrichment_BP.png
