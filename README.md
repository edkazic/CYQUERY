CY:QUERY
========

Cypher and Neo4j Graph DB with Cold Fusion

This is a Neo4j library for Cold Fusion (tested with Adobe CF and Railo CF servers).

http://www.adobe.com/au/products/coldfusion-enterprise.html

http://www.getrailo.org/ (open source)

CY:QUERY is built to support pure REST protocol to push Cypher query to the Neo4j DB server so there is a minimal chance of incompatibilities between Neo4j versions. The returning set is fully Cold Fusion Query object compatible and for data processing user can take the advantage of all standard Cold Fusion features.

USAGE
=====

Create normal CF project, make sure you have TAGS directory with content from the repository under your project and on the CF page have import function:

```<cfimport taglib="TAGS" prefix="CY">```

Optionaly few data parsing functions are available with include:

```<cfinclude template="TAGS/GetData.cfm">```


Executing Cypher Queries
========================

Cupher query can be executed as simple as:

```
<CY:QUERY name="Cnt">
	MATCH (n) //comment is supported as well
	RETURN count(n) as NodeCount
</CY:QUERY>
```

The "name" is compulsory attribute for CY:QUERY and it is used as a reference to returned Cold Fusion object.
The returned result set will be formatted in CF Query object and result of this query can be retrieved with:

```
#Cnt.NodeCount#
```

Another attribute (optional) is returnFormat="JSON" in case you need to return JSON object instead of the CF object.

In addition variables CYErrors and CYExecutionTime are returned as well as standard CF variables:

```
#CYErrors#
#CYExecutionTime#
#Cnt.RecordCount#
#Cnt.ColumnList#
#Cnt.CurrentRow# (for dynamic parsing eg within LOOP)
```

Examples
========
With this distribution there are 9 examples and it is strongly recommended to go through them and learn about hidden gems.

Example1
========
In this example we will learn how to create standard movies database.
In addition there are functions for deleting all data from the DB, examples of CYErrors use to test your CY:QUERY execution, returning object in JSON format as well as analysis of returned data set.

Delete ALL nodes and ALL relations from the DB
```
	<CY:QUERY name="DeleteAll">
		MATCH (n)
		OPTIONAL MATCH (n-[r]-())
		DELETE n,r
	</CY:QUERY>

	<CFIF CYErrors NEQ "">
		<CFOUTPUT>#CYErrors#</CFOUTPUT>
		<CFABORT>
	</CFIF>
```

Example2
========
In Example 2 we will explore CF object return type for the movies database.

Get entire content of your Neo4j DB (you would have to remove LIMIT 1000 clause if required)

```
<CY:QUERY name="DumpAll">
//Match all nodes and relations
MATCH p=(a)-[r]->(b)
RETURN
	id(a) 	  AS Node1ID,
	labels(a) AS Node1Label,
	a 	  	  AS Node1Property,
	id(r) 	  AS RelationID,
	type(r)   AS RelationType,
	r 	  	  AS RelationProperty,
	id(b) 	  AS Node2ID,
	labels(b) AS Node2Label,
	b 	  	  AS Node2Property,
	p 	      AS Path
LIMIT 1000

//////////////////////////////////////
UNION
//////////////////////////////////////

//Match all nodes with no relations
MATCH (n) where not( n--() )
RETURN
	id(n)	  AS Node1ID,
	labels(n) AS Node1Label,
	n 	  	  AS Node1Property,
	null 	  AS RelationID,
	null 	  AS RelationType,
	null 	  AS RelationProperty,
	null 	  AS Node2ID,
	null 	  AS Node2Label,
	null 	  AS Node2Property,
	null 	  AS Path
LIMIT 1000
</CY:QUERY>
```

Example3
========
In Example 3 we will explore various return data types within CF object and present few ideas for parsing data.

Return Data Types

ReturnValueType |ExampleReturnNames |	ValueStructure
--------------- |-------------------|----------------------
id(node) 	|NodeID		    |int
labels(node) 	|NodeLabel	    |array of labels
node 		|NodeProperty	    |structure of properties (a property can be single or an array of values)
id(relation) 	|RelationID	    |int
type(relation) 	|RelationType	    |string
relation 	|RelationProperty   |structure of properties (a property can be single or an array of values)
path 		|Path		    |array of structures: first node structure of properties, relation structure of properties and second node structure of properties




