<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    exclude-result-prefixes="xs"
    version="1.0">
    
<!-- de une ou plusieurs notices PubMed récupérées via l'IHM vers TEI Conditor. A voir : 
 - format issu de l'API
 - requête : il y a des notices en cours de finition, MedlineCitation @Status="In-Data-Review" ou "In-Process" ou "Publisher"; il en reste en 2014, bcp plus en 2017  -->
    
<!-- C. Stock et C. Morel, 2018-07 :
        - modèle TEI non finalisé complétement
        - en cours. Copie de sav le 25-07, même dossier.
-->

<!-- à affiner :
        -Identifiers de Author, AffiliationInfo, Investigator : j'ai traité ceux que j'ai trouvés en 2014-17 
        - <!ENTITY % text             "#PCDATA | b | i | sup | sub | u" > in : 
            - AbstractText, Affiliation, ArticleTitle, BookTitle et VernacularTitle (plus mml), CollectiveName, Keyword (plus mml), 
            - sub,sup, b,i,u(%text)*, 
            - CitationString, CoiStatement, CollectionTitle, Param, PublisherName, SectionTitle, Suffix, VolumeTitle
        - Allowed <mml:math> in <AbstractText>, <ArticleTitle>, <BookTitle>, <CollectionTitle>, <Keyword>, <VernacularTitle> : une seule notice
        
        - email avant affiliation : NEW - inactivé car encore bazar
 -->

<xsl:output encoding="UTF-8" indent="no" standalone="no"/> <!-- !!! changer avant de fournir -->

