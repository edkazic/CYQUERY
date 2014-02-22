<cfimport taglib="TAGS" prefix="CY">
<cfinclude template="TAGS/GetData.cfm">

<!--- 	In this example we have Restore Backup DB functionality for backup files created in previous example.
		This backup functionality can not restore original Node ID and Relation ID.--->

<cfset backupName="movie">
<cfset block=100> <!---Size of the processing blocks (default 100)--->
<cfset deleteBkp="yes">
<cfset DeleteAll=false>

<!---If "DeleteAll" variable above is set to "true" your backup database will replace current DB.
     Set DeleteAll to false if you would like to keep current DB and append backup DB --->


<cfset tickStart=GetTickCount()>

<cfset backupFile=#backupName#&".bkp">
<cfset backupDir=ExpandPath("bkp")>
<cfset header="Restored DB<br>">

<cfzip
    action = "unzip"
    destination = "#backupDir#"
    file = "#backupDir#\#backupFile#.zip"
    overwrite = "yes">

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
</cfif>

<cfset bkpHnd = FileOpen("#backupDir#\#backupFile#", "read")>

<cfset buffer="">
<cfset cnt=block>

<cfloop condition="NOT FileisEOF(bkpHnd)">
	<cfset line = FileReadLine(bkpHnd)>

	<cfif left(line,4) EQ "REL:">
		<cfset Node1Label=GetToken(line,2,"|")>
		<cfset Node2Label=GetToken(line,3,"|")>
		<cfset RelationType=GetToken(line,4,"|")>
		<cfset Path=GetToken(line,5,"|")>

		<cfset cnt=cnt-1>

		<CFOUTPUT>
		<cfset buffer=buffer&"
		MERGE (a#cnt##getCLabel(Node1Label)#  #getFromPath(Path,1)#  )
		MERGE (b#cnt##getCLabel(Node2Label)#  #getFromPath(Path,3)#  )
		CREATE UNIQUE (a#cnt#)-[:#RelationType#  #getFromPath(Path,2)#  ]->(b#cnt#)
		">
		</CFOUTPUT>
	<cfelseif left(line,4) EQ "NOD:">
		<cfset Node1Label=GetToken(line,2,"|")>
		<cfset Node1Property=GetToken(line,3,"|")>
		<cfset Node1Property=removeSpec(Node1Property)>
		<cfset Node1Property=removeQuote(Node1Property)>

		<cfset cnt=cnt-1>

		<CFOUTPUT>
		<cfset buffer=buffer&"
		MERGE (#getCLabel(Node1Label)#  #Node1Property#  )
		">
		</CFOUTPUT>
	<cfelse>
		<cfset header=header&line&"<br>">
	</cfif>

	<cfif cnt LT 1>
		<cfoutput>
			<CY:QUERY name="nodesandrels">
			#buffer#
			</CY:QUERY>
		</cfoutput>
			<cfif CYErrors NEQ "">
				<CFOUTPUT>#CYErrors#</CFOUTPUT>
				<CFABORT>
			</cfif>

		<cfset cnt=block>
		<cfset buffer="">
	</cfif>
</cfloop>

<cfif buffer NEQ "">
<cfoutput>
<CY:QUERY name="nodesandrels">
#buffer#
</CY:QUERY>
</cfoutput>
	<cfif CYErrors NEQ "">
		<CFOUTPUT>#CYErrors#</CFOUTPUT>
		<CFABORT>
	</cfif>
</cfif>

<cfset FileClose(bkpHnd)>

<cfoutput>#header#</cfoutput>

<cfset tickEnd=GetTickCount()>
<cfoutput>Restore Time: #evaluate((tickEnd-tickStart)/1000)# sec<BR></cfoutput>

<cfif deleteBkp EQ "yes">
	<cffile action = "delete" file = "#backupDir#\#backupFile#">
</cfif>


