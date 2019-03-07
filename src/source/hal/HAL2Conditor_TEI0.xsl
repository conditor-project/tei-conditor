<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:hal="http://hal.archives-ouvertes.fr" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" exclude-result-prefixes="xs tei hal" version="1.0">

    <!-- de la TEI HAL, modèle aofr.xsd à la TEI Conditor V0.
        Différence principale : affiliations fils de auteur (TEI HAL : dans l'élément "back") ; dans Conditor :
        - non structurée (PubMed, WoS ; pour HAL : utilisation d'un fichier travaillé sur le référentiel AureHal, affil_hal_struct.xml) 
        - structurée pour HAL (structure proche de TEI HAL, desc en moins) ; au choix ultérierement.
        Des attributs valides dans aofr.xsd ne le sont pas dans le schéma plus récent issu du odd (exemples : email @type). Un certain nmbre ont été conservés tel que faute d'attribut correct correspondant.
    
    Pour passer à la V1, valide par rapport à odd, schéma plus récent et plus générique TEI proposé par L. Romary mais non adopté par CCSD pour l'instant :
    - déplacer les idno de type analytic dans 'analytic' (prêt, en commentaire)
    - ajouter un 'p' fils de abstract (prêt, en commentaire)
    - voir en détail pour ces attributs : @type de email invalide, pour halId @notation idem (@subtype). 
    Laurent Romary fait évoluer le .odd de HAL dans ce sens. -->


    <xsl:output indent="yes"/>


    <xsl:param name="DateAcqu"/>
    <xsl:param name="DateCreat"/>
    <!-- indiquée par le shell Conditor ultérieur -->

    <!-- élément racine  : TEI, un seul à cause des id de valeur répétée si plusieurs. -->

    <xsl:template match="/tei:TEI">
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <!-- validation, tmp : -->
            <xsl:attribute name="xsi:schemaLocation">http://www.tei-c.org/ns/1.0 ../modele/HAL_source_resultat_schemas/HALschema_xsd/document.xsd</xsl:attribute>
            <text>
                <body>
                    <listBibl>
                        <biblFull>
                            <!-- titleStmt obligatoire ; minimum : fils title. HAL ajoute les auteurs, et les funder (la meilleure solution pouir ces derniers), mais sous forme de lien vers back/listOrg  -->
                            <titleStmt>
                                <xsl:choose>
                                    <xsl:when test="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:titleStmt/tei:title">
                                        <xsl:for-each select="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:titleStmt/tei:title">
                                            <title>
                                                <xsl:copy-of select="@*"/>
                                                <xsl:value-of select="normalize-space(.)"/>
                                            </title>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:when test="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:sourceDesc/tei:biblStruct/tei:analytic/tei:title">
                                        <xsl:for-each select="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:sourceDesc/tei:biblStruct/tei:analytic/tei:title">
                                            <title>
                                                <xsl:copy-of select="@*"/>
                                                <xsl:value-of select="normalize-space(.)"/>
                                            </title>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:when test="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title">
                                        <xsl:for-each select="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:sourceDesc/tei:biblStruct/tei:monogr/tei:title">
                                            <title>
                                                <xsl:copy-of select="@*"/>
                                                <xsl:value-of select="normalize-space(.)"/>
                                            </title>
                                        </xsl:for-each>
                                    </xsl:when>
                                </xsl:choose>


                                <xsl:comment>
                                    <xsl:text>Les auteurs sont dans la description bibliographique, chemin : TEI/text/body/listBibl/biblFull/sourceDesc/biblStruct/analytic/author ou TEI/text/body/listBibl/biblFull/sourceDesc/biblStruct/monogr/author</xsl:text>
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
                                    <date type="whenDownloaded">
                                        <xsl:value-of select="$DateAcqu"/>
                                    </date>
                                    <date type="whenCreated">
                                        <xsl:value-of select="$DateCreat"/>
                                    </date>
                                    <xsl:copy-of select="tei:text//tei:date[@whenEndEmbargoed]"/>
                                    <!-- plutôt dans imprint ? -->
                                    <!-- autres détails dans HAL : voir -->
                                </edition>
                            </editionStmt>

                            <publicationStmt>
                                <distributor>Conditor</distributor>                                <!-- ou authority ou publisher -->
                            </publicationStmt>


                            <xsl:if test="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:notesStmt/tei:note">
                                <notesStmt>
                                    <xsl:apply-templates select="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:notesStmt"/>
                                </notesStmt>
                            </xsl:if>

                            <sourceDesc>
                                <biblStruct>
                                    <xsl:apply-templates select="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:sourceDesc/tei:biblStruct"/>
                                    <!-- crée :
                                       - analytic (avec idno en V1)
                                       - monogr
                                       - idno analytic pour V0
                                       - ref-->
                                </biblStruct>
                            </sourceDesc>


                            <xsl:apply-templates select="tei:text/tei:body/tei:listBibl/tei:biblFull/tei:profileDesc"/>

                        </biblFull>
                    </listBibl>
                </body>
            </text>
        </TEI>
    </xsl:template>


    <xsl:template match="tei:notesStmt">
        <xsl:for-each select="tei:note">
            <note xmlns="http://www.tei-c.org/ns/1.0">
                <!--  <xsl:copy-of select="."/> : xsltproc remet xmlns:hal=... -->
                <!-- appel aux URL, possible, OK en encodage numérique, exemple :
                        <xsl:attribute name="type">
                        <xsl:text>http://api.archives-ouvertes.fr/ref/metadataList/?q=metaName_s:</xsl:text>
                        <xsl:value-of select="@type"/>
                        <xsl:text>&#36;fl=*&#36;=xml</xsl:text>
                    </xsl:attribute>
                    <xsl:copy-of select="@n"/> -->
                <xsl:copy-of select="@type"/>
                <xsl:copy-of select="@n"/>
                <xsl:choose>
                    <xsl:when test="@type='audience'">                        <!-- 0=not set, 1=international, 2=national, 3 idem -->
                        <xsl:if test="@n='1'">audience : international</xsl:if>
                        <xsl:if test="@n='2'">audience : national</xsl:if>
                        <xsl:if test="@n='3'">audience : national</xsl:if>
                    </xsl:when>
                    <xsl:when test="@type='invited'">                        <!-- 0=no, 1=yes  -->                        <!-- mandatory metadata invitedCommunication ; mais absente des notices récentes exemple -->
                        <xsl:if test="@n='0'">invited communication : no</xsl:if>
                        <xsl:if test="@n='1'">invited communication : yes</xsl:if>
                    </xsl:when>
                    <xsl:when test="@type='popular'">                        <!-- 0=not set, 1=international, 2=national -->
                        <xsl:if test="@n='0'">popular level : no</xsl:if>
                        <xsl:if test="@n='1'">popular level : yes</xsl:if>
                    </xsl:when>
                    <xsl:when test="@type='peer'">                        <!-- 0=not set, 1=international, 2=national -->
                        <xsl:if test="@n='0'">peer reviewing : no</xsl:if>
                        <xsl:if test="@n='1'">peer reviewing : yes</xsl:if>
                    </xsl:when>
                    <xsl:when test="@type='proceedings'">                        <!-- 0=not set, 1=international, 2=national -->
                        <xsl:if test="@n='0'">proceedings : no</xsl:if>
                        <xsl:if test="@n='1'">proceedings : yes</xsl:if>
                    </xsl:when>
                    <xsl:when test="@type='openAccess'">                        <!-- 0=not set, 1=international, 2=national -->
                        <xsl:if test="@n='0'">open access : no</xsl:if>
                        <xsl:if test="@n='1'">green open access : yes</xsl:if>
                        <xsl:if test="@n='2'">gold open access : yes</xsl:if>
                    </xsl:when>
                    <xsl:when test="@type='thesisOriginal'">                        <!-- 0=not set, 1=international, 2=national -->
                        <xsl:if test="@n='0'">original thesis version : no</xsl:if>
                        <xsl:if test="@n='1'">original thesis version : yes</xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>

            </note>
        </xsl:for-each>

    </xsl:template>

    <xsl:template match="tei:author">

        <!-- ajout du xmlns tei à <author> pour ne pas avoir de xmlns vide; idem pour bien d'autres, ou local-name() 
           OK en sortie : <author role=, ... mais pour fils persname, ajout xmlns=hal -->
        <author xmlns="http://www.tei-c.org/ns/1.0">

            <xsl:attribute name="role">
                <xsl:value-of select="@role"/>
            </xsl:attribute>

            <xsl:choose>
                <xsl:when test="tei:persName">

                    <!-- <xsl:copy-of select="tei:persName"/> -->                    <!-- xsltProc remet xmlnx:hal= ... -->
                    <persName>
                        <!-- <xsl:copy-of select="tei:persName/*"/> remet xmlns de hal sur les fils. Forme suivante OK : -->
                        <forename>
                            <xsl:value-of select="tei:persName/tei:forename"/>
                        </forename>
                        <surname>
                            <xsl:value-of select="tei:persName/tei:surname"/>
                        </surname>
                    </persName>

                    <!-- <xsl:copy-of select="tei:email"/> -->                    <!-- xsltProc idem -->
                    <!-- @type non accepté mais LR l'a ajouté au schéma odd, donc OK, 2018-12- ...
                   forme suivante OK : -->
                    <xsl:for-each select="tei:email">
                        <email>
                            <xsl:copy-of select="@*"/>
                            <xsl:value-of select="."/>
                        </email>
                    </xsl:for-each>

                    <!-- il y a ici en plus des affiliations parfois des orgName <xs:element minOccurs="0" ref="ns1:orgName"/>
                      certains sont dans la notice, autres non. A voir -->

                    <xsl:apply-templates select="tei:affiliation"/>

                    <xsl:call-template name="IDNO"/>

                </xsl:when>
            </xsl:choose>
        </author>
    </xsl:template>

    <xsl:template match="tei:affiliation">
        <xsl:variable name="aff" select="substring-after(@ref, '#')"/>
        <affiliation xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="n">
                <xsl:value-of select="$aff"/>
            </xsl:attribute>
            <!-- 1 - en un élément texte : -->
            <xsl:choose>
                <xsl:when test="document('affil_hal_struct.xml')//structures/structure[struct=$aff]/ad">                    <!-- travail de Alain pour 2014 : toutes infos -->
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

            <orgName xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="type">
                    <xsl:value-of select="ancestor::tei:TEI//tei:org[@xml:id=$aff]/@type"/>
                </xsl:attribute>
                <name>
                    <xsl:value-of select="normalize-space(ancestor::tei:TEI//tei:org[@xml:id=$aff]/tei:orgName)"/>
                </name>
                <xsl:if test="ancestor::tei:TEI//tei:org[@xml:id=$aff]/tei:orgName[@type='acronym']">
                    <name type="acronym">
                        <xsl:value-of select="normalize-space(ancestor::tei:TEI//tei:org[@xml:id=$aff]/tei:orgName[@type='acronym'])"/>
                    </name>
                </xsl:if>
                <!-- récupère un code de structure - *** pas OK : -->
                <xsl:for-each select="/tei:TEI//tei:org[@xml:id=$aff]//tei:listRelation/tei:relation[@name]">
                    <name type="code">
                        <xsl:value-of select="@name"/>
                    </name>
                </xsl:for-each>

                <address>
                    <!-- <xsl:copy-of select="/tei:TEI//tei:org[@xml:id=$aff]//tei:addrLine"/>
                         et <xsl:copy-of select="/tei:TEI//tei:org[@xml:id=$aff]//tei:country"/> m pb xsltproc : xmlns hal-->
                    <xsl:if test="/tei:TEI//tei:org[@xml:id=$aff]//tei:addrLine">
                        <addrLine>
                            <xsl:value-of select="ancestor::tei:TEI//tei:org[@xml:id=$aff]//tei:addrLine"/>
                        </addrLine>
                    </xsl:if>
                    <country>
                        <xsl:attribute name="key">
                            <xsl:value-of select="ancestor::tei:TEI//tei:org[@xml:id=$aff]//tei:country/@key"/>
                        </xsl:attribute>
                    </country>

                </address>
                <idno type="halStructureId">
                    <xsl:value-of select="$aff"/>
                </idno>


                <xsl:for-each select="/tei:TEI//tei:org[@xml:id=$aff]">                    <!-- for-each pour descendre au niveau idno, traité par le call-template avec for-each -->
                    <xsl:call-template name="IDNO"/>
                </xsl:for-each>


            </orgName>


            <xsl:for-each select="/tei:TEI//tei:org[@xml:id=$aff]//tei:relation[@active]">
                <xsl:call-template name="Affiliation">
                    <xsl:with-param name="RelAct" select="substring-after(@active, '#')"/>
                </xsl:call-template>

            </xsl:for-each>
        </affiliation>
    </xsl:template>

    <xsl:template name="Affiliation">
        <xsl:param name="RelAct"/>

        <xsl:for-each select="ancestor::tei:TEI//tei:org[@xml:id=$RelAct]">
            <!-- <xsl:if test="@type='institution'"> -->            <!-- élimine niveaux intermédiaires pour certains, demande A. Coret et D Le Hennaff -->
            <orgName xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="type">
                    <xsl:value-of select="@type"/>
                    <!-- élément de back/listOrg typé avec @type=labo, reseauchteam, institution ... et contenu informationnel -->
                </xsl:attribute>

                <name>
                    <xsl:value-of select="tei:orgName"/>
                </name>
                <xsl:if test="tei:orgName[@type='acronym']">
                    <name type="acronym">
                        <xsl:value-of select="tei:orgName[@type='acronym']"/>
                    </name>
                </xsl:if>
                <!--  <xsl:copy-of select="/*//tei:org[@xml:id=$aff]/tei:desc"/>   -->                <!-- addrLine et country -->

                <idno type="halStructureId">
                    <xsl:value-of select="$RelAct"/>
                </idno>
                <!-- autres : (type RNSR, IdRef, autres?), valeur d'attribut transformée par template IDNO suivant : -->
                <xsl:call-template name="IDNO"/>

            </orgName>
            <!--  </xsl:if> -->

            <xsl:for-each select="ancestor::tei:TEI//tei:org[@xml:id=$RelAct]//tei:relation[@active]">
                <xsl:call-template name="Affiliation">
                    <xsl:with-param name="RelAct" select="substring-after(@active, '#')"/>
                </xsl:call-template>
            </xsl:for-each>

        </xsl:for-each>
    </xsl:template>

    <xsl:template match="tei:biblStruct">

        <analytic xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="tei:analytic/tei:title">
                <title>
                    <xsl:copy-of select="@*"/>
                    <xsl:value-of select="normalize-space(.)"/>
                </title>
            </xsl:for-each>
            <xsl:apply-templates select="tei:analytic/tei:author"/>

            <!-- ajouter les idno de type analytic ici dans V1, y compris halId qui est dans publicationStmt -->
            <xsl:call-template name="IDNO"/>
        </analytic>

        <xsl:apply-templates select="tei:monogr"/>

        <!-- TEI0 (TEI analytic après monogr) : -->
        <idno type="halId" 
            xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:value-of select="//tei:TEI//tei:publicationStmt/tei:idno[@type='halId']"/>
        </idno>
        <xsl:call-template name="IDNO"/>

        <!-- <ref type=’file’ target=’[URL]’/>, URL item et full text -->
        <!-- <xsl:text>ref</xsl:text> -->
        <xsl:for-each select="/tei:TEI//tei:editionStmt//tei:ref">
            <!-- <xsl:element name="{local-name(.)}"> crée xmlns="" -->
            <ref xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of select="@*"/>
                <xsl:if test="date">
                    <date xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:copy-of select="date/@*"/>
                    </date>                    <!-- date fin embargo -->
                </xsl:if>
            </ref>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="tei:monogr">

        <monogr xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="tei:idno">

                <xsl:choose>
                    <xsl:when test="@type='ISSN'">
                        <idno>
                            <xsl:attribute name="type">issn</xsl:attribute>
                            <xsl:value-of select="."/>
                        </idno>
                    </xsl:when>
                    <xsl:when test="@type='ISSNe'">
                        <idno>
                            <xsl:attribute name="type">eissn</xsl:attribute>
                            <xsl:value-of select="."/>
                        </idno>
                    </xsl:when>
                    <xsl:when test="@type='ISBN'">
                        <idno>
                            <xsl:attribute name="type">isbn</xsl:attribute>
                            <xsl:value-of select="."/>
                        </idno>
                    </xsl:when>

                    <xsl:when test="@type='localRef'">
                        <idno>
                            <xsl:attribute name="type">localRef</xsl:attribute>
                            <xsl:value-of select="."/>
                        </idno>
                    </xsl:when>
                    <!-- exemple : mémoire, patent intéressant -->

                    <xsl:when test="@type='halJournalId'"></xsl:when>

                    <xsl:otherwise>                        <!-- corrects source : issn, eissn, isbn notamment -->
                        <!-- <xsl:copy-of select="."/> xmlns hal-->
                        <idno xmlns="http://www.tei-c.org/ns/1.0">
                            <xsl:copy-of select="@*"/>
                            <xsl:value-of select="."/>
                        </idno>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:for-each>

            <!-- qqc comme title est obligatoire pour valider si on a imprint, et on a tj, au moins une date dedans. Or les titres de monogr comme thèses peuvent être dans analytic, on récupère. -->
            <xsl:choose>
                <xsl:when test="tei:title">
                    <xsl:for-each select="tei:title">
                        <xsl:element name="{local-name()}">
                            <xsl:copy-of select="tei:title/@*"/>
                            <xsl:value-of select="tei:title"/>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="../tei:analytic/tei:title">
                    <title xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:copy-of select="../tei:analytic/tei:title/@*"/>
                        <xsl:value-of select="../tei:analytic/tei:title"/>
                    </title>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="{local-name(tei:title)}"/>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:if test="tei:authority[@type='supervisor']">
                <editor role="ths">
                    <persName>
                        <xsl:value-of select="tei:authority[@type='supervisor']"/>
                    </persName>
                    <xsl:if test="tei:idno">
                        <xsl:call-template name="IDNO"/>
                    </xsl:if>
                </editor>
            </xsl:if>
            <xsl:if test="tei:authority[@type='institution']">
                <editor role="dgg">
                    <orgName>
                        <xsl:value-of select="tei:authority[@type='institution']"/>
                    </orgName>
                    <xsl:if test="tei:idno">
                        <xsl:call-template name="IDNO"/>
                    </xsl:if>
                </editor>
            </xsl:if>
            <xsl:if test="tei:authority[@type='school']">
                <editor role="dos">
                    <orgName>
                        <xsl:value-of select="tei:authority[@type='institution']"/>
                    </orgName>
                    <xsl:if test="tei:idno">
                        <xsl:call-template name="IDNO"/>
                    </xsl:if>
                </editor>
            </xsl:if>
            <xsl:if test="tei:editor">
                <editor role="edt">
                    <persName>
                        <xsl:value-of select="tei:authority[@type='supervisor']"/>
                    </persName>
                    <xsl:if test="tei:idno">
                        <xsl:call-template name="IDNO"/>
                    </xsl:if>
                </editor>
            </xsl:if>

            <xsl:if test="tei:meeting">
                <meeting xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:for-each select="tei:meeting/*">
                        <xsl:element name="{local-name()}">
                            <xsl:copy-of select="@*"/>
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:for-each>
                </meeting>
            </xsl:if>

            <xsl:if test="tei:respStmt">                <!-- organisateur meeting, séparé dans HAL -->
                <respStmt xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:for-each select="tei:respStmt/*">
                        <xsl:element name="{local-name()}">
                            <xsl:copy-of select="@*"/>
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:for-each>
                </respStmt>
            </xsl:if>

            <xsl:if test="tei:country">                <!-- sens à voir - pour cartes, brevets, img, cours - idem country -->
                <editor xmlns="http://www.tei-c.org/ns/1.0">
                    <country>
                        <xsl:copy-of select="@*"/>
                        <xsl:value-of select="."/>
                    </country>
                    <xsl:if test="tei:settlement">
                        <settlement>
                            <xsl:copy-of select="@*"/>
                            <xsl:value-of select="."/>
                        </settlement>
                    </xsl:if>
                </editor>
            </xsl:if>
            <!-- date est fréquemment dans imprint (date type=datePub), mais sinon : la récupérer dans date type=whenProduced (24211 en 2014)
            et il ne suffit pas de remettre le xmlns tei dans imprint -->

            <imprint xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:for-each select="tei:imprint/*">
                    <xsl:element name="{local-name()}">
                        <xsl:copy-of select="@*"/>
                        <xsl:value-of select="."/>
                    </xsl:element>
                </xsl:for-each>
                <xsl:if test="not(tei:imprint/tei:date)">
                    <!-- <xsl:copy-of select="/tei:TEI//tei:date[@type='whenProduced']"/> xmlns de hal -->
                    <date type='whenProduced'>
                        <xsl:value-of select="/tei:TEI//tei:date[@type='whenProduced']"/>
                    </date>
                </xsl:if>
            </imprint>
        </monogr>

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
                        <name>
                            <xsl:value-of select="tei:orgName"/>
                        </name>
                        <xsl:copy-of select="tei:desc/*"/>
                        <xsl:copy-of select="tei:date"/>
                        <xsl:if test="@type='anrProject'">
                            <country key="FR">France</country>
                        </xsl:if>
                        <xsl:if test="@type='europeanProject'">
                            <country key="FR">Europe</country>
                        </xsl:if>
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
                            <xsl:value-of select="@n"/>
                        </classCode>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </textClass>
        <xsl:copy-of select="tei:abstract"/>
    </xsl:template>

    <xsl:template name="IDNO">
        <xsl:for-each select="tei:idno">
            <!-- traite :
            - ceux dont le nom d'attribut est à transformer, 
            - ceux qu'on croise et qui ont la bonne forme mais xsltproc ajoute xmlns=hal... 
            - ceux qu'on ne garde pas
            - puis otherwise pour les autres, en évitant le xmlns hal ; à suivre -->
            <xsl:choose>
                <!-- *** auteurs -->
                <xsl:when test="@type='halauthorid'">
                    <idno type="halAuthorId" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>
                <xsl:when test="type='idRef'">
                    <idno type="idRef" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>
                <!-- modèle HAL_API : type=http://www.idref.fr/ -->
                <xsl:when test="contains(@type, 'idref')">
                    <idno type="idRef" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>
                <xsl:when test="@type='IdRef'">
                    <idno type="idRef" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>

                <xsl:when test="@type='ORCID'">
                    <idno type="orcid" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>
                <xsl:when test="@type='VIAF'">
                    <idno type="viaf" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>
                <xsl:when test="@type='ISNI'">
                    <idno type="isni" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>

                <xsl:when test="@type='1'">
                    <idno type="arxiv" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>
                <xsl:when test="@type='10'">
                    <idno type="viaf" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>
                <xsl:when test="@type='11'">
                    <idno type="isni" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>
                <xsl:when test="@type='2'">
                    <idno type="researcherId" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>
                <xsl:when test="@type='3'">
                    <idno type="idRef" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>
                <xsl:when test="@type='4'">
                    <idno type="orcid" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>

                <xsl:when test="@type='ResearcherId'">
                    <idno type="researcherId" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>
                <xsl:when test="@type='idhal'">
                    <idno type="idHal" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <!-- <xsl:attribute name="subtype"><xsl:value-of select="@notation"/></xsl:attribute> -->
                        <xsl:copy-of select="@*"/>
                        <xsl:value-of select="."/>
                    </idno>
                    <!-- *** @notation a été ajouté par LR dans odd. Sinon :attribut incorrect schéma odd. Peut être remplacé par subtype. -->
                </xsl:when>

                <xsl:when test="@type='arXiv'">
                    <idno type="arxiv" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>

                <!-- *** structures : -->
                <xsl:when test="@type='halStructureId'">
                    <xsl:copy-of select="."/>
                </xsl:when>                <!-- copy-of ne remet pas xmlns hal -->
                <xsl:when test="@type='RNSR'">
                    <idno type="rnsr" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>
                <xsl:when test="@type='IdUnivLorraine'">
                    <idno type="IdUnivLorraine" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>

                <!-- *** documents : -->
                <xsl:when test="@type='artNumber'">
                    <idno type="artNo" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>

                <xsl:when test="@type='doi'">
                    <idno type="doi" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>
                <xsl:when test="@type='DOI'">
                    <idno type="doi" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>
                <xsl:when test="@type='halId'">
                    <idno type="halId" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>


                <!-- (inutile qd on enlève otherwise, mais à suivre après tests -->
                <xsl:when test="@type='anr'">
                    <idno type="anr" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>
                <xsl:when test="@type='programme'">
                    <idno type="programme" 
                        xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:value-of select="."/>
                    </idno>
                </xsl:when>

                <!-- ceux à éliminer : -->
                <!-- <xsl:when test="@type='localRef'"/> à discuter, exemple : WO2014146673.pdf pour brevet -->
                <xsl:when test="@type='halJournalId'"/>
                <!-- plus : @type=stamp dans seriesStmt, elt non récupéré par XSL -->

                <xsl:otherwise>                    <!-- patentNumber ... -->
                    <!-- <xsl:copy-of select="."/> xmlns hal -->
                    <idno xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:copy-of select="@*"/>
                        <xsl:value-of select="normalize-space(.)"/>
                    </idno>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>

    </xsl:template>
</xsl:stylesheet>