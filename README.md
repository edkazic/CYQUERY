CY:QUERY
========

Cypher and Neo4j Graph DB with Cold Fusion

This is a Neo4j library for Cold Fusion (tested with Adobe CF and Railo CF servers).

http://www.adobe.com/au/products/coldfusion-enterprise.html

http://www.getrailo.org/ (open source)

CY:CYPHER is built to support pure REST protocol to push Cypher query to the Neo4j DB server so there is a minimal chance of incompatibilities between Neo4j versions. The returning set is fully Cold Fusion Query object compatible and for data processing user can take the advantage of all standard Cold Fusion features.

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
#Cnt.RecordCount#
#Cnt.ColumnList#
#Cnt.CurrentRow# (for dynamic parsing eg within LOOP)
```

Examples
========
With this distribution there are 6 examples and it is strongly recommended to go through them and learn about hidden gems.

Example1
========
In this example we will learn how to create standard movies database.
In addition there are functions for deleting all data from the DB, examples of CYErrors use to test your CY:QUERY execution, returning object in JSON format as well as analysis of returned data set.

Example2
========
In Example 2 we will explore CF object return type for the movies database.

Example3
========
In Example 3 we will explore various return data types within CF object and present few ideas for parsing data.

Example4
========
In Example 4 we will further improve on parsing data functions and introduce Query of Query applied on CY:QUERY

Example5
========
This time we will introduce powerful Query of Query "linked tables" feature for two CY:QUERY data sets.

Example6
========
In this example we will create DB test nodes (with property) and relations (with property) between them to form a closed chain. It is a demonstration of creating CY:QUERY dynamically (on the fly).