<xsl:param name="DateAcqu">2018-07-04</xsl:param>  <!-- en dur pour l'instant : nom de fichier ? -->
<xsl:param name="DateCreat">2018-07-24</xsl:param>  <!-- indiquée par le shell ultérieur -->
    
    <!-- élément racine  : 
        - sur les fichiers années 2014-17 : PubmedArticleSet (PubmedArticle (en majorité), PubmedBookArticle (42 ou 43), DeleteCitation (0 dans le corpus)
        - Possible dans la DTD : PubmedBookArticleSet (PubmedBookArticle*)  : pas dans ce corpus -->
    
  
 <xsl:template match="/">
     <!-- au choix : une ou plusieurs notices, elt racine non précisé : -->
    <xsl:choose>
        <!-- <xsl:when test="count(PubmedArticleSet/*) &gt; 1"> -->  <!-- racine trouvée ici, à suivre ; pour s'en affranchir : -->
        <xsl:when test="count(*/PubmedArticle) &gt; 1 or count(*/PubmedBookArticle) &gt; 1">
            <teiCorpus>
                <xsl:attribute name="xsi:schemaLocation">http://www.tei-c.org/ns/1.0 HALschema_xsd/document.xsd</xsl:attribute>
                <xsl:for-each select="*/PubmedArticle | */PubmedBookArticle | */DeleteCitation">
                    <xsl:apply-templates select="."/>
                </xsl:for-each>
            </teiCorpus>
        </xsl:when>
        <xsl:when test="count(//PubmedArticle)=1">
                <xsl:apply-templates select="//PubmedArticle"/>
        </xsl:when>
       <!-- idem -->
           <xsl:when test="count(//PubmedBookArticle)=1">
                <xsl:apply-templates select="//PubmedBookArticle"/>
        </xsl:when>
        <xsl:when test="count(//DeleteCitation)=1">
                <xsl:apply-templates select="//DeleteCitation"/>  <!-- ne contient que le PMID, et pas d'exemple ici. Voir ce qu'on doit faire -->
        </xsl:when>
        <xsl:otherwise>
            <TEI xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:text>*** NOUVELLE ARBORESCENCE SOURCE : regarder ***</xsl:text>
            </TEI>
        </xsl:otherwise>
    </xsl:choose> 
</xsl:template>
    
<xsl:template match="PubmedArticle">
    <!-- dans le fils MedlineCitation, un attribut : Owner (NLM|NASA|PIP|KIE|HSR|HMD) "NLM" . Voir si on garde toutes les notices -->
   
  <TEI xmlns="http://www.tei-c.org/ns/1.0">
    
  <text>
    <body>
        <listBibl>
            <biblFull>
                <!-- titleStmt obligatoire ; minimum : fils title. HAL ajoute les auteurs, et les funder (la meilleure solution)  -->
                <titleStmt>
                    <xsl:apply-templates select="MedlineCitation/Article/ArticleTitle"/> <!-- tj 1 seul -->
                    <xsl:apply-templates select="MedlineCitation/Article/AuthorList"/>
                    <xsl:apply-templates select="MedlineCitation/Article/GrantList"/>
                </titleStmt>
                
                <editionStmt>
                    <edition>
                        <date type="whenDownloaded"><xsl:value-of select="$DateAcqu"/></date>
                        <date type="whenCreated"><xsl:value-of select="$DateCreat"/></date>
                        <xsl:comment>
                            <xsl:text>Elément suivant particulier à PubMed : les notices sont à différents stades de traitement, voir https://dtd.nlm.nih.gov/ncbi/pubmed/doc/out/180101/att-Status.html</xsl:text>
                        </xsl:comment>    
                     <!-- à décommenter si utile :   <note type="recordStatus"><xsl:value-of select="MedlineCitation/@Status"/></note> -->
                    </edition>
                </editionStmt>
                
                <publicationStmt>
                    <distributor>Conditor</distributor> <!-- ou authority ou publisher -->
                </publicationStmt>
                
                <!-- voir après si dispo dans Pubmed :
                <notesStmt>
                    <note type="commentary">Commentaire</note>$$$ %%metadata comment $$
                    <note type="audience" n=" "/> Audience, public  $$$ 0=not set, 1=international, 2=national  audience  $$
                    <note type="invited" n=" "/> Conférence invitée (= Keynote speaker ? à vérifier)$$$ %%mandatory metadata invitedCommunication $$
                    <note type="popular" n=" "/>  popularLevel  $$$ 0=no, 1=yes  $$
                    <note type="peer" n=" "/>   peerReviewing  $$$ 0=no, 1=yes $$
                    <note type="proceedings" n=" "/>  proceedings  (ce sont des actes ???)  $$$ 0=no, 1=yes  $$
                    <note type="openAccess" n=" "/>  Open Access    ;  Transformation : n="0", si le champ OA = No,  n="1", si le champ OA = Green... ; n="2", si le champ OA = Gold</note> 
                </notesStmt> -->
               
                
                <sourceDesc>
                    <biblStruct>
                        <analytic>
                                                       
                            <xsl:apply-templates select="MedlineCitation/Article/ArticleTitle"/>
                            
                            <xsl:apply-templates select="MedlineCitation/Article/AuthorList"/>
                            <!-- InvestigatorList (209497)
                                (PubMed : identifies an investigator (or collaborator) who contributed to the publication as a member of a group author.) -->
                            <xsl:apply-templates select="MedlineCitation/InvestigatorList"/>
                            
                            <!-- ICI si modèle TEI NEW (voir avec dédoublonnage) -->
                            <xsl:call-template name="ArticleIdList"/>
                        </analytic>
                        
                        <monogr>
                            <xsl:apply-templates select="MedlineCitation/Article/Journal"></xsl:apply-templates>
                            <!-- voir plus tard si author fils de authorList de type editor dans PubMed ; sur ce corpus 2014-2017, uniquement dans les PubmedBookArticle -->
                            <xsl:call-template name="Imprint"/> <!-- elts dispersés -->
                        </monogr>
                        
                        <!-- *** idno ici, modèle TEI OLD *** :
                        <xsl:call-template name="ArticleIdList"/>  -->
                        
                    </biblStruct>
                </sourceDesc>
          
            <profileDesc>
                <langUsage>
                    <language>
                        <xsl:attribute name="ident"><xsl:value-of select="substring(MedlineCitation/Article/Language, 1, 2)"/></xsl:attribute>
                    </language>
                </langUsage>
                
               
                <!-- mots-clés :  -->             
                <!-- <xsl:if test="MedlineCitation/SupplMeshList|MedlineCitation/MeshHeadingList|MedlineCitation/PersonalNameSubjectList|MedlineCitation/KeywordList"> -->
                    <!-- fils de MedlineCitation, disséminés -->
                    <textClass>
                        <xsl:apply-templates select="MedlineCitation"/>  <!-- mots clés diverses listes et clascode type Publi -->
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
                        <!-- efficace, à affiner ou décider autre chose :
                        <xsl:for-each select="text()|node()">
                            <xsl:copy-of select="."/>
                        </xsl:for-each> -->
                    </title>
                </xsl:if>
            </xsl:if>
        
        <xsl:if test="../VernacularTitle">
            <xsl:element name="title"> 
            <!-- pas d'attribut lang à VernacularTitle, utiliser celui de Language et le mettre sur 2 lettres -->
            <xsl:attribute name="xml:lang"><xsl:value-of select="substring(../Language, 1, 2)"/></xsl:attribute>
            <xsl:value-of select="normalize-space(..//VernacularTitle)"/>
            <!-- <xsl:for-each select="text()|node()">  les sup et sub et mathml slt, je pense
                <xsl:copy-of select="."/>
            </xsl:for-each> -->
            </xsl:element>
        </xsl:if>
</xsl:template>
    
<xsl:template match="Journal"> <!-- Journal (ISSN?, JournalIssue, Title?, ISOAbbreviation?) -->
    
    <!-- pas d'ISBN dans les PubmedArticle 2014-17 -->
    
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
    
    
    <xsl:template match="AuthorList">  <!-- @Type optionnel (une vingtaine sur cq année), @CompleteYN="Y|N"> 
    aucun élément avec @CompleteYN="N" -->
    <!-- revu : 
        - editor au lieu de author role=edt
        - pour les Books complets, ils sont dans Book (et sont auteur, sauf mention contraire) -->
        
        <xsl:for-each select="Author"> <!-- <!ELEMENT	Author (((LastName, ForeName?, Initials?, Suffix?) | CollectiveName), Identifier*, AffiliationInfo*), @ValidYN="Y">
                                                2014:98, 2015:117, 2016:9, 2017:0 Valid=N-->
           
            <xsl:choose>
            
            <xsl:when test="../@Type='authors'">
            <author role="aut">
                <xsl:if test="@ValidYN='N'">
                    <xsl:attribute name="cert">unknown</xsl:attribute> <!-- high, medium, low ... -->
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
                    <xsl:when test="../../ArticleTitle">    <!-- book chapter: on est dans BookDocument, niveau analytic -->
                        <author role="aut">
                            <xsl:if test="@ValidYN='N'">
                                <xsl:attribute name="cert">unknown</xsl:attribute> <!-- high, medium, low ... -->
                            </xsl:if>
                            <xsl:call-template name="Names"/>
                        </author>
                    </xsl:when>
                    <xsl:when test="../../BookTitle and not(../../..//ArticleTitle)">  <!-- nv monogr, Book, sans nv analytic : livre complet -->
                        <author role="aut">
                            <xsl:if test="@ValidYN='N'">
                                <xsl:attribute name="cert">unknown</xsl:attribute> <!-- high, medium, low ... -->
                            </xsl:if>
                            <xsl:call-template name="Names"/>
                        </author>
                    </xsl:when>
                    <xsl:when test="../../BookTitle and ../../..//ArticleTitle">  <!-- nv monogr mais avec analytic : chapitre -->
                        <editor role="edt">
                            <xsl:if test="@ValidYN='N'">
                                <xsl:attribute name="cert">unknown</xsl:attribute> <!-- high, medium, low ... -->
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
        <!-- Investigator (LastName, ForeName?, Initials?, Suffix?, Identifier*, AffiliationInfo*), @ValidYN (Y | N) "Y" -->
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
                 <forename><xsl:value-of select="ForeName"/></forename>
             </xsl:if>
             <!-- Initiales : complété lot 4, test -->
             <xsl:if test="Initials">
                 <forename type="initial"><xsl:value-of select="Initials"/></forename>
             </xsl:if>
             <!-- contenu hétérogène (tei:genName ou tei:roleName) , et pas auteurs fr: -->
             <!--    <xsl:if test="string-length(Suffix) &gt; 0">
                            <genName><xsl:value-of select="Suffix"/></genName> 
                        </xsl:if> -->
             <surname><xsl:value-of select="LastName"/></surname>
         </persName>
     </xsl:if>   
     <xsl:if test="CollectiveName"> <!-- 8905; string, sans pays en général ; 2785 avec Investigator(s) -->
         <orgName><xsl:value-of select="CollectiveName"/></orgName>  <!-- pas possible d'isoler le pays, rarement indiqué -->
     </xsl:if>
     


     <!-- ID, 4 dans la source pubmed : 
                        <Identifier Source="ORCID">0000-0002-6711-872X</Identifier>  ou <Identifier Source="ORCID">http://orcid.org/0000-0002-9127-348X</Identifier>
                        <Identifier Source="GRID" (grid.numéro
                        <Identifier Source="ISNI" (numéro), , <Identifier Source="RINGGOLD" (numéro)
                        Attention : URL complète ou id seul.
                         Fils de Author, Affilliation, Investigator   -->
     <xsl:for-each select="Identifier">
         <xsl:element name="idno">
             <xsl:attribute name="type">
                 <!-- mettre du choose pour voir nouveaux cas ? -->
                 <xsl:if test="@Source='ORCID'">orcid</xsl:if>
                 <xsl:if test="@Source='ISNI'">isni</xsl:if>
                 <xsl:if test="@Source='GRID'">grid</xsl:if>  <!-- ces 2 derniers : organismes, mais ne côute rien -->
                 <xsl:if test="@Source='RINGGOLD'">ringgold</xsl:if>
             </xsl:attribute>
             <xsl:choose>
                 <xsl:when test="contains(., 'http://orcid.org')">
                     <xsl:value-of select="substring-after(substring-after(., '.'), '/')"/>         <!-- car normalement pas l'URL; j'ai les 2 cas -->
                 </xsl:when>
                 <xsl:otherwise> <xsl:value-of select="."/></xsl:otherwise>
             </xsl:choose>
             
         </xsl:element>
     </xsl:for-each>
     
     <xsl:for-each select="AffiliationInfo/Affiliation">
         <!-- new : mail, à tester !!! TO DO : Découper après ":", mais qqfois il y en a 2, et on a encore des noms, adresses, des ponctuations ... 
         <xsl:variable name="apres">
         <xsl:choose>
             <xsl:when test="contains(., '.')">
                <xsl:value-of select="substring-after(., '.')"/>
             </xsl:when>
             <xsl:when test="contains(., ';')">
                 <xsl:value-of select="substring-after(., ';')"/>
             </xsl:when>
         </xsl:choose>
         </xsl:variable>
         <xsl:if test="contains($apres, '@')">
             <email><xsl:value-of select="$apres"/></email>
         </xsl:if> -->
         
         <affiliation>
             <xsl:value-of select="normalize-space(.)"/>
             <!-- affiner : isoler pays : plus simple en dehors de la chaine affiliation : -->
             <xsl:choose>
                 <xsl:when test="contains(., ', France,') or contains(., ', France.') or contains(., ', France ,') or contains(., 'France;')"><country>France</country></xsl:when>
                 <xsl:when test="contains(., ', Gadeloupe,') or contains(., ', Guadeloupe.') or contains(., ', Guadeloupe ,') or contains(., 'Guadeloupe;')"><country>France</country></xsl:when>
                 <xsl:when test="contains(., ', Martinique,') or contains(., ', Martinique.') or contains(., ', Martinique ,') or contains(., 'Marinique;')"><country>France</country></xsl:when>
                 <!-- <xsl:otherwise>
                    <xsl:call-template name="finChaine">
                        <xsl:with-param name="avant">
                            <xsl:choose>
                                <xsl:when test="contains(., '.')"><xsl:value-of select="substring-before(., '.')"/></xsl:when>
                                <xsl:when test="contains(., ';')"><xsl:value-of select="substring-before(., ';')"/></xsl:when>
                                <xsl:otherwise><xsl:value-of select="normalize-space(.)"/></xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                        <xsl:with-param name="apres" select="."/>
                    </xsl:call-template>
                </xsl:otherwise> -->
             </xsl:choose>
         </affiliation>
         
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
     </xsl:for-each>
 </xsl:template>
    
<xsl:template name="finChaine">
    <xsl:param name="avant"/>
    <xsl:param name="apres"/>
        <xsl:choose>
            <xsl:when test="contains($apres, ',')">
                <xsl:call-template name="finChaine">
                    <xsl:with-param name="avant" select="substring-before($apres, ',')"/>
                    <xsl:with-param name="apres" select="substring-after($apres, ',')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <country>
                    <xsl:choose>
                        <xsl:when test="contains($apres, 'India')">India</xsl:when>
                        <xsl:when test="contains($apres, 'China')">China</xsl:when>
                        <xsl:when test="contains($apres, 'UK')">UK</xsl:when>
                        <xsl:when test="contains($apres, ', France')">France</xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="contains($apres, '.')"> <!-- il ne devrait plus y en avoir, mais il y en a -->
                                    <xsl:value-of select="normalize-space(substring-before(($apres), '.'))"/>
                                </xsl:when>
                                <xsl:otherwise><xsl:value-of select="normalize-space($apres)"/></xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>          
                    </xsl:choose>
                </country>
            </xsl:otherwise>
        </xsl:choose>
</xsl:template>
    
    <xsl:template name="Imprint">  <!-- un autre pour les Books, trop long sinon -->
        
        <imprint>
            <xsl:choose>
                <xsl:when test="Publisher"> <!-- ( PublisherName, PublisherLocation? ) pour books et chapter, élément fils de Book, template appelé dans celui sur Book -->
                    <publisher>
                        <xsl:value-of select="Publisher/PublisherName"/>
                        <xsl:if test="Publisher/PublisherLocation">
                            <xsl:text>, </xsl:text>
                            <xsl:value-of select="PublisherLocation"/>
                        </xsl:if>
                    </publisher>
                </xsl:when>
            <!-- le groupe du 10-09-2018 n'en veut pas :
                <xsl:when test="MedlineCitation/MedlineJournalInfo/Country">   $$$ articles, pas de Publisher $$
                    <pubPlace><xsl:value-of select="MedlineCitation/MedlineJournalInfo/Country"/></pubPlace>
                </xsl:when> -->
            </xsl:choose>
            
            <date type="datePub"> <!-- Articles - Alain ajoute :  <date type="yearPub">2014</date>, fait ci-dessous --> 
                <xsl:choose>
                    <xsl:when test="MedlineCitation/Article/ArticleDate"> <!-- (ArticleDate?, (Year, Month, Day)) -->
                        <xsl:value-of select="MedlineCitation/Article/ArticleDate/Year"/>
                        <xsl:text>-</xsl:text>
                        <xsl:value-of select="MedlineCitation/Article/ArticleDate/Month"/>
                        <xsl:text>-</xsl:text>
                        <xsl:value-of select="MedlineCitation/Article/ArticleDate/Day"/>
                    </xsl:when>
                    <xsl:when test="MedlineCitation/Article/Journal/JournalIssue/PubDate/Year">   <!-- PubDate oblig ((Year, ((Month, Day?) | Season)?) | MedlineDate) -->
                        <xsl:value-of select="MedlineCitation/Article/Journal/JournalIssue/PubDate/Year"/>
                        <xsl:text>-</xsl:text>
                        <!-- <xsl:value-of select="MedlineCitation/Article/Journal/JournalIssue/PubDate/Month"/> -->
                        <xsl:if test="MedlineCitation/Article/Journal/JournalIssue/PubDate/Month">
                            <xsl:variable  name="mois" select="MedlineCitation/Article/Journal/JournalIssue/PubDate/Month"/>
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
                    </xsl:when>
                    <xsl:when test="MedlineDate"> <!--  articles : date qui ne convient pas aux patterns précédents, ex de la doc : <MedlineDate>2015 Nov-Dec</MedlineDate>, <MedlineDate>1998 Dec-1999 Jan</MedlineDate> -->
                        <xsl:value-of select="MedlineDate"/>
                    </xsl:when>
                    
                    <!-- Book (..PubDate, BeginningDate?, EndingDate?), fils "year" slt dans le corpus : -->
                    <xsl:when test="PubDate">
                        <xsl:value-of select="PubDate/Year"/>
                    </xsl:when>   <!-- BeginningDate=PubDate ; *** EndingDate non traité (qquns) -->
                    
                    <xsl:otherwise><xsl:text>£££ trouver une date</xsl:text></xsl:otherwise>
                </xsl:choose>
                </date> <!-- date @datePub -->
                <date type="year">
                    <xsl:choose>
                        <xsl:when test="MedlineCitation/Article/ArticleDate"> <!-- ArticleDate? (Year, Month, Day) -->
                            <xsl:value-of select="MedlineCitation/Article/ArticleDate/Year"/>
                        </xsl:when>
                        <xsl:when test="MedlineCitation/Article/Journal/JournalIssue/PubDate/Year">   <!-- PubDate oblig ((Year, ((Month, Day?) | Season)?) | MedlineDate) -->
                            <xsl:value-of select="MedlineCitation/Article/Journal/JournalIssue/PubDate/Year"/>
                        </xsl:when>
                        <!-- Books -->
                        <xsl:when test="PubDate"><xsl:value-of select="PubDate/Year"/></xsl:when>
                    </xsl:choose>
                </date>
            
            <xsl:if test="string-length(MedlineCitation/Article/Journal/JournalIssue/Volume) &gt; 0"> 
                <!-- OK mais contient des Suppl, Suppl 2, Pt [A-Z1-9],  Spec Iss (avec ou sans rien), Spec No 1,  Hors série n°2,  ... : 
                    <xsl:value-of select="MedlineCitation/Article/Journal/JournalIssue/Volume"/> 
                    *** Décider si on garde ou pas le texte -->
                <xsl:variable name="Vol" select="MedlineCitation/Article/Journal/JournalIssue/Volume"/>
                
                <!-- On peut créer une seule fois le Volume.  -->
                <biblScope unit="volume"><xsl:value-of select="normalize-space(substring-before($Vol, ' '))"/></biblScope>
                
                <!-- Ajout info supplémentaire dans Issue|autresEquivalents : -->
                <xsl:choose>
                    <xsl:when test="contains($Vol, 'No')"> 
                        <!-- <biblScope unit="specialIssue"><xsl:value-of select="normalize-space(substring-after ($Vol, 'No'))"/></biblScope>
                         je découpe ici, mais ne peux le faire sur l'élément issue : trop de cas. A voir si on garde le texte partout ou ou si le nettoie quand on peut :  
                        OU, si on garde le texte : -->
                        <biblScope unit="specialIssue"><xsl:value-of select="normalize-space(substring-after ($Vol, ''))"/></biblScope>
                        <!-- <xsl:text>£££ Issu du Vol £££</xsl:text> -->
                    </xsl:when>
                    <xsl:when test="contains($Vol, '°')"> <!-- 32 Hors série n°2 -->
                        <!-- <biblScope unit="specialIssue"><xsl:value-of select="normalize-space(substring-after($Vol, '°'))"/></biblScope> -->
                        <biblScope unit="specialIssue"><xsl:value-of select="normalize-space(substring-after($Vol, ' '))"/></biblScope>
                       <!-- <xsl:text>£££ Issu du Vol £££</xsl:text> -->
                    </xsl:when>
                    <xsl:when test="contains($Vol, 'Suppl')"> <!-- homogène : Vol Suppl chiffres, qquns : 46 Suppl 1 UCTN -->
                        <biblScope unit="volume"><xsl:value-of select="normalize-space(substring-before($Vol, 'Suppl'))"/></biblScope>
                        <!-- <biblScope unit="supplement"><xsl:value-of select="normalize-space(substring-after($Vol, 'Suppl'))"/></biblScope> -->
                        <biblScope unit="supplement"><xsl:value-of select="normalize-space(substring-after($Vol, ' '))"/></biblScope>
                        <!-- <xsl:text>£££ Issu du Vol £££</xsl:text> -->
                    </xsl:when> 
                    <xsl:when test="contains($Vol, 'Pt')"> <!-- idem : Vol Pt 1ch ou lettre -->
                    <!-- <biblScope unit="volume"><xsl:value-of select="normalize-space(substring-before($Vol, 'Pt'))"/></biblScope> -->
                    <!--    <biblScope unit="part"><xsl:value-of select="normalize-space(substring-after($Vol, 'Pt '))"/></biblScope> -->
                        <biblScope unit="part"><xsl:value-of select="normalize-space(substring-after($Vol, ' '))"/></biblScope>
                        <!-- <xsl:text>£££ Issu du Vol £££</xsl:text> -->
                    </xsl:when>
                    <xsl:when test="contains($Vol, 'Spec')"> <!-- Spec Iss -->
                      <!--  <biblScope unit="volume"><xsl:value-of select="normalize-space(substring-before($Vol, 'Spec'))"/></biblScope> -->
                        <biblScope unit="specialIssue"><xsl:value-of select="normalize-space(substring-after ($Vol, 'Iss'))"/></biblScope>
                        <!-- <xsl:text>£££ Issu du Vol £££</xsl:text> -->
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
                <!-- Autres (IsgmlInfos, à voir : (ordre : Issue    Vol      PMID)
                    Database issue  43      25428371
                    Web Server issue        42      24878919 
                    F1000 Faculty Rev       4       26594351
                -->
            </xsl:if>
            
            <xsl:if test="MedlineCitation/Article/Pagination">
               <biblScope unit="pp">  
            <!-- dans Article/Pagination avec fils EndPage/StartPage (rare, en devenir) ou MedlinePgn -->
                <xsl:choose>
                    <xsl:when test="MedlineCitation/Article/Pagination/MedlinePgn"> <!-- forme : 4 si seule ; 3841-50 ... plus bizarres aussi mais ... -->
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
              
           <!-- <biblScope unit="meetAbstrNo">   numéro  de "meeting abstract"   (WOS)  </biblScope> Pubmed ne sait pas dire-->
        </imprint>
        
    </xsl:template>

<xsl:template match="GrantList">
    <xsl:for-each select="Grant">  <!-- Grant (GrantID?, Acronym?, Agency, Country) -->
        <funder>
            <xsl:if test="GrantID">
            <idno type="grantId">  <!-- à discuter + indiquer la source ? -->
                <xsl:value-of select="GrantID"/>
            </idno>
            </xsl:if>
            <name>     <!-- orgname ??? -->
                <xsl:value-of select="normalize-space(Agency)"/>
                <!--  <xsl:if test="Acronym">  $$$ funder peut contenir abbr. ; on supprime car propre US
                    <xsl:text> (</xsl:text>
                    <xsl:value-of select="Acronym"/>
                    <xsl:text>)</xsl:text>
                </xsl:if> -->
            </name>
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
         <!--  -->
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

    <!-- MC
        source : dans MedlineCitation, divers :
           KeywordList* @ Owner (NLM | NLM-AUTO | NASA | PIP | KIE | NOTNLM | HHS) "NLM"
                Keyword+ @MajorTopicYN (Y | N) "N" (si NOTNLM, tj 'N')
           SupplMeshList? (SupplMeshName+)
                 @Type (Disease | Protocol | Organism) #REQUIRED
		           UI CDATA #REQUIRED >
           MeshHeadingList?
                (MeshHeading+)
                        (DescriptorName, QualifierName*)pour les 2, @UI et MajorTopicYN oblig ; pour Desciptorname, Type (Geographic) opt. 
                        traités de 2 manières : concaténé, ou pas du tout.
           PersonalNameSubjectList?
           ChemicalList?
           GeneSymbolList?
                   
    résultat TEI Sudoc Alain :
                          <keywords scheme="rameau">
                                <term xml:lang="fr" type="topicalName" ref="https://www.idref.fr/031387136">Édentation partielle</term>
                                <term xml:lang="fr" type="subdivisionForm" ref="https://www.idref.fr/027253139">Thèses et écrits académiques</term>
                            </keywords>
-->
   
  <xsl:template match="MedlineCitation">
        <xsl:if test="MeshHeadingList">
 <!--   <xsl:comment>
        <xsl:text>Mots-Clés, choix : </xsl:text>
        <xsl:text>1 : simple, type présentation : un "term" par couple "descripteur/qualificatif", avec * quand Major, attributs pour lang et identifiant des descripteurs. 
        </xsl:text>
        <xsl:text>2 : complet et granulaire : un keywords par MeshHeading, un 'term' avec attributs supplémentaires</xsl:text>
    </xsl:comment>
    <keywords scheme="meshHeading">
        <xsl:for-each select="MeshHeadingList/MeshHeading"> 
            <xsl:choose>
                <xsl:when test="QualifierName">
                    <xsl:for-each select="QualifierName">
                        <term xml:lang="en">
                            <xsl:attribute name="xml:base"><xsl:text>https://www.ncbi.nlm.nih.gov/mesh/</xsl:text><xsl:value-of select="../DescriptorName/@UI"/></xsl:attribute>
                            <xsl:value-of select="normalize-space(../DescriptorName)"/>
                            <xsl:if test="../DescriptorName/@MajorTopicYN='Y'"><xsl:text>*</xsl:text></xsl:if>
                            <xsl:text>/</xsl:text>
                            <xsl:value-of select="."/>
                            <xsl:if test="@MajorTopicYN='Y'"><xsl:text>*</xsl:text></xsl:if>
                        </term>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <term xml:lang="en">
                        <xsl:attribute name="xml:base"><xsl:text>https://www.ncbi.nlm.nih.gov/mesh/</xsl:text><xsl:value-of select="DescriptorName/@UI"/></xsl:attribute>
                        <xsl:value-of select="normalize-space(DescriptorName)"/></term>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </keywords>  fin choix simple -->
    
<!--    <xsl:comment>
        <xsl:text>MeshHeadings : choix granularité maximale : </xsl:text></xsl:comment> -->
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
                    <xsl:value-of select="."/>
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
                <xsl:value-of select="."/>
            </term>
        </xsl:for-each>
        </keywords>
    </xsl:if>
 
    <xsl:if test="ChemicalList">
    <!--    <xsl:comment>
     <xsl:text>2 formes possibles : la 1° est alignée avec HAL, la seconde granulaire comme Pubmed</xsl:text>
 </xsl:comment> -->
        
   <!--     <keywords scheme="meshChemical">
        <xsl:for-each select="ChemicalList/Chemical"> $$$ Chemical (RegistryNumber, NameOfSubstance) $$
            <term type="Mesh-Chemical">
                <xsl:attribute name="xml:base"><xsl:text>https://www.ncbi.nlm.nih.gov/mesh/</xsl:text><xsl:value-of select="NameOfSubstance/@UI"/></xsl:attribute>
                <xsl:value-of select="NameOfSubstance"/>
                <xsl:text> - Registry Number : </xsl:text>
                <xsl:value-of select="RegistryNumber"/>
            </term>
        </xsl:for-each>
        </keywords> -->
       
<!-- <xsl:comment>
     <xsl:text>meshChemical, Forme la plus granulaire :</xsl:text>
 </xsl:comment> -->
        
            <xsl:for-each select="ChemicalList/Chemical"> <!-- Chemical (RegistryNumber, NameOfSubstance) -->
                <keywords scheme="meshChemical">
                <term type="substanceName">
                    <xsl:attribute name="xml:base"><xsl:text>https://www.ncbi.nlm.nih.gov/mesh/</xsl:text><xsl:value-of select="NameOfSubstance/@UI"/></xsl:attribute>
                    <xsl:value-of select="NameOfSubstance"/>
                </term>
                <term type="registryNumber">
                    <xsl:value-of select="RegistryNumber"/>
                </term>
                </keywords>
            </xsl:for-each>
        
    </xsl:if> 
    
        <!-- GeneSymbolList? 1991-1995 -->
    
    <xsl:if test="KeywordList"> <!--Owner (NLM | NLM-AUTO | NASA | PIP | KIE | NOTNLM | HHS) -->   
        <keywords scheme="author">
            <!-- je pensais traiter chaque cas, mais uniquement valeur "NOTNLM" dans le corpus.
            Ils sont tous mineurs -->
            <xsl:for-each select="KeywordList[@Owner='NOTNLM']/Keyword">
             <term type="author">
                <xsl:value-of select="."/>
            </term>
        </xsl:for-each>
        <!-- extension au cas où : -->
            <xsl:for-each select="KeywordList[@Owner!='NOTNLM']/Keyword">
                <term>
                    <xsl:attribute name="type"><xsl:value-of select="./@Owner"/></xsl:attribute>
                    <xsl:value-of select="."/>
                </term>
            </xsl:for-each>
        </keywords>
    </xsl:if>
    
    <xsl:if test="PersonalNameSubjectList">
        <keywords>
        <xsl:for-each select="PersonalNameSubjectList/PersonalNameSubject"> <!-- ( LastName, ForeName?, Initials?, Suffix? ) -->
            <term type="personalName">
                <xsl:value-of select="LastName"/>
                <xsl:if test="ForeName">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="ForeName"/>
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
    <!-- AbstracText+, @Label CDATA #IMPLIED
		               NlmCategory (BACKGROUND | OBJECTIVE | METHODS | RESULTS | CONCLUSIONS | UNASSIGNED) #IMPLIED2 
    - créer des p avec @type=(BACKGROUND ... ?) - Non, 2018-09-10 -->
    <abstract xml:lang="en"> 
        <!-- un 'p' par partie, OK :
        <xsl:for-each select="AbstractText"> $$$ (%text; | mml:math | DispFormula)* $$$
            <p>
                <xsl:if test="@Label">
                    <xsl:value-of select="@Label"/>
                    <xsl:text> : </xsl:text>
                </xsl:if>
                <xsl:value-of select="normalize-space(.)"/>   
            </p>
        </xsl:for-each>  
       
        <xsl:if test="CopyrightInformation">
            <p>
            <xsl:text>Copyright : </xsl:text><xsl:value-of select="CopyrightInformation"/>
            </p>
        </xsl:if> -->
        
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
        <!-- <xsl:attribute name="type"><xsl:value-of select="@Type"/></xsl:attribute> pas autorisé dans abstract -->
        <xsl:for-each select="AbstractText"> 
           <!-- <p> -->
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:if test="position()!=last()"><xsl:text> </xsl:text></xsl:if>
           <!-- </p> -->
            <xsl:if test="CopyrightInformation">
                <!-- <xsl:text> Copyright : </xsl:text> -->
                <xsl:text> </xsl:text>
                <xsl:value-of select="normalize-space(CopyrightInformation)"/>
            </xsl:if>
        </xsl:for-each>
    </abstract>
    </xsl:template>
    
    
    
 <!-- *************************************** 
     2° élément fils de PubmedArticleSet : 
      *************************************** -->
<xsl:template match="PubmedBookArticle">  <!-- copie de PubmedArticle, en cours -->
    
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
        
        <text>
            <body>
                <listBibl>
                    <biblFull>
                        <!-- titleStmt obligatoire ; minimum : fils title. HAL ajoute les auteurs (sans parent "authorList"), et les funder (c'est une solution)  -->
                        <titleStmt>
                            <xsl:call-template name="Title"/>   <!-- quand partie de book -->
                            <xsl:apply-templates select="BookDocument/AuthorList"/>   <!-- auteurs de la partie. Voir qd pas de partie -->
                            <!-- les auteurs de type editor sont dans BookDocument/Book/AuthorList -->
                            <xsl:apply-templates select=".//GrantList"/> <!-- ** TO DO -->
                           
                        </titleStmt>
                        
                        <editionStmt>
                            <edition>
                                <date type="whenDownloaded"><xsl:value-of select="$DateAcqu"/></date>
                                <date type="whenCreated"><xsl:value-of select="$DateCreat"/></date>
                            </edition>
                        </editionStmt>
                        
                        <!-- !!! obligatoire dans le schéma documentNamesDates.xsd (rep ROMA_min), présent modèle MD HAL : publicationStmt OU extent) -->
                        <publicationStmt>
                            <distributor>Conditor</distributor> <!-- ou authority ou publisher -->
                        </publicationStmt>
                        
                        <!-- voir après dans notices :
                <notesStmt>
                    <note type="commentary">Commentaire</note>$$$ %%metadata comment $$
                    <note type="audience" n=" "/> Audience, public  $$$ 0=not set, 1=international, 2=national  audience  $$
                    <note type="invited" n=" "/> Conférence invitée (= Keynote speaker ? à vérifier)$$$ %%mandatory metadata invitedCommunication $$
                    <note type="popular" n=" "/>  popularLevel  $$$ 0=no, 1=yes  $$
                    <note type="peer" n=" "/>   peerReviewing  $$$ 0=no, 1=yes $$
                    <note type="proceedings" n=" "/>  proceedings  (ce sont des actes ???)  $$$ 0=no, 1=yes  $$
                    <note type="openAccess" n=" "/>  Open Access    ;  Transformation : n="0", si le champ OA = No,  n="1", si le champ OA = Green... ; n="2", si le champ OA = Gold</note> 
                
                    <note type="thesisOriginal" n=" "/>  la notice décrit la version de soutenance = original  $$$  0=no, 1=yes  $$
                </notesStmt> -->
                        
                        
                        <sourceDesc>
                            <biblStruct>
                                <xsl:if test=".//ArticleTitle">
                                <analytic>
                                    
                                    <xsl:call-template name="Title"/>      <!-- cas avec BookTitle slt ou ArticleTitle, plus bas -->
                                    
                                    <xsl:apply-templates select="BookDocument/AuthorList"/>  <!-- auteurs de la partie ; plus haut -->
                                    
                                    <!-- InvestigatorList (209497)
                                (PubMed : identifies an investigator (or collaborator) who contributed to the publication as a member of a group author.) -->
                                    <xsl:apply-templates select=".//InvestigatorList"/> <!-- dans Book ou BookDocument, 0 dans le corpus -->
                                    
                                    <!-- ICI si modèle TEI NEW (voir avec dédoublonnage) -->
                                    <xsl:call-template name="ArticleIdList"/>  <!-- plus haut -->
                                </analytic>
                                </xsl:if>
                                
                                <monogr>
                                
                                    <xsl:apply-templates select="BookDocument/Book"/>  <!-- idno, title, authorList[@type=editor] -->
                                    
                                    <!-- <xsl:call-template name="Imprint"/> dans Book -->
                                </monogr>
                                
                                <!-- *** idno ici, modèle TEI OLD *** :
                        <xsl:call-template name="ArticleIdList"/>  -->
                                
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
                            <!-- résumé(s), 'en', autres : -->
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
        titre :
    ils on tous un BookTitle ; 40 ont un ArticleTitle, 2 sans, exemple :
    <PubmedBookArticle><BookDocument><PMID Version="1">29465922</PMID><ArticleIdList><ArticleId IdType="bookaccession">NBK481869</ArticleId><ArticleId IdType="doi">10.1007/978-3-319-25559-0</ArticleId></ArticleIdList><Book><Publisher><PublisherName>Springer</PublisherName><PublisherLocation>Cham (CH)</PublisherLocation></Publisher><BookTitle book="spr9783319255590">Safer Healthcare: Strategies for the Real World</BookTitle><PubDate><Year>2016</Year></PubDate><AuthorList Type="authors"><Author><LastName>Vincent</LastName><ForeName>Charles</ForeName><Initials>C</Initials><AffiliationInfo><Affiliation>University of Oxford, Oxford, United Kingdom</Affiliation></AffiliationInfo></Author><Author><LastName>Amalberti</LastName><ForeName>René</ForeName><Initials>R</Initials><AffiliationInfo><Affiliation>Haute Autorité de Santé Paris, France</Affiliation></AffiliationInfo></Author></AuthorList><Isbn>9783319255576</Isbn><Isbn>9783319255590</Isbn><ELocationID EIdType="doi">10.1007/978-3-319-25559-0</ELocationID><Medium>Internet</Medium></Book><Language>eng</Language><PublicationType UI="D016454">Review</PublicationType><Sections><Section><SectionTitle book="spr9783319255590" part="fm2">Preface</SectionTitle></Section><Section><SectionTitle book="spr9783319255590" part="fm3">Acknowledgements and Thanks</SectionTitle></Section><Section><LocationLabel Type="chapter">1</LocationLabel><SectionTitle book="spr9783319255590" part="ch1">Progress and Challenges for Patient Safety</SectionTitle></Section><Section><LocationLabel Type="chapter">2</LocationLabel><SectionTitle book="spr9783319255590" part="ch2">The Ideal and the Real</SectionTitle></Section><Section><LocationLabel Type="chapter">3</LocationLabel><SectionTitle book="spr9783319255590" part="ch3">Approaches to Safety: One Size Does Not Fit All</SectionTitle></Section><Section><LocationLabel Type="chapter">4</LocationLabel><SectionTitle book="spr9783319255590" part="ch4">Seeing Safety Through the Patient’s Eyes</SectionTitle></Section><Section><LocationLabel Type="chapter">5</LocationLabel><SectionTitle book="spr9783319255590" part="ch5">The Consequences for Incident Analysis</SectionTitle></Section><Section><LocationLabel Type="chapter">6</LocationLabel><SectionTitle book="spr9783319255590" part="ch6">Strategies for Safety</SectionTitle></Section><Section><LocationLabel Type="chapter">7</LocationLabel><SectionTitle book="spr9783319255590" part="ch7">Safety Strategies in Hospitals</SectionTitle></Section><Section><LocationLabel Type="chapter">8</LocationLabel><SectionTitle book="spr9783319255590" part="ch8">Safety Strategies for Care in the Home</SectionTitle></Section><Section><LocationLabel Type="chapter">9</LocationLabel><SectionTitle book="spr9783319255590" part="ch9">Safety Strategies in Primary Care</SectionTitle></Section><Section><LocationLabel Type="chapter">10</LocationLabel><SectionTitle book="spr9783319255590" part="ch10">New Challenges for Patient Safety</SectionTitle></Section><Section><LocationLabel Type="chapter">11</LocationLabel><SectionTitle book="spr9783319255590" part="ch11">A Compendium of Safety Strategies and Interventions</SectionTitle></Section><Section><LocationLabel Type="chapter">12</LocationLabel><SectionTitle book="spr9783319255590" part="ch12">Managing Risk in the Real World</SectionTitle></Section></Sections></BookDocument><PubmedBookData><History><PubMedPubDate PubStatus="pubmed"><Year>2018</Year><Month>2</Month><Day>22</Day><Hour>6</Hour><Minute>1</Minute></PubMedPubDate><PubMedPubDate PubStatus="medline"><Year>2018</Year><Month>2</Month><Day>22</Day><Hour>6</Hour><Minute>1</Minute></PubMedPubDate><PubMedPubDate PubStatus="entrez"><Year>2018</Year><Month>2</Month><Day>22</Day><Hour>6</Hour><Minute>1</Minute></PubMedPubDate></History><PublicationStatus>ppublish</PublicationStatus><ArticleIdList><ArticleId IdType="pubmed">29465922</ArticleId></ArticleIdList></PubmedBookData></PubmedBookArticle>

cf notices_PubmedBookArticle, indent ou pas -->

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
                <xsl:if test="Publisher"> <!-- ( PublisherName, PublisherLocation? ) pour books et chapter, élément fils de Book, template appelé dans celui sur Book -->
                    <publisher>
                        <xsl:value-of select="Publisher/PublisherName"/>
                        <xsl:if test="Publisher/PublisherLocation">
                            <xsl:text>, </xsl:text>
                            <xsl:value-of select="Publisher/PublisherLocation"/>
                        </xsl:if>
                    </publisher>
                </xsl:if>
            
            <date type="datePub"> <!-- Alain ajoute :  <date type="yearPub">2014</date>, fait ci-dessous --> 
                    <!-- PubDate oblig ((Year, ((Month, Day?) | Season)?) | MedlineDate) -->
                <xsl:choose>
                        <xsl:when test="PubDate/Year[string-length(.) &gt; 0]">
                            <xsl:value-of select="PubDate/Year"/>
                          <!-- BeginningDate=PubDate ; *** EndingDate non traité (qquns) -->
                        
                        <!-- <xsl:value-of select="MedlineCitation/Article/Journal/JournalIssue/PubDate/Month"/> -->
                        <xsl:if test="PubDate/Month">
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
                                <xsl:otherwise><xsl:value-of select="$mois"/></xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="PubDate/Day">
                                <xsl:text>-</xsl:text>
                                <xsl:value-of select="PubDate/Day"/>
                            </xsl:if>
                        </xsl:if>
                       </xsl:when> 
                    
                    <xsl:otherwise><xsl:text>£££ date ? £££</xsl:text></xsl:otherwise>
                </xsl:choose>
            </date> <!-- date @datePub -->
            <date type="year">
                <xsl:choose>
                    <xsl:when test="PubDate"><xsl:value-of select="PubDate/Year"/></xsl:when>
                </xsl:choose>
            </date>
            
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
            
            <!-- <biblScope unit="meetAbstrNo">   numéro  de "meeting abstract"   (WOS)  </biblScope> Pubmed ne sait pas dire-->
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