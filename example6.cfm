<cfimport taglib="TAGS" prefix="CY">

<!--- In this example we will create nodes (with property) and relations (with property) between them to form a closed chain--->
<cfset DeleteAll=false>

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




<!----The following CY:QUERY will create nodeNo number of nodes with properties and relations between them forming closed chain--------->
<!----The CY:QUERY is created dynamically using ColdFusion LOOP---->

<cfset nodeNo=100><!---As of writing of this example Neo4j 2.0.1 is failing if there are more than 1800 nodes and 1800 relations together in one CY:QUERY ???---->
<cfset nodeStart=1>

<CFOUTPUT>
<CY:QUERY name="nodes">
	CREATE (node#nodeStart#:Node {name:'node#nodeStart#'}) 				//Create first innitial node
	<CFLOOP index="x" from="#evaluate(nodeStart+1)#" to="#nodeNo#">  					//Create Nodes and Relations nodeNo-1 times
		CREATE (node#Evaluate(x-1)#)-[:LINKED_TO {Relation: 'link#Evaluate(x-1)#'}]->(node#x#:Node {name:'node#x#'})
	</CFLOOP>
	CREATE (node#nodeNo#)-[:LINKED_TO {Relation:'link#nodeNo#'}]->(node#NodeStart#)		//Create last node relation to close the chain with the first node
</CY:QUERY>
</CFOUTPUT>

<cfif CYErrors NEQ "">
	<CFOUTPUT>#CYErrors#</CFOUTPUT>
	<CFABORT>
</cfif>
	<CFOUTPUT>Create Time: #CYExecutionTime# sec<BR></CFOUTPUT><!---Display time required to execute the CY:QUERY--->



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

