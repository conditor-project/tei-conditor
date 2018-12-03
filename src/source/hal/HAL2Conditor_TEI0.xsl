<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:hal="http://hal.archives-ouvertes.fr"
    exclude-result-prefixes="xs tei hal"
    version="1.0">
    
    <!-- copie 0 : souci avec xmlns="" qui se recréent dans certaines éléments, tei comme hal
        avec ou sans xmlns:hal="http://hal.archives-ouvertes.fr" et 'hal' dans exclude-prefix : idem : le processeur remet l'url pour les xsl:copy-of -->
    
    <!-- de la TEI HAL, modèle aofr.xsd à la TEI Conditor V0.
        Différence principale : affiliations fils de auteur (TEI HAL : dans l'élément "back") : non structurée (utilisation d'un fichier travaillé sur le référentiel AureHal) 
        et structurée (structure proche de TEI HAL, desc en moins) ; au choix ultérierement.
        Des attributs valides dans aofr.xsd ne le sont pas dans le schéma plus récent issu du odd (exemples : email @type). Un certain nmbre ont été conservés tel que faute d'attribut correct correspondant.
    
    Pour passer à la V1, valide par rapport à odd, schéma plus récent et plus générique TEI proposé par L. Romary mais non adopté par CCSD pour l'instant :
    - déplacer les idno de type analytic dans 'analytic' (prêt, en commentaire)
    - ajouter un 'p' fils de abstract (prêt, en commentaire)
    - voir en détail pour ces attributs. -->
    
    
    <xsl:output indent="yes" standalone="yes"/>
    
    
    <xsl:param name="DateAcqu"/>  
    <xsl:param name="DateCreat"/>  <!-- indiquée par le shell Conditor ultérieur -->
    
    <!-- élément racine  : TEI, un seul à cause des id de valeur répétée sinon. -->
    
    <xsl:template match="/tei:TEI">
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <text>
                <body>
                    <listBibl>
                        <biblFull>
                            <!-- titleStmt obligatoire ; minimum : fils title. HAL ajoute les auteurs, et les funder (la meilleure solution pouir ces derniers), mais sous forme de lien vers back/listOrg  -->
                            <titleStmt>
                                <xsl:choose>
                                    <xsl:when test="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:titleStmt/tei:title">
                                        <xsl:for-each select="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:titleStmt/tei:title">
                                            <title><xsl:copy-of select="@*"/><xsl:value-of select="normalize-space(.)"/></title>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:when test="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:sourceDesc/tei:biblStruct/tei:analytic/tei:title">
                                        <xsl:for-each select="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:sourceDesc/tei:biblStruct/tei:analytic/tei:title">
                                            <title><xsl:copy-of select="@*"/><xsl:value-of select="normalize-space(.)"/></title>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:when test="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title">
                                        <xsl:for-each select="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title">
                                            <title><xsl:copy-of select="@*"/><xsl:value-of select="normalize-space(.)"/></title>
                                        </xsl:for-each>
                                    </xsl:when>
                                </xsl:choose>
                                
                                
                                <xsl:comment><xsl:text>Les auteurs sont dans la description bibliographique, chemin : TEI/text/body/listBibl/biblFull/sourceDesc/biblStruct/analytic/author ou TEI/text/body/listBibl/biblFull/sourceDesc/biblStruct/monogr/author</xsl:text>
                                </xsl:comment>
                                <!-- OU (auteur + affiliation forme lien slt: 
                                <xsl:choose>
                                    <xsl:when test="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:titleStmt/tei:author">
   
                                        <xsl:for-each select="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:titleStmt/tei:author">
                                        <author><xsl:copy-of select="@*"/>
                                        <xsl:copy-of select="tei:persName"/>
                                           <xsl:if test="tei:idno[@type='halauthorid']">
                                                <idno type="halAuthorId"><xsl:value-of select="tei:idno[@type='halauthorid']"/></idno>
                                          </xsl:if>
                                         <xsl:copy-of select="tei:affiliation"/>
                                        </author>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:when test="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:sourceDesc/tei:biblStruct/tei:analytic/tei:author">
                                        <xsl:for-each select="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:sourceDesc/tei:biblStruct/tei:analytic/tei:author">
                                            <author><xsl:copy-of select="@*"/>
                                                <xsl:copy-of select="tei:persName"/>
                                                <xsl:if test="tei:idno[@type='halauthorid']">
                                                    <idno type="halAuthorId"><xsl:value-of select="tei:idno[@type='halauthorid']"/></idno>
                                                </xsl:if>
                                                <xsl:copy-of select="tei:affiliation"/>
                                            </author>  
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:when test="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:author">
                                        <xsl:for-each select="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:author">
                                            <author><xsl:copy-of select="@*"/>
                                                <xsl:copy-of select="tei:persName"/>
                                                <xsl:if test="tei:idno[@type='halauthorid']">
                                                    <idno type="halAuthorId"><xsl:value-of select="tei:idno[@type='halauthorid']"/></idno>
                                                </xsl:if>
                                                <xsl:copy-of select="tei:affiliation"/>
                                            </author>
                                        </xsl:for-each>
                                        
                                    </xsl:when>
                                </xsl:choose> -->
                                
                                <!-- funders -->
                                <xsl:apply-templates select="tei:text/tei:back//tei:listOrg[@type='projects']"/> 
                            </titleStmt>
                        
                            <editionStmt>
                                <edition>
                                    <date type="whenDownloaded"><xsl:value-of select="$DateAcqu"/></date>
                                    <date type="whenCreated"><xsl:value-of select="$DateCreat"/></date>
                                    <xsl:copy-of select="tei:text//tei:date[@whenEndEmbargoed]"/> <!-- plutôt dans imprint ? -->
                                    <!-- autres détails dans HAL : voir -->
                                </edition>
                            </editionStmt>
                            
                            <publicationStmt>
                                <distributor>Conditor</distributor> <!-- ou authority ou publisher -->
                            </publicationStmt>
                            
                            
                            <xsl:if test="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:notesStmt/tei:note">
                                <notesStmt>                             
                                    <xsl:apply-templates select="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:notesStmt"/>
                                </notesStmt> 
                            </xsl:if>
                          
                            <sourceDesc>
                                <biblStruct>
                                    <analytic>
                                        <xsl:for-each select="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:sourceDesc/tei:biblStruct/tei:analytic/tei:title">
                                        <title>
                                            <xsl:copy-of select="@*"/>
                                            <xsl:value-of select="normalize-space(.)"/>
                                        </title>
                                        </xsl:for-each>
                                        <xsl:apply-templates select="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:sourceDesc/tei:biblStruct/tei:analytic/tei:author"/>
                                        <!-- ajouter les idno de type analytic ici dans V1, y compris halId qui est dans publicationStmt -->
                                    </analytic>
                                   <!-- <monogr> facultatif -->
                                        <xsl:apply-templates select="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:sourceDesc/tei:biblStruct/tei:monogr"/>
                                    <!-- </monogr> -->
                                    <!-- <xsl:apply-templates select="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:sourceDesc"/> -->
                                </biblStruct>
                            </sourceDesc>
                            
                            <profileDesc>
                            <xsl:apply-templates select="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:profileDesc"/>
                            </profileDesc>
                        </biblFull></listBibl></body></text></TEI>
    </xsl:template>
    
    
    <xsl:template match="tei:notesStmt">
        <xsl:for-each select="tei:note">
            <xsl:choose>
                <xsl:when test="@type='commentary'"> <xsl:copy-of select="."/></xsl:when>  <!-- xsltproc remet xmlns:hal=... -->
                <xsl:when test="@type='description'"><xsl:copy-of select="."/></xsl:when>   <!-- idem -->
                <xsl:otherwise>
                    <note xmlns="http://www.tei-c.org/ns/1.0">
                        <!-- appel aux URL, possible - vérifier que OK (pas pour popular !) - mais pas idéal : peut changer
                            avec &, incorrrect, avec &amp;, l'URL n'aboutit pas, OK en encodage numérique :
                        <xsl:attribute name="type">
                        <xsl:text>http://api.archives-ouvertes.fr/ref/metadataList/?q=metaName_s:</xsl:text>
                        <xsl:value-of select="@type"/>
                        <xsl:text>&#36;fl=*&#36;=xml</xsl:text>
                    </xsl:attribute>
                    <xsl:copy-of select="@n"/> -->
                        
                        <xsl:copy-of select="@type"/>
                        <xsl:copy-of select="@n"/>
                        <xsl:choose>
                            <xsl:when test="@type='audience'"> <!-- 0=not set, 1=international, 2=national -->
                                <xsl:if test="@n='1'">audience : international</xsl:if>
                                <xsl:if test="@n='2'">audience : national</xsl:if>
                            </xsl:when>
                            <xsl:when test="@type='invited'"> <!-- 0=no, 1=yes  --><!-- mandatory metadata invitedCommunication ; mais absente des notices récentes exemple -->
                                <xsl:if test="@n='0'">invited communication : no</xsl:if>
                                <xsl:if test="@n='1'">invited communication : yes</xsl:if>
                            </xsl:when>
                            <xsl:when test="@type='popular'"> <!-- 0=not set, 1=international, 2=national -->
                                <xsl:if test="@n='0'">popular level : no</xsl:if>
                                <xsl:if test="@n='1'">popular level : yes</xsl:if>
                            </xsl:when>
                            <xsl:when test="@type='peer'"> <!-- 0=not set, 1=international, 2=national -->
                                <xsl:if test="@n='0'">peer reviewing : no</xsl:if>
                                <xsl:if test="@n='1'">peer reviewing : yes</xsl:if>
                            </xsl:when>
                            <xsl:when test="@type='proceedings'"> <!-- 0=not set, 1=international, 2=national -->
                                <xsl:if test="@n='0'">proceedings : no</xsl:if>
                                <xsl:if test="@n='1'">proceedings : yes</xsl:if>
                            </xsl:when>
                            <xsl:when test="@type='openAccess'"> <!-- 0=not set, 1=international, 2=national -->
                                <xsl:if test="@n='0'">open access : no</xsl:if>
                                <xsl:if test="@n='1'">green open access : yes</xsl:if>
                                <xsl:if test="@n='2'">gold open access : yes</xsl:if>
                            </xsl:when>
                            <xsl:when test="@type='thesisOriginal'"> <!-- 0=not set, 1=international, 2=national -->
                                <xsl:if test="@n='0'">original thesis version : no</xsl:if>
                                <xsl:if test="@n='1'">original thesis version : yes</xsl:if>
                            </xsl:when>
                        </xsl:choose>
                    </note>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        
    </xsl:template>
    
   <xsl:template match="tei:author">
       <author xmlns="http://www.tei-c.org/ns/1.0">
           <xsl:attribute name="role"><xsl:value-of select="@role"/></xsl:attribute>
           
           <xsl:choose>
               <xsl:when test="tei:persName">
                   
                    <xsl:copy-of select="tei:persName"/>   <!-- xsltProc remet xmlnx:hal= ... -->
                    <!-- OK mais pas fini à cause casse des attributs : <xsl:copy-of select="tei:idno"/>, OK : -->
                   
                    <xsl:copy-of select="tei:email"/>    <!-- xsltProc idem -->
                   <!-- @type non accepté xsd new -->
                  <!-- ??? <xs:element minOccurs="0" ref="ns1:orgName"/> certains sont dans la notice ou le fichier orgname_filsdeAuthor, autres non -->
                   
                   <xsl:apply-templates select="tei:affiliation"/>
                   
                   <xsl:call-template name="IDNO"/> <!-- fonctionne -->
                    
               </xsl:when></xsl:choose>
       </author>
   </xsl:template>
    
  <xsl:template match="tei:affiliation">
    <xsl:variable name="aff" select="substring-after(@ref, '#')"/>
        <affiliation>
            <xsl:attribute name="n"><xsl:value-of select="$aff"/></xsl:attribute>
            <!-- 1 - en un élément texte : -->
            <xsl:choose>
                <xsl:when test="document('affil_hal_struct.xml')//structures/structure[struct=$aff]/ad"> <!-- travail de Alain pour 2014 : toutes infos -->
                    <xsl:value-of select="document('affil_hal_struct.xml')//structures/structure[struct=$aff]/ad"/>
                </xsl:when>
                <xsl:otherwise>
                    
                    <xsl:for-each select="ancestor::tei:TEI//tei:org[@xml:id=$aff]/tei:orgName">
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:for-each>
                    <xsl:if test="ancestor::tei:TEI//tei:org[@xml:id=$aff]//tei:addrLine">
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="normalize-space(ancestor::tei:TEI//tei:org[@xml:id=$aff]//tei:addrLine)"/>
                    </xsl:if>
                    <xsl:if test="ancestor::tei:TEI//tei:org[@xml:id=$aff]//tei:country">
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="ancestor::tei:TEI//tei:org[@xml:id=$aff]//tei:country/@key"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            
            <!-- infos complémentaires structurées, dans orgName (org pas autorisé comme fils de affiliation) : -->
            
            <orgName>
                <xsl:attribute name="type"><xsl:value-of select="ancestor::tei:TEI//tei:org[@xml:id=$aff]/@type"/></xsl:attribute>
                <name>
                    <xsl:value-of select="normalize-space(ancestor::tei:TEI//tei:org[@xml:id=$aff]/tei:orgName)"/>
                </name>
                <xsl:if test="ancestor::tei:TEI//tei:org[@xml:id=$aff]/tei:orgName[@type='acronym']">
                    <name type="acronym">
                        <xsl:value-of select="normalize-space(ancestor::tei:TEI//tei:org[@xml:id=$aff]/tei:orgName[@type='acronym'])"/>
                    </name>
                </xsl:if>
                <!-- récupère un code de structure : -->
                <xsl:for-each select="ancestor::tei:TEI//tei:org[@xml:id=$aff]//listRelation/relation[@name]">
                    <name type="code"><xsl:value-of select="@name"/></name>
                </xsl:for-each>
                
                <address>
                    <xsl:copy-of select="ancestor::tei:TEI//tei:org[@xml:id=$aff]//tei:addrLine"/>
                    <xsl:copy-of select="ancestor::tei:TEI//tei:org[@xml:id=$aff]//tei:country"/>
                    
                </address>
                <idno type="halStructureId"><xsl:value-of select="$aff"/></idno>

                
                <xsl:for-each select="ancestor::tei:TEI//tei:org[@xml:id=$aff]">
                    <xsl:call-template name="IDNO"/> 
                </xsl:for-each>   
                
                
            </orgName>
            
            
            <xsl:for-each select="ancestor::tei:TEI//tei:org[@xml:id=$aff]//tei:relation[@active]">
                <xsl:call-template name="Affiliation">
                    <xsl:with-param name="RelAct" select="substring-after(@active, '#')"/>
                </xsl:call-template>
                
            </xsl:for-each>   
        </affiliation> 
    </xsl:template> 

    <xsl:template name="Affiliation">
        <xsl:param name="RelAct"/>    

        <xsl:for-each select="ancestor::tei:TEI//tei:org[@xml:id=$RelAct]">
            <xsl:if test="@type='institution'">
        <orgName>
            <xsl:attribute name="type">
                <xsl:value-of select="@type"/>  <!-- élément de back/listOrg typé avec @type=labo, reseauchteam, institution ... et contenu informationnel -->
            </xsl:attribute>
            
            <name>
                <xsl:value-of select="tei:orgName"/>
            </name>
            <xsl:if test="tei:orgName[@type='acronym']">
                <name type="acronym"><xsl:value-of select="tei:orgName[@type='acronym']"/></name>
            </xsl:if>
           <!--  <xsl:copy-of select="/*//tei:org[@xml:id=$aff]/tei:desc"/>   --> <!-- addrLine et country -->
            
            <idno type="halStructureId"><xsl:value-of select="$RelAct"/></idno>  
            <!-- il y en a (type RNSR, IdRef autres?), valeur d'attribut transformée par template IDNOXSL suivant : -->
            <xsl:call-template name="IDNO"/>
            
        </orgName>
            </xsl:if>
            
            <xsl:for-each select="ancestor::tei:TEI//tei:org[@xml:id=$RelAct]//tei:relation[@active]">
                <xsl:call-template name="Affiliation">
                    <xsl:with-param name="RelAct" select="substring-after(@active, '#')"/>
                </xsl:call-template>
            </xsl:for-each>
            
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="tei:monogr">
        
        <monogr xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="tei:idno">
               
                   <xsl:choose>
                       <xsl:when test="@type='ISSN'"><idno><xsl:attribute name="type">issn</xsl:attribute><xsl:value-of select="."/></idno></xsl:when>
                       <xsl:when test="@type='ISSNe'"><idno><xsl:attribute name="type">eissn</xsl:attribute><xsl:value-of select="."/></idno></xsl:when>
                       <xsl:when test="@type='ISBN'"><idno><xsl:attribute name="type">isbn</xsl:attribute><xsl:value-of select="."/></idno></xsl:when>
                       
                       <xsl:when test="@type='localRef'"></xsl:when>
                       <xsl:when test="@type='halJournalId'"></xsl:when> <!-- à discuter CS -->
                       
                       <xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
                   </xsl:choose>
                   <!-- Plus : type=localRef">t14/351</idno><idno type="halJournalId" status="VALID">20299</idno> -->
               
           </xsl:for-each>
            
            <xsl:copy-of select="tei:title"/>
            
            <xsl:if test="tei:authority[@type='supervisor']">
                <editor role="ths"><persName>
                    <xsl:value-of select="tei:authority[@type='supervisor']"/>
                </persName></editor>
            </xsl:if>   
            <xsl:if test="tei:authority[@type='institution']">
                <editor role="dgg"><orgName>
                    <xsl:value-of select="tei:authority[@type='institution']"/>
                </orgName></editor>
            </xsl:if>
            <xsl:if test="tei:authority[@type='school']">
                <editor role="dos"><orgName>
                    <xsl:value-of select="tei:authority[@type='institution']"/>
                </orgName></editor>
            </xsl:if>
            <xsl:if test="tei:editor">
                <editor role="edt">
                    <persName>
                        <xsl:value-of select="tei:authority[@type='supervisor']"/>
                    </persName>
                </editor>
                
                <xsl:call-template name="IDNO"/>  <!-- voir si OK -->
            </xsl:if>
            
            <xsl:copy-of select="meeting"/>
            <xsl:copy-of select="respStmt"/> <!-- à discuter -->
            
            <xsl:copy-of select="tei:settlement"/>  <!-- pour cartes, brevets, idem country -->
            <xsl:copy-of select="tei:country"/>
            
            <xsl:if test="tei:imprint/*[text()]">
                <xsl:copy-of select="tei:imprint"/>
            </xsl:if>
        </monogr>
        
        <!-- TEI V0 : -->
        <!-- <xsl:copy-of select="tei:idno"/> -->
        <idno type="halId"><xsl:value-of select="ancestor::tei:TEI//tei:publicationStmt/tei:idno[@type='halId']"/></idno>
        <xsl:call-template name="IDNO"/>
        
        <!-- <ref type=’file’ target=’[URL]’/>, URL full text -->
       <!-- <xsl:text>ref</xsl:text> -->
        <xsl:copy-of select="ancestor::tei:TEI//tei:editionStmt//tei:ref"/>
        
    </xsl:template>
    
    <xsl:template match="tei:listOrg[@type='projects']">
        <!-- source :
        <org type="anrProject" xml:id="projanr-11" status="VALID">
                        <idno type="anr">ANR-05-PADD-0011</idno>
                        <idno type="program">Programme fédérateur Agriculture et Développement
                            Durable</idno>
                        <orgName>COPT</orgName>
                        <desc>Conception d'Observatoires de Pratiques Territorialisées</desc>
                        <date type="start">2005</date>
                    </org>
                </listOrg>
        -->
        
        <xsl:for-each select="tei:org">
            <funder xmlns="http://www.tei-c.org/ns/1.0">
                <!-- <xsl:copy-of select=".//tei:idno"/> -->
                <xsl:call-template name="IDNO"></xsl:call-template>
                <xsl:if test="orgName">
                <orgName>
                    <xsl:copy-of select="@*"/>
                    <name><xsl:value-of select="tei:orgName"/></name>
                    <xsl:copy-of select="tei:desc/*"/>
                        <xsl:copy-of select="tei:date"/>
                    <xsl:if test="@type='anrProject'"><country key="FR">France</country></xsl:if>
                    <xsl:if test="@type='europeanProject'"><country key="FR">Europe</country></xsl:if>
                </orgName>
                </xsl:if>
            </funder>
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template match="tei:profileDesc">
        <xsl:copy-of select="tei:langUsage"/>
        <textClass>
            <xsl:copy-of select="tei:textClass/tei:keywords"/>
            <xsl:for-each select="tei:textClass/tei:classCode">
                <xsl:choose>
                    <xsl:when test="@scheme='halTypology'">
                        <classCode scheme="typology">
                            <xsl:value-of select="."/>
                        </classCode>
                    </xsl:when>
                    <xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </textClass>
        <xsl:copy-of select="tei:abstract"/>
    </xsl:template>
    
    <xsl:template name="IDNO">
        <xsl:for-each select="tei:idno">
        <xsl:choose>
            
            <xsl:when test="@type='halauthorid'"><idno type="halAuthorId" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="."/></idno></xsl:when>
            <xsl:when test="@type='idRef'"><xsl:copy-of select="."/></xsl:when> <!-- voir si copy-of génère xmlns, si oui, comentaires -->
            <xsl:when test="@type='IdRef'"><idno type="idRef" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="."/></idno></xsl:when>
            <xsl:when test="@type='ORCID'"><idno type="orcid" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="."/></idno></xsl:when>
            <xsl:when test="@type='VIAF'"><idno type="viaf" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="."/></idno></xsl:when>
            <xsl:when test="@type='ISNI'"><idno type="isni" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="."/></idno></xsl:when>
            
            <!-- trouvé fichier Alain-Christiane (dans TEI) : -->
            <xsl:when test="@type='1'"><idno type="arxiv" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="."/></idno></xsl:when>
            <xsl:when test="@type='10'"><idno type="viaf" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="."/></idno></xsl:when>
            <xsl:when test="@type='11'"><idno type="isni" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="."/></idno></xsl:when>
            <xsl:when test="@type='2'"><idno type="researcherId" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="."/></idno></xsl:when>
            <xsl:when test="@type='3'"><idno type="idRef" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="."/></idno></xsl:when>
            <xsl:when test="@type='4'"><idno type="orcid" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="."/></idno></xsl:when>
            <xsl:when test="@type='1'"><idno type="arxiv" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="."/></idno></xsl:when>
            <xsl:when test="@type='10'"><idno type="viaf" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="."/></idno></xsl:when>
            <xsl:when test="@type='11'"><idno type="isni" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="."/></idno></xsl:when>
            <xsl:when test="@type='ResearcherId'"><idno type="researcherId" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="."/></idno></xsl:when>
            <xsl:when test="@type='idhal'">
                <idno type="idHal">
                    <xsl:attribute name="subtype"><xsl:value-of select="@notation"/></xsl:attribute>
                    <xsl:value-of select="."/>
                </idno> 
                <!-- @notation="numeric|string"> attribut incorrect schéma odd, remplacé par subtype --></xsl:when>
            
            <xsl:when test="@type='arXiv'"><idno type="arxiv" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="."/></idno></xsl:when>
            
            
            <xsl:when test="@type='halStructureId'"><xsl:copy-of select="."/></xsl:when>
            <xsl:when test="@type='RNSR'"><idno type="rnsr" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="."/></idno></xsl:when>   
            
            <xsl:when test="@type='artNumber'"><idno type="artNo" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="."/></idno></xsl:when>
            
            <xsl:when test="@type='doi'"><xsl:copy-of select="."/></xsl:when>
            <xsl:when test="@type='DOI'"><idno type="doi" xmlns="http://www.tei-c.org/ns/1.0"><xsl:value-of select="."/></idno></xsl:when>
            
            <!-- (inutile qd on enlève otherwise ), à suivre -->
            <xsl:when test="@type='anr'"><idno type="anr"><xsl:value-of select="."/></idno></xsl:when>
            <xsl:when test="@type='programme'"><idno type="anr"><xsl:value-of select="."/></idno></xsl:when>
            
            
            <xsl:when test="@type='localRef'"/>
            <!-- plus : @type=stamp dans seriesStmt, elt non récupéré par XSL -->
            
            <xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
        </xsl:choose>
        </xsl:for-each>
        
    </xsl:template>
</xsl:stylesheet>