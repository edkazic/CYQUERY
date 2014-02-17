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


<CFOUTPUT>
<!---Display data in the table---->
<table border=1>

<!---Create header for the table--->
<tr>
<TD>Node1ID</TD><TD>Node1Label</TD><TD>Node1Property</TD><TD>RelationID</TD><TD>RelationType</TD><TD>RelationProperty</TD><TD>Node2ID</TD><TD>Node2Label</TD><TD>Node2Property</TD>

<!----We could use something like:
<CFLOOP list="#DumpAll.ColumnList#" index="token">
<TD>#token#</TD>
</CFLOOP>
This would dump all column titles for the table header but then wa would not be sure in which order column titles will come?
Also we want to skip "path" column for this example so it is appropriate to make the table header manually.
---->
</tr>


<!---Loop through the records and for each record create a table row with columns---->
<CFLOOP query="DumpAll">
<tr>

<!---Node1ID--->
<td>#DumpAll.Node1ID#</td>

<!---Node1Label--->
<td>
<CFIF IsJSON(DumpAll.Node1Label)>
<CFSET data=#deserializeJSON(DumpAll.Node1Label)#>
	<CFIF IsArray(data)>
		<CFLOOP array="#data#" index="token">
			#token#<br>
		</CFLOOP>
	</CFIF>
</CFIF>
</td>

<!---Node1Property--->
<!---
Structure of propertie values (either node or relation) returned from Cypher query can be formated as simple value or Array
Here is an example of relation property "role" that is defined as array of values (note squre brackets after role:)
CREATE
  (TomH)-[:ACTED_IN {roles:['Hero Boy', 'Father', 'Conductor', 'Hobo', 'Scrooge', 'Santa Claus']}]->(ThePolarExpress),
And here is an example of node property defined as structure of "summary" and "rating" simple value properties
CREATE
  (JessicaThompson)-[:REVIEWED {summary:'An amazing journey', rating:95}]->(CloudAtlas),
It is required to check for the return type for nodes and relations properties.
--->
<td>
<CFIF IsJSON(DumpAll.Node1Property)>
<CFSET data=#deserializeJSON(DumpAll.Node1Property)#>
	<CFIF IsStruct(data)>
		<CFLOOP list="#structKeyList(data)#" index="token">
			<CFIF IsArray(Evaluate("data.#token#"))><!---check if properties are in array--->
				<CFLOOP array="#Evaluate("data.#token#")#" index="token2"><!---Loop through the array--->
					#token#: #token2#<br>
				</CFLOOP>
			<CFELSE>  <!---simple value--->
					#token#: #Evaluate("data.#token#")#<br>
			</CFIF>
		</CFLOOP>
	</CFIF>
</CFIF>
</td>

<!---RelationID--->
<td>#DumpAll.RelationID#</td>

<!---RelationType--->
<CFIF IsJSON(DumpAll.RelationType)>
	<CFSET data=#deserializeJSON(DumpAll.RelationType)#>
<CFELSE>
	<CFSET data=""><!---Relation Type is not defined--->
</CFIF>
<td>#data#</td>

<!---RelationProperty--->
<td>
<CFIF IsJSON(DumpAll.RelationProperty)>
<CFSET data=#deserializeJSON(DumpAll.RelationProperty)#>
	<CFIF IsStruct(data)>
		<CFLOOP list="#structKeyList(data)#" index="token">
			<CFIF IsArray(Evaluate("data.#token#"))>
				<CFLOOP array="#Evaluate("data.#token#")#" index="token2">
					#token#: #token2#<br>
				</CFLOOP>
			<CFELSE>
					#token#: #Evaluate("data.#token#")#<br>
			</CFIF>
		</CFLOOP>
	</CFIF>
</CFIF>
</td>

<!---Node2ID--->
<td>#DumpAll.Node2ID#</td>

<!---Node2Label--->
<td>
<CFIF IsJSON(DumpAll.Node2Label)>
<CFSET data=#deserializeJSON(DumpAll.Node2Label)#>
	<CFIF IsArray(data)>
		<CFLOOP array="#data#" index="token">
			#token#<br>
		</CFLOOP>
	</CFIF>
</CFIF>
</td>

<!---Node2Property--->
<td>
<CFIF IsJSON(DumpAll.Node2Property)>
<CFSET data=#deserializeJSON(DumpAll.Node2Property)#>
	<CFIF IsStruct(data)>
		<CFLOOP list="#structKeyList(data)#" index="token">
			<CFIF IsArray(Evaluate("data.#token#"))>
				<CFLOOP array="#Evaluate("data.#token#")#" index="token2">
					#token#: #token2#<br>
				</CFLOOP>
			<CFELSE>
					#token#: #Evaluate("data.#token#")#<br>
			</CFIF>
		</CFLOOP>
	</CFIF>
</CFIF>
</td>











</tr>
</CFLOOP>
</table>
</CFOUTPUT>

<!---
In this example we can see how we can parse different return types and extract information.

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




