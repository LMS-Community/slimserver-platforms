self.%ADDON%_preaction = function()
{
}

self.%ADDON%_onloadaction = function()
{
}

self.%ADDON%_enable = function()
{
  document.getElementById('BUTTON_%ADDON%_APPLY').disabled = false;
  var runtimeSecs = document.getElementById('%ADDON%_RUNTIME_SECS');
  if (runtimeSecs)
  {
    runtimeSecs.disabled = false;
  }
}

self.%ADDON%_remove = function()
{
  if( !confirm(S['CONFIRM_REMOVE_ADDON']) )
  {
    return;
  }
  
  var set_url;
  
  if ( confirm(S['CONFIRM_KEEP_ADDON_DATA']) )
  {
    set_url = NasState.otherAddOnHash['%ADDON%'].DisplayAtom.set_url
                + '?OPERATION=set&command=RemoveAddOn&data=preserve';
  }
  else
  {
    set_url = NasState.otherAddOnHash['%ADDON%'].DisplayAtom.set_url
                + '?OPERATION=set&command=RemoveAddOn&data=remove';
  }

  applyChangesAsynch(set_url,  %ADDON%_handle_remove_response);
}

self.%ADDON%_handle_remove_response = function()
{
  if ( httpAsyncRequestObject && 
      httpAsyncRequestObject.readyState && 
      httpAsyncRequestObject.readyState == 4 ) 
  {
    if ( httpAsyncRequestObject.responseText.indexOf('<payload>') != -1 )
    {
       showProgressBar('default');
       xmlPayLoad  = httpAsyncRequestObject.responseXML;
       var status = xmlPayLoad.getElementsByTagName('status').item(0);
       if (!status || !status.firstChild)
       {
          return;
       }

       if ( status.firstChild.data == 'success')
       {
         display_messages(xmlPayLoad);
         updateAddOn('%ADDON%');
         if (!NasState.otherAddOnHash['%ADDON%'])
         {
            remove_element('%ADDON%');
            if (getNumAddOns() == 0 )
            {
               document.getElementById('no_addons').className = 'visible';
            }
         }
         else
         {
           hide_element('%ADDON%_LINK');
         }
       }
       else if (status.firstChild.data == 'failure')
       {
         display_error_messages(xmlPayLoad);
       }
    }
    httpAsyncRequestObject = null;
  }
}

self.%ADDON%_page_change = function()
{
  var id_array = new Array( '%ADDON%_RUNTIME_SECS' );
  for (var ix = 0; ix < id_array.length; ix++ )
  {
     NasState.otherAddOnHash['%ADDON%'].DisplayAtom.fieldHash[id_array[ix]].value = 
     document.getElementById(id_array[ix]).value;
     NasState.otherAddOnHash['%ADDON%'].DisplayAtom.fieldHash[id_array[ix]].modified = true;
  }
}


self.%ADDON%_enable_save_button = function()
{
  document.getElementById('BUTTON_%ADDON%_APPLY').disabled = false;
}

self.%ADDON%_apply = function()
{

   var page_changed = false;
   var set_url = NasState.otherAddOnHash['%ADDON%'].DisplayAtom.set_url;
   var runtimeSecs = document.getElementById('%ADDON%_RUNTIME_SECS');
   if (runtimeSecs)
   {
     var id_array = new Array ('%ADDON%_RUNTIME_SECS');
     for (var ix = 0; ix < id_array.length ; ix ++)
     {
       if (  NasState.otherAddOnHash['%ADDON%'].DisplayAtom.fieldHash[id_array[ix]].modified )
       {
          page_changed = true;
          break;
       }
     }
   }
   var enabled = document.getElementById('CHECKBOX_%ADDON%_ENABLED').checked ? 'checked' :  'unchecked';
   var current_status  = NasState.otherAddOnHash['%ADDON%'].Status;
   if ( page_changed )
   {
      set_url += '?command=ModifyAddOnService&OPERATION=set&' + 
                  NasState.otherAddOnHash['%ADDON%'].DisplayAtom.getApplicablePagePostStringNoQuest('modify') +
                  '&CHECKBOX_%ADDON%_ENABLED=' +  enabled;
      if ( enabled == 'checked' && current_status == 'on' ) 
      {
        set_url += "&SWITCH=NO";
      }
      else
      {
         set_url += "&SWITCH=YES";
      }
   }
   else
   {
      set_url += '?command=ToggleService&OPERATION=set&CHECKBOX_%ADDON%_ENABLED=' + enabled;
   }
   applyChangesAsynch(set_url, %ADDON%_handle_apply_response);
}

