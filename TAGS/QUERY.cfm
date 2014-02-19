<!------------------------------------------------------------------------

CY:QUERY

ColdFusion tag implementation for Cypher (Neo4j DB)

Usage:
- Include <cfimport taglib="./TAGS" prefix="CY"> line in your Cold Fusion source page
- Save this file in the directory TAGS within your project and name it QUERY.CFM
- Use CY:QUERY with Cypher same way as you would use CFQUERY with SQL eg:

    <CY:QUERY name="GetNodes">
	  MATCH (n)
	  RETURN n
	  LIMIT 100
    </CY:QUERY>

- The query will return object GetNodes (attribute name) that is formated as Cold Fusion CFQUERY object
- Use returnFormat="JSON" (eg. <CY:QUERY name="GetNodes" returnFormat="JSON">)
  if you would like to return JSON object instead of CF query object
- Variable CYErrors will be returned with any errors or it will be empty for no errors
- Variable CYExecutionTime contains time in seconds
- If required change Connection URLDB below for different Neo4j server location

Author: Ed Kazic
Radmis Pty Ltd, www.radmis.com

14/02/2014 Version 1.0 innitial release

-------------------------------------------------------------------------->

<cfsetting enablecfoutputonly="No" showdebugoutput="Yes" requesttimeout="600000">

<!-----Execute at the end of CY:QUERY tag----------------------------------------------->
<cfif thisTag.ExecutionMode is 'end'>

<cfset Caller.CYExecutionTime="">
<cfset tickStart=GetTickCount()>
<CFTRY>
	   <!---Check for compulsory parameter---->
<cfif IsDefined("Attributes.name")>

	   <!-----Connection URL-------->
