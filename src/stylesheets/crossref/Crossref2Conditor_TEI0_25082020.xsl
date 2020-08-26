<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:fr="http://www.crossref.org/fundref.xsd"
xmlns:jats="http://www.ncbi.nlm.nih.gov/JATS1"
xmlns:cr="http://www.crossref.org/xschema/1.1"
xmlns:rs="http://www.crossref.org/qrschema/3.0"
exclude-result-prefixes="xs xsi fr jats cr rs"
version="1.0">
    <!-- ========================================================================================================
        C Stock, S. Gregorio, 2020-06. Dernière modification : 30-06-2020.        
        
     Cette feuille de style Crossref2Conditor_TEI0 regroupe le traitement de 3 catégories Crossref différentes :
     <journal>, <conference>, <book>.
     Ne sont pas inclus les types <database>, <peer_review>, <dissertation>, <standard>, <report-paper>, <posted_content> ou <sa_component>
      
        Commence par traiter les notices "journal" : templates génériques et granulaires appelés
    Puis vers ligne 317: les notices "conference" : templates génériques et granulaires appelés
    Puis vers ligne 516 : les notices "book" : templates génériques et granulaires appelés
    Les templates communs aux 3 catégories figurent à partir de la ligne 894
    
      3 grandes différences entre TEI0 et TEI1:
      - "abstract" : dans le nouveau modèle, il doit avoir un ou plusieurs fils éléments (p, list table). Dans l'ancien, valeur textuelle.
      - "idno" de type analytic : dans le nouveau modèle, fils de "analytic", dans l'ancien, fils de biblStruct (après monographic)
      abstract à modifier dans le fichier de config vers ElasticSearch. idno : le chemin est large, donc bon dans les 2 cas.
      - détail affiliations et organismes en général soit dans biblStruct (possible avec odd, choix Conditor) soit dans 'back' (modèle aofr, avec lien de type rid dans biblStruct) 
       Ce XSL traite la forme adoptée pour les 1° corpus chargés. Le faire évoluer en _TEI1 pour la suite
      - idno analytic dans biblStruct
      - abstract sans fils
      - on garde affiliation (non structurée ici) dans author
         
    A suivre si besoin :
        - Traitement des fils de certains éléments, en général textuels dans autres sources : 
        <!ENTITY % text             "#PCDATA | b | i | sup | sub | u" > possibles dans : 
            - abstract, title, , 
            - sub,sup, b,i,u(%text)*, 
        *** Pour l'instant, texte plat ***.
        
       Affiliations peu fréquentes, non structurées et très hétérogènes ; 
        création de "country" dans la cible 'affiliation' :   *** pour France uniquement pour l'instant *** (country key="FR" comme dans HAL), reste trop hétérogène au découpage, ou il faut une liste de pays ... ou rien : infos apportées par autres sources
              - problèmes observés suivant éditeur : 
                    - concaténation de 2 (ou plus) affiliations dans un élément <affiliation>
                    - affiliation tronquée au bout d'environ 250 caractères (problème cöté éditeur, car maxLength 512 car dans Crossref)
                    - 1 affiliation/ adresse éclatée dans différents champs <affiliation> : observé chez la Royal Society of Chemistry (RSC), DOI 10.1039
        	
   Modifications le 19/6/2020   et le 24/6/2020 :
        paramètres date Acq et dateCreated (today)
        Ajout  bloc <respStmt> 
        Publication_Date : tests et transformations pour MOIS  
        Ajout <journal_issue/titles> pour title level=m
        Ajout test langue de l'objet (article, paper, chapter) 
        Ajout test pour <classCode scheme="typology"> : test des attributs content_item@component_type et book@book_type
        Bloc <imprint> pour book
        Changement de position pour isbn
    Modifications le 29/06/2020 :
        Ajout test sur <subtitle> balise vide
        Ajout de normalize-space pour les titres (journal_article, conference_paper) et abstract.
    
     Modifications le 25/08/2020 :   
     xmlns:tei="http://www.tei-c.org/ns/1.0" devient xmlns="http://www.tei-c.org/ns/1.0"
     Type de document (<classCode scheme="typology">) "journal_article" devient "Journal article"
 ============================================================================================================== -->
