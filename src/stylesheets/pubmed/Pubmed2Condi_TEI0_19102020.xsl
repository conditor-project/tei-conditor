﻿<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xs"
    version="1.0">
    
<!-- ========================================================================================================
        C. Morel, 2018-09. Christiane Stock.  Dernière modification : 19 octobre 2020     
        
      2 modèles TEI disponibles :
      -oafr.xsd, modèle encore actuel de HAL, des choix spécifiques sur attributs, valeurs d'attributs et arborescence organismes. ne convient pas tel que pour Conditor
      - HAL_odd.xml, modèle plus récent déposé sur GitHub HAL et créé par L. Romary; et son dérivé via ROMA, document.xsd (qui appelle 2 autres xsd)
      Déposés dans https://github.com/conditor-project/tei-conditor/src/schema, sous-répertoire HALschema.xsd pour les 3 xsd liés. 
      
      3 grandes différences :
      - "abstract" : dans le nouveau modèle, il doit avoir un ou plusieurs fils éléments (p, list table). Dans l'ancien, valeur textuelle.
      - "idno" de type analytic : dans le nouveau modèle, fils de "analytic", dans l'ancien, fils de biblStruct (après monographic)
      abstract à modifier dans le fichier de config vers ElasticSearch. idno : le chemin est large, donc bon dans les 2 cas.
      - détail affiliations et organismes en général soit dans biblStruct (possible avec odd, choix Conditor) soit dans 'back' (modèle aofr, avec lien de type rid dans biblStruct) 
      
      Ce XSL traite la forme adoptée pour les 1° corpus chargés. Le faire évoluer en _TEI1 pour la suite
      - idno analytic dans biblStruct
      - abstract sans fils
      - on garde affiliation (non structurée ici) dans author
      
    Commence par traiter les notices "PubmedArticle" : templates génériques et granulaires appelés
    Puis vers ligne 820 : les notices "PubmedBookArticle" : templates génériques, appel de certains templates granulaires précédents et de nouveaux templates(plus bas)
    
    A suivre si besoin :
        - Traitement des fils de certains éléments, en général textuels dans autres sources : 
        <!ENTITY % text             "#PCDATA | b | i | sup | sub | u" > possibles dans : 
            - AbstractText, Affiliation, ArticleTitle, BookTitle et VernacularTitle (plus mml), CollectiveName, Keyword (plus mml), 
            - sub,sup, b,i,u(%text)*, 
            - CitationString, CoiStatement, CollectionTitle, Param, PublisherName, SectionTitle, Suffix, VolumeTitle
        sup et sub ont un sens sémantique, pas les autres. 
        - Allowed <mml:math> in <AbstractText>, <ArticleTitle>, <BookTitle>, <CollectionTitle>, <Keyword>, <VernacularTitle> : une seule notice, résumé
        *** Pour l'instant, texte plat ***.
        
        - affiliations non structurées et très hétérogènes ; création de "country" dans la cible 'affiliation' : 
        *** pour France uniquement pour l'instant *** (country key="FR" comme dans HAL), reste trop hétérogène au découpage, ou il faut une liste de pays ... ou rien : infos apportées par autres sources
        - email : dans affiliation, idem - inactivé  
        
        Modif 22-10-2018 :
        - tj un titre dans 'analytic' meme pour ouvrages complets car utile XPath vers JSON
        - les titres originaux ne sont pas forcément de la langue de l'article, notamment quand c'est en Anglais
        - correction erreur chemin sur medlineDate et identifiers affiliation.
		
	Modif décembre 2018 : ajouter une URL par calcul quand notice PMC.
	Modif 8 mars 2019 : distinguer dates publi numérique article et journal
	Modif 16/4/2020  :  <ref>URL</ref> changed to  <ref type="file" n="1" target="URL"/> (link towards the fullText)  
	
    Modifications le 12-06-2020
         - paramètre date de création  devient <xsl:param name="today"/>  pour workflow Concerto
         - commentaire sur auteurs dans <titleStmt> mis en commentaire
         - ajout du bloc <respStmt>
        
   Modifications le 30-09-2020
        bloc <funder> : 
            - ajout <idno type="program"> (cf. notices HAL)  
            - ajout <name@type="agency">
            - ajout <name@type="project"> 
         bloc <imprint> for Book :
            - ajout <pubPlace>
         bloc <keywords scheme="author"> :
            - <term type="author"> devient <term xml:lang="en">
         bloc <langUsage> :
            - génération du libellé anglais à partir du code à 3 caractères (copie OG-EThOS)
   
   Modifications le 19 octobre 2020        
                <keywords scheme="meshChemical"> : ajout de l'attribut @xml:lang="en"
 ============================================================================================================== -->

