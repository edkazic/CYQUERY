<cfimport taglib="./TAGS" prefix="CY">

<cfscript>
/*----------------------*/
function getID(data) {
var ret=data;
    return ret;
}

/*----------------------*/
function getRelationType(data) {
var ret="";
if(isJSON(data))
    ret=deserializeJSON(data);
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
			if(isArray(Evaluate("buf.#list[j]#")))
				{
				var arr=Evaluate("buf.#list[j]#");
				  	  for (i = 1; i <= arrayLen(arr); i++)
						ret = ret & list[j] & ':' & arr[i] & '<br>';
				}
				else {
						ret=ret & list[j]  & ':' & evaluate("buf.#list[j]#") & '<br>';
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


<!---
The following is an example of "Query of Query" where CY:QUERY data set is queried with CF SQL engine and sorted by Node1Property.
It is not strictly correct as Node1Property is complex object but it is good enough as an example.
--->


<CFQUERY name="DumpAll" dbtype = "query">
SELECT * FROM CYDumpAll
ORDER BY Node1Property
</CFQUERY>



<!---
The following is the way to display data on the screen in the same way as in the previous example
except this time inline CF tags are replaced with script functions for simplicity.
--->


<CFOUTPUT>
<!---Display data in the table---->
<table border=1>

<!---Create header for the table--->
<tr>
<TD>Node1ID</TD><TD>Node1Label</TD><TD>Node1Property</TD><TD>RelationID</TD><TD>RelationType</TD><TD>RelationProperty</TD><TD>Node2ID</TD><TD>Node2Label</TD><TD>Node2Property</TD>
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
<td>#getRelationType(DumpAll.RelationType)#</td>

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

