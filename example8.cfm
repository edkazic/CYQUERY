<cfimport taglib="TAGS" prefix="CY">

<!--- In this example we will implement simple DB backup system --->
<!--- The complete Neo4j DB is saved to the text file and then compressed (zip) to save space --->

<!--- Backup header - edit for each backup--->
<cfset backupName="movie">
<cfset backupTitle="Movies Database">
<cfset backupCreatedBy="Ed Kazic">
<cfset backupCreatedAt=DateFormat(Now(),"DD-MMM-YYYY " )&TimeFormat(Now(),"HH:MM:SS")>

<cfset block=1000> <!--- size of the processing block (default 1000) --->
<cfset deleteBkp="yes"> <!--- delete backup file after the zip file is created --->




<cfset backupFile=#backupName#&".bkp">
<cfset backupDir=ExpandPath("bkp")>
<cfset output="Title: #backupTitle#
Created By: #backupCreatedBy#
Created At: #backupCreatedAt#
================================">

<cfif NOT DirectoryExists(backupDir)>
	<cfset DirectoryCreate(backupDir)>
</cfif>

<cffile action = "write" file = "#backupDir#\#backupFile#" charset="utf-8" addNewLine="yes" output = "#output#">

<cfoutput>#Replace("#output#","#Chr(10)#","<br>","all")#<br></cfoutput>

<!---Get number of nodes with relations from the database---->

<CY:QUERY name="Get">
	MATCH p=(a)-[r]->(b)
	RETURN count(a) AS Cnt
</CY:QUERY>

<cfif CYErrors NEQ "">
	<CFOUTPUT>#CYErrors#</CFOUTPUT>
	<CFABORT>
</cfif>
<CFOUTPUT>- Nodes with relations, count #Get.Cnt#, Time: #CYExecutionTime# sec<BR>----------<br></CFOUTPUT>

<cfloop index="x" from="0" to="#evaluate(Get.Cnt-1)#" step="#block#">
	<cfoutput>
	<CY:QUERY name="DumpBlock">
		MATCH p=(a)-[r]->(b)
		RETURN
			labels(a) 	AS Node1Label,
			type(r) 	AS RelationType,
			r 			AS RelationProperty,
			labels(b) 	AS Node2Label,
			p 			AS Path
		ORDER BY id(a)
		SKIP #x# LIMIT #block#
	</CY:QUERY>

	<cfif CYErrors NEQ "">
		#CYErrors#
		<CFABORT>
	</cfif>
	Retrieve Block: #evaluate((x+block)/block)# from DB, Time: #CYExecutionTime# sec<BR>

	<cfset tickStart=GetTickCount()>
	<cfloop query="DumpBlock">
		<cffile action = "append"
				file = "#backupDir#\#backupFile#"
				charset = "utf-8"
				addNewLine = "yes"
	    		output = "REL:|#DumpBlock.Node1Label#|#DumpBlock.Node2Label#|#DumpBlock.RelationType#|#DumpBlock.Path#">
	</cfloop>
	<CFSET tickEnd=GetTickCount()>
	Write Block #evaluate((x+block)/block)# to file, Time: #evaluate((tickEnd-tickStart)/1000)# sec<BR>
	</cfoutput>
</cfloop>

<!---Get number of nodes with no relations from the database---->

	<CY:QUERY name="Get">
	MATCH (n) where not( n--() )
	RETURN count(n) AS Cnt
	</CY:QUERY>

<cfif CYErrors NEQ "">
	<CFOUTPUT>#CYErrors#</CFOUTPUT>
	<CFABORT>
</cfif>
<CFOUTPUT>----------<br>- Nodes without relations, count #Get.Cnt#, Time: #CYExecutionTime# sec<br>----------<br></CFOUTPUT>

<cfloop index="x" from="0" to="#evaluate(Get.Cnt-1)#" step="#block#">
	<cfoutput>
	<CY:QUERY name="DumpBlock">
		MATCH (n) where not( n--() )
		RETURN
			labels(n) 	AS Node1Label,
			n			AS Node1Property
		ORDER BY id(n)
		SKIP #x# LIMIT #block#
	</CY:QUERY>

	<cfif CYErrors NEQ "">
		#CYErrors#
		<CFABORT>
	</cfif>
	Retrieve Block: #evaluate((x+block)/block)# from DB, Time: #CYExecutionTime# sec<BR>

	<cfset tickStart=GetTickCount()>
	<cfloop query="DumpBlock">
		<cffile action = "append"
				file = "#backupDir#\#backupFile#"
				charset = "utf-8"
				addNewLine = "yes"
	    		output = "NOD:|#DumpBlock.Node1Label#|#DumpBlock.Node1Property#">
	</cfloop>
	<CFSET tickEnd=GetTickCount()>
	Write Block #evaluate((x+block)/block)# to file, Time: #evaluate((tickEnd-tickStart)/1000)# sec<BR>
	</cfoutput>
</cfloop>


<cfzip action = "zip" file = "#backupDir#\#backupFile#.zip" source = "#backupDir#\#backupFile#" overwrite = "yes">

<cfif deleteBkp EQ "yes">
	<cffile action = "delete" file = "#backupDir#\#backupFile#">
</cfif>






