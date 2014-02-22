
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
function getCLabel(data) {
var ret="";
 if(isJSON(data))
 	{
	var buf=deserializeJSON(data);
	if(isArray(buf))
	  {
	  	  for (i = 1; i <= arrayLen(buf); i++)
				ret = ret & ':' & buf[i];
	  }
 	}
return ret;
}

/*----------------------*/
function getFromPath(data,poz) {
var ret="";
var buf="";
 if(isJSON(data))
 	{
    ret=getToken(data,poz,"}");
    buf=right(ret,len(ret)-1)&"}";
    ret=removeQuote(buf);
    ret=removeSpec(ret);
 	}
return ret;
}

/*----------------------*/
function removeSpec(data) {
var ret="";
ret=replace(data,"\/","/","all");
return ret;
}

/*----------------------*/
function removeQuote(data) {
var ret="";
var state=0;
var upd=1;
var yyy=Reverse(data);
var qqq="";

for(x=1;x<=len(yyy);x++)
{
var tok=mid(yyy,x,1);

if (state==0)
	{
	 if(tok == ":") state=1;
	}
else if(state==1)
	{
	if(tok == '"' || tok == ' ')
		{
		if(tok == '"')
			{
			state=2;
			upd=0;
			}
		}
	  else
		state=0;
	}
else if(state==2)
	{
		if( tok == '"') {
			upd=0;
			state=0;
		}
	}

if(upd) qqq=qqq&tok;
else upd=1;
}

ret=Reverse(qqq);
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
var ret=DateFormat(data,"DD-MMM-YYYY");
/*
ToDo
here is the place to define any special data type (eg getDate()) you may need
*/
    return ret;
}


</cfscript>