Example4
========
In Example 4 we will further improve on parsing data functions and introduce Query of Query applied on CY:QUERY

Example function for interpreting properties (either Node or Relation)

```
function getProperty(data) {
var ret="";

 if(isJSON(data))
 	{
	var buf=deserializeJSON(data);
	if(isStruct(buf))
	   {
		var list=listToArray(structKeyList(buf));
		for (j = 1; j <= arrayLen(list); j++)
			{
			if(isArray(evaluate("buf.#list[j]#")))
				{
				var arr=evaluate("buf.#list[j]#");
				  	  for (i = 1; i <= arrayLen(arr); i++)
						ret = ret & list[j] & ': ' & arr[i] & '<br>';
				}
				else {
						ret=ret & list[j]  & ': ' & evaluate("buf.#list[j]#") & '<br>';
				}
			}
		}
	}
return ret;
}
</cfscript>
```

Example5
========
This time we will introduce powerful Query of Query "linked tables" feature for two CY:QUERY data sets.

CF Query where two retrieved CY:QUERY sets (CYNodesOut and CYNodesIn) are linked by RelationID and resulting set sorted by the age of the actor.

```
<CFQUERY name="DumpAll" dbtype = "query">
SELECT 	CYNodesOut.NodeID    	AS Node1ID,
	CYNodesOut.NodeLabel 	    AS Node1Label,
	CYNodesOut.NodeProperty	    AS Node1Property,
	CYNodesOut.RelationID	    AS RelationID,
	CYNodesOut.RelationType	    AS RelationType,
	CYNodesOut.RelationProperty AS RelationProperty,
	CYNodesIn.NodeID 	        AS Node2ID,
	CYNodesIn.NodeLabel 	    AS Node2Label,
	CYNodesIn.NodeProperty	    AS Node2Property,
	CYNodesOut.Born		        AS Born
FROM CYNodesOut, CYNodesIn
WHERE CYNodesOut.RelationID=CYNodesIn.RelationID
ORDER BY Born DESC
</CFQUERY>
```

Example6
========
In this example we will create DB test nodes (with property) and relations (with property) between them to form a closed chain. It is a demonstration of creating CY:QUERY dynamically (on the fly).

Dynamically created CY:QUERY using ColdFusion LOOP. This piece of code will create 900 nodes and 900 relations each with properties in just one dynamically created CY:QUERY and then it will dispay the time it took to create this DB set


```
<cfset nodeNo=900>
<cfset nodeStart=1>

<CY:QUERY name="nodes">
	CREATE (node#nodeStart#:Node {name:'node#nodeStart#'}) 		//Create first innitial node
	<CFLOOP index="x" from="#evaluate(nodeStart+1)#" to="#nodeNo#"> //Create Nodes and Relations nodeNo-nodeStart times
		CREATE (node#Evaluate(x-1)#)-[:LINKED_TO {Relation: 'link#Evaluate(x-1)#'}]->(node#x#:Node {name:'node#x#'})
	</CFLOOP>
	CREATE (node#nodeNo#)-[:LINKED_TO {Relation:'link#nodeNo#'}]->(node#NodeStart#)		//Create last node relation to close the chain with the first node
</CY:QUERY>
```

Example7
========
In this example we will create DB test nodes with Cypher parameters


```
<CY:QUERY name="nodes">
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
```

Example8
========
In this example we will implement simple DB backup system. The complete Neo4j DB is saved to the text file and then compressed (zip) to save spacee.

The entire DB is stored in the text file. There are two types of text data blocks: nodes with relations (REL) and nodes without relations (NOD). They are stored in the format:

```
REL:|Node1Label|Node2Label|RelationType|Path
NOD:|Node1Label|Node1Property
```

This backup strategy is not very efficient but the purpose is to show some of the Cypher and CF integration techniques. It is using lots of data parsing which are expensive in terms of execution. Still it can be useful for small size databases.


Example9
========
In this example we have Backup Restore functionality for backup files created in previous example. This backup functionality can not restore original Node ID and Relation ID but all the nodes, labels, relations, types and properties are preserved.



License and Acknowledgements
============================

Made available under the MIT License (MIT).

Copyright © Ed Kazic, CTO Radmis Pty Ltd 

www.radmis.com