<xsl:output encoding="UTF-8" indent="yes"/> 

    <xsl:param name="DateAcqu"/>
    <xsl:param name="today"/> <!-- Date de création de la notice Conditor = transformation XSLT -->
    
    <!-- élément racine  : 
        - sur les fichiers années 2014-17 : PubmedArticleSet (PubmedArticle (en majorité), PubmedBookArticle (42 ou 43), DeleteCitation (0 dans le corpus)
        - Possible dans la DTD : PubmedBookArticleSet (PubmedBookArticle*)  : pas dans ce corpus -->
  
 <xsl:template match="/">
     <!-- traite au choix : une ou plusieurs notices, elt racine non précisé : -->
    <xsl:choose>
        <xsl:when test="count(*/PubmedArticle) &gt; 1 or count(*/PubmedBookArticle) &gt; 1">
            <teiCorpus>
                <!-- si on veut valider sur schéma, exemple (attention au chemin, contextuel) : 
                <xsl:attribute name="xsi:schemaLocation">http://www.tei-c.org/ns/1.0 HALschema_xsd/document.xsd</xsl:attribute> -->
                <xsl:for-each select="*/PubmedArticle | */PubmedBookArticle | */DeleteCitation">
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
            </teiCorpus>
        </xsl:when>
        <xsl:when test="count(//PubmedArticle)=1">
                <xsl:apply-templates select="//PubmedArticle"/>
        </xsl:when>
           <xsl:when test="count(//PubmedBookArticle)=1">
                <xsl:apply-templates select="//PubmedBookArticle"/>
        </xsl:when>
        <xsl:when test="count(//DeleteCitation)=1">
                <xsl:apply-templates select="//DeleteCitation"/>  <!-- ne contient que le PMID, et pas d'exemple ici. Voir ce qu'on doit faire -->
        </xsl:when>
        <xsl:otherwise>
            <TEI xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:text>*** NOUVELLE ARBORESCENCE SOURCE : ***</xsl:text>
            </TEI>
        </xsl:otherwise>
    </xsl:choose> 
</xsl:template>
    
<xsl:template match="PubmedArticle">
    <!-- dans le fils MedlineCitation, un attribut : Owner (NLM|NASA|PIP|KIE|HSR|HMD) "NLM" . Non traité -->
   
  <TEI xmlns="http://www.tei-c.org/ns/1.0">
    
  <text>
    <body>
        <listBibl>
            <biblFull>
                <!-- titleStmt obligatoire ; minimum : fils title. HAL ajoute les auteurs, et les funder (la meilleure solution pouir ces derniers)  -->
                <titleStmt>
                    <xsl:apply-templates select="MedlineCitation/Article/ArticleTitle"/> <!-- tj 1 et un seul -->
                    
                    <!-- <xsl:apply-templates select="MedlineCitation/Article/AuthorList"/> OU au choix : 
                    <xsl:comment><xsl:text>Les auteurs sont dans la description bibliographique biblStruct : TEI/text/body/listBibl/biblFull/sourceDesc/biblStruct/analytic/author ou monogr/author</xsl:text></xsl:comment>    -->
                    <xsl:apply-templates select="MedlineCitation/Article/GrantList"/>
                </titleStmt>
                
                <editionStmt>
                    <edition>
                        <date type="whenDownloaded"><xsl:value-of select="$DateAcqu"/></date>
                        <date type="whenCreated"><xsl:value-of select="$today"/></date>
                        <!-- <xsl:comment>
                            <xsl:text>Elément suivant particulier à PubMed : les notices sont à différents stades de traitement, voir https://dtd.nlm.nih.gov/ncbi/pubmed/doc/out/180101/att-Status.html</xsl:text>
                        </xsl:comment>  --> 
                     <!-- à décommenter si utile :   <note type="recordStatus"><xsl:value-of select="MedlineCitation/@Status"/></note> -->
                    </edition>        
                <respStmt>
                    <resp>Generated by TEI-Conditor XSLT (https://github.com/conditor/tei-conditor), from original Pubmed document pmid  <xsl:value-of select="//ArticleId[@IdType='pubmed']"/></resp>
                    <name>Conditor</name>
                </respStmt>
                </editionStmt>
                <publicationStmt>
                    <distributor>Conditor</distributor> <!-- ou authority ou publisher -->
                </publicationStmt>

                <!-- ajout d'une note indiquant l'état de publication (plusieurs flux dans PubMed dont éditeurs avec acceptés non publiés, plusieurs PMID 
                Voire le statut dans le workflow : -->
                <notesStmt>
                    <note type="publicationStatus">
                        <xsl:value-of select="normalize-space(PubmedData/PublicationStatus)"/>
                    </note>
                    <note type="recordStatus"><xsl:value-of select="normalize-space(MedlineCitation/@Status)"/></note>
                </notesStmt>
                
                <sourceDesc>
                    <biblStruct>
                        <analytic>
                                                       
                            <xsl:apply-templates select="MedlineCitation/Article/ArticleTitle"/>
                            
                            <xsl:apply-templates select="MedlineCitation/Article/AuthorList"/>
                            <!-- InvestigatorList (209497), "identifies an investigator (or collaborator) who contributed to the publication as a member of a group author.") -->
                            <xsl:apply-templates select="MedlineCitation/InvestigatorList"/>
                            
                            <!-- *** idno analytic ICI si modèle TEI NEW (valide avec HAL_odd.xml, pas valide avec aofr.xsd) 
                            <xsl:call-template name="ArticleIdList"/>  -->
                        </analytic>
                        
                        <monogr>
                            <xsl:apply-templates select="MedlineCitation/Article/Journal"></xsl:apply-templates>
                            <xsl:call-template name="Imprint"/> <!-- elts dispersés -->
                        </monogr>
                        
                        <!-- *** idno ici, modèle TEI0 *** :  -->
                        <xsl:call-template name="ArticleIdList"/> 
                        
                        <!-- lien calculé vers document dans PMC : avec les attributs de HAL pour le Xpath Json -->
                        <xsl:if test="PubmedData//ArticleId[@IdType='pmc']">
                            <ref type="file" n="1">
                                <xsl:attribute name="target">
                                    <xsl:text>https://www.ncbi.nlm.nih.gov/pmc/articles/</xsl:text>
                                    <xsl:value-of select="//ArticleId[@IdType='pmc']"/>
                                </xsl:attribute>
                            </ref>
                        </xsl:if>
                    </biblStruct>
                </sourceDesc>
          
            <profileDesc>
                <langUsage>
                    <xsl:if test="MedlineCitation/Article/Language [string-length() &gt; 0]">
                    <language>
                        <xsl:attribute name="ident"><xsl:value-of select="substring(MedlineCitation/Article/Language, 1, 2)"/></xsl:attribute>
                        <xsl:apply-templates select="MedlineCitation/Article/Language"></xsl:apply-templates>
                    </language>
                    </xsl:if>
                </langUsage>
                               
                <!-- mots-clés et type de publication (classcode, toujours au moins 1) :  -->             
                <!-- <xsl:if test="MedlineCitation/SupplMeshList|MedlineCitation/MeshHeadingList|MedlineCitation/PersonalNameSubjectList|MedlineCitation/KeywordList"> -->
                    <!-- fils de MedlineCitation, disséminés -->
                    <textClass>
                        <xsl:apply-templates select="MedlineCitation"/>
                    </textClass>
               <!-- </xsl:if> -->
                
                <!-- résumé(s), 'en', autres : -->
                <xsl:apply-templates select="MedlineCitation/Article/Abstract"/>
                <xsl:apply-templates select="MedlineCitation/OtherAbstract"/>
            </profileDesc>
                
            </biblFull>
        </listBibl>
    </body>
   </text>
  </TEI>
 
</xsl:template>
    
 <!-- *****************************
     Templates plus granulaires appelés par les templates sur PubmedArticle et (ou pas) sur PubmedBookArticle 
      ***************************** --> 
    
    <xsl:template match="ArticleTitle">  <!-- tj présent, vide ou [Not Available]. ou renseigné -->
        <!-- décision 20180725 : pas de title vide -->
            <xsl:if test="string-length(.) &gt; 0"> <!-- titre habituel PubMed ; éliminer vides et Not Available pour title eng -->
                <xsl:if test="not(contains(.,'Not Available'))">
                    <title xml:lang="en"> 
                        <xsl:value-of select="normalize-space(.)"/>
                        <!-- texte plat. Voir si on récupère des éléments fils sémantiques comme sub et sup -->
                    </title>
                </xsl:if>
            </xsl:if>
        
        <xsl:if test="../VernacularTitle">
            <xsl:element name="title"> 
            <!-- pas d'attribut lang à VernacularTitle, utiliser celui de Language et le mettre sur 2 lettres -->
                <!-- il n'y a pas d'attribut lang à VernacularTitle, utiliser celui de Language (sauf quand eng, faux***NEW octobre) - et le mettre sur 2 lettres -->
                <xsl:if test="../Language!='eng'">
                    <xsl:attribute name="xml:lang"><xsl:value-of select="substring(../Language, 1, 2)"/></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="normalize-space(..//VernacularTitle)"/>
            <!-- idem, texte plat --> 
            </xsl:element>
        </xsl:if>
</xsl:template>
    
<xsl:template match="Journal">        <!-- Journal (ISSN?, JournalIssue, Title?, ISOAbbreviation?) -->
    
    <xsl:for-each select="ISSN[@IssnType='Print']">
        <idno type="issn"><xsl:value-of select="."/></idno>
    </xsl:for-each>
    <xsl:for-each select="ISSN[@IssnType='Electronic']">
        <idno type="eissn"><xsl:value-of select="."/></idno>      
    </xsl:for-each>
   
    <xsl:for-each select="../MedlineJournalInfo/ISSNLinking">
        <idno type="lissn"><xsl:value-of select="."/></idno>
    </xsl:for-each>
   
    <xsl:if test="Title">
        <title level="j"><xsl:value-of select="Title"/></title>
    </xsl:if>
    <xsl:choose>
        <xsl:when test="ISOAbbreviation">
            <title level="j" type="abbrevIso"><xsl:value-of select="ISOAbbreviation"/></title>
        </xsl:when>
        <xsl:when test="MedlineJournalInfo/MedlineTA">
            <title level="j" type="abbrevIso"><xsl:value-of select="MedlineJournalInfo/MedlineTA"/></title>
        </xsl:when>
    </xsl:choose>
    
</xsl:template>
    
    
    <xsl:template match="AuthorList">
        <!-- Chemins variés selon type de document ; 2 rôles TEI (author et editor), dans la source : @Type optionnel (mais peu : une vingtaine sur cq année), @CompleteYN="Y|N", tous complets.   
        test sur position par rapport à articleTitle quand pas d'attribut Type -->
        
        <xsl:for-each select="Author"> <!-- <!ELEMENT	Author (((LastName, ForeName?, Initials?, Suffix?) | CollectiveName), Identifier*, AffiliationInfo*), @ValidYN="Y">
                                                2014:98, 2015:117, 2016:9, 2017:0 Valid=N-->
            <xsl:choose>
            
            <xsl:when test="../@Type='authors'">
            <author role="aut">
                <xsl:if test="@ValidYN='N'">
                    <xsl:attribute name="cert">unknown</xsl:attribute> <!-- Voir si on garde cet attribut ... -->
                </xsl:if>
                <xsl:call-template name="Names"/>
            </author>   
            </xsl:when>
            <xsl:when test="../@Type='editors'">  <!-- books, dans monogr -->
                <editor role="edt">
                    <xsl:if test="@ValidYN='N'">
                        <xsl:attribute name="cert">unknown</xsl:attribute> <!-- high, medium, low ... -->
                    </xsl:if>
                    <xsl:call-template name="Names"/>
                </editor>
            </xsl:when>
            <xsl:otherwise>  <!-- pas d'attribut -->
                <xsl:choose>
                    <xsl:when test="../../ArticleTitle">    <!-- article ou book chapter(on est dans BookDocument), niveau analytic -->
                        <author role="aut">
                            <xsl:if test="@ValidYN='N'">
                                <xsl:attribute name="cert">unknown</xsl:attribute>
                            </xsl:if>
                            <xsl:call-template name="Names"/>
                        </author>
                    </xsl:when>
                    <xsl:when test="../../BookTitle and not(../../..//ArticleTitle)">  <!-- nv monogr, Book (fils de BookDocument), sans info nv analytic : livre complet -->
                        <author role="aut">
                            <xsl:if test="@ValidYN='N'">
                                <xsl:attribute name="cert">unknown</xsl:attribute>
                            </xsl:if>
                            <xsl:call-template name="Names"/>
                        </author>
                    </xsl:when>
                    <xsl:when test="../../BookTitle and ../../..//ArticleTitle">  <!-- nv monogr mais avec analytic : chapitre -->
                        <editor role="edt">
                            <xsl:if test="@ValidYN='N'">
                                <xsl:attribute name="cert">unknown</xsl:attribute>
                            </xsl:if>
                            <xsl:call-template name="Names"/>
                        </editor>
                    </xsl:when>
                    <xsl:otherwise>
                        <author>
                        <xsl:call-template name="Names"/></author>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>  
           </xsl:choose>
                
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template match="InvestigatorList"> <!-- pas d'attribut -->
        <!-- Investigator (LastName, ForeName?, Initials?, Suffix?, Identifier*, AffiliationInfo*), @ValidYN (Y | N) "Y" 
        On peut faire pareil avec 'cert' ou non -->
        <xsl:for-each select="Investigator">
            <author role="aut">
                <xsl:call-template name="Names"/>
            </author>
        </xsl:for-each>
        
    </xsl:template>
    
 <xsl:template name="Names">
     <xsl:if test="LastName">   <!-- distinguer Coll et pers -->
         <persName>
             <xsl:if test="ForeName">
                 <!-- <forename type="first"> mais il n'y a qu'un élément dans Pubmed -->
                 <forename><xsl:value-of select="normalize-space(ForeName)"/></forename>
             </xsl:if>
             <!-- Initiales : complété lot 4, test 
             <xsl:if test="Initials">
                 <forename type="initial"><xsl:value-of select="Initials"/></forename>
             </xsl:if> -->
             <surname><xsl:value-of select="normalize-space(LastName)"/></surname>
         </persName>
     </xsl:if>   
     <xsl:if test="CollectiveName">
         <orgName><xsl:value-of select="normalize-space(CollectiveName)"/></orgName>  <!-- pas possible d'isoler le pays, rarement indiqué -->
     </xsl:if>
     
     <xsl:for-each select="Identifier">
         <xsl:element name="idno">
             <xsl:attribute name="type">
                 <xsl:if test="@Source='ORCID'">orcid</xsl:if>
                 <xsl:if test="@Source='ISNI'">isni</xsl:if>
                 <xsl:if test="@Source='GRID'">grid</xsl:if>  <!-- ces 2 derniers : organismes, mais ne côute rien -->
                 <xsl:if test="@Source='RINGGOLD'">ringgold</xsl:if>
             </xsl:attribute>
             <xsl:choose>
                 <xsl:when test="contains(., 'http://orcid.org')">
                     <xsl:value-of select="substring-after(substring-after(., '.'), '/')"/>         <!-- normalement pas l'URL; les 2 cas -->
                 </xsl:when>
                 <xsl:otherwise> <xsl:value-of select="."/></xsl:otherwise>
             </xsl:choose>
         </xsl:element>
     </xsl:for-each>
     
     <xsl:for-each select="AffiliationInfo">
         <!-- très hétérogène, tests de découpage pour récupérer mail et country non satisfaisants. On se limite à récupérer <country>France<country> -->
         <!-- mail éventuel -->
         
         <affiliation>
             <xsl:value-of select="normalize-space(Affiliation)"/>
             <xsl:choose>
                 <xsl:when test="contains(Affiliation, ', France,') or contains(., ', France.') or contains(., ', France ,') or contains(., 'France;')"><country key="FR"/></xsl:when>
                 <xsl:when test="contains(Affiliation, ', Guadeloupe,') or contains(., ', Guadeloupe.') or contains(., ', Guadeloupe ,') or contains(., 'Guadeloupe;')"><country key="FR"/></xsl:when>
                 <xsl:when test="contains(Affiliation, ', Martinique,') or contains(., ', Martinique.') or contains(., ', Martinique ,') or contains(., 'Marinique;')"><country key="FR"/></xsl:when>
                 <xsl:when test="contains(Affiliation, ', Guyane,') or contains(., ', Guyane.') or contains(., ', Guyane ,') or contains(., 'Guyane;')"><country key="FR"/></xsl:when>
                 <xsl:when test="contains(Affiliation, ', La Réunion,') or contains(., ', La Réunion.') or contains(., ', La Réunion ,') or contains(., 'La Réunion;')"><country key="FR"/></xsl:when>
                 <xsl:when test="contains(Affiliation, ', Mayotte,') or contains(., ', Mayotte.') or contains(., ', Mayotte ,') or contains(., 'Mayotte;')"><country key="FR"/></xsl:when>
                 <xsl:when test="contains(Affiliation, ', Nouvelle Calédonie,') or contains(., ', Nouvelle Calédonie.') or contains(., ', Nouvelle Calédonie ,') or contains(., 'Nouvelle Calédonie;')"><country key="FR"/></xsl:when>
                 <xsl:when test="contains(Affiliation, ', Polynésie française,') or contains(., ', Polynésie française.') or contains(., ', Polynésie française ,') or contains(., 'Polynésie française;')"><country key="FR"/></xsl:when>
                 <xsl:when test="contains(Affiliation, ', Saint Barthélémy,') or contains(., ', Saint Barthélémy.') or contains(., ', Saint Barthélémy ,') or contains(., 'Saint Barthélémy;')"><country key="FR"/></xsl:when>
                 <xsl:when test="contains(Affiliation, ', Saint Martin,') or contains(., ', Saint Martin.') or contains(., ', Saint Martin ,') or contains(., 'Saint Martin;')"><country key="FR"/></xsl:when>
                 <xsl:when test="contains(Affiliation, ', St Pierre et Miquelon,') or contains(., ', St Pierre et Miquelon.') or contains(., ', St Pierre et Miquelon ,') or contains(., 'St Pierre et Miquelon;')"><country key="FR"/></xsl:when>
                 <xsl:when test="contains(Affiliation, ', St Barthélémy,') or contains(., ', St Barthélémy.') or contains(., ', St Barthélémy ,') or contains(., 'St Barthélémy;')"><country key="FR"/></xsl:when>
                 <xsl:when test="contains(Affiliation, ', St Martin,') or contains(., ', St Martin.') or contains(., ', St Martin ,') or contains(., 'St Martin;')"><country key="FR"/></xsl:when>
                 <xsl:when test="contains(Affiliation, ', Saint Pierre et Miquelon,') or contains(., ', Saint Pierre et Miquelon.') or contains(., ', Saint Pierre et Miquelon ,') or contains(., 'Saint Pierre et Miquelon;')"><country key="FR"/></xsl:when>
                 <xsl:when test="contains(Affiliation, ', Wallis-et-Futuna,') or contains(., ', Wallis-et-Futuna.') or contains(., ', Wallis-et-Futuna ,') or contains(., 'Wallis-et-Futuna;')"><country key="FR"/></xsl:when>
                 <!-- source : http://www.france-dom-tom.fr/. 
                     à suivre autres pays ??? Un call-template de découpage du texte source est prêt mais ne donne pas satisfaction -->
             </xsl:choose>
         
         <xsl:for-each select="Identifier">
             <xsl:element name="idno">
                 <xsl:attribute name="type"> <!-- idem id auteurs -->
                     <xsl:if test="@Source='ORCID'">orcid</xsl:if>
                     <xsl:if test="@Source='ISNI'">isni</xsl:if>
                     <xsl:if test="@Source='GRID'">grid</xsl:if>
                     <xsl:if test="@Source='RINGGOLD'">ringgold</xsl:if>
                 </xsl:attribute>
                 <xsl:value-of select="normalize-space(.)"/>
             </xsl:element>
         </xsl:for-each>
             
         </affiliation>
     </xsl:for-each>
         
 </xsl:template>
    
    
<xsl:template name="Imprint">  <!-- ne sert que pour les articles ; un autre pour les Books, trop long sinon -->
        
        <imprint>
            <xsl:choose>
                <xsl:when test="Publisher"> <!-- dans les articles, n'existe pas jusque là ; pays seul -->
                    <publisher>
                        <xsl:value-of select="Publisher/PublisherName"/>
                    </publisher>
                </xsl:when>
                <xsl:when test="Publisher/PublisherLocation"> <!-- dans les articles, n'existe pas jusque là ; pays seul -->
                    <pubPlace>
                            <xsl:value-of select="PublisherLocation"/>
                    </pubPlace>
                </xsl:when>
            <!-- le groupe du 10-09-2018 ne veut pas récupérer le pays, sauf s'il est dans une chaîne difficile à découper. Si change d'avis :
                <xsl:when test="MedlineCitation/MedlineJournalInfo/Country">   $$$ articles, pas de Publisher $$
                    <pubPlace><xsl:value-of select="MedlineCitation/MedlineJournalInfo/Country"/></pubPlace>
                </xsl:when> -->
            </xsl:choose>
            
            <xsl:if test="MedlineCitation/Article/ArticleDate"> 
            <!-- ArticleDate? (Year, Month, Day) pour uniquement des publis électroniques (DateType="Electronic slt"). Ils ont tous en plus une PubDate dans Journal-->
                <date type="dateEpub">
                    <xsl:value-of select="MedlineCitation/Article/ArticleDate/Year"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="MedlineCitation/Article/ArticleDate/Month"/>
                    <xsl:text>-</xsl:text>
                    <xsl:value-of select="MedlineCitation/Article/ArticleDate/Day"/>
                </date>
            </xsl:if>
            
            <date type="datePub"> <!-- Articles. Forme ISO à passer en attribut, et originale à garder ??? --> 
                <xsl:choose>
                    
                    <xsl:when test="MedlineCitation/Article/Journal/JournalIssue/PubDate/Year">   <!-- PubDate oblig ((Year, ((Month, Day?) | Season)?) | MedlineDate) -->
                        <xsl:value-of select="MedlineCitation/Article/Journal/JournalIssue/PubDate/Year"/>
                        <xsl:text>-</xsl:text>
                        <!-- <xsl:value-of select="MedlineCitation/Article/Journal/JournalIssue/PubDate/Month"/> -->
                        <xsl:if test="MedlineCitation/Article/Journal/JournalIssue/PubDate/Month[text()]">
                            <xsl:variable  name="mois" select="MedlineCitation/Article/Journal/JournalIssue/PubDate/Month"/>
                            <!-- 01 et 1 à 12 et Apr, Aug, Dec, Feb, Jan, Jul, Jun, Mar May Nov Oct Sep -->
                            <xsl:choose>
                             <xsl:when test="contains($mois, '0')"><xsl:value-of select="$mois"/></xsl:when>
                             <xsl:when test="$mois='1' or $mois='Jan'">01</xsl:when>
                                <xsl:when test="$mois='2' or $mois='Feb'">02</xsl:when>
                                <xsl:when test="$mois='3' or $mois='Mar'">03</xsl:when>
                                <xsl:when test="$mois='4' or $mois='Apr'">04</xsl:when>
                                <xsl:when test="$mois='5' or $mois='May'">05</xsl:when>
                                <xsl:when test="$mois='6' or $mois='Jun'">06</xsl:when>
                                <xsl:when test="$mois='7' or $mois='Jul'">07</xsl:when>
                                <xsl:when test="$mois='8' or $mois='Aug'">08</xsl:when>
                                <xsl:when test="$mois='9' or $mois='Sep'">09</xsl:when>
                                <xsl:when test="$mois='Oct'">10</xsl:when>
                                <xsl:when test="$mois='Nov'">11</xsl:when>
                                <xsl:when test="$mois='Dec'">12</xsl:when>
                                <xsl:otherwise><xsl:value-of select="$mois"/></xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="MedlineCitation/Article/Journal/JournalIssue/PubDate/Day">
                                <xsl:text>-</xsl:text>
                                <xsl:value-of select="MedlineCitation/Article/Journal/JournalIssue/PubDate/Day"/>
                            </xsl:if>
                        </xsl:if>
                        
                        <!-- OK mais pas ISO, à suivre :
                            <xsl:if test="MedlineCitation/Article/Journal/JournalIssue/PubDate/Season">
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="MedlineCitation/Article/Journal/JournalIssue/PubDate/Season"/>
                        </xsl:if> -->
                    </xsl:when> <!-- sur Year -->
                    
                    <xsl:when test="MedlineCitation/Article/Journal/JournalIssue/PubDate/MedlineDate"> 
                        <!--  articles : date qui ne convient pas aux patterns précédents, ex de la doc :
                            <MedlineDate>2015 Nov-Dec</MedlineDate>, <MedlineDate>1998 Dec-1999 Jan</MedlineDate>
                            Décision lot 4 : uniquement l'année -->
                        <xsl:choose>
                            <xsl:when test="contains(MedlineCitation/Article/Journal/JournalIssue/PubDate/MedlineDate, ' ')">
                                <xsl:value-of select="substring-before(MedlineCitation/Article/Journal/JournalIssue/PubDate/MedlineDate, ' ')"/>
                            </xsl:when>
                            <xsl:otherwise><xsl:value-of select="MedlineCitation/Article/Journal/JournalIssue/PubDate/MedlineDate"/></xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    
                </xsl:choose>
                </date> 
            
            <xsl:if test="contains(MedlineCitation/Article/Journal/JournalIssue/PubDate/MedlineDate, ' ')">
                <date type="orig"><xsl:value-of select="MedlineCitation/Article/Journal/JournalIssue/PubDate/MedlineDate"/></date>
            </xsl:if>
            <xsl:if test="contains(MedlineCitation/Article/Journal/JournalIssue/PubDate/Season, ' ')">
                <date type="orig">
                    <xsl:value-of select="MedlineCitation/Article/Journal/JournalIssue/PubDate/Year"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="MedlineCitation/Article/Journal/JournalIssue/PubDate/Season"/></date>
            </xsl:if>
            
  <!--         <date type="yearPub">  
                    <xsl:choose>
                        <xsl:when test="MedlineCitation/Article/ArticleDate"> 
                            <xsl:value-of select="MedlineCitation/Article/ArticleDate/Year"/>
                        </xsl:when>
                        <xsl:when test="MedlineCitation/Article/Journal/JournalIssue/PubDate/Year">   
                            <xsl:value-of select="MedlineCitation/Article/Journal/JournalIssue/PubDate/Year"/>
                        </xsl:when>
                        <xsl:when test="MedlineCitation/Article/Journal/JournalIssue/PubDate/MedlineDate">   
                            <xsl:value-of select="substring-before(MedlineCitation/Article/Journal/JournalIssue/PubDate/MedlineDate, ' ')"/>
                        </xsl:when>
                    </xsl:choose>
                </date>  -->
            
            <xsl:if test="string-length(MedlineCitation/Article/Journal/JournalIssue/Volume) &gt; 0"> 
                <!-- OK mais contient des Suppl, Suppl 2, Pt [A-Z1-9],  Spec Iss (avec ou sans rien), Spec No 1,  Hors série n°2,  ... :  -->
                <xsl:variable name="Vol" select="MedlineCitation/Article/Journal/JournalIssue/Volume"/>
                
                <!-- Volume et num spéciaux intégrés dans volume : -->
                <xsl:choose>
                    <xsl:when test="contains($Vol, 'Suppl')"> <!-- homogène : Vol Suppl chiffres, qquns : 46 Suppl 1 UCTN -->
                        <biblScope unit="volume"><xsl:value-of select="normalize-space(substring-before($Vol, 'Suppl'))"/></biblScope>
                        <!-- <biblScope unit="supplement"><xsl:value-of select="normalize-space(substring-after($Vol, 'Suppl'))"/></biblScope> -->
                        <biblScope unit="supplement"><xsl:value-of select="normalize-space(substring-after($Vol, ' '))"/></biblScope>
                    </xsl:when> 
                    <xsl:when test="contains($Vol, 'Pt')"> <!-- idem : Vol Pt 1ch ou lettre -->
                    <biblScope unit="volume"><xsl:value-of select="normalize-space(substring-before($Vol, 'Pt'))"/></biblScope>
                    <!--    <biblScope unit="part"><xsl:value-of select="normalize-space(substring-after($Vol, 'Pt '))"/></biblScope> -->
                        <biblScope unit="part"><xsl:value-of select="normalize-space(substring-after($Vol, ' '))"/></biblScope>
                    </xsl:when>
                    <xsl:when test="contains($Vol, 'Spec')"> <!-- Spec Iss -->
                      <biblScope unit="volume"><xsl:value-of select="normalize-space(substring-before($Vol, 'Spec'))"/></biblScope>
                        <biblScope unit="specialIssue"><xsl:value-of select="normalize-space(substring-after ($Vol, ' '))"/></biblScope>
                    </xsl:when>
                    <xsl:when test="contains($Vol, 'No')">
                        <biblScope unit="volume"><xsl:value-of select="normalize-space(substring-before($Vol, ' '))"/></biblScope>
                        <!-- découpe : <biblScope unit="specialIssue"><xsl:value-of select="normalize-space(substring-after ($Vol, 'No'))"/></biblScope>
                         je découpe ici, mais ne peux le faire sur l'élément issue : trop de cas. A voir si on garde le texte partout OU ou si le nettoie quand on peut :  
                        OU, si on garde le texte : -->
                        <biblScope unit="specialIssue"><xsl:value-of select="normalize-space(substring-after($Vol, ''))"/></biblScope>
                    </xsl:when>
                    <xsl:when test="contains($Vol, '°')"> <!-- 32 Hors série n°2 -->
                        <biblScope unit="volume"><xsl:value-of select="normalize-space(substring-before($Vol, ' '))"/></biblScope>
                        <!-- découpe num : <biblScope unit="specialIssue"><xsl:value-of select="normalize-space(substring-after($Vol, '°'))"/></biblScope> -->
                        <biblScope unit="specialIssue"><xsl:value-of select="normalize-space(substring-after($Vol, ' '))"/></biblScope>
                    </xsl:when>
                    <xsl:when test="contains($Vol, ' ')"> <!-- Spec Iss -->
                        <biblScope unit="volume"><xsl:value-of select="normalize-space(substring-before($Vol, ' '))"/></biblScope>
                        <biblScope unit="specialIssue"><xsl:value-of select="normalize-space(substring-after ($Vol, ' '))"/></biblScope>
                    </xsl:when>
                    <xsl:otherwise>
                        <biblScope unit="volume"><xsl:value-of select="normalize-space($Vol)"/></biblScope>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            
            <xsl:if test="string-length(MedlineCitation/Article/Journal/JournalIssue/Issue) &gt; 0">
                <xsl:variable name="Issue" select="MedlineCitation/Article/Journal/JournalIssue/Issue"/>
                <!-- hétérogène : 
                Sup +/- long, avec ou sans num devant et formes variées :7(Suppl 6), 8 Suppl, 9 Suppl, 9 Suppl 2, Sup2, Supp_1, Suppl, Suppl 1, Suppl-1, Suppl. 1, sup3 ...  Pt 2 Suppl 1, Suppl 1 M7
Suppl 1 Proceedings of the International Conference on Human, Supplement_5, Technical Suppl
                Pt avec numéro devant ou sans : 9 Pt B (ou 1 ...); Pt 1, Pt 10, Pt 2 Sup 1
                Spe : 2 slt : 2 and 3-Spec Issue, Spec Iss ; pas de H, N, n (sauf 2 supl avec titres)
                 
                1 seul avec Suppl dans le num et le Vol : Suppl 1 23Suppl 1       PMID 28198925
                Choix actuel : numéro simple dans issue, et, quand indications spécifiques : num et indications dans suppl, part ... 
                -->
                <xsl:choose>
                    <xsl:when test="contains($Issue, 'Sup')">
                        <biblScope unit="supplement"><xsl:value-of select="normalize-space($Issue)"/></biblScope>
                    </xsl:when>
                    <xsl:when test="contains($Issue, 'sup')">
                        <biblScope unit="supplement"><xsl:value-of select="normalize-space($Issue)"/></biblScope>
                    </xsl:when>
                    <xsl:when test="contains($Issue, 'Pt')">
                        <biblScope unit="part"><xsl:value-of select="normalize-space($Issue)"/></biblScope>
                    </xsl:when>
                    <xsl:when test="contains($Issue, 'Spe')">
                        <biblScope unit="specialIssue"><xsl:value-of select="normalize-space($Issue)"/></biblScope>
                    </xsl:when>
                    <xsl:otherwise><biblScope unit="issue"><xsl:value-of select="normalize-space($Issue)"/></biblScope></xsl:otherwise>
                </xsl:choose>
                <!-- valeurs  : (IsgmlInfos, à voir : (ordre : Issue    Vol     ex de PMID)
                    Database issue          43      25428371
                    Web Server issue        42      24878919 
                    F1000 Faculty Rev       4       26594351
                -->
            </xsl:if>
            
            <xsl:if test="MedlineCitation/Article/Pagination">
               <biblScope unit="pp">  
            <!-- dans Article/Pagination avec fils EndPage/StartPage (rare, en devenir) ou MedlinePgn -->
                <xsl:choose>
                    <xsl:when test="MedlineCitation/Article/Pagination/MedlinePgn">          <!-- forme : 4 si seule ; 3841-50 sinon -->
                        <xsl:value-of select="MedlineCitation/Article/Pagination/MedlinePgn"/>
                    </xsl:when>
                    <xsl:when test="StartPage">  <!-- les 2 pages complètes -->
                        <xsl:value-of select="MedlineCitation/Article/Pagination/StartPage"/>
                        <xsl:if test="MedlineCitation/Article/Pagination/EndPage">
                            <xsl:text>-</xsl:text>
                            <xsl:value-of select="MedlineCitation/Article/Pagination/EndPage"/>
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>
            </biblScope>
          </xsl:if> <!-- pag -->
              
        </imprint>
        
    </xsl:template>

<xsl:template match="GrantList">
    <xsl:for-each select="Grant">  <!-- Grant (GrantID?, Acronym?, Agency, Country) -->
        <funder>
            <xsl:if test="GrantID">
            <idno type="grantNumber">  
                <xsl:value-of select="GrantID"/>
            </idno>
            </xsl:if>
            <xsl:if test="Agency">
            <name type="agency">     
                <xsl:value-of select="normalize-space(Agency)"/>
                <!--  funder peut contenir abbr. ; on supprime car propre US -->
            </name>
            </xsl:if>
                <country><xsl:value-of select="Country"/></country>   <!-- existe comme fils de funder -->
        </funder>
    </xsl:for-each>
</xsl:template>
    
 <xsl:template name="ArticleIdList">
   <!-- source :
      - PubmedData/ArticleId (#PCDATA), @ IdType (doi | pii | pmcpid | pmpid | pmc | mid | sici | pubmed | medline | pmcid | pmcbook | bookaccession) "pubmed" > 
      - MedlineCitation/Article/ELocationID (#PCDATA, @(doi | pii) #REQUIRED ... mais ne rend pas une info de plus que ArticleId (grep et grep -v)
      - MedlineCitation/PMID 
   résultat :
            idno type="doi"> DOI -  article/chapitre/paper   </idno>
                <idno type="doiB">   DOI book : tester utilité   </idno>
                <idno type="pubmed"> identifiant Pubmed </idno>
                <idno type="utKey">  identifiant WoS   </idno>
				<idno type="nnt">  Numéro national de thèse   </idno>
				<idno type="ppnSudoc">  identifiant Sudoc   </idno>
				 <idno type="halId">  Identifiant notice HAL  </idno>
                <idno type="arxiv">   Identifiant arXiv   </idno>
				<idno type="patentNumber">     Numéro de brevet   </idno>
                <idno type="idProdInra">    Identifiant ProdInra </idno>
				<idno type="pii"> -->
  
     <xsl:choose>
         <!-- 1 : article : -->
         <xsl:when test="PubmedData//ArticleId">  <!-- normalement constant, et complet pour pubmed -->
             <xsl:for-each select="PubmedData//ArticleId">
         <xsl:if test="@IdType='doi'"><idno type="doi"><xsl:value-of select="."/></idno></xsl:if>
         <xsl:if test="@IdType='pii'"><idno type="pii"><xsl:value-of select="."/></idno></xsl:if>
             <xsl:if test="@IdType='pubmed'"><idno type="pubmed"><xsl:value-of select="."/></idno></xsl:if>
            <xsl:if test="@IdType='pmc'"><idno type="pmc"><xsl:value-of select="."/></idno></xsl:if>
            <!-- etc ... --> 
     </xsl:for-each>
     </xsl:when>
         
     <!--    2 - book -->
         <xsl:when test="BookDocument">
           <!--  <BookDocument>
                 <PMID Version="1">29787061</PMID>
                 <ArticleIdList>
                     <ArticleId IdType="bookaccession">NBK500156</ArticleId>    ????? non traité 
                     <ArticleId IdType="doi">10.1007/978-3-319-16104-4_8</ArticleId>
         </xsl:when>  -->
             <idno type="pubmed"><xsl:value-of select="BookDocument/PMID"/></idno> 
             <!-- il n'est jamais dans le suivant, il est aussi dans ../PubmedBookData//ArticleId (seul)
             Uniquement doi dans le corpus, mais qui sait ? -->
             <xsl:for-each select="BookDocument//ArticleId">
                 <xsl:if test="@IdType='doi'"><idno type="doi"><xsl:value-of select="."/></idno></xsl:if>
                 <xsl:if test="@IdType='pii'"><idno type="pii"><xsl:value-of select="."/></idno></xsl:if>
                 <!--  -->
                 <xsl:if test="@IdType='pmc'"><idno type="pmc"><xsl:value-of select="."/></idno></xsl:if>
                 <!-- etc ... --> 
             </xsl:for-each>
         </xsl:when>
         
     <xsl:otherwise> <!-- à tout hasard pour article si plus ancien -->
         <idno type="pubmed"><xsl:value-of select="/PMID"/></idno>
     </xsl:otherwise>
     </xsl:choose>
</xsl:template>
    
   <!--    keywords  -  Mesh  -->
  <xsl:template match="MedlineCitation">
        <xsl:if test="MeshHeadingList">
 <!-- on choisit de les structurer au maximum. Autre solution en réserve ailleurs -->
    <xsl:for-each select="MeshHeadingList/MeshHeading">
    <keywords scheme="meshHeading">
            <term>
                <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="DescriptorName[@MajorTopicYN='Y']"><xsl:text>majorDescriptor</xsl:text>
                            <xsl:if test="DescriptorName[@Type='Geographic']">;geographicalName</xsl:if>
                        </xsl:when>
                        <xsl:otherwise><xsl:text>minorDescriptor</xsl:text>
                            <xsl:if test="DescriptorName[@Type='Geographic']">;geographicalName</xsl:if>
                        </xsl:otherwise> 
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="xml:lang">en</xsl:attribute>
                <xsl:attribute name="xml:base"><xsl:text>https://www.ncbi.nlm.nih.gov/mesh/</xsl:text><xsl:value-of select="DescriptorName/@UI"/></xsl:attribute>
                <xsl:value-of select="normalize-space(DescriptorName)"/>
            </term>
            <xsl:for-each select="QualifierName">
                <term>
                    <xsl:attribute name="type">
                    <xsl:choose>
                        <xsl:when test="@MajorTopicYN='Y'"><xsl:text>majorQualifier</xsl:text>
                        </xsl:when>
                        <xsl:otherwise><xsl:text>minorQualifier</xsl:text>
                        </xsl:otherwise> 
                    </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="xml:lang">en</xsl:attribute>
                    <xsl:attribute name="xml:base"><xsl:text>https://www.ncbi.nlm.nih.gov/mesh/</xsl:text><xsl:value-of select="@UI"/></xsl:attribute>
                    <xsl:value-of select="normalize-space(.)"/>
                </term>
            </xsl:for-each>
    </keywords>
    </xsl:for-each>
        </xsl:if>  <!-- MeshheadingList -->
    
    
    <xsl:if test="SupplMeshList">
        <!-- SupplMeshList? (SupplMeshName+)
        @Type (Disease | Protocol | Organism) #REQUIRED
        UI #REQUIRED -->
        <keywords scheme="meshSuppl">
            <xsl:for-each select="SupplMeshList/SupplMeshName">
            <term>
                <xsl:attribute name="xml:lang">en</xsl:attribute>
                <xsl:attribute name="type"><xsl:value-of select="@Type"/></xsl:attribute>
                <xsl:attribute name="xml:base"><xsl:text>https://www.ncbi.nlm.nih.gov/mesh/</xsl:text><xsl:value-of select="@UI"/></xsl:attribute>
                <xsl:value-of select="normalize-space(.)"/>
            </term>
        </xsl:for-each>
        </keywords>
    </xsl:if>
 
    <xsl:if test="ChemicalList">
   <!-- on choisit de garder la structure source. Autre solution en réserve ailleurs -->
        
            <xsl:for-each select="ChemicalList/Chemical"> <!-- Chemical (RegistryNumber, NameOfSubstance) -->
                <keywords scheme="meshChemical">
                    <term type="substanceName">
                     <xsl:attribute name="xml:lang">en</xsl:attribute>
                    <xsl:attribute name="xml:base"><xsl:text>https://www.ncbi.nlm.nih.gov/mesh/</xsl:text><xsl:value-of select="NameOfSubstance/@UI"/></xsl:attribute>
                    <xsl:value-of select="normalize-space(NameOfSubstance)"/>
                </term>
                <term type="registryNumber">
                    <xsl:value-of select="RegistryNumber"/>
                </term>
                </keywords>
            </xsl:for-each>
        
    </xsl:if> 
    
        <!-- GeneSymbolList? 1991-1995 -->
    
      <xsl:if test="KeywordList"> <!--Owner (NLM | NLM-AUTO | NASA | PIP | KIE | NOTNLM | HHS), uniquement valeur "NOTNLM" dans le corpus. -->   
        <keywords scheme="author">
            <xsl:for-each select="KeywordList[@Owner='NOTNLM']/Keyword">
             <term xml:lang="en">
                <xsl:value-of select="normalize-space(.)"/>
            </term>
        </xsl:for-each>
        <!-- extension au cas où : -->
            <xsl:for-each select="KeywordList[@Owner!='NOTNLM']/Keyword">
                <term xml:lang="en">
                    <xsl:attribute name="type"><xsl:value-of select="./@Owner"/></xsl:attribute>
                    <xsl:value-of select="normalize-space(.)"/>
                </term>
            </xsl:for-each>
        </keywords>
    </xsl:if>
    
    <xsl:if test="PersonalNameSubjectList">
        <keywords>
        <xsl:for-each select="PersonalNameSubjectList/PersonalNameSubject"> <!-- ( LastName, ForeName?, Initials?, Suffix? ) -->
            <term type="personalName">
                <xsl:value-of select="normalize-space(LastName)"/>
                <xsl:if test="ForeName">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="normalize-space(ForeName)"/>
                </xsl:if>
            </term>
        </xsl:for-each>
        </keywords>
    </xsl:if>
        
    <!-- classCode, pour type de doc (sinon, pas de code de classement). Ailleurs pour les books -->
    <xsl:for-each select="Article/PublicationTypeList/PublicationType">
        <classCode scheme="typology"><xsl:value-of select="."/></classCode>
    </xsl:for-each>
  
</xsl:template>
    
<xsl:template match="Abstract"> 
    <!-- fils source : AbstracText+, @Label CDATA #IMPLIED
		                              @NlmCategory (BACKGROUND | OBJECTIVE | METHODS | RESULTS | CONCLUSIONS | UNASSIGNED) #IMPLIED2 
    Quand @label ou @NlmCategory est renseigné, la valeur n'est plus dans le texte. On la récupère ici
    Et on en crée pas plusieurs 'p' typés, mais un seul p pour tout le résumé (2018-09-10) 
    
    (%text; | mml:math | DispFormula)* ; un seul résumé contient mml ; texte à plat pour l'instant.
    -->
    <abstract xml:lang="en"> 
        
        <!-- sans 'p' : -->
        <xsl:for-each select="AbstractText"> 
                <xsl:if test="@Label">
                    <xsl:value-of select="@Label"/>
                    <xsl:text> : </xsl:text>
                </xsl:if>
                <xsl:value-of select="normalize-space(.)"/>  
            <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
        </xsl:for-each> 
        <xsl:if test="CopyrightInformation">
            <!-- inutile en général : contient "Copyright" "©" <xsl:text> Copyright : </xsl:text> -->
            <xsl:text> </xsl:text>
            <xsl:value-of select="normalize-space(CopyrightInformation)"/>
        </xsl:if>
    </abstract>
    
</xsl:template>
    
    <xsl:template match="OtherAbstract">
    <!-- <OtherAbstract @Type="Publisher" @Language="fre", spa ...> -->
    <abstract>
        <xsl:attribute name="xml:lang"><xsl:value-of select="substring(@Language, 1, 2)"/></xsl:attribute>
        <!-- <p> -->
        <xsl:for-each select="AbstractText"> 
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
            <xsl:if test="CopyrightInformation">
                <!-- <xsl:text> Copyright : </xsl:text> -->
                <xsl:text> </xsl:text>
                <xsl:value-of select="normalize-space(CopyrightInformation)"/>
            </xsl:if>
        </xsl:for-each>
        <!-- </p> -->
    </abstract>
    </xsl:template>
    
  <xsl:template match="Language">
      
      <xsl:choose>
          <xsl:when test="normalize-space(.)='aar' ">Afar</xsl:when>
          <xsl:when test="normalize-space(.)='abk' ">Abkhazian</xsl:when>
          <xsl:when test="normalize-space(.)='afr' ">Afrikaans</xsl:when>
          <xsl:when test="normalize-space(.)='aka' ">Akan</xsl:when>
          <xsl:when test="normalize-space(.)='alb' ">Albanian</xsl:when>
          <xsl:when test="normalize-space(.)='amh' ">Amharic</xsl:when>
          <xsl:when test="normalize-space(.)='ara' ">Arabic</xsl:when>
          <xsl:when test="normalize-space(.)='arm' ">Armenian</xsl:when>
          <xsl:when test="normalize-space(.)='asm' ">Assamese</xsl:when>
          <xsl:when test="normalize-space(.)='ava' ">Avaric</xsl:when>
          <xsl:when test="normalize-space(.)='ave' ">Avestan</xsl:when>
          <xsl:when test="normalize-space(.)='aym' ">Aymara</xsl:when>
          <xsl:when test="normalize-space(.)='aze' ">Azerbajani</xsl:when>
          <xsl:when test="normalize-space(.)='bak' ">Bashkir</xsl:when>
          <xsl:when test="normalize-space(.)='bam' ">Bambara</xsl:when>
          <xsl:when test="normalize-space(.)='baq' ">Basque</xsl:when>
          <xsl:when test="normalize-space(.)='bel' ">Byelorussian</xsl:when>
          <xsl:when test="normalize-space(.)='ben' ">Bengali</xsl:when>
          <xsl:when test="normalize-space(.)='bre' ">Breton</xsl:when>
          <xsl:when test="normalize-space(.)='bul' ">Bulgarian</xsl:when>
          <xsl:when test="normalize-space(.)='bur' ">Burmese</xsl:when>
          <xsl:when test="normalize-space(.)='cat' ">Catalan</xsl:when>
          <xsl:when test="normalize-space(.)='che' ">Chechen</xsl:when>
          <xsl:when test="normalize-space(.)='chi' ">Chinese</xsl:when>
          <xsl:when test="normalize-space(.)='chu' ">Church slavic</xsl:when>
          <xsl:when test="normalize-space(.)='chv' ">Chuvash</xsl:when>
          <xsl:when test="normalize-space(.)='cor' ">Cornish</xsl:when>
          <xsl:when test="normalize-space(.)='cos' ">Corsican</xsl:when>
          <xsl:when test="normalize-space(.)='cre' ">Cree</xsl:when>
          <xsl:when test="normalize-space(.)='cze' ">Czech</xsl:when>
          <xsl:when test="normalize-space(.)='dan' ">Danish</xsl:when>
          <xsl:when test="normalize-space(.)='dut' ">Dutch</xsl:when>
          <xsl:when test="normalize-space(.)='eng' ">English</xsl:when>
          <xsl:when test="normalize-space(.)='epo' ">Esperanto</xsl:when>
          <xsl:when test="normalize-space(.)='est' ">Estonian</xsl:when>
          <xsl:when test="normalize-space(.)='ewe' ">Ewe</xsl:when>
          <xsl:when test="normalize-space(.)='fao' ">Faroese</xsl:when>
          <xsl:when test="normalize-space(.)='fin' ">Finnish</xsl:when>
          <xsl:when test="normalize-space(.)='fre' ">French</xsl:when>
          <xsl:when test="normalize-space(.)='ful' ">Fulah</xsl:when>
          <xsl:when test="normalize-space(.)='geo' ">Georgian</xsl:when>
          <xsl:when test="normalize-space(.)='ger' ">German</xsl:when>
          <xsl:when test="normalize-space(.)='glg' ">Galician</xsl:when>
          <xsl:when test="normalize-space(.)='gre' ">Greek, modern</xsl:when>
          <xsl:when test="normalize-space(.)='guj' ">Gujarati</xsl:when>
          <xsl:when test="normalize-space(.)='hau' ">Hausa</xsl:when>
          <xsl:when test="normalize-space(.)='heb' ">Hebrew</xsl:when>
          <xsl:when test="normalize-space(.)='her' ">Herero</xsl:when>
          <xsl:when test="normalize-space(.)='hin' ">Hindi</xsl:when>
          <xsl:when test="normalize-space(.)='hrv' ">Croatian</xsl:when>
          <xsl:when test="normalize-space(.)='hun' ">Hungarian</xsl:when>
          <xsl:when test="normalize-space(.)='ice' ">Icelandic</xsl:when>
          <xsl:when test="normalize-space(.)='ind' ">Indonesian</xsl:when>
          <xsl:when test="normalize-space(.)='ita' ">Italian</xsl:when>
          <xsl:when test="normalize-space(.)='jav' ">Javanese</xsl:when>
          <xsl:when test="normalize-space(.)='jpn' ">Japanese</xsl:when>
          <xsl:when test="normalize-space(.)='kan' ">Kannada</xsl:when>
          <xsl:when test="normalize-space(.)='kas' ">Kashmiri</xsl:when>
          <xsl:when test="normalize-space(.)='kau' ">Kanuri</xsl:when>
          <xsl:when test="normalize-space(.)='kaz' ">Kazakh</xsl:when>
          <xsl:when test="normalize-space(.)='kik' ">Kikuyu</xsl:when>
          <xsl:when test="normalize-space(.)='kin' ">Kinyarwanda</xsl:when>
          <xsl:when test="normalize-space(.)='kir' ">Kirghiz</xsl:when>
          <xsl:when test="normalize-space(.)='kon' ">Kongo</xsl:when>
          <xsl:when test="normalize-space(.)='kor' ">Korean</xsl:when>
          <xsl:when test="normalize-space(.)='kur' ">Kurdish</xsl:when>
          <xsl:when test="normalize-space(.)='lao' ">Lao</xsl:when>
          <xsl:when test="normalize-space(.)='lat' ">Latin</xsl:when>
          <xsl:when test="normalize-space(.)='lav' ">Latvian</xsl:when>
          <xsl:when test="normalize-space(.)='lit' ">Lithuanian</xsl:when>
          <xsl:when test="normalize-space(.)='lub' ">Luba-Katanga</xsl:when>
          <xsl:when test="normalize-space(.)='lug' ">Ganda</xsl:when>
          <xsl:when test="normalize-space(.)='mac' ">Macedonian</xsl:when>
          <xsl:when test="normalize-space(.)='mal' ">Malayalam</xsl:when>
          <xsl:when test="normalize-space(.)='mao' ">Maori</xsl:when>
          <xsl:when test="normalize-space(.)='mar' ">Marathi</xsl:when>
          <xsl:when test="normalize-space(.)='may' ">Malay</xsl:when>
          <xsl:when test="normalize-space(.)='mlg' ">Malagasy</xsl:when>
          <xsl:when test="normalize-space(.)='mlt' ">Maltese</xsl:when>
          <xsl:when test="normalize-space(.)='mon' ">Mongolian</xsl:when>
          <xsl:when test="normalize-space(.)='nav' ">Navajo</xsl:when>
          <xsl:when test="normalize-space(.)='nep' ">Nepali</xsl:when>
          <xsl:when test="normalize-space(.)='nor' ">Norwegian</xsl:when>
          <xsl:when test="normalize-space(.)='nya' ">Nyanja</xsl:when>
          <xsl:when test="normalize-space(.)='oci' ">Language d'Oc</xsl:when>
          <xsl:when test="normalize-space(.)='oji' ">Ojibwa</xsl:when>
          <xsl:when test="normalize-space(.)='ori' ">Oriya</xsl:when>
          <xsl:when test="normalize-space(.)='oss' ">Ossetic</xsl:when>
          <xsl:when test="normalize-space(.)='pan' ">Panjabi</xsl:when>
          <xsl:when test="normalize-space(.)='per' ">Persan, modern</xsl:when>
          <xsl:when test="normalize-space(.)='pli' ">Pali</xsl:when>
          <xsl:when test="normalize-space(.)='pol' ">Polish</xsl:when>
          <xsl:when test="normalize-space(.)='por' ">Portuguese</xsl:when>
          <xsl:when test="normalize-space(.)='pus' ">Pushto</xsl:when>
          <xsl:when test="normalize-space(.)='que' ">Quechua</xsl:when>
          <xsl:when test="normalize-space(.)='roh' ">Raeto-Romance </xsl:when>
          <xsl:when test="normalize-space(.)='rum' ">Romanian</xsl:when>
          <xsl:when test="normalize-space(.)='run' ">Rundi</xsl:when>
          <xsl:when test="normalize-space(.)='rus' ">Russian</xsl:when>
          <xsl:when test="normalize-space(.)='sag' ">Sango</xsl:when>
          <xsl:when test="normalize-space(.)='san' ">Sanskrit</xsl:when>
          <xsl:when test="normalize-space(.)='sin' ">Sinhala; sinhalese</xsl:when>
          <xsl:when test="normalize-space(.)='slo' ">Slovak</xsl:when>
          <xsl:when test="normalize-space(.)='slv' ">Slovenian</xsl:when>
          <xsl:when test="normalize-space(.)='snd' ">Sindhi</xsl:when>
          <xsl:when test="normalize-space(.)='som' ">Somali</xsl:when>
          <xsl:when test="normalize-space(.)='spa' ">Spanish</xsl:when>
          <xsl:when test="normalize-space(.)='srp' ">Serbian</xsl:when>
          <xsl:when test="normalize-space(.)='sun' ">Sundanese</xsl:when>
          <xsl:when test="normalize-space(.)='swa' ">Swahili</xsl:when>
          <xsl:when test="normalize-space(.)='swe' ">Swedish</xsl:when>
          <xsl:when test="normalize-space(.)='tah' ">Tahitian</xsl:when>
          <xsl:when test="normalize-space(.)='tam' ">Tamil</xsl:when>
          <xsl:when test="normalize-space(.)='tel' ">Telugu</xsl:when>
          <xsl:when test="normalize-space(.)='tha' ">Thao</xsl:when>
          <xsl:when test="normalize-space(.)='tib' ">Tibetan</xsl:when>
          <xsl:when test="normalize-space(.)='tir' ">Tigrinya</xsl:when>
          <xsl:when test="normalize-space(.)='tuk' ">Turkmen</xsl:when>
          <xsl:when test="normalize-space(.)='tur' ">Turkish</xsl:when>
          <xsl:when test="normalize-space(.)='twi' ">Twi</xsl:when>
          <xsl:when test="normalize-space(.)='uig' ">Uighur</xsl:when>
          <xsl:when test="normalize-space(.)='ukr' ">Ukrainian</xsl:when>
          <xsl:when test="normalize-space(.)='urd' ">Urdu</xsl:when>
          <xsl:when test="normalize-space(.)='uzb' ">Uzbek</xsl:when>
          <xsl:when test="normalize-space(.)='vie' ">Vietnamese</xsl:when>
          <xsl:when test="normalize-space(.)='wel' ">Welsh</xsl:when>
          <xsl:when test="normalize-space(.)='wol' ">Wolof</xsl:when>
          <xsl:when test="normalize-space(.)='xho' ">Xhosa</xsl:when>
          <xsl:when test="normalize-space(.)='yid' ">Yiddish</xsl:when>
          <xsl:when test="normalize-space(.)='yor' ">Yiddish</xsl:when>
          <xsl:when test="normalize-space(.)='zul' ">Zulu</xsl:when>
          <!-- à completer -->
          <xsl:otherwise>
              <xsl:text>English</xsl:text>
          </xsl:otherwise>
      </xsl:choose>   
  </xsl:template>  
    
 <!-- **********************************************************
     2° élément fils de PubmedArticleSet, PubmedBookArticle : 
      ********************************************************** -->
<xsl:template match="PubmedBookArticle"> 
 <!-- 41 sur 43 sont des chapitres de livres, 2 des livres complets -->   
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
        
        <text>
            <body>
                <listBibl>
                    <biblFull>
                        <!-- titleStmt obligatoire ; minimum : fils title. HAL ajoute les auteurs (sans parent "authorList"), et les funder (c'est une solution)  -->
                        <titleStmt>
                            <xsl:call-template name="Title"/>   <!-- quand partie de book -->
                            
                            <!-- <xsl:apply-templates select="BookDocument/AuthorList"/>  OU :
                            <xsl:comment>
                        <xsl:text>Pour ne pas allonger inutilement la description, les auteurs sont présents ci-dessous,  
                            chemin : TEI/text/body/listBibl/biblFull/sourceDesc/biblStruct/analytic/author 
                            ou TEI/text/body/listBibl/biblFull/sourceDesc/biblStruct/monogr/author</xsl:text>
                    </xsl:comment>  -->
                            <!-- les auteurs de type editor sont dans BookDocument/Book/AuthorList -->
                            <xsl:apply-templates select=".//GrantList"/>
                        </titleStmt>
                        
                        <editionStmt>
                            <edition>
                                <date type="whenDownloaded"><xsl:value-of select="$DateAcqu"/></date>
                                <date type="whenCreated"><xsl:value-of select="$today"/></date>
                            </edition>
                            <respStmt>
                                <resp>Generated by TEI-Conditor XSLT (https://github.com/conditor/tei-conditor), from original Pubmed document pmid  <xsl:value-of select="//ArticleId[@IdType='pubmed']"/></resp>
                                <name>Conditor</name>
                            </respStmt>
                        </editionStmt>
                        
                        <publicationStmt>
                            <distributor>Conditor</distributor> <!-- ou authority ou publisher -->
                        </publicationStmt>                        
                        
                        <sourceDesc>
                            <biblStruct>
                                <analytic>
                                    <!-- crée un analytic dans tous les cas, même book complet, pour XPath utltérieurs sur titles.
                                    Sinon, mettre le if ci-dessous au-dessus de analytic-->
                                    <xsl:call-template name="Title"/>      <!-- cas avec BookTitle slt ou ArticleTitle, plus bas -->
                                    
                                    <xsl:if test=".//ArticleTitle">
                                    <xsl:apply-templates select="BookDocument/AuthorList"/>  <!-- auteurs de la partie ; plus haut -->
                                    
                                    <!-- InvestigatorList (209497)
                                (PubMed : identifies an investigator (or collaborator) who contributed to the publication as a member of a group author.) -->
                                    <xsl:apply-templates select=".//InvestigatorList"/> <!-- dans Book ou BookDocument, 0 dans le corpus -->
                                    
                                    <!-- ICI si modèle TEI NEW (voir avec dédoublonnage) -->
                                    <!--    <xsl:call-template name="ArticleIdList"/> -->
                                        
                                    </xsl:if>
                                </analytic>
                                
                                <monogr>
                                
                                    <xsl:apply-templates select="BookDocument/Book"/>  <!-- idno, title, authorList[@type=editor] -->
                                    
                                </monogr>
                                
                                <!-- *** idno ici, modèle TEI OLD *** : -->
                        <xsl:call-template name="ArticleIdList"/>  
                                
                            </biblStruct>
                        </sourceDesc>
                        
                        <profileDesc>
                            <langUsage>
                                <language>
                                    <xsl:variable name="lang" select="BookDocument/Language"/>
                                    <xsl:attribute name="ident"><xsl:value-of select="substring($lang, 1, 2)"/></xsl:attribute>
                                    <xsl:if test="$lang='fre'">French</xsl:if>
                                    <xsl:if test="$lang='eng'">English</xsl:if>
                                    <xsl:if test="$lang='spa'">Spanish</xsl:if>    
                                    <xsl:if test="$lang='ger'">German</xsl:if>
                                </language>
                            </langUsage>
                           
                            <textClass>
                                <xsl:apply-templates select="BookDocument"/>   <!-- génère classcode de valeur Book ou Book chapter -->
                            </textClass>
                            
                            <xsl:apply-templates select=".//Abstract"/>
                            <xsl:apply-templates select=".//OtherAbstract"/>
                        </profileDesc>
                        
                    </biblFull>
                </listBibl>
            </body>
        </text>
    </TEI>
    
    <!-- 42 notices
        titre :     ils on tous un BookTitle ; 40 ont un ArticleTitle, 2 sans (Book complets) -->

</xsl:template>
    
<xsl:template name="Title">  <!-- 2 cas : ArticleTitle (chapitres) ou pas (livre complet ?) ; BookTitle partout -->
    <xsl:choose>
        <xsl:when test="BookDocument/ArticleTitle">
            <xsl:apply-templates select="BookDocument/ArticleTitle"/>  <!-- gestion sub sup à prévoir -->
        </xsl:when>
        <xsl:otherwise>  <!-- 2 cas sur 42 -->
            <xsl:element name="title"> 
                <xsl:attribute name="xml:lang"><xsl:value-of select="substring(..//Language, 1, 2)"/></xsl:attribute>
                <xsl:value-of select="normalize-space(BookDocument/Book/BookTitle)"/>
            </xsl:element>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>    
    
    <xsl:template match="Book"> <!-- ( Publisher, BookTitle, PubDate, BeginningDate?, EndingDate?, AuthorList*, InvestigatorList?, Volume?, VolumeTitle?, Edition?, CollectionTitle?, Isbn*, ELocationID*, Medium?, ReportNumber? )) -->
      
        <!-- pas d'ISSN autorisé Book -->
        <xsl:for-each select="Isbn">
            <idno type="isbn"><xsl:value-of select="normalize-space(.)"/></idno>
        </xsl:for-each>
        
        <xsl:for-each select="ELocationID">
                <xsl:if test="@EIdType='doi'"><idno type="doi"><xsl:value-of select="."/></idno></xsl:if>
                <xsl:if test="@EIdType='pii'"><idno type="pii"><xsl:value-of select="."/></idno></xsl:if>
        </xsl:for-each>       
        <xsl:if test="ReportNumber">
            <idno type="reportNumber"><xsl:value-of select="ReportNumber"/></idno>
        </xsl:if>
        <xsl:if test="not(../ArticleTitle)">
            <idno type="pubmed"><xsl:value-of select="../PMID"/></idno>
        </xsl:if>
        <!-- <Medium>Internet</Medium> : à traiter -->
        
        <xsl:if test="BookTitle[string-length(.) &gt; 0]">
            <title level="m">
                <xsl:attribute name="xml:lang"><xsl:value-of select="substring(..//Language, 1, 2)"/></xsl:attribute>
                <xsl:value-of select="normalize-space(BookTitle)"/>
                <xsl:if test="VolumeTitle">
                        <xsl:text> : </xsl:text>
                        <xsl:value-of select="normalize-space(VolumeTitle)"/>
                </xsl:if>
            </title>
        </xsl:if>  <!-- notion de chapitre, partie dans imprint : biblScope -->
        
        <xsl:if test="CollectionTitle">
            <title level="j">
                <xsl:attribute name="xml:lang"><xsl:value-of select="substring(..//Language, 1, 2)"/></xsl:attribute>
                <xsl:value-of select="CollectionTitle"/></title>
        </xsl:if>
        
        <!-- authors AuthorList de type editor (ou rien) mais dans Book -->
        <xsl:apply-templates select="AuthorList"/> <!-- mais voir si c'est un auteur-éditeur ou un éditeur-auteur ! -->
        
        <xsl:call-template name="ImprintBook"/>
        
    </xsl:template>
    
    <xsl:template name="ImprintBook">  <!-- un autre pour les Books, trop long sinon -->
        <imprint>
            <xsl:if test="Publisher/PublisherName">   <!-- ( PublisherName, PublisherLocation? ) pour books et chapter, élément fils de Book, template appelé dans celui sur Book -->
                    <publisher>
                        <xsl:value-of select="Publisher/PublisherName"/>
                    </publisher>
                </xsl:if>
                <xsl:if test="Publisher/PublisherLocation">
                    <pubPlace>
                        <xsl:value-of select="Publisher/PublisherLocation"/>
                    </pubPlace>
                </xsl:if>
                <!-- le groupe du 10-09-2018 ne veut pas récupérer le pays, sauf s'il est dans une chaîne difficile à découper. Si change d'avis :
                <xsl:when test="MedlineCitation/MedlineJournalInfo/Country">   $$$ articles, pas de Publisher $$
                    <pubPlace><xsl:value-of select="MedlineCitation/MedlineJournalInfo/Country"/></pubPlace>
                </xsl:when> -->
            
     <!--           <xsl:if test="Publisher"> 
                    <publisher>
                        <xsl:value-of select="Publisher/PublisherName"/>
                        <xsl:if test="Publisher/PublisherLocation">
                            <xsl:text>, </xsl:text>
                            <xsl:value-of select="Publisher/PublisherLocation"/>
                        </xsl:if>
                    </publisher>
                </xsl:if>  -->
            
            <date type="datePub">  
                    
                <xsl:choose>
                        <xsl:when test="PubDate/Year[string-length(.) &gt; 0]">
                            <xsl:value-of select="PubDate/Year"/>
                          <!-- BeginningDate=PubDate ; *** EndingDate non traité (qquns, semble être fin de diffusion) -->
                        
                            <!-- <xsl:value-of select="MedlineCitation/Article/Journal/JournalIssue/PubDate/Month"/> -->
                            <xsl:if test="PubDate/Month[text()]">
                                <xsl:text>-</xsl:text>
                                <xsl:variable  name="mois" select="PubDate/Month"/>
                                <!-- 01 et 1 à 12 et Apr, Aug, Dec, Feb, Jan, Jul, Jun, Mar May Nov Oct Sep -->
                                <xsl:choose>
                                    <xsl:when test="contains($mois, '0')"><xsl:value-of select="$mois"/></xsl:when>
                                    <xsl:when test="$mois='1' or $mois='Jan'">01</xsl:when>
                                    <xsl:when test="$mois='2' or $mois='Fev'">02</xsl:when>
                                    <xsl:when test="$mois='3' or $mois='Mar'">03</xsl:when>
                                    <xsl:when test="$mois='4' or $mois='Apr'">04</xsl:when>
                                    <xsl:when test="$mois='5' or $mois='May'">05</xsl:when>
                                    <xsl:when test="$mois='6' or $mois='Jun'">06</xsl:when>
                                    <xsl:when test="$mois='7' or $mois='Jul'">07</xsl:when>
                                    <xsl:when test="$mois='8' or $mois='Aug'">08</xsl:when>
                                    <xsl:when test="$mois='9' or $mois='Sep'">09</xsl:when>
                                    <xsl:when test="contains($mois,'Oct')">10</xsl:when>
                                    <xsl:when test="contains($mois,'Nov')">11</xsl:when>
                                    <xsl:when test="contains($mois,'Dec')">12</xsl:when>
                                    <!-- <xsl:otherwise><xsl:value-of select="$mois"/></xsl:otherwise> -->
                            </xsl:choose>
                                <xsl:if test="PubDate/Day">
                                    <xsl:text>-</xsl:text>
                                    <xsl:value-of select="PubDate/Day"/>
                                </xsl:if>
                            </xsl:if>
                           <!-- pas ISO, sinon OK :
                               <xsl:if test="PubDate/Season">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="PubDate/Season"/>
                            </xsl:if> -->
                       </xsl:when>                         
                </xsl:choose>
            </date> 
            
            <!-- <date type="yearPub">
                <xsl:choose>
                    <xsl:when test="PubDate"><xsl:value-of select="PubDate/Year"/></xsl:when>
                </xsl:choose>
            </date> -->
            
            <xsl:if test="string-length(Volume) &gt; 0"> 
                <biblScope unit="volume"><xsl:value-of select="normalize-space(substring-before(Volume, ' '))"/></biblScope>
                <!-- Aucun dans ce corpus 2014-2017, ni de VolumeTitle frère ; à voir -->
            </xsl:if>
            <xsl:if test="../LocationLabel">  <!-- *** à revoir : Chp. 8, Essay 1 ... -->
                <biblScope unit="part"><xsl:value-of select="../LocationLabel"/></biblScope>
            </xsl:if>
            
            <xsl:if test="../Pagination">
                <biblScope unit="pp">
                    <!-- dans BookDocument (parent de Book)/Pagination avec fils EndPage,StartPage (rare, en devenir) ou MedlinePgn -->
                    <xsl:choose>
                        <xsl:when test="../Pagination/MedlinePgn"> <!-- forme : 4 si seule ; 3841-50 ... plus bizarres aussi mais ... -->
                            <xsl:value-of select="../Pagination/MedlinePgn"/>
                        </xsl:when>
                        <xsl:when test="../Pagination/StartPage">  <!-- les 2 pages complètes -->
                            <xsl:value-of select="../Pagination/StartPage"/>
                            <xsl:if test="../Pagination/EndPage">
                                <xsl:text>-</xsl:text>
                                <xsl:value-of select="../Pagination/EndPage"/>
                            </xsl:if>
                        </xsl:when>
                    </xsl:choose>
                </biblScope>
            </xsl:if> <!-- pag -->
            
        </imprint>
    </xsl:template>
    
    <xsl:template match="BookDocument">
            <xsl:choose>
                <xsl:when test="ArticleTitle"> <classCode scheme="typology">Book chapter</classCode></xsl:when>
                <xsl:otherwise> <classCode scheme="typology">Book</classCode></xsl:otherwise>
            </xsl:choose>
            
            <xsl:for-each select="PublicationType">
                <classCode scheme="typology"><xsl:value-of select="."/></classCode>
            </xsl:for-each>
        
    </xsl:template>
 
</xsl:stylesheet>