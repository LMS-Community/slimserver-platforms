self.UEML_preaction = function()
{
}

self.UEML_onloadaction = function()
{
	// set a link to the UE Music Library web UI
	$.ajax({
		url: NasState.otherAddOnHash['UEML'].DisplayAtom.set_url + '?OPERATION=get_web_port',
		success: function(xmlPayLoad) {
			var port = xmlPayLoad.getElementsByTagName('content').item(0);
			
			if (port.firstChild.data)
				port = port.firstChild.data;
				
			if (isNaN(parseInt(port)))
				port = 3546;
			
			$('#sbwebui').html('<a href="http://' + window.location.hostname + ':' + port + '" target="_blank">Free Your Music!</a>');
		}
	});
	
	toggleCleanupOptions();
}

self.UEML_enable = function()
{
  document.getElementById('BUTTON_UEML_APPLY').disabled = false;
}

self.UEML_remove = function()
{
  if( !confirm(S['CONFIRM_REMOVE_ADDON']) )
  {
    return;
  }
  
  var set_url;
  
  if ( confirm(S['CONFIRM_KEEP_ADDON_DATA']) )
  {
    set_url = NasState.otherAddOnHash['UEML'].DisplayAtom.set_url
                + '?OPERATION=set&command=RemoveAddOn&data=preserve';
  }
  else
  {
    set_url = NasState.otherAddOnHash['UEML'].DisplayAtom.set_url
                + '?OPERATION=set&command=RemoveAddOn&data=remove';
  }

  applyChangesAsynch(set_url,  UEML_handle_remove_response);
}

self.UEML_handle_remove_response = function()
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
         updateAddOn('UEML');
         if (!NasState.otherAddOnHash['UEML'])
         {
            remove_element('UEML');
            if (getNumAddOns() == 0 )
            {
               document.getElementById('no_addons').className = 'visible';
            }
         }
         else
         {
           hide_element('UEML_LINK');
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

self.UEML_page_change = function()
{
  var id_array = new Array();
  for (var ix = 0; ix < id_array.length; ix++ )
  {
     NasState.otherAddOnHash['UEML'].DisplayAtom.fieldHash[id_array[ix]].value = 
     document.getElementById(id_array[ix]).value;
     NasState.otherAddOnHash['UEML'].DisplayAtom.fieldHash[id_array[ix]].modified = true;
  }
}


self.UEML_enable_save_button = function()
{
  document.getElementById('BUTTON_UEML_APPLY').disabled = false;
}

self.UEML_apply = function()
{

   var page_changed = false;
   var set_url = NasState.otherAddOnHash['UEML'].DisplayAtom.set_url;

   var enabled = document.getElementById('CHECKBOX_UEML_ENABLED').checked ? 'checked' :  'unchecked';
   var current_status  = NasState.otherAddOnHash['UEML'].Status;
   if ( page_changed )
   {
      set_url += '?command=ModifyAddOnService&OPERATION=set&' + 
                  NasState.otherAddOnHash['UEML'].DisplayAtom.getApplicablePagePostStringNoQuest('modify') +
                  '&CHECKBOX_UEML_ENABLED=' +  enabled;
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
      set_url += '?command=ToggleService&OPERATION=set&CHECKBOX_UEML_ENABLED=' + enabled;
   }
   applyChangesAsynch(set_url, UEML_handle_apply_response);
}

self.UEML_handle_apply_response = function()
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
		  success_message_start = success_message_start.replace('%ADDON_NAME%', NasState.otherAddOnHash['UEML'].FriendlyName);
	      var success_message_stop  = AS['SUCCESS_ADDON_STOP'];
		  success_message_stop = success_message_stop.replace('%ADDON_NAME%', NasState.otherAddOnHash['UEML'].FriendlyName);

	      if ( NasState.otherAddOnHash['UEML'].Status == 'off' )
	      {
	        NasState.otherAddOnHash['UEML'].Status = 'on';
	        NasState.otherAddOnHash['UEML'].RunStatus = 'OK';

			// enable/disable cleanup options	        
	        toggleCleanupOptions(false);
	        
	        refresh_applicable_pages();
	      }
	      else
	      {
	        NasState.otherAddOnHash['UEML'].Status = 'off';
	        NasState.otherAddOnHash['UEML'].RunStatus = 'not_present';

			// enable/disable cleanup options	        
	        toggleCleanupOptions(true);
	        
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

self.UEML_handle_apply_toggle_response = function()
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

self.UEML_service_toggle = function()
{
  
  var addon_enabled = document.getElementById('CHECKBOX_UEML_ENABLED').checked ? 'checked' :  'unchecked';
  var set_url    = NasState.otherAddOnHash['UEML'].DisplayAtom.set_url
                   + '?OPERATION=set&command=ToggleService&CHECKBOX_UEML_ENABLED='
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
    //if UEML is enabled
    NasState.otherAddOnHash['UEML'].Status = 'on';                                             
    NasState.otherAddOnHash['UEML'].RunStatus = 'OK';                                            
    refresh_applicable_pages();  
    //else if UEML is disabled
    NasState.otherAddOnHash['UEML'].Status = 'off';                    
    NasState.otherAddOnHash['UEML'].RunStatus = 'not_present';         
    refresh_applicable_pages(); 
  }
  else
  {
    display_error_messages(xmlSyncPayLoad);
  }
}

// custom callback to remove UEML prefs/cache etc.
self.UEML_cleanup = function() 
{
	var prefs = document.forms.ueml_cleanup.cleanup_prefs.checked;
	var cache = document.forms.ueml_cleanup.cleanup_cache.checked;

	showProgressBar('wait');

	$.ajax({
		url: NasState.otherAddOnHash['UEML'].DisplayAtom.set_url + '?OPERATION=cleanup&command=' + (prefs ? 'prefs|' : '') + (cache ? 'cache|' : ''),
		cache: false,
		complete: function(jqXHR, textStatus) {
			document.forms.ueml_cleanup.cleanup_prefs.checked = false;
			document.forms.ueml_cleanup.cleanup_cache.checked = false;
		
			showProgressBar('default');
		}
	});
}

function toggleCleanupOptions(enable)
{
	if (enable == undefined)
		enable = NasState.otherAddOnHash['UEML'].Status != 'on';
		
	document.forms.ueml_cleanup.cleanup_prefs.disabled = !enable;
	document.forms.ueml_cleanup.cleanup_cache.disabled = !enable;
	document.forms.ueml_cleanup.cleanup_do.disabled    = !enable;
	
	if (enable)
		$('#LABEL_CLEANUP_PLEASE_STOP_SC').hide();
	else
		$('#LABEL_CLEANUP_PLEASE_STOP_SC').show();
}