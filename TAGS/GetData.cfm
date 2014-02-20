
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

/*----------------------*/
function getDate(data) {
var ret=data;
/*
ToDo 
here is the place to define any special data type eg getDate() you may need
*/
    return ret;
}


</cfscript>

