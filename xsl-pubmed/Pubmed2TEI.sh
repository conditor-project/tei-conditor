# Pour corpus avec plusieurs notices, au choix :
# 1 - separe les notices de teiCorpus, répertoire "TEI".
# mais la séparation génère un xmlns vide à 'text' (je n'ai pas trouvé de solution, en XSL V1, c'est limité)
# donc on le supprime après (ligne 20). Ca fonctionne.

# 2  : separe les notices source, dans un répertoire PubmedUnic_annee (pour Pubmed)

# organisation et nommages source sont la mienne ... simple à ce stade
# Dans les 2 cas, les XML TEI sont dans TEI/PubmedUnic_[annee]/, et nommés "leuridentifiant.xml", ici le PMID

# 1 - separer le TEI multinotices :
# for corpus in TEI/*_TEI.xml  # TEI/qqc_an_TEI.xml
# do
#		an=`echo $corpus | cut -d_ -f2`
#		xsltproc --stringparam AN $an separe_notices.xsl ${corpus} > TEI/resultat_separe.txt
# done

# for notice in TEI/Pubmed[12]*/*_0.xml		
#	do
#		CHEMIN=`echo $notice | cut -d_ -f1`
#		cat $notice | perl -pe 's| xmlns=""||g' > ${CHEMIN}.xml
#done
# rm -rf TEI/Pubmed[12]*/*_0.xml


# 2 - separe corpus source : OK 
 for corpus in anneesCompletesIndent/*_*_source.xml
 do
	
	an=`echo $corpus | cut -d_ -f3`
	xsltproc --stringparam AN $an separe_notices.xsl ${corpus} > resultat_separe.txt
	# cette commande crée le repertoire PubmedUnic_annee, via le XSL
 done
	
for REP in PubmedUnic_*
do
	mkdir TEI/$REP
	
	for source in $REP/*.xml
	do
		xsltproc Pubmed2Conditor.xsl $source > TEI/$source
	done
done
