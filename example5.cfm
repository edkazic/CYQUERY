<cfimport taglib="TAGS" prefix="CY">

<!---This time properties parsing functions are stored in the library and can be just included in the page---->
<cfinclude template="TAGS/GetData.cfm">

<!---In this example we will demonstrate linked tables feature in Query of Query
We will use two CY:QUERY and then link them through the common relation---->

<!---Get data for nodes that have "outgoing" (a)-->() relation defined---->

<CY:QUERY name="CYNodesOut">
//Match all nodes and relations
MATCH (a)-[r]->()
RETURN
id(a) 		AS NodeID,
labels(a) 	AS NodeLabel,
a 			AS NodeProperty,
id(r) 		AS RelationID,
type(r) 	AS RelationType,
r 			AS RelationProperty,
a.born      AS Born
LIMIT 1000
</CY:QUERY>

<cfif CYErrors NEQ "">
	<CFOUTPUT>#CYErrors#</CFOUTPUT>
	<CFABORT>
</cfif>


<!---Get data for nodes that have "incoming" (a)<--() relation defined---->

<CY:QUERY name="CYNodesIn">
//Match all nodes and relations
MATCH (a)<-[r]-()
RETURN
id(a) 		AS NodeID,
labels(a) 	AS NodeLabel,
a 			AS NodeProperty,
id(r) 		AS RelationID,
type(r) 	AS RelationType,
r 			AS RelationProperty
LIMIT 1000
</CY:QUERY>

<cfif CYErrors NEQ "">
	<CFOUTPUT>#CYErrors#</CFOUTPUT>
	<CFABORT>
</cfif>


<!---Create CF Query where two retrieved CY:QUERY sets (CYNodesOut and CYNodesIn) are linked by RelationID and sort resulting set by the age of the actor--->
<CFQUERY name="DumpAll" dbtype = "query">
SELECT CYNodesOut.NodeID    AS Node1ID,
CYNodesOut.NodeLabel 	    AS Node1Label,
CYNodesOut.NodeProperty	    AS Node1Property,
CYNodesOut.RelationID	    AS RelationID,
CYNodesOut.RelationType	    AS RelationType,
CYNodesOut.RelationProperty	AS RelationProperty,
CYNodesIn.NodeID 		    AS Node2ID,
CYNodesIn.NodeLabel 	    AS Node2Label,
CYNodesIn.NodeProperty	    AS Node2Property,
lower(CYNodesOut.Born)      AS Born
FROM CYNodesOut, CYNodesIn
WHERE CYNodesOut.RelationID=CYNodesIn.RelationID
ORDER BY Born DESC
</CFQUERY>


<CFOUTPUT>
<!---Display data in the table---->
<table border=1>

<!---Create header for the table--->
<tr>
<td>Node1ID</td><td>Node1Label</td><td>Node1Property</td><td>RelationID</td><td>RelationType</td><td>RelationProperty</td><td>Node2ID</td><td>Node2Label</td><td>Node2Property</td>
</tr>

<!---Loop through the records and for each record create a table row with columns---->
<CFLOOP query="DumpAll">
<tr>
<!---Node1ID--->
<td>#getID(DumpAll.Node1ID)#</td>

<!---Node1Label--->
<td>#getLabel(DumpAll.Node1Label)#</td>

<!---Node1Property--->
<td>#getProperty(DumpAll.Node1Property)#</td>

<!---RelationID--->
<td>#getID(DumpAll.RelationID)#</td>

<!---RelationType--->
<td>#getString(DumpAll.RelationType)#</td>

<!---RelationProperty--->
<td>#getProperty(DumpAll.RelationProperty)#</td>

<!---Node2ID--->
<td>#getID(DumpAll.Node2ID)#</td>

<!---Node2Label--->
<td>#getLabel(DumpAll.Node2Label)#</td>

<!---Node2Property--->
<td>#getProperty(Node2Property)#</td>

</tr>
</CFLOOP>
</table>
</CFOUTPUT>