<cfset URLDB="http://localhost:7474/db/data/transaction/commit">
<cfset cyQuery="">
<cfset Caller.CYErrors="">

		<!---------Test Call to check health of Neo4j DB---------------->
	<CFTRY>
		<cfhttp url="#URLDB#" method="post" result="httpResp" timeout="10" >
		    <cfhttpparam type="HEADER" name="Content-Type" value="application/json; charset=UTF-8">
	    	<cfhttpparam type="body" value=#serializeJSON({"statements":[{"statement":"MATCH (n) RETURN n LIMIT 1"}]})#>
		</cfhttp>
		<!--------Get DB response---------------->
	 	<cfset jsonData = deserializeJSON(httpResp.fileContent) />
	 	<cfset Caller.CYErrors = serializeJSON(jsonData.errors) />
	 	<cfif Caller.CYErrors EQ "[]"><cfset Caller.CYErrors = ""></cfif>
		<CFCATCH><cfset Caller.CYErrors = "ERROR: No communication with Neo4j? <br>Check if Neo4j DB is active and if connection details are correct!"></CFCATCH>
	</CFTRY>


	<cfif Caller.CYErrors EQ "">
		<!-----Build CY:QUERY statement-------->
        <cfset stFields = {"statements":[{"statement":"#thisTag.GeneratedContent#"}]}>
		<cfset cyQuery='#Attributes.name#'>
        <cfset "Caller.#cyQuery#"="">

		<!---------Call Neo4j DB---------------->
		<cftry>
		<cfhttp url="#URLDB#" method="post" result="httpResp" timeout="600000" >
		    <cfhttpparam type="HEADER" name="Content-Type" value="application/json; charset=UTF-8">
	    	<cfhttpparam type="body" value="#serializeJSON(stFields)#">
		</cfhttp>

		<!--------Get DB response---------------->
	 	<cfset jsonData = deserializeJSON(httpResp.fileContent) />
	 	<cfset Caller.CYErrors = serializeJSON(jsonData.errors) />
	 	<cfif Caller.CYErrors EQ "[]"><cfset Caller.CYErrors = ""></cfif>

		<cfcatch><cfset Caller.CYErrors='ERROR: Neo4j Server problem? '></cfcatch>
		</cftry>
	</cfif>

	<cfif Caller.CYErrors NEQ "" AND isDefined("jsonData.Errors")>
		<!--------Parse Error Message------------>
		<cfset err=jsonData.Errors>
		<cfset err1=err[1].message>
		<cfset poz2=Len(err1)-Find('"',reverse(err1),1)>  	<!---find last--->
		<cfset poz1=Len(err1)-Find('"',reverse(err1),Len(err1)-poz2+1)>
		<cfset poz3=Find('column',err1,1)>
		<cfset rpoz=Val(Mid(err1,poz3+7,10))>
		<cfif poz1 NEQ -1 AND poz2 NEQ -1 AND poz3 NEQ -1 AND rpoz NEQ 0>
			<cfset err2=Mid(err1,1,poz1)>
			<cfset err3=Mid(err1,poz1+2,poz2-poz1-1)>
			<cfset err5=Mid(err3,1,rpoz-1)>
			<cfset err6=Mid(err3,rpoz-0,Len(err3)-rpoz)>
	 		<cfset Caller.CYErrors="#err[1].code#<br>#err2#<BR>...<br>#err5#<FONT COLOR=RED>#err6#</FONT><br>...">
		<cfelse>
	 		<cfset Caller.CYErrors="#err[1].code#<br>#err[1].message#">
		</cfif>
	</cfif>

	<!-----If type is JSON, just return whole structure and  dont process further------------->
	<cfif IsDefined("Attributes.returnFormat") AND Attributes.returnFormat EQ "JSON">
		 <cfset "Caller.#cyQuery#"=jsonData>
	<cfelse>

		<cfif Caller.CYErrors EQ "" and not ArrayIsEmpty(jsonData.results)>
			<!-----Create a query set (using results from Neo4j) that would be returned back---->

			<cfset ColumnsLen=ArrayLen(jsonData.results[1].columns)>
			<cfset Columns=jsonData.results[1].columns>
			<cfset RecordsLen=ArrayLen(jsonData.results[1].data)>
			<cfset Records=jsonData.results[1].data>

			<!-----if there are records to process continue------------>
			<cfif RecordsLen GT 0>
				<cfset col="">
				<cfset typ="">
				<cfloop index="x" from="1" to="#ColumnsLen#">
					<cfset col=col&#REreplace(Columns[x], "[^a-zA-Z0-9]","_","all")#&",">
					<cfset typ=typ&"VarChar"&",">
				</cfloop>
				<cfset col=Left(col,Len(col)-1)>
				<cfset typ=Left(typ,Len(typ)-1)>
				<cfset retQuery = QueryNew("#col#", "#typ#")>

				<!-----Build Query set for return--------->
				<cfloop index="y" from="1" to="#RecordsLen#">
				<cfset newRow = QueryAddRow(retQuery, 1)>
					<cfloop index="x" from="1" to="#ColumnsLen#">
						<cfset tmpCol="">
							<cftry>
								<cfif IsArray("#Records[y].row[x]#") OR IsStruct("#Records[y].row[x]#")>
									<cfset tmpCol=#serializeJSON(Records[y].row[x])#>
								<cfelse>
									<cfset tmpCol=#Records[y].row[x]#>
								</cfif>
							<cfcatch><cfset tmpCol=""></cfcatch>
							</cftry>

						<cfset temp = QuerySetCell(retQuery,"#REreplace(Columns[x], "[^a-zA-Z0-9]","_","all")#","#tmpCol#")>
					</cfloop>
				</cfloop>

				<cfset "Caller.#cyQuery#"=retQuery>
			</cfif>
		</cfif>
	 </cfif>

<cfelse>
	<cfset Caller.CYErrors='ERROR: Query name is compulsory? eg. <CY:QUERY name="qname">...</CY:QUERY> '>
</cfif>


<CFCATCH><cfset Caller.CYErrors='ERROR: Unknown Processing Error?'></CFCATCH>
</CFTRY>
<CFSET tickEnd=GetTickCount()>
<cfset Caller.CYExecutionTime=(tickEnd-tickStart)/1000>
<cfset thisTag.GeneratedContent=""> <!---Remove the content within QUERY TAG---->

</cfif>




