<cfimport taglib="./TAGS" prefix="CY">



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
LIMIT 1000

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
LIMIT 1000
</CY:QUERY>

<CFIF CYErrors NEQ "">
	<CFOUTPUT>#CYErrors#</CFOUTPUT>
	<CFABORT>
</CFIF>

<!---Display entire movies data object as Cold Fusion Object---->
<CFDUMP var="#DumpAll#">


<!---
The returned JSON Object is orgnised in complex combination of structures and arrays.
The Cold Fusion Object is returned as a results[1].data[].column[] array of rows each representing set of columns from the result Cyper records.
Column List can be retrieved as results[1].columns[] array


id(node) 		NodeID				int
labels(node) 	NodeLabel			array of labels
node 			NodeProperty		structure of properties
id(relation) 	RelationID			int
type(relation) 	RelationType		string
relation 		RelationProperty	structure of properties
path 			Path				array of: first node properties structure,
											  relation properties structure and
											  second node properties structure
--->