self.%ADDON%_handle_apply_response = function()
{
  if ( httpAsyncRequestObject &&
       httpAsyncRequestObject.readyState &&
       httpAsyncRequestObject.readyState == 4 )
  {
    if ( httpAsyncRequestObject.responseText.indexOf('<payload>') != -1 )
    {
      showProgressBar('default');
      xmlPayLoad = httpAsyncRequestObject.responseXML;
      var status = xmlPayLoad.getElementsByTagName('status').item(0);
      if ( !status || !status.firstChild )
      {
        return;
      }

      if ( status.firstChild.data == 'success' )
      {
        var log_alert_payload = xmlPayLoad.getElementsByTagName('normal_alerts').item(0);
        if ( log_alert_payload )
	{
	  var messages = grabMessagePayLoad(log_alert_payload);
	  if ( messages && messages.length > 0 )
	  {
	      if ( messages != 'NO_ALERTS' )
	      {
	        alert (messages);
	      }
	      var success_message_start = AS['SUCCESS_ADDON_START'];
		  success_message_start = success_message_start.replace('%ADDON_NAME%', NasState.otherAddOnHash['%ADDON%'].FriendlyName);
	      var success_message_stop  = AS['SUCCESS_ADDON_STOP'];
		  success_message_stop = success_message_stop.replace('%ADDON_NAME%', NasState.otherAddOnHash['%ADDON%'].FriendlyName);

	      if ( NasState.otherAddOnHash['%ADDON%'].Status == 'off' )
	      {
	        NasState.otherAddOnHash['%ADDON%'].Status = 'on';
	        NasState.otherAddOnHash['%ADDON%'].RunStatus = 'OK';
	        refresh_applicable_pages();
	      }
	      else
	      {
	        NasState.otherAddOnHash['%ADDON%'].Status = 'off';
	        NasState.otherAddOnHash['%ADDON%'].RunStatus = 'not_present';
	        refresh_applicable_pages();
	      }
	    }
        }
      }
      else if (status.firstChild.data == 'failure')
      {
        display_error_messages(xmlPayLoad);
      }
    }
    httpAsyncRequestObject = null;
  }
}

self.%ADDON%_handle_apply_toggle_response = function()
{
  if (httpAsyncRequestObject &&
      httpAsyncRequestObject.readyState &&
      httpAsyncRequestObject.readyState == 4 )
  {
    if ( httpAsyncRequestObject.responseText.indexOf('<payload>') != -1 )
    {
      showProgressBar('default');
      xmlPayLoad = httpAsyncRequestObject.responseXML;
      var status = xmlPayLoad.getElementsByTagName('status').item(0);
      if (!status || !status.firstChild)
      {
        return;
      }
      if ( status.firstChild.data == 'success' )
      {
        display_messages(xmlPayLoad);
      }
      else
      {
        display_error_messages(xmlPayLoad);
      }
    }
  }
}

self.%ADDON%_service_toggle = function()
{
  
  var addon_enabled = document.getElementById('CHECKBOX_%ADDON%_ENABLED').checked ? 'checked' :  'unchecked';
  var set_url    = NasState.otherAddOnHash['%ADDON%'].DisplayAtom.set_url
                   + '?OPERATION=set&command=ToggleService&CHECKBOX_%ADDON%_ENABLED='
                   + addon_enabled;
  
  var xmlSyncPayLoad = getXmlFromUrl(set_url);
  var syncStatus = xmlSyncPayLoad.getElementsByTagName('status').item(0);
  if (!syncStatus || !syncStatus.firstChild)
  {
     return ret_val;
  }

  if ( syncStatus.firstChild.data == 'success' )
  {
    display_messages(xmlSyncPayLoad);
    //if %ADDON% is enabled
    NasState.otherAddOnHash['%ADDON%'].Status = 'on';                                             
    NasState.otherAddOnHash['%ADDON%'].RunStatus = 'OK';                                            
    refresh_applicable_pages();  
    //else if %ADDON% is disabled
    NasState.otherAddOnHash['%ADDON%'].Status = 'off';                    
    NasState.otherAddOnHash['%ADDON%'].RunStatus = 'not_present';         
    refresh_applicable_pages(); 
  }
  else
  {
    display_error_messages(xmlSyncPayLoad);
  }
}

