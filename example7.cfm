<cfimport taglib="TAGS" prefix="CY">

<!--- In this example we will create nodes (with property) using Cypher querying with parameters--->
<cfset DeleteAll=true>

<!---If "DeleteAll" variable above is set to "true" this CY:QUERY would delete ALL nodes and ALL relations in your Neo4j DB------>
<cfif DeleteAll>
	<CY:QUERY name="DeleteAll">
		MATCH (n)
		OPTIONAL MATCH (n-[r]-())
		DELETE n,r
	</CY:QUERY>

	<cfif CYErrors NEQ "">
		<CFOUTPUT>#CYErrors#</CFOUTPUT>
		<CFABORT>
	</cfif>
	<CFOUTPUT>DeleteTime: #CYExecutionTime# sec<BR></CFOUTPUT><!---Display Execution time required to delete DB set--->
</cfif>


<CFOUTPUT>
<CY:QUERY name="nodes" returnFormat="xJSON">
"CREATE (n:Person { props } ) RETURN n",
  "parameters" : {
    "props" : [ {
      "name" : "Name1",
      "position" : "Position1"
    }, {
      "name" : "Name2",
      "position" : "Position2"
    } ]
  }
</CY:QUERY>

<cfif CYErrors NEQ "">
	<CFOUTPUT>#CYErrors#</CFOUTPUT>
	<CFABORT>
</cfif>
<CFOUTPUT>Create 2 nodes Time: #CYExecutionTime# sec<BR></CFOUTPUT>



<cfset nodeNo=1000>

<!----The following CY:QUERY will create nodeNo-2 number of nodes with parametrizied nodes properties---->

<cfset cfprops="">
<cfloop index="x" from="3" to="#nodeNo#"> <!---Create parameters list---->
	<cfset cfprops=cfprops&'{
	"name":"Name#x#",
	"position":"Position#x#"
	},'>
</cfloop>
<cfset cfprops=left(cfprops,len(cfprops)-1)> <!---remove last comma--->

<CY:QUERY name="nodes"> <!---create nodes--->
"CREATE (n:Person { props } )",

    "parameters" : 	{
    "props" : [ #cfprops# ]
  					}
</CY:QUERY>
</CFOUTPUT>

<cfif CYErrors NEQ "">
	<CFOUTPUT>#CYErrors#</CFOUTPUT>
	<CFABORT>
</cfif>
	<CFOUTPUT>Create #evaluate(nodeNo-2)# nodes time: #CYExecutionTime# sec<BR></CFOUTPUT><!---Display time required to execute the CY:QUERY--->



<!---Get ALL data from the database---->

<CY:QUERY name="DumpAll">
//Match all nodes and relations
MATCH p=(a)-[r]->(b)
RETURN
id(a) 		AS Node1ID,
labels(a) 	AS Node1Label,
a 			AS Node1Property,
id(r) 		AS RelationID,
type(r) 	AS RelationType,
r 			AS RelationProperty,
id(b) 		AS Node2ID,
labels(b) 	AS Node2Label,
b 			AS Node2Property,
p 			AS Path
LIMIT 10000

//////////////////////////////////////
UNION
//////////////////////////////////////

//Match all nodes with no relations
MATCH (n) where not( n--() )
RETURN
id(n) 		AS Node1ID,
labels(n) 	AS Node1Label,
n 			AS Node1Property,
null 		AS RelationID,
null 		AS RelationType,
null 		AS RelationProperty,
null 		AS Node2ID,
null 		AS Node2Label,
null 		AS Node2Property,
null 		AS Path
LIMIT 10000
</CY:QUERY>

<cfif CYErrors NEQ "">
	<CFOUTPUT>#CYErrors#</CFOUTPUT>
	<CFABORT>
</cfif>
<CFOUTPUT>Retrieve Time: #CYExecutionTime# sec<BR></CFOUTPUT>

<!---Save entire DB data object in the variable so that display preparation time can be measured---->
<cfset tickStart=GetTickCount()>
	<CFSAVECONTENT variable="table">
		<CFDUMP var="#DumpAll#">
	</CFSAVECONTENT>
<cfset tickEnd=GetTickCount()>

<CFOUTPUT>Display Preparation Time: #Evaluate((tickEnd-tickStart)/1000)# sec<BR></CFOUTPUT>

<CFOUTPUT>#table#</CFOUTPUT>

