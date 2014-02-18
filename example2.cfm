<cfimport taglib="./TAGS" prefix="CY">



<!---Get ALL data from the database---->
<!---if returnFormat is not defined the returning set is ColdFusion object---->

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
The returned ColdFusion Object is conforming standard ColdFusion query structure.
In addition the variables CYErrors and CYExecutionTime are available immediatly after CY:QUERY execution.

The ColdFusion object is named using the "name" variable from the CY:QUERY and the object is returned as a table of records and columns.
Specifically the Cold Fusion Object is built on results[1].data[records].row[columns] JSON matrix.

Access to each property value in the CF result set is achieved using standard CF syntax "queryname.columnname".

Looping through reords can be done eg using <CFLOOP query="queryName">
and accessing columns is done by referencing queryName.Column1, queryName.column2 etc.

CF Query variables are also available:
- queryName.ColumnList
- queryName.RecordCount
- queryName.CurrentRow (eg within the LOOP)

In addition Query of Query can be used on the record set for aditional data processing using standard SQL.

Resulting value for each "cell" can be complex structure and it is dependent on the Cypher request as follows:

ReturnValueType ExampleReturnNames	ValueStructure
--------------- ------------------- ----------------------
id(node) 		NodeID				int
labels(node) 	NodeLabel			array of labels
node 			NodeProperty		structure of properties (a propery can be single or an array of values)
id(relation) 	RelationID			int
type(relation) 	RelationType		string
relation 		RelationProperty	structure of properties (a propery can be single or an array of values)
path 			Path				array of structures: first node structure of properties,
											  			 relation structure of properties and
											  			 second node structure of properties


--->
