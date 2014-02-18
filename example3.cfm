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

<cfif CYErrors NEQ "">
	<CFOUTPUT>#CYErrors#</CFOUTPUT>
	<CFABORT>
</cfif>


<CFOUTPUT>
<!---Parse returned data and display in the standard HTML table---->
<table border=1>

<!---Create header for the table--->
<tr>
<!----To create the header we could use something like:
<cfloop list="#DumpAll.ColumnList#" index="token">
<td>#token#</td>
</cfloop>
This would dump all column titles for the table header but then we would not be sure in which order column titles will come?
Also we want to skip "path" column for this example so it is appropriate to make the table header manually.
---->

<td>Node1ID</td><td>Node1Label</td><td>Node1Property</td><td>RelationID</td><td>RelationType</td><td>RelationProperty</td><td>Node2ID</td><td>Node2Label</td><td>Node2Property</td>
</tr>


<!---Loop through the CY:QUERY records and for each record create a table row with columns---->
<cfloop query="DumpAll">
<tr>

<!---Node1ID--->
<td>#DumpAll.Node1ID#</td>

<!---Node1Label--->
<td>
<cfif IsJSON(DumpAll.Node1Label)>
<cfset data=#deserializeJSON(DumpAll.Node1Label)#>
	<cfif IsArray(data)>
		<cfloop array="#data#" index="token">
			#token#<br>
		</cfloop>
	</cfif>
</cfif>
</td>

<!---Node1Property--->
<!---
Structure of propertie values (either node or relation) returned from Cypher query can be formated as simple value or as an Array
Here is an example of relation property "role" that is defined as array of values (note squre brackets after role:)

CREATE
  (TomH)-[:ACTED_IN {roles:['Hero Boy', 'Father', 'Conductor', 'Hobo', 'Scrooge', 'Santa Claus']}]->(ThePolarExpress),

And here is an example of node property defined as structure of "summary" and "rating" with simple value properties

CREATE
  (JessicaThompson)-[:REVIEWED {summary:'An amazing journey', rating:95}]->(CloudAtlas),

To properly extract data it is required to check for the return type for nodes and relations properties.
--->
<td>
<cfif IsJSON(DumpAll.Node1Property)>
<cfset data=#deserializeJSON(DumpAll.Node1Property)#>
	<cfif IsStruct(data)>
		<cfloop list="#structKeyList(data)#" index="token">
			<cfif IsArray(Evaluate("data.#token#"))><!---check if properties are in array form--->
				<cfloop array="#Evaluate("data.#token#")#" index="token2"><!---Loop through the array--->
					#token#: #token2#<br>
				</cfloop>
			<cfelse>  <!---simple value--->
					#token#: #Evaluate("data.#token#")#<br>
			</cfif>
		</cfloop>
	</cfif>
</cfif>
</td>

<!---RelationID--->
<td>#DumpAll.RelationID#</td>

<!---RelationType--->
<td>#DumpAll.RelationType#</td>

<!---RelationProperty--->
<td>
<cfif IsJSON(DumpAll.RelationProperty)>
<cfset data=#deserializeJSON(DumpAll.RelationProperty)#>
	<cfif IsStruct(data)>
		<cfloop list="#structKeyList(data)#" index="token">
			<cfif IsArray(Evaluate("data.#token#"))>
				<cfloop array="#Evaluate("data.#token#")#" index="token2">
					#token#: #token2#<br>
				</cfloop>
			<cfelse>
					#token#: #Evaluate("data.#token#")#<br>
			</cfif>
		</cfloop>
	</cfif>
</cfif>
</td>

<!---Node2ID--->
<td>#DumpAll.Node2ID#</td>

<!---Node2Label--->
<td>
<cfif IsJSON(DumpAll.Node2Label)>
<cfset data=#deserializeJSON(DumpAll.Node2Label)#>
	<cfif IsArray(data)>
		<cfloop array="#data#" index="token">
			#token#<br>
		</cfloop>
	</cfif>
</cfif>
</td>

<!---Node2Property--->
<td>
<cfif IsJSON(DumpAll.Node2Property)>
<cfset data=#deserializeJSON(DumpAll.Node2Property)#>
	<cfif IsStruct(data)>
		<cfloop list="#structKeyList(data)#" index="token">
			<cfif IsArray(Evaluate("data.#token#"))>
				<cfloop array="#Evaluate("data.#token#")#" index="token2">
					#token#: #token2#<br>
				</cfloop>
			<cfelse>
					#token#: #Evaluate("data.#token#")#<br>
			</cfif>
		</cfloop>
	</cfif>
</cfif>
</td>

</tr>
</cfloop>
</table>
</CFOUTPUT>

<!---
In this example we demonstrated how to parse different return types of return variables and extract information.

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




