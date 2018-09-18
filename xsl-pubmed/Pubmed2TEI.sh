# separe les notices de teiCorpus, supprime le xmlns vide de text
# OU : separe les notices source

# for corpus in TEI/*_TEI.xml  # TEI/qqc_an_TEI.xml
# do
#		an=`echo $corpus | cut -d_ -f2`
#		# echo $an
#		# TO DO :
#		cat $corpus | perl -pe 's| xmlns="http://www.tei-c.org/ns/1.0"||g' > ${corpus}2
#		# xsl V1, fragile : 
#		xsltproc --stringparam AN $an separe_notices.xsl ${corpus}2 > TEI/resultat_separe.txt
#		# pas OK : xsltproc --stringparam AN $an separe_noticesV2.xsl $corpus > TEI/resultat_separe.txt
# done

# for notice in TEI/Pubmed[12]*/*_0.xml		
#	do
#		# ls $notice | cut -d_ -f1
#		CHEMIN=`echo $notice | cut -d_ -f1`
#		cat $notice | perl -pe 's| xmlns=""||g' > ${CHEMIN}.xml
#done


# Corpus source : OK 
# for corpus in anneesCompletesIndent/*_*_sansDTD.xml
# for corpus in anneesCompletesIndent/*_2014_sansDTD.xml
# do
	
#	an=`echo $corpus | cut -d_ -f3`
#	xsltproc --stringparam AN $an separe_notices.xsl ${corpus} > resultat_separe.txt
	
# done
	
# Puis :
for REP in PubmedUnic_*
do
	# mkdir TEI/$REP
	
	for source in $REP/*.xml
	do
		xsltproc Pubmed2Conditor.xsl $source > TEI/$source
	done
done
