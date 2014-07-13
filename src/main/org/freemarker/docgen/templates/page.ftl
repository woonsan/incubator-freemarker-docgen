[#ftl ns_prefixes={"D":"http://docbook.org/ns/docbook"}]
[#-- Avoid inital empty line! --]
[#import "util.ftl" as u]
[#import "navigation.ftl" as nav]
[#import "node-handlers.ftl" as defaultNodeHandlers]
[#import "customizations.ftl" as customizations]
[#set nodeHandlers = [customizations, defaultNodeHandlers]]
[#-- Avoid inital empty line! --]
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <link rel="stylesheet" href="docgen-resources/docgen.css" type="text/css">
  <meta name="generator" content="FreeMarker Docgen (DocBook 5)">
  <title>
    [#set titleElement = u.getRequiredTitleElement(.node)]
    [#set title = u.titleToString(titleElement)]
    [#set topLevelTitle = u.getRequiredTitleAsString(.node?root.*)]
    ${topLevelTitle?html}[#if title != topLevelTitle] - ${title?html}[/#if]
  </title>
  [#if !disableJavaScript]
    <script type="text/javascript" src="docgen-resources/jquery.js"></script>
    <script type="text/javascript" src="docgen-resources/linktargetmarker.js"></script>
  [/#if]
</head>
<body>

[@nav.navigationBar top=true /]

<div id="mainContent">
  [#var pageType = pageType!.node?node_name]

  [#if pageType == "index" || pageType == "glossary"]
    [#visit .node using nodeHandlers]
  [#elseif pageType == "docgen:detailed_toc"]
    [@toc att="docgen_detailed_toc_element" maxDepth=99 title="Detailed Table of Contents" /]
  [#else]
    [#-- Normal page content: --]

    [#-- - Render page title: --]
    [#visit titleElement using nodeHandlers]
    
    [#-- - Render either ToF (Table of Files) or Page ToC; --]
    [#--   both is called, but at least one of them will be empty: --]
    [@toc att="docgen_file_element" maxDepth=maxTOFDisplayDepth /]
    [@toc att="docgen_page_toc_element" maxDepth=99 title="Page Contents" minLength=2 /]
    
    [#-- - Render the usual content, like <para>-s etc.: --]
    [#list .node.* as child]
      [#if child.@docgen_file_element?size == 0
          && child?node_name != "title"
          && child?node_name != "subtitle"]
        [#visit child using nodeHandlers]
      [/#if]
    [/#list]
  [/#if]
  
  [#-- Render footnotes, if any: --]
  [#set footnotes = defaultNodeHandlers.footnotes]
  [#if footnotes?size != 0]
    <div id="footnotes">
      Footnotes:
      <ol>
        [#list footnotes as footnote]
          <li><a name="autoid_footnote_${footnote_index + 1}"></a>${footnote}</li>
        [/#list]
      </ol>
    </div>
  [/#if]
</div>

[@nav.navigationBar top=false /]

<table border=0 cellspacing=0 cellpadding=0 width="100%">
  [#set pageGenTimeHTML = "HTML generated: ${transformStartTime?string('yyyy-MM-dd HH:mm:ss z')?html}"]
  [#set footerTitleHTML = topLevelTitle?html]
  [#set bookSubtitle = u.getOptionalSubtitleAsString(.node?root.book)]
  [#if bookSubtitle??]
    [#set footerTitleHTML = footerTitleHTML + " -- " + bookSubtitle?html]
  [/#if]
  [#if !showXXELogo]
    <tr>
      <td colspan=2><img src="docgen-resources/img/none.gif" width=1 height=4 alt=""></td>
    <tr>
      <td align="left" valign="top"><span class="footer">
          ${footerTitleHTML}
      </span></td>
      <td align="right" valign="top"><span class="footer">
          ${pageGenTimeHTML}
      </span></td>
    </tr>
  [#else]
    <tr>
      <td colspan=2><img src="docgen-resources/img/none.gif" width=1 height=8 alt=""></td>
    <tr>
      <td align="left" valign="top"><span class="smallFooter">
          [#if footerTitleHTML != ""]
            ${footerTitleHTML}
            <br>
          [/#if]
          ${pageGenTimeHTML}
      </span></td>
      <td align="right" valign="top"><span class="smallFooter">
          <a href="http://www.xmlmind.com/xmleditor/">
            <img src="docgen-resources/img/xxe.gif" alt="Edited with XMLMind XML Editor">
          </a>
      </span></td>
    </tr>
  [/#if]
</table>
[#if !disableJavaScript]
  <!-- Put pre-loaded images here: -->
  <div style="display: none">
    <img src="docgen-resources/img/linktargetmarker.gif" alt="Here!" />
  </div>
[/#if]
</body>
</html>

[#macro toc att maxDepth title=null minLength=1]
  [#set tocElems = .node["*[@${att}]"]]
  [#if tocElems?size >= minLength]
    <div class="toc">
      <p>
        <b>
          [#if !title??]
            [#if .node?parent?node_type == "document"]
              Table of Contents
            [#else]
              ${pageType?cap_first} Contents
            [/#if]
          [#else]
            ${title}
          [/#if]
        </b>
        [#if alternativeTOCLink??]
          &nbsp;&nbsp;[#t]
          <font size="-1">[[#t]
          <a href="${alternativeTOCLink?html}">[#t]
            ${alternativeTOCLabel?cap_first?html}...[#t]
          </a>[#t]
          ]</font>[#t]
        [/#if]
      </p>
      
      [@toc_inner tocElems att maxDepth /]
    </div>
    <a name="docgen_afterTheTOC"></a>
  [/#if]
[/#macro]

[#macro toc_inner tocElems att maxDepth curDepth=1]
  [#if tocElems?size == 0][#return][/#if]
  <ul [#if curDepth == 1]class="noMargin"[/#if]>
    [#if curDepth==1 && startsWithTopLevelContent]
      <li style="padding-bottom: 0.5em"><i><a href="#docgen_afterTheTOC">Intro.</a></i></li>
    [/#if]
    [#list tocElems as tocElem]
      <li>
        ${u.getTitlePrefix(tocElem, true)?html}[#rt]
        <a href="${CreateLinkFromID(tocElem.@id)?html}">[#t]
          [#recurse u.getRequiredTitleElement(tocElem) using nodeHandlers][#t]
        </a>[#lt]
        [#if curDepth < maxDepth]
          [@toc_inner tocElem["*[@${att}]"], att, maxDepth, curDepth + 1 /]
        [/#if]
      </li>
    [/#list]
  </ul>
[/#macro]