<cfimport taglib="./TAGS" prefix="CY">

<!---Here we have functions for parsing different property types grouped together for more convenience--->
<cfscript>
/*----------------------*/
function getID(data) {
var ret=data;
if(ret NEQ "") ret=val(ret);
    return ret;
}

/*----------------------*/
function getString(data) {
var ret=Trim(data);
    return ret;
}

/*----------------------*/
function getLabel(data) {
var ret="";
 if(isJSON(data))
 	{
	var buf=deserializeJSON(data);
	if(isArray(buf))
	  {
	  	  for (i = 1; i <= arrayLen(buf); i++)
				ret = ret & buf[i] & '<br>';
	  }
 	}
return ret;
}

/*----------------------*/
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




<!---Get ALL data from the database---->

<CY:QUERY name="CYDumpAll">
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
p 			AS Path,
a.name		AS Name //this is an additional field
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
null 		AS Path,
n.name		AS Name
LIMIT 1000
</CY:QUERY>

<cfif CYErrors NEQ "">
	<CFOUTPUT>#CYErrors#</CFOUTPUT>
	<CFABORT>
</cfif>


<!---
In this example we demonstrate "Query of Query" (CF feature) where CY:QUERY data set is queried with CF SQL engine and data set is sorted by Name.
The Name is "lowered" to low case as SQL query sort is case sensitive.
--->


<CFQUERY name="DumpAll" dbtype = "query">
SELECT lower(NAME), NODE1ID, NODE1LABEL, NODE1PROPERTY, RELATIONID, RELATIONPROPERTY, RELATIONTYPE, NODE2ID, NODE2LABEL, NODE2PROPERTY
FROM CYDumpAll
ORDER BY NAME
</CFQUERY>

<!---
We can "dump" complete CF object as:
<cfdump var="#DumpAll#">
--->

<!---
The following is the alternative way to display data on the screen.
This time inline CF tags are replaced with script functions for simplicity.
--->


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