<xsl:output encoding="UTF-8" indent="yes"/> 

    <xsl:param name="DateAcqu"/>
    <xsl:param name="today"/> <!-- Date de création de la notice Conditor = transformation XSLT -->
 
  <xsl:template match="/">
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
                <!-- traite au choix : une ou plusieurs notices, elt racine non précisé : -->
                <xsl:choose>
                    <xsl:when test="count(//journal | //cr:journal | //rs:crossref_result//cr:crossref/cr:journal) &gt; 1 
                        or count(//conference | //cr:conference | //rs:crossref_result//cr:crossref/cr:conference) &gt; 1 
                        or count(//book | //cr:book | //rs:crossref_result//cr:crossref/cr:book) &gt; 1">
                        <teiCorpus>
                            <xsl:for-each select="//journal | //cr:journal | //rs:crossref_result//cr:crossref/cr:journal
                                | //conference | //cr:conference | //rs:crossref_result//cr:crossref/cr:conference
                                | //book | //cr:book | //rs:crossref_result//cr:crossref/cr:book">
                                <xsl:apply-templates/>
                            </xsl:for-each>
                        </teiCorpus>
                    </xsl:when>
                    <xsl:when test="count(//journal | //cr:journal)=1">
                        <xsl:apply-templates select="//journal | //cr:journal"/>
                    </xsl:when>
                    <xsl:when test="count(//rs:crossref_result//cr:crossref/cr:journal)=1">
                        <xsl:apply-templates select="//rs:crossref_result//cr:crossref/cr:journal"/>
                    </xsl:when>
                    <xsl:when test="count(//conference | //cr:conference | //rs:crossref_result//cr:crossref/cr:conference)=1">
                        <xsl:apply-templates select="//conference | //cr:conference | //rs:crossref_result//cr:crossref/cr:conference"/>
                    </xsl:when>
                    <xsl:when test="count(//book | //cr:book)=1">
                        <xsl:apply-templates select="//book | //cr:book"/> 
                    </xsl:when>
                    <xsl:when test="count(//rs:crossref_result//cr:crossref/cr:book)=1">
                        <xsl:apply-templates select="//rs:crossref_result//cr:crossref/cr:book" mode="book"/> 
                    </xsl:when>
                    <xsl:otherwise>
                            <xsl:text>*** NOUVELLE ARBORESCENCE SOURCE : ***</xsl:text>
                    </xsl:otherwise>
                </xsl:choose> 
      </TEI>
  </xsl:template>         
            
    <xsl:template match="journal| cr:journal">     
    
    <text>
        <body>
            <listBibl>
                <biblFull>
                    <titleStmt>
                        <xsl:apply-templates select="//journal/journal_article/titles |//cr:journal/cr:journal_article/cr:titles" mode="journal"/>
                        <xsl:apply-templates select="//journal/journal_article/fr:program |//cr:journal/cr:journal_article/fr:program" mode="journal"/>
                </titleStmt>
                
                <editionStmt>
                    <edition>
                        <date type="whenDownloaded"><xsl:value-of select="$DateAcqu"/></date>
                        <date type="whenCreated"><xsl:value-of select="$today"/></date>
                    </edition>
                    <respStmt>
                        <resp><xsl:text>Generated by TEI-Conditor XSLT (https://github.com/conditor/tei-conditor), from original Crossref document DOI: </xsl:text>
                            <xsl:value-of select="//journal/journal_article/doi_data/doi | //cr:journal/cr:journal_article/cr:doi_data/cr:doi"/>
                        </resp>
                          <name>Conditor</name>
                     </respStmt>
                </editionStmt>
                
                <publicationStmt>
                    <distributor>Conditor</distributor> 
                </publicationStmt>
                
                <sourceDesc>
                    <biblStruct>
                        <analytic>                       
                            <xsl:apply-templates select="//journal/journal_article/titles | //cr:journal/cr:journal_article/cr:titles" mode="journal"/>
                            <xsl:apply-templates select="//journal/journal_article/contributors/person_name[@contributor_role='author'] |//cr:journal/cr:journal_article/cr:contributors/cr:person_name[@contributor_role='author']"/> 
                            <xsl:apply-templates select="//journal/journal_article/contributors/organization[@contributor_role='author'] | //cr:journal/cr:journal_article/cr:contributors/cr:organization[@contributor_role='author']"/>
                        </analytic>
                        
                        <monogr>
                            
                            <!-- ajout SG pour reprendre le doi niveau revue issue si on le reprend 
                            <xsl:apply-templates select="//journal/journal_issue/doi_data/doi | //cr:journal/cr:journal_issue/cr:doi_data/cr:doi"/>  -->
                            
                            <xsl:apply-templates select="//journal/journal_metadata | //cr:journal/cr:journal_metadata"/>
                            <xsl:call-template name="journal_issue_title"/>
                            <xsl:apply-templates select="//journal/journal_article/contributors/person_name[@contributor_role='editor'] |//cr:journal/cr:journal_article/cr:contributors/cr:person_name[@contributor_role='editor']"/> 
                            <xsl:apply-templates select="//journal/journal_article/contributors/organization[@contributor_role='editor']|//cr:journal/cr:journal_article/cr:contributors/cr:organization[@contributor_role='editor']"/>
                            <xsl:apply-templates select="//journal/journal_issue/contributors/person_name[@contributor_role='editor']| //cr:journal/cr:journal_issue/cr:contributors/cr:person_name[@contributor_role='editor']"/> 
                            <xsl:apply-templates select="//journal/journal_issue/contributors/organization[@contributor_role='editor']| //cr:journal/cr:journal_issue/cr:contributors/cr:organization[@contributor_role='editor']"/>
                            <imprint>
                                <!--  No <publisher> for journals  in record  -->
                                <xsl:apply-templates select="//journal/journal_article/publication_date |//cr:journal/cr:journal_article/cr:publication_date"/>
                                <xsl:apply-templates select="//journal/journal_issue |//cr:journal/cr:journal_issue"/>
                                <xsl:apply-templates select="//journal/journal_article/pages |//cr:journal/cr:journal_article/cr:pages"/>
                                <xsl:apply-templates select="//journal/journal_article/publisher_item/item_number |//cr:journal/cr:journal_article/cr:publisher_item/cr:item_number"/>
                            </imprint>
                        </monogr>
                        
                        <!-- *** idno ici, modèle TEI0 *** :   -->
                        <xsl:apply-templates select="//journal/journal_article/doi_data/doi |//cr:journal/cr:journal_article/cr:doi_data/cr:doi"/>
                        <xsl:apply-templates select="//journal/journal_article/publisher_item/identifier[@id_type='pii'] | //cr:journal/cr:journal_article/cr:publisher_item/cr:identifier[@id_type='pii']"/>
                        <xsl:apply-templates select="//journal/journal_article/publisher_item/identifier[@id_type='pmid'] | //cr:journal/cr:journal_article/cr:publisher_item/cr:identifier[@id_type='pmid']"/>
                    </biblStruct>
                </sourceDesc>
          
            <profileDesc>
                <xsl:if test="//journal/journal_article[@language!=''] | //cr:journal/cr:journal_article[@language!='']">
                <langUsage>
                    <language>
                        <xsl:attribute name="ident">
                            <xsl:value-of select="//journal/journal_article/@language | //cr:journal/cr:journal_article/@language"/></xsl:attribute>
                    </language>
                </langUsage>
                </xsl:if>
                
                <textClass>
                    <classCode scheme="typology">Journal article</classCode>
                </textClass>
                
                <!-- résumé(s), 'en', autres : -->
                <xsl:apply-templates select="//journal/journal_article/abstract | //journal/journal_article/jats:abstract |//cr:journal/cr:journal_article/jats:abstract"/>
                
            </profileDesc>
            </biblFull>
        </listBibl>
    </body>
   </text>
  
</xsl:template>
    
 <!-- *****************************
            Templates 
      ***************************** --> 
    
    <xsl:template match="titles | cr:titles" mode="journal">  <!-- tj présent, vide ou [Not Available]. ou renseigné -->
        <xsl:apply-templates select="title | cr:title" mode="journal"/>
        <xsl:apply-templates select="subtitle | cr:subtitle" mode="journal"/>
        <xsl:apply-templates select="original_language_title | cr:original_language_title"/>
    </xsl:template>
  
  
    <xsl:template match="title | cr:title" mode="journal">
        <title>
            <!--  tests sur langue soit en attribut titre article, soit en attribut revue -->
            <xsl:attribute name="xml:lang">          
                <xsl:choose>
                    <xsl:when test="//journal/journal_article[@language!='']">
                        <xsl:value-of select="//journal/journal_article/@language"/>
                    </xsl:when>
                    <xsl:when test="//journal/journal_metadata[@language!='']">
                        <xsl:value-of select="//journal/journal_metadata/@language"/>
                    </xsl:when>
                    <xsl:otherwise>en</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <!--
            <xsl:apply-templates/>  -->
            <xsl:value-of select="normalize-space(.)"/>
        </title>
    </xsl:template>
    
    <xsl:template match="subtitle| cr:subtitle" mode="journal">
        <xsl:if test="./text()">  <!--  élément vide pour certains éditeurs  -->
        <title type="sub">
            <xsl:attribute name="xml:lang">          
                <xsl:choose>
                    <xsl:when test="//journal/journal_article[@language!=''] | //cr:journal/cr:journal_article[@language!='']">
                        <xsl:value-of select="//journal/journal_article/@language | //cr:journal/cr:journal_article/@language"/>
                    </xsl:when>
                    <xsl:when test="//journal/journal_metadata[@language!=''] | //cr:journal/cr:journal_metadata[@language!='']">
                        <xsl:value-of select="//journal/journal_metadata/@language | //cr:journal/cr:journal_metadata/@language"/>
                    </xsl:when>
                    <xsl:otherwise>en</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>    
        </title>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="journal_metadata | cr:journal_metadata">
        <xsl:apply-templates select="issn | cr:issn"/>
        <xsl:apply-templates select="full_title | cr:full_title"/>
        <xsl:apply-templates select="abbrev_title | cr:abbrev_title"/>
    </xsl:template>

    <xsl:template match="full_title | cr:full_title">
        <title level="j">
            <xsl:apply-templates/>    
        </title>
    </xsl:template>

    <xsl:template match="abbrev_title | cr:abbrev_title">
        <title level="j" type="abbrevIso">
            <xsl:apply-templates/>    
        </title>
    </xsl:template>
    
    <xsl:template name="journal_issue_title">
        <xsl:if test="//journal/journal_issue/titles/text() | //cr:journal/cr:journal_issue/cr:titles/text()">
            <title level="m">
                <xsl:value-of select="//journal/journal_issue/titles/title | //cr:journal/cr:journal_issue/cr:titles/cr:title"/>
            </title></xsl:if>
    </xsl:template>
    
  <!--  volumaison  -->
    <xsl:template match="journal_issue | cr:journal_issue">  
        <xsl:apply-templates select="journal_volume/volume | cr:journal_volume/cr:volume"/>   
        <xsl:apply-templates select="issue | cr:issue"/>  
        <xsl:apply-templates select="special_numbering | cr:special_numbering"/> 
    </xsl:template>
    
    <xsl:template match="special_numbering | cr:special_numbering">
        <biblScope unit="specialIssue">
            <xsl:apply-templates/>
        </biblScope> 
    </xsl:template>              
       
    
    <xsl:template match="fr:program" mode="journal">
        <xsl:for-each select="fr:assertion[@name='fundgroup']">  <!-- Grant (GrantID?, Acronym?, Agency, Country) -->
        <funder>
            <xsl:if test="fr:assertion[@name='funder_name']">
            <name>    
                <xsl:value-of select="normalize-space(fr:assertion[@name='funder_name'])"/>
                <xsl:if test="fr:assertion[@name='funder_identifier']">
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="normalize-space(fr:assertion/fr:assertion[@name='funder_identifier'])"/>
                    <xsl:text>)</xsl:text>
                </xsl:if>
            </name>
            </xsl:if>
            <xsl:if test="fr:assertion[@name='award_number']">
                <xsl:for-each  select="fr:assertion[@name='award_number']">
                <idno type="grantNumber"> 
                    <xsl:value-of select="."/>
                </idno>
                </xsl:for-each>
            </xsl:if>
        </funder>
    </xsl:for-each>
</xsl:template>
     
     
 <!--  ===============================================================
                 Template generique <conference>
     ==========================================================  -->
    
    <xsl:template match="conference | cr:conference">
        <text>
            <body>
                <listBibl>
                    <biblFull>
                        <titleStmt>
                        <xsl:apply-templates select="//conference/conference_paper/titles | //cr:conference/cr:conference_paper/cr:titles" mode="conference"/>
                        <xsl:apply-templates select="//conference/conference_paper/fr:program | //cr:conference/cr:conference_paper/fr:program"/>
                </titleStmt>
                
                        <editionStmt>
                            <edition>
                                <date type="whenDownloaded"><xsl:value-of select="$DateAcqu"/></date>
                                <date type="whenCreated"><xsl:value-of select="$today"/></date>
                    </edition>
                            <respStmt>
                                <resp><xsl:text>Generated by TEI-Conditor XSLT (https://github.com/conditor/tei-conditor), from original Crossref document DOI: </xsl:text>
                             <xsl:value-of select="//conference/conference_paper/doi_data/doi | //cr:conference/cr:conference_paper/cr:doi_data/cr:doi"/></resp>
                                <name>Conditor</name>
                    </respStmt>
                </editionStmt>
                
                        <publicationStmt>
                            <distributor>Conditor</distributor> 
                </publicationStmt>
                
                        <sourceDesc>
                            <biblStruct>
                                <analytic>      
                            <xsl:apply-templates select="//conference/conference_paper/titles | //cr:conference/cr:conference_paper/cr:titles" mode="conference"/>
                            <xsl:apply-templates select="//conference/conference_paper/contributors/person_name[@contributor_role='author'] | //cr:conference/cr:conference_paper/cr:contributors/cr:person_name[@contributor_role='author']"/> 
                            <xsl:apply-templates select="//conference/conference_paper/contributors/organization[@contributor_role='author'] | //cr:conference/cr:conference_paper/cr:contributors/cr:organization[@contributor_role='author']"/>
                        </analytic>
                        
                                <monogr>
                            <xsl:apply-templates select="//conference/proceedings_metadata/isbn | //cr:conference/cr:proceedings_metadata/cr:isbn"/>
                            <xsl:apply-templates select="//conference/proceedings_series_metadata/series_metadata | //cr:conference/cr:proceedings_series_metadata/cr:series_metadata"/>                            
                            <xsl:apply-templates select="//conference/proceedings_series_metadata/proceedings_title | //cr:conference/cr:proceedings_series_metadata/cr:proceedings_title"/>
                            <xsl:apply-templates select="//conference/proceedings_metadata/proceedings_title | //cr:conference/cr:proceedings_metadata/cr:proceedings_title"/>
                            <xsl:apply-templates select="//conference/contributors/person_name[@contributor_role='editor'] | //cr:conference/cr:contributors/cr:person_name[@contributor_role='editor']"/> 
                            <xsl:apply-templates select="//conference/contributors/organization[@contributor_role='editor'] | //cr:conference/cr:contributors/cr:organization[@contributor_role='editor']"/>
                            <xsl:apply-templates select="//conference/event_metadata | //cr:conference/cr:event_metadata"/>
                                    <imprint>
                                <xsl:apply-templates select="//conference/proceedings_series_metadata/publisher | //cr:conference/cr:proceedings_series_metadata/cr:publisher"/>
                                <xsl:apply-templates select="//conference/proceedings_metadata/publisher | //cr:conference/cr:proceedings_metadata/cr:publisher"/>
                                <xsl:apply-templates select="//conference/conference_paper/publication_date | //cr:conference/cr:conference_paper/cr:publication_date"/>
                                <xsl:apply-templates select="//conference/proceedings_series_metadata/volume | //cr:conference/cr:proceedings_series_metadata/cr:volume"/>  
                                <!-- no volume for proceedings_metadata -->
                                <xsl:apply-templates select="//conference/conference_paper/pages | //cr:conference/cr:conference_paper/cr:pages"/>
                                <xsl:apply-templates select="//conference/conference_paper/publisher_item/item_number | //cr:conference/cr:conference_paper/cr:publisher_item/cr:item_number"/>  <!--  unit="artNo"  -->
                            </imprint>
                        </monogr>
                        
                        <!-- *** idno ici, modèle TEI0 *** :   -->
                        <xsl:apply-templates select="//conference/conference_paper/doi_data/doi | //cr:conference/cr:conference_paper/cr:doi_data/cr:doi"/>
                        <xsl:apply-templates select="//conference/conference_paper/publisher_item/identifier[@id_type='pii'] | //cr:conference/cr:conference_paper/cr:publisher_item/cr:identifier[@id_type='pii']"/> 
                        <xsl:apply-templates select="//conference/conference_paper/publisher_item/identifier[@id_type='pmid'] | //cr:conference/cr:conference_paper/cr:publisher_item/cr:identifier[@id_type='pmid']"/> 
                    </biblStruct>
                </sourceDesc>
          
                        <profileDesc>
                
                <xsl:if test="//conference/conference_paper[@language!=''] | //cr:conference/cr:conference_paper[@language!='']">
                    <langUsage>
                        <language>
                        <xsl:attribute name="ident"><xsl:value-of select="//conference/conference_paper/@language| //cr:conference/cr:conference_paper/@language"/></xsl:attribute>
                    </language>
                </langUsage>
                </xsl:if>
                
                            <textClass>
                                <classCode scheme="typology">conference_paper</classCode>
                </textClass>
                
                <!-- résumé(s), 'en', autres : -->
                <xsl:apply-templates select="//conference/conference_paper/jats:abstract | //conference/conference_paper/abstract | //cr:conference/cr:conference_paper/cr:abstract"/>
                
            </profileDesc>
            </biblFull>
        </listBibl>
    </body>
   </text>
  
</xsl:template>
    
 <!-- *****************************
     Templates conference
      ***************************** --> 
    
    <xsl:template match="titles | cr:titles" mode="conference">  
        <xsl:apply-templates select="title | cr:title" mode="conference"/>
        <xsl:apply-templates select="subtitle | cr:subtitle" mode="conference"/>
        <xsl:apply-templates select="original_language_title | cr:original_language_title"/>
</xsl:template>
    
    <xsl:template match="title | cr:title" mode="conference">
        <xsl:element name="title">
            <!--  tests sur langue  -->
            <xsl:attribute name="xml:lang">          
                <xsl:choose>
                    <xsl:when test="//conference/conference_paper[@language!=''] | //cr:conference/cr:conference_paper[@language!='']">
                        <xsl:value-of select="//conference/conference_paper/@language| //cr:conference/cr:conference_paper/@language"/>
                    </xsl:when>
                    <xsl:otherwise>en</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <!--
            <xsl:apply-templates/>  -->            
            <xsl:value-of select="normalize-space(.)"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="subtitle | cr:subtitle" mode="conference">
        <xsl:if test="./text()">
        <title type="sub">
            <xsl:attribute name="xml:lang">          
                <xsl:choose>
                    <xsl:when test="//conference/conference_paper[@language!=''] | //cr:conference/cr:conference_paper[@language!='']">
                        <xsl:value-of select="//conference/conference_paper/@language| //cr:conference/cr:conference_paper/@language"/>
                    </xsl:when>
                    <xsl:otherwise>en</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>    
        </title></xsl:if>
    </xsl:template>
  
    <!--  bloc "monogr"  - début  -->

    <xsl:template match="proceedings_title | cr:proceedings_title">
        <title level="m">
        <xsl:apply-templates/>
        </title>
    </xsl:template>
    
    <!-- elements du bloc "meeting"  -->
    <xsl:template match="event_metadata | cr:event_metadata">
        <meeting>
            <xsl:apply-templates select="conference_name | cr:conference_name"/>    
            <xsl:apply-templates select="conference_date | cr:conference_date"/>       
            <xsl:apply-templates select="conference_location | cr:conference_location"/> 
   <!--         <xsl:apply-templates select="conference_acronym"/>  -->
        </meeting>
    </xsl:template>
    
    <xsl:template match="conference_name | cr:conference_name">
        <title>
            <xsl:apply-templates/>    
        </title>
    </xsl:template>
    
    <xsl:template match="conference_date | cr:conference_date">
        <!-- faire un test sur présence d'attribut ou non -->
        <xsl:choose>
            <xsl:when test="@start_year!=''">
                <date type="start">
                    <xsl:value-of select="@start_year"/>
                    <xsl:if test="@start_month!=''">
                        <xsl:text>-</xsl:text>
                        <xsl:value-of select="@start_month"/>
                    </xsl:if>
                    <xsl:if test="@start_day!=''">
                        <xsl:text>-</xsl:text>
                        <xsl:value-of select="@start_day"/>
                    </xsl:if>
                </date>
            <xsl:if test="@end_year!=''">
                <date type="end">
                    <xsl:value-of select="@end_year"/>
                    <xsl:if test="@end_month!=''">
                        <xsl:text>-</xsl:text>
                        <xsl:value-of select="@end_month"/>
                    </xsl:if>
                    <xsl:if test="@end_day!=''">
                        <xsl:text>-</xsl:text>
                        <xsl:value-of select="@end_day"/>
                    </xsl:if>
                </date>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <date>
                    <xsl:apply-templates/>    
                </date>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
               
    <xsl:template match="conference_location | cr:conference_location">
        <settlement>
            <xsl:apply-templates/>    
        </settlement>
   </xsl:template>
    
  
    <!--  ===============================================================
                 Template generique <book>
     ==========================================================  -->
    
    <xsl:template match="book | cr:book">
        <text>
            <body>
                <listBibl>
                    <biblFull>
                        <titleStmt>
                        <xsl:choose>
                            <xsl:when test="//book/content_item | //cr:book/cr:content_item!=''">
                                <xsl:apply-templates select="//book/content_item/titles | //cr:book/cr:content_item/cr:titles" mode="book"/>   
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="//book/book_series_metadata/titles | //cr:book/cr:book_series_metadata/cr:titles" mode="book"/>
                                <xsl:apply-templates select="//book/book_metadata/titles | //cr:book/cr:book_metadata/cr:titles" mode="book"/>     
                            </xsl:otherwise>
                        </xsl:choose>
      <!--             Trouve-t-on des funder dans les book ? <xsl:apply-templates select="//conference/conference_paper/fr:program"/>  TO DO  -->
                </titleStmt>
                
                        <editionStmt>
                            <edition>
                                <date type="whenDownloaded"><xsl:value-of select="$DateAcqu"/></date>
                                <date type="whenCreated"><xsl:value-of select="$today"/></date>
                    </edition>
                            <respStmt>
                                <resp><xsl:text>Generated by TEI-Conditor XSLT (https://github.com/conditor/tei-conditor), from original Crossref document DOI: </xsl:text>
                               <xsl:value-of select="//book/content_item/doi_data/doi | //cr:book/cr:content_item/cr:doi_data/cr:doi"/></resp>
                                <name>Conditor</name>
                      </respStmt>
                </editionStmt>
                
                        <publicationStmt>
                            <distributor>Conditor</distributor> 
                </publicationStmt>
                
                        <sourceDesc>
                    <biblStruct>
                        <analytic>
           <!--  title of document/object  -->
                             <xsl:choose>
                                 <xsl:when test="//book/content_item | //cr:book/cr:content_item !=''">
                                     <xsl:apply-templates select="//book/content_item/titles | //cr:book/cr:content_item/cr:titles" mode="book"/>   
                                 </xsl:when>
                                   <xsl:otherwise>
                                       <xsl:apply-templates select="//book/book_series_metadata/titles | //cr:book/cr:book_series_metadata/cr:titles" mode="book"/>
                                       <xsl:apply-templates select="//book/book_metadata/titles | //cr:book/cr:book_metadata/cr:titles" mode="book"/>        
                                    </xsl:otherwise>
                             </xsl:choose>
           <!--  responsibility statement of document/object  -->
                            <xsl:choose>
                                <xsl:when test="//book/content_item | //cr:book/cr:content_item !=''">
                                    <xsl:apply-templates select="//book/content_item/contributors/person_name[@contributor_role='author'] | //cr:book/cr:content_item/cr:contributors/cr:person_name[@contributor_role='author']"/> 
                                    <xsl:apply-templates select="//book/content_item/contributors/organization[@contributor_role='author'] | //cr:book/cr:content_item/cr:contributors/cr:organization[@contributor_role='author']"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="//book/book_series_metadata/contributors/person_name[@contributor_role='author'] | //cr:book/cr:book_series_metadata/cr:contributors/cr:person_name[@contributor_role='author']"/>
                                    <xsl:apply-templates select="//book/book_series_metadata/contributors/organization[@contributor_role='author'] | //cr:book/cr:book_series_metadata/cr:contributors/cr:organization[@contributor_role='author']"/>
                                    <xsl:apply-templates select="//book/book_metadata/contributors/person_name[@contributor_role='author'] | //cr:book/cr:book_metadata/cr:contributors/cr:person_name[@contributor_role='author']"/>
                                    <xsl:apply-templates select="//book/book_metadata/contributors/organization[@contributor_role='author'] | //cr:book/cr:book_metadata/cr:contributors/cr:organization[@contributor_role='author']"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </analytic>
                        
                        <monogr>
                            <!-- titre de contenant  -->
                            <xsl:apply-templates select="//book/book_series_metadata/isbn | //cr:book/cr:book_series_metadata/cr:isbn"/>
                            <xsl:apply-templates select="//book/book_metadata/isbn | //cr:book/cr:book_metadata/cr:isbn"/>
                            <xsl:apply-templates select="//book/book_series_metadata/issn | //cr:book/cr:book_series_metadata/cr:issn"/>
                            <xsl:apply-templates select="//book/book_series_metadata/series_metadata | //cr:book/cr:book_series_metadata/cr:series_metadata"/>
                            <xsl:if test ="//book/content_item | //cr:book/cr:content_item !=''">
                                <xsl:apply-templates select="//book/book_series_metadata | //cr:book/cr:book_series_metadata" mode="book"/>                         
                                <xsl:apply-templates select="//book/book_metadata | //cr:book/cr:book_metadata" mode="book"/>
                            </xsl:if>
                            <xsl:apply-templates select="//book/book_series_metadata/contributors/person_name[@contributor_role='editor'] | //cr:book/cr:book_series_metadata/cr:contributors/cr:person_name[@contributor_role='editor']"/> 
                            <xsl:apply-templates select="//book/book_series_metadata/contributors/organization[@contributor_role='editor'] | //cr:book/cr:book_series_metadata/cr:contributors/cr:organization[@contributor_role='editor']"/>
                            <xsl:apply-templates select="//book/book_metadata/contributors/person_name[@contributor_role='editor'] | //cr:book/cr:book_metadata/cr:contributors/cr:person_name[@contributor_role='editor']"/> 
                            <xsl:apply-templates select="//book/book_metadata/contributors/organization[@contributor_role='editor'] | //cr:book/cr:book_metadata/cr:contributors/cr:organization[@contributor_role='editor']"/>
                            <imprint>
                            <xsl:apply-templates select="//book/book_series_metadata/publisher| //cr:book/cr:book_series_metadata/cr:publisher"/>
                            <xsl:apply-templates select="//book/book_metadata/publisher | //cr:book/cr:book_metadata/cr:publisher"/>
                            <xsl:choose>
                                <xsl:when test="//book/content_item | //cr:book/cr:content_item !=''">
                                    <xsl:apply-templates select="//book/content_item/publication_date | //cr:book/cr:content_item/cr:publication_date"/>   
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="//book/book_series_metadata/publication_date | //cr:book/cr:book_series_metadata/cr:publication_date"/>   
                                    <xsl:apply-templates select="//book/book_metadata/publication_date | //cr:book/cr:book_metadata/cr:publication_date"/>   
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:apply-templates select="//book/book_series_metadata/volume | //cr:book/cr:book_series_metadata/cr:volume"/> 
                            <xsl:apply-templates select="//book/content_item/pages | //cr:book/cr:content_item/cr:pages"/>
                            <xsl:if test="//book/content_item/component_number | //cr:book/cr:content_item/cr:component_number !=''">
                                 <xsl:call-template name="component_number"/>
                            </xsl:if>
             <!--         <xsl:if test="//book/content_item[@component_type='chapter']">
                                <xsl:call-template name="chapter"/>
                            </xsl:if> <xsl:if test="//book/content_item[@component_type='part']">
                                <xsl:call-template name="part"/>
                            </xsl:if> 
                            <xsl:if test="//book/content_item[@component_type='reference_entry']">
                                <xsl:call-template name="reference_entry"/>
                            </xsl:if>   -->
                            <xsl:apply-templates select="//book/content_item/publisher_item/item_number | //cr:book/cr:content_item/cr:publisher_item/cr:item_number"/>  <!--  unit="artNo"  -->
                        </imprint>
                      </monogr>
                        
                        <!-- *** idno ici, dont DOI ; modèle TEI0 *** :   -->
                        <xsl:choose>
                            <xsl:when test="//book/content_item | //cr:book/cr:content_item !=''">
                                <xsl:apply-templates select="//book/content_item/doi_data/doi | //cr:book/cr:content_item/cr:doi_data/cr:doi"/>   
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="//book/book_series_metadata/doi_data/doi | //cr:book/cr:book_series_metadata/cr:doi_data/cr:doi"/>   
                                <xsl:apply-templates select="//book/book_metadata/doi_data/doi | //cr:book/cr:book_metadata/cr:doi_data/cr:doi"/>   
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:apply-templates select="//book/content_item/publisher_item | //cr:book/cr:content_item/cr:publisher_item"/>  <!--  pii et pmid -->
                    </biblStruct>
                </sourceDesc>
          
            <profileDesc>
                <xsl:if test="//book/content_item[@language!=''] | //cr:book/cr:content_item[@language!='']">
                    <langUsage>
                        <language>
                        <xsl:attribute name="ident">
                            <xsl:value-of select="//book/content_item/@language | //cr:book/cr:content_item/@language"/>
                        </xsl:attribute>
                    </language>
                </langUsage>
                </xsl:if>
                
                <textClass>
                    <xsl:choose>
                        <xsl:when test="//book/content_item | //cr:book/cr:content_item !=''">
                            <classCode scheme="typology">
                                <xsl:value-of select="//book/content_item/@component_type | //cr:book/cr:content_item/@component_type"/>
                            </classCode>
                        </xsl:when>
                        <xsl:otherwise>
                            <classCode scheme="typology">
                                <xsl:value-of select="//book/@book_type | //cr:book/@book_type"/>
                            </classCode>                       
                        </xsl:otherwise>
                    </xsl:choose>
                </textClass>
                
                <!-- résumé(s), 'en', autres : -->
                <xsl:apply-templates select="//book/content_item/jats:abstract | //book/content_item/abstract | //cr:book/cr:content_item/cr:abstract"/>
                
            </profileDesc>
            </biblFull>
        </listBibl>
    </body>
   </text>
</xsl:template>
    
 <!-- *****************************
     Templates book
      ***************************** --> 
    
    <xsl:template match="titles | cr:titles" mode="book">  <!-- tj présent, vide ou [Not Available]. ou renseigné -->
        <xsl:apply-templates select="title | cr:title" mode="book"/>
        <xsl:apply-templates select="subtitle | cr:subtitle" mode="book"/>
        <xsl:apply-templates select="original_language_title | cr:original_language_title"/>
    </xsl:template>
    
    <xsl:template match="title | cr:title" mode="book">
        <xsl:element name="title">
	   <!--  tests sur langue n'importe ou sauf dans données journal -->
       <xsl:attribute name="xml:lang">          
       <xsl:choose>
          <xsl:when test="//book/content_item[@language!=''] | //cr:book/cr:content_item[@language!='']">
              <xsl:value-of select="//book/content_item/@language | //cr:book/cr:content_item/@language"/>
          </xsl:when>
           <xsl:when test="//book_series_metadata[@language!=''] | //cr:book_series_metadata[@language!='']">
               <xsl:value-of select="//book_series_metadata/@language | //cr:book_series_metadata/@language"/>
           </xsl:when>
           <xsl:when test="//book_metadata[@language!=''] | //cr:book_metadata[@language!='']">
               <xsl:value-of select="//book_metadata/@language | //cr:book_metadata/@language"/>
           </xsl:when>
           <xsl:otherwise>en</xsl:otherwise>
       </xsl:choose>
       </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="subtitle | cr:subtitle" mode="book">
        <xsl:if test="./text()">
        <title type="sub">
            <xsl:attribute name="xml:lang">          
                <xsl:choose>
                    <xsl:when test="//book/content_item[@language!=''] | //cr:book/cr:content_item[@language!='']">
                        <xsl:value-of select="//book/content_item/@language | //cr:book/cr:content_item/@language"/>
                    </xsl:when>
                    <xsl:when test="//book_series_metadata[@language!=''] | //cr:book_series_metadata[@language!='']">
                        <xsl:value-of select="//book_series_metadata/@language | //cr:book_series_metadata/@language"/>
                    </xsl:when>
                    <xsl:when test="//book_metadata[@language!=''] | //cr:book_metadata[@language!='']">
                        <xsl:value-of select="//book_metadata/@language | //cr:book_metadata/@language"/>
                    </xsl:when>
                    <xsl:otherwise>en</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates/>    
        </title>
        </xsl:if>
    </xsl:template>
	
  
    <!--  bloc "monogr"  - début = données revue -->
    
  
<!--  Titre de la monographie -->  
    <xsl:template match="book_metadata | cr:book_metadata" mode="book">      
        <title level="m">
             <xsl:attribute name="xml:lang">          
                <xsl:choose>
                    <xsl:when test="//book_metadata[@language!=''] | //cr:book_metadata[@language!='']">
                        <xsl:value-of select="//book_metadata/@language | //cr:book_metadata/@language"/>
                    </xsl:when>
                    <xsl:when test="//book_series_metadata[@language!=''] | //cr:book_series_metadata[@language!='']">
                        <xsl:value-of select="//book_series_metadata/@language | //cr:book_series_metadata/@language"/>
                    </xsl:when>
                    <xsl:otherwise>en</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="titles/title | cr:titles/cr:title"/>
        </title>
        <xsl:if test="//book/book_metadata/titles/subtitle | //cr:book/cr:book_metadata/cr:titles/cr:subtitle!=''">
            <title level="m" type="sub">            
            <xsl:attribute name="xml:lang">          
                <xsl:choose>
                    <xsl:when test="//book_metadata[@language!=''] | //cr:book_metadata[@language!='']">
                        <xsl:value-of select="//book_metadata/@language | //cr:book_metadata/@language"/>
                    </xsl:when>
                    <xsl:when test="//book_series_metadata[@language!=''] | //cr:book_series_metadata[@language!='']">
                        <xsl:value-of select="//book_series_metadata/@language | //cr:book_series_metadata/@language"/>
                    </xsl:when>
                    <xsl:otherwise>en</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="titles/subtitle | cr:titles/cr:subtitle"/>
        </title>
        </xsl:if>
        <xsl:if test="//book/book_metadata/titles/original_language_title | //cr:book/cr:book_metadata/cr:titles/cr:original_language_title !=''">
            <title level="m">
            <xsl:value-of select="titles/original_language_title | cr:titles/cr:original_language_title"/>
        </title>
        </xsl:if>
    </xsl:template>  
 
    <xsl:template match="book_series_metadata | cr:book_series_metadata" mode="book">      
        <title level="m">            
            <xsl:attribute name="xml:lang">          
                <xsl:choose>
                    <xsl:when test="//book_metadata[@language!=''] | //cr:book_metadata[@language!='']">
                        <xsl:value-of select="//book_metadata/@language | //cr:book_metadata/@language"/>
                    </xsl:when>
                    <xsl:when test="//book_series_metadata[@language!=''] | //cr:book_series_metadata[@language!='']">
                        <xsl:value-of select="//book_series_metadata/@language | //cr:book_series_metadata/@language"/>
                    </xsl:when>
                    <xsl:otherwise>en</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="titles/title | cr:titles/cr:title"/>
        </title>
        <xsl:if test="//book/book_series_metadata/titles/subtitle | //cr:book/cr:book_series_metadata/cr:titles/cr:subtitle!=''">
            <title level="m" type="sub">                
                <xsl:attribute name="xml:lang">          
                    <xsl:choose>
                        <xsl:when test="//book_metadata[@language!=''] | //cr:book_metadata[@language!='']">
                            <xsl:value-of select="//book_metadata/@language | //cr:book_metadata/@language"/>
                        </xsl:when>
                        <xsl:when test="//book_series_metadata[@language!=''] | //cr:book_series_metadata[@language!='']">
                            <xsl:value-of select="//book_series_metadata/@language | //cr:book_series_metadata/@language"/>
                        </xsl:when>
                        <xsl:otherwise>en</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:value-of select="titles/subtitle | cr:titles/cr:subtitle"/>
            </title>
        </xsl:if>
        <xsl:if test="//book/book_series_metadata/titles/original_language_title | //cr:book/cr:book_series_metadata/cr:titles/cr:original_language_title!=''">
            <title level="m"> 
                <xsl:value-of select="titles/original_language_title | cr:titles/cr:original_language_title"/>
            </title>
        </xsl:if>
    </xsl:template>  
     
    <xsl:template name="pMonth">
        <xsl:variable  name="mois" select="//journal/journal_article/publication_date[@media_type='print']/month |//cr:journal/cr:journal_article/cr:publication_date[@media_type='print']/cr:month |
            //conference/conference_paper/publication_date[@media_type='print']/month |//cr:conference/cr:conference_paper/cr:publication_date[@media_type='print']/cr:month |
            //book/content_item/publication_date[@media_type='print']/month |//cr:book/cr:content_item/cr:publication_date[@media_type='print']/cr:month"/>
        <!-- 01 et 1 à 12 et Apr, Aug, Dec, Feb, Jan, Jul, Jun, Mar May Nov Oct Sep -->
        <xsl:choose>
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
    </xsl:template>
    
    <xsl:template name="eMonth">
        <xsl:variable  name="mois" select="//journal/journal_article/publication_date[@media_type='online']/month |//cr:journal/cr:journal_article/cr:publication_date[@media_type='online']/cr:month
            | //conference/conference_paper/publication_date[@media_type='online']/month |//cr:conference/cr:conference_paper/cr:publication_date[@media_type='online']/cr:month
            | //book/content_item/publication_date[@media_type='online']/month|//cr:book/cr:content_item/cr:publication_date[@media_type='online']/cr:month
            "/>
        <!-- 01 et 1 à 12 et Apr, Aug, Dec, Feb, Jan, Jul, Jun, Mar May Nov Oct Sep -->
        <xsl:choose>
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
    </xsl:template> 
    
    <xsl:template name="Month">
        <xsl:variable  name="mois" select="//journal/journal_article/publication_date/month |//cr:journal/cr:journal_article/cr:publication_date/cr:month
            |//conference/conference_paper/publication_date/month |//cr:conference/cr:conference_paper/cr:publication_date/cr:month
            |//book/content_item/publication_date/month | //cr:book/cr:content_item/cr:publication_date/cr:month"/>
        <!-- 01 et 1 à 12 et Apr, Aug, Dec, Feb, Jan, Jul, Jun, Mar May Nov Oct Sep -->
        <xsl:choose>
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
    </xsl:template>
    
    <xsl:template name="component_number">  
        <xsl:if test="//book/content_item[@component_type='chapter'] or //cr:book/cr:content_item[@component_type='chapter']"> 
            <biblScope unit="chapter">
                <xsl:value-of select="//book/content_item/component_number | //cr:book/cr:content_item/cr:component_number"/> 
        </biblScope>
        </xsl:if> <xsl:if test="//book/content_item[@component_type='part'] | //cr:book/cr:content_item[@component_type='part']">
            <biblScope unit="part">
            <xsl:value-of select="//book/content_item/component_number | //cr:book/cr:content_item/cr:component_number"/> 
        </biblScope>
    </xsl:if> 
        <xsl:if test="//book/content_item[@component_type='reference_entry'] | //cr:book/cr:content_item[@component_type='reference_entry']">
            <biblScope unit="entry">
            <xsl:value-of select="//book/content_item/component_number | //cr:book/cr:content_item/cr:component_number"/> 
        </biblScope>
    </xsl:if>
    </xsl:template>
  
    <!--
  ===================================================================================================  
     SGR templates génériques (commun en écriture à journal /conference / book) pour éviter les redondances -->
    
    <!-- funder  / funding  -->
    <xsl:template match="fr:program">
        <xsl:for-each select="fr:assertion[@name='fundgroup']">  <!-- Grant (GrantID?, Acronym?, Agency, Country) -->
            <funder>
                <xsl:if test="fr:assertion[@name='funder_name']">
                    <name>  
                        <xsl:value-of select="normalize-space(fr:assertion[@name='funder_name'])"/>
                    </name>
                </xsl:if>
                <xsl:if test="fr:assertion[@name='award_number']">
                    <idno type="grantNumber">  <!-- à discuter + indiquer la source ? -->
                        <xsl:value-of select="fr:assertion[@name='award_number']"/>
                    </idno>
                </xsl:if>
            </funder>
        </xsl:for-each>
    </xsl:template>
    
    
    <xsl:template match="isbn | cr:isbn">
        <xsl:choose>
            <xsl:when test="@media_type='print'">
                <idno type="isbn">
                    <xsl:apply-templates/>    
                </idno>
            </xsl:when>
            <xsl:when test="@media_type='electronic'">
                <idno type="eisbn">
                    <xsl:apply-templates/>    
                </idno>
            </xsl:when>
            <xsl:otherwise>
                <idno type="isbn">
                    <xsl:apply-templates/>    
                </idno>
            </xsl:otherwise>
        </xsl:choose>			
    </xsl:template> 
    
    <!-- elements du bloc "imprint"  -->
    
    <xsl:template match="publisher | cr:publisher">
        <xsl:apply-templates select="publisher_name | cr:publisher_name"/>
        <xsl:apply-templates select="publisher_place | cr:publisher_place"/>
    </xsl:template>
    
    <xsl:template match="publisher_name | cr:publisher_name">
        <publisher  xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates/>    
        </publisher>
    </xsl:template>
    
    <xsl:template match="publisher_place | cr:publisher_place">
        <pubPlace>
            <xsl:apply-templates/>    
        </pubPlace>
    </xsl:template>
    
    <xsl:template match="original_language_title | cr:original_language_title">
        <title> 
            <xsl:apply-templates/> 
        </title>
    </xsl:template>
    
    <xsl:template match="publication_date | cr:publication_date">
        <xsl:choose>
            <xsl:when test="@media_type='online'">
                <date type="dateEpub">
                    <xsl:apply-templates select="year | cr:year"/>
                    <xsl:if test="month | cr:month!=''">
                        <xsl:text>-</xsl:text>
                        <xsl:call-template name="eMonth"/>                
                    </xsl:if>
                    <xsl:if test="day | cr:day!=''">
                        <xsl:text>-</xsl:text>
                        <xsl:apply-templates select="day | cr:day"/>
                    </xsl:if>
                </date>
            </xsl:when> 
            <xsl:when test="@media_type='print'">
                <date type="datePub">
                    <xsl:apply-templates select="year | cr:year"/>
                    <xsl:if test="month | cr:month!=''">
                        <xsl:text>-</xsl:text>
                        <xsl:call-template name="pMonth"/>                    
                    </xsl:if>
                    <xsl:if test="day | cr:day!=''">
                        <xsl:text>-</xsl:text>
                        <xsl:apply-templates select="day | cr:day"/>
                    </xsl:if>
                </date>
            </xsl:when>
            <xsl:otherwise>
                <date type="datePub">
                    <xsl:apply-templates select="year | cr:year"/>
                    <xsl:if test="month | cr:month!=''">
                        <xsl:text>-</xsl:text>
                        <xsl:call-template name="Month"/>                
                    </xsl:if>
                    <xsl:if test="day | cr:day!=''">
                        <xsl:text>-</xsl:text>
                        <xsl:apply-templates select="day | cr:day"/>
                    </xsl:if>
                </date>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>          
    
    <xsl:template match="year | cr:year">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="day | cr:day">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="volume | cr:volume">
        <biblScope unit="volume">
            <xsl:apply-templates/>
        </biblScope> 
    </xsl:template>
    
    <xsl:template match="issue | cr:issue">
        <biblScope unit="issue">
            <xsl:apply-templates/>
        </biblScope> 
    </xsl:template>
    
    <!--  Pagination  -->
    <xsl:template match="pages | cr:pages">
        <biblScope unit="pp">  
            <xsl:if test="first_page | cr:first_page">
                <xsl:value-of select="first_page | cr:first_page"/>
            </xsl:if>
            <xsl:if test="last_page | cr:last_page"> 
                <xsl:text>-</xsl:text>
                <xsl:value-of select="last_page | cr:last_page"/>
            </xsl:if>
        </biblScope>
    </xsl:template>
    
    <!--  Identifier  -->
    <xsl:template match="item_number | cr:item_number">
        <biblScope unit="artNo">
            <xsl:apply-templates/>   
        </biblScope> 
    </xsl:template>
    
    <xsl:template match="publisher_item | cr:publisher_item">
        <xsl:apply-templates select="identifier[@id_type='pii'] | cr:identifier[@id_type='pii']"/>
        <xsl:apply-templates select="identifier[@id_type='pmid'] | cr:identifier[@id_type='pmid']"/>
    </xsl:template>  
    
    <!--  Identifier  -->
    <xsl:template match="doi | cr:doi">
        <idno type="doi">
            <xsl:apply-templates/>    
        </idno>
    </xsl:template>
    
    
    <xsl:template match="identifier[@id_type='pii'] | cr:identifier[@id_type='pii']">
        <idno type="pii">
            <xsl:apply-templates/>    
        </idno>
    </xsl:template>
    
    <xsl:template match="identifier[@id_type='pmid'] | cr:identifier[@id_type='pmid']">
        <idno type="pubmed">
            <xsl:apply-templates/>    
        </idno>
    </xsl:template>
    
    <xsl:template match="abstract | jats:abstract | cr:abstract"> 
        <abstract xml:lang="en">
            <!--
            <xsl:apply-templates/>  -->            
            <xsl:value-of select="normalize-space(.)"/>
        </abstract>
    </xsl:template>
    
    <xsl:template match="person_name[@contributor_role='author'] | cr:person_name[@contributor_role='author']"> 
        <author role="aut">
            <persName>
                <xsl:apply-templates select="given_name |cr:given_name"/>
                <xsl:apply-templates select="surname | cr:surname"/>
            </persName>
            <xsl:apply-templates select="affiliation | cr:affiliation"/>
            <xsl:apply-templates select="ORCID | cr:ORCID"/>
        </author>
    </xsl:template> 
    
    <xsl:template match="person_name[@contributor_role='editor']| cr:person_name[@contributor_role='editor']"> 
        <editor role="edt">
            <persName>
                <xsl:apply-templates select="given_name |cr:given_name"/>
                <xsl:apply-templates select="surname | cr:surname"/>
            </persName>
            <xsl:apply-templates select="affiliation | cr:affiliation"/>
            <xsl:apply-templates select="ORCID | cr:ORCID"/>
        </editor>
    </xsl:template> 
    
    <xsl:template match="given_name |cr:given_name">
        <forename> 
            <xsl:apply-templates/>
        </forename>
    </xsl:template>
    
    <xsl:template match="surname | cr:surname">
        <surname>
            <xsl:apply-templates/>
        </surname>
    </xsl:template>
    
    <xsl:template match="affiliation | cr:affiliation">
        <affiliation>
            <xsl:apply-templates/>
            <xsl:choose>
                <xsl:when test="contains(affiliation, ', France,') or contains(., ', France.') or contains(., ', France ,') or contains(., 'France;')"><country key="FR"/></xsl:when>
                <xsl:when test="contains(affiliation, ', Guadeloupe,') or contains(., ', Guadeloupe.') or contains(., ', Guadeloupe ,') or contains(., 'Guadeloupe;')"><country key="FR"/></xsl:when>
                <xsl:when test="contains(affiliation, ', Martinique,') or contains(., ', Martinique.') or contains(., ', Martinique ,') or contains(., 'Marinique;')"><country key="FR"/></xsl:when>
                <xsl:when test="contains(affiliation, ', Guyane,') or contains(., ', Guyane.') or contains(., ', Guyane ,') or contains(., 'Guyane;')"><country key="FR"/></xsl:when>
                <xsl:when test="contains(affiliation, ', La Réunion,') or contains(., ', La Réunion.') or contains(., ', La Réunion ,') or contains(., 'La Réunion;')"><country key="FR"/></xsl:when>
                <xsl:when test="contains(affiliation, ', Mayotte,') or contains(., ', Mayotte.') or contains(., ', Mayotte ,') or contains(., 'Mayotte;')"><country key="FR"/></xsl:when>
                <xsl:when test="contains(affiliation, ', Nouvelle Calédonie,') or contains(., ', Nouvelle Calédonie.') or contains(., ', Nouvelle Calédonie ,') or contains(., 'Nouvelle Calédonie;')"><country key="FR"/></xsl:when>
                <xsl:when test="contains(affiliation, ', Polynésie française,') or contains(., ', Polynésie française.') or contains(., ', Polynésie française ,') or contains(., 'Polynésie française;')"><country key="FR"/></xsl:when>
                <xsl:when test="contains(affiliation, ', Saint Barthélémy,') or contains(., ', Saint Barthélémy.') or contains(., ', Saint Barthélémy ,') or contains(., 'Saint Barthélémy;')"><country key="FR"/></xsl:when>
                <xsl:when test="contains(affiliation, ', Saint Martin,') or contains(., ', Saint Martin.') or contains(., ', Saint Martin ,') or contains(., 'Saint Martin;')"><country key="FR"/></xsl:when>
                <xsl:when test="contains(affiliation, ', St Pierre et Miquelon,') or contains(., ', St Pierre et Miquelon.') or contains(., ', St Pierre et Miquelon ,') or contains(., 'St Pierre et Miquelon;')"><country key="FR"/></xsl:when>
                <xsl:when test="contains(affiliation, ', St Barthélémy,') or contains(., ', St Barthélémy.') or contains(., ', St Barthélémy ,') or contains(., 'St Barthélémy;')"><country key="FR"/></xsl:when>
                <xsl:when test="contains(affiliation, ', St Martin,') or contains(., ', St Martin.') or contains(., ', St Martin ,') or contains(., 'St Martin;')"><country key="FR"/></xsl:when>
                <xsl:when test="contains(affiliation, ', Saint Pierre et Miquelon,') or contains(., ', Saint Pierre et Miquelon.') or contains(., ', Saint Pierre et Miquelon ,') or contains(., 'Saint Pierre et Miquelon;')"><country key="FR"/></xsl:when>
                <xsl:when test="contains(affiliation, ', Wallis-et-Futuna,') or contains(., ', Wallis-et-Futuna.') or contains(., ', Wallis-et-Futuna ,') or contains(., 'Wallis-et-Futuna;')"><country key="FR"/></xsl:when>
                <!-- source : http://www.france-dom-tom.fr/. 
                     à suivre autres pays ??? Un call-template de découpage du texte source est prêt mais ne donne pas satisfaction -->
            </xsl:choose>
        </affiliation>
    </xsl:template>
    
    <xsl:template match="organization[@contributor_role='author'] | cr:organization[@contributor_role='author']">
        <author role="aut">
            <orgName> 
                <xsl:apply-templates/>
            </orgName>
        </author>
    </xsl:template>
    
    <xsl:template match="organization[@contributor_role='editor']| cr:organization[@contributor_role='editor']">
        <editor role="edt">
            <orgName> 
                <xsl:apply-templates/>
            </orgName>
        </editor>
    </xsl:template>
    
    
    <xsl:template match="ORCID | cr:ORCID">
        <xsl:element name="idno">
            <xsl:attribute name="type">orcid</xsl:attribute>
            <xsl:choose>
                <xsl:when test="contains(., 'http://orcid.org')">
                    <xsl:value-of select="substring-after(substring-after(., '.'), '/')"/>  
                </xsl:when>
                <xsl:otherwise> 
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="series_metadata | cr:series_metadata">
        <title level="j">
            <xsl:value-of select="titles/title | cr:titles/cr:title"/>
        </title>
        <xsl:if test="titles/subtitle | cr:titles/cr:subtitle !=''">
            <title level="j" type="sub"> 
                <xsl:value-of select="titles/subtitle | cr:titles/cr:subtitle"/>
            </title>
        </xsl:if>            
        <xsl:apply-templates select="issn | cr:issn"/>
    </xsl:template>
    
    <xsl:template match="issn | cr:issn">
        <xsl:choose>
            <xsl:when test="@media_type='print'">
                <idno type="issn">
                    <xsl:apply-templates/>    
                </idno>
            </xsl:when>
            <xsl:when test="@media_type='electronic'">
                <idno type="eissn">
                    <xsl:apply-templates/>    
                </idno>
            </xsl:when>
            <xsl:otherwise>
                <idno type="issn">
                    <xsl:apply-templates/>    
                </idno>
            </xsl:otherwise>
        </xsl:choose>			
    </xsl:template> 
    
</xsl:stylesheet>
