<cfcomponent output="no">
<cfscript>variables.dsn=request.dsn</cfscript>

<cffunction name="newWidget" access="public" output="true" returntype="void">
	<cfargument name="ratingName" type="string" required="true" hint="This should be unique">
	<cfargument name="ratingTitle" type="string" required="true" hint="Title that will appear to the user">
	<cfargument name="ratingNumber" type="numeric" required="true" hint="Max number of stars">
	<cfargument name="pathToSpryJS" type="string" required="true" hint="relative or absolute web path to Spry widget JS files">
	<cfargument name="pathToSpryCSS" type="string" required="true" hint="relative or absolute web path to Spry widget CSS files">
	 <cfset rsWidget = insertOrSelect(ratingName,RatingTitle)>
	 <cfset uservote = getRatingForUser(rsWidget.id,"#cftoken##cfid#")>
	 <cfset averagevote = getRatingValue(rswidget.id)>
	<cfset pathtoCFC = "/"& replace(getmetadata().name,".","/","all") & ".cfc">	
	<cfsavecontent variable="body">
	<cfoutput>
	<script language="JavaScript" type="text/javascript" src="#pathToSpryJS#SpryRating.js"></script>
<link href="#pathToSpryCSS#samples.css" rel="stylesheet" type="text/css" />
<link href="#pathToSpryCSS#SpryRating.css" rel="stylesheet" type="text/css" />
<div><h3>#rsWidget.title#</h3><span id="rating#rsWidget.id#" class="ratingContainer">
		   <cfloop from="1" to="#ratingNumber#" index="i">
		    <span class="ratingButton"></span>
		   </cfloop>
<input id="ratedElement" type="hidden" name="ratingField" value="" />
			<span class="ratingRatedMsg">Thanks for your rating!</span>
</span>
<p>&nbsp;</p>
</div><script type="text/javascript">
	var firstRating#replace(rsWidget.id,"-","_","all")# = new Spry.Widget.Rating("rating#rsWidget.id#", {allowMultipleRating:false,<cfif userVote gt 0> readOnly:true,</cfif>saveUrl: "#pathToCFC#?method=userRate",postData:"ratingId=#rsWidget.id#&rate=@@ratingValue@@",ratingValue:<cfoutput>#averageVote#</cfoutput>});
	var myObs = {};
	firstRating#replace(rsWidget.id,"-","_","all")#.addObserver(myObs);
	myObs.onServerUpdate = function(obj, req){
		var returnVal = parseFloat(req.xhRequest.responseText);
		if (!isNaN(returnVal)){
			firstRating#replace(rsWidget.id,"-","_","all")#.setValue(returnVal, true);
		}
	}
</script>
	</cfoutput>
	</cfsavecontent>
<cfoutput>#HtmlCompressFormat(body)#</cfoutput> 
</cffunction>
<!--- Saves rate based on users id (default cftoken/cfid, user will have to clear out sesison cookie
to be able to vote again, you can change this to something else like user id --->
<cffunction name="userRate" access="remote" output="false" returntype="string">
	<cfargument name="ratingId" type="string" required="true">
	<cfargument name="rate" type="numeric" required="true">
	<cfargument name="userId" type="string" required="no" default="#cftoken##cfid#">
	
		<cfquery name="castVote" datasource="#variables.dsn#">
			insert into ratingsVote (ratingid,rate,userid)
			values ('#ratingid#',#rate#,'#userId#')
		</cfquery>
		<cfreturn getRatingValue(ratingid)>
</cffunction>
<!--- gets the average rating for specified ratings widget  --->
<cffunction name="getRatingValue" access="remote" output="false" retuntype="string">
	<cfargument  name="ratingId" type="string" required="true">
<!--- mysql specific ifnull  --->
	<cfquery name="getRatingValue" datasource="#variables.dsn#">
			select ifnull(AVG(rate),'0') avg_rate from ratingsvote where ratingid = '#ratingid#'
	</cfquery>
	<cfreturn getRatingValue.avg_rate >
</cffunction>
<!--- gets the users vote to  --->
<cffunction name="getRatingForUser" access="remote" output="false" returntype="string">
	<cfargument name="ratingId" type="string" required="true">
	<cfargument name="userID" type="string" required="true">
	<cfquery name="getRatingForUser" datasource="#variables.dsn#">
		select rate from ratingsVote where ratingid='#ratingId#' and userid ="#userID#"
	</cfquery>
	<cfif getRatingForUser.recordcount eq 0>
		<cfset uservote = 0>
	<cfelse>
		<cfset uservote = getRatingForUser.rate>
	</cfif>
	<cfreturn uservote>
</cffunction>
<!--- helper function for the newwidget, will either get the details from the db if
exists or insert a new vote --->
<cffunction name="insertOrSelect" access="private" returntype="query" output="false">
	<cfargument name="ratingName" type="string" required="true">
	<cfargument name="ratingTitle" type="string" required="true">
	<cfquery name="getRatingId" datasource="#variables.dsn#">
		select id,title from rating where name ='#ratingName#'
	</cfquery>
	<cfif not getratingid.recordcount>
		<cfset ratingID = createUUID()>
		<cfquery name="getRatingId" datasource="#variables.dsn#">
			insert into rating (id,title,name)
			values ('#ratingid#','#ratingTitle#','#ratingName#' )
		</cfquery>
		<cfset getRatingId = queryNew('id,title,name')>
		<cfset newrow = queryAddRow(getRatingId,1)>
		<cfset temp = querySetCell(getRatingId,'id','#ratingid#')>
		<cfset temp = querySetCell(getRatingId,'title','#ratingTitle#')>
		<cfset temp = querySetCell(getRatingId,'name','#ratingName#')>
	</cfif>
	<cfreturn getRatingId/>
</cffunction>
<cffunction name="HtmlCompressFormat" returntype="string" access="private" output="false">
	<cfargument name="sInput" type="string" required="yes">
<cfset var level = 2>
<cfsilent>
<cfscript>
/**
 * Replaces a huge amount of unnecessary whitespace from your HTML code.
 * 
 * @param sInput 	 HTML you wish to compress. (Required)
 * @return Returns a string. 
 * @author Jordan Clark (&#74;&#111;&#114;&#100;&#97;&#110;&#67;&#108;&#97;&#114;&#107;&#64;&#84;&#101;&#108;&#117;&#115;&#46;&#110;&#101;&#116;) 
 * @version 1, November 19, 2002 
 */
   
   if( arrayLen( arguments ) GTE 2 AND isNumeric(arguments[2]))
   {
      level = arguments[2];
   }
   // just take off the useless stuff
   sInput = trim(sInput);
   switch(level)
   {
      case "3":
      {
         //   extra compression can screw up a few little pieces of HTML, doh         
         sInput = reReplace( sInput, "[[:space:]]{2,}", " ", "all" );
         sInput = replace( sInput, "> <", "><", "all" );
         sInput = reReplace( sInput, "<!--[^>]+>", "", "all" );
         break;
      }
      case "2":
      {
         sInput = reReplace( sInput, "[[:space:]]{2,}", chr( 13 ), "all" );
         break;
      }
      case "1":
      {
         // only compresses after a line break
         sInput = reReplace( sInput, "(" & chr( 10 ) & "|" & chr( 13 ) & ")+[[:space:]]{2,}", chr( 13 ), "all" );
         break;
      }
   }
</cfscript>
</cfsilent>
  <cfreturn sInput/>
  </cffunction>
</cfcomponent>