self.SQUEEZEBOX_preaction = function()
{
}

self.SQUEEZEBOX_onloadaction = function()
{
	// set a link to the Logitech Media Server web UI
	$.ajax({
		url: NasState.otherAddOnHash['SQUEEZEBOX'].DisplayAtom.set_url + '?OPERATION=get_web_port',
		success: function(xmlPayLoad) {
			var port = xmlPayLoad.getElementsByTagName('content').item(0);
			
			if (port.firstChild.data)
				port = port.firstChild.data;
				
			if (isNaN(parseInt(port)))
				port = 9000;
			
			$('#sbwebui').html('<a href="http://' + window.location.hostname + ':' + port + '" target="_blank">Free Your Music!</a>');
		}
	});
	
	toggleCleanupOptions();
}

self.SQUEEZEBOX_enable = function()
{
  document.getElementById('BUTTON_SQUEEZEBOX_APPLY').disabled = false;
}

self.SQUEEZEBOX_remove = function()
{
  if( !confirm(S['CONFIRM_REMOVE_ADDON']) )
  {
    return;
  }
  
  var set_url;
  
  if ( confirm(S['CONFIRM_KEEP_ADDON_DATA']) )
  {
    set_url = NasState.otherAddOnHash['SQUEEZEBOX'].DisplayAtom.set_url
                + '?OPERATION=set&command=RemoveAddOn&data=preserve';
  }
  else
  {
    set_url = NasState.otherAddOnHash['SQUEEZEBOX'].DisplayAtom.set_url
                + '?OPERATION=set&command=RemoveAddOn&data=remove';
  }

  applyChangesAsynch(set_url,  SQUEEZEBOX_handle_remove_response);
}

self.SQUEEZEBOX_handle_remove_response = function()
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
         updateAddOn('SQUEEZEBOX');
         if (!NasState.otherAddOnHash['SQUEEZEBOX'])
         {
            remove_element('SQUEEZEBOX');
            if (getNumAddOns() == 0 )
            {
               document.getElementById('no_addons').className = 'visible';
            }
         }
         else
         {
           hide_element('SQUEEZEBOX_LINK');
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

self.SQUEEZEBOX_page_change = function()
{
  var id_array = new Array();
  for (var ix = 0; ix < id_array.length; ix++ )
  {
     NasState.otherAddOnHash['SQUEEZEBOX'].DisplayAtom.fieldHash[id_array[ix]].value = 
     document.getElementById(id_array[ix]).value;
     NasState.otherAddOnHash['SQUEEZEBOX'].DisplayAtom.fieldHash[id_array[ix]].modified = true;
  }
}


self.SQUEEZEBOX_enable_save_button = function()
{
  document.getElementById('BUTTON_SQUEEZEBOX_APPLY').disabled = false;
}

self.SQUEEZEBOX_apply = function()
{

   var page_changed = false;
   var set_url = NasState.otherAddOnHash['SQUEEZEBOX'].DisplayAtom.set_url;

   var enabled = document.getElementById('CHECKBOX_SQUEEZEBOX_ENABLED').checked ? 'checked' :  'unchecked';
   var current_status  = NasState.otherAddOnHash['SQUEEZEBOX'].Status;
   if ( page_changed )
   {
      set_url += '?command=ModifyAddOnService&OPERATION=set&' + 
                  NasState.otherAddOnHash['SQUEEZEBOX'].DisplayAtom.getApplicablePagePostStringNoQuest('modify') +
                  '&CHECKBOX_SQUEEZEBOX_ENABLED=' +  enabled;
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
      set_url += '?command=ToggleService&OPERATION=set&CHECKBOX_SQUEEZEBOX_ENABLED=' + enabled;
   }
   applyChangesAsynch(set_url, SQUEEZEBOX_handle_apply_response);
}

self.SQUEEZEBOX_handle_apply_response = function()
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
		  success_message_start = success_message_start.replace('%ADDON_NAME%', NasState.otherAddOnHash['SQUEEZEBOX'].FriendlyName);
	      var success_message_stop  = AS['SUCCESS_ADDON_STOP'];
		  success_message_stop = success_message_stop.replace('%ADDON_NAME%', NasState.otherAddOnHash['SQUEEZEBOX'].FriendlyName);

	      if ( NasState.otherAddOnHash['SQUEEZEBOX'].Status == 'off' )
	      {
	        NasState.otherAddOnHash['SQUEEZEBOX'].Status = 'on';
	        NasState.otherAddOnHash['SQUEEZEBOX'].RunStatus = 'OK';

			// enable/disable cleanup options	        
	        toggleCleanupOptions(false);
	        
	        refresh_applicable_pages();
	      }
	      else
	      {
	        NasState.otherAddOnHash['SQUEEZEBOX'].Status = 'off';
	        NasState.otherAddOnHash['SQUEEZEBOX'].RunStatus = 'not_present';

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

self.SQUEEZEBOX_handle_apply_toggle_response = function()
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

self.SQUEEZEBOX_service_toggle = function()
{
  
  var addon_enabled = document.getElementById('CHECKBOX_SQUEEZEBOX_ENABLED').checked ? 'checked' :  'unchecked';
  var set_url    = NasState.otherAddOnHash['SQUEEZEBOX'].DisplayAtom.set_url
                   + '?OPERATION=set&command=ToggleService&CHECKBOX_SQUEEZEBOX_ENABLED='
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
    //if SQUEEZEBOX is enabled
    NasState.otherAddOnHash['SQUEEZEBOX'].Status = 'on';                                             
    NasState.otherAddOnHash['SQUEEZEBOX'].RunStatus = 'OK';                                            
    refresh_applicable_pages();  
    //else if SQUEEZEBOX is disabled
    NasState.otherAddOnHash['SQUEEZEBOX'].Status = 'off';                    
    NasState.otherAddOnHash['SQUEEZEBOX'].RunStatus = 'not_present';         
    refresh_applicable_pages(); 
  }
  else
  {
    display_error_messages(xmlSyncPayLoad);
  }
}

// custom callback to remove Squeezebox prefs/cache etc.
self.SQUEEZEBOX_cleanup = function() 
{
	var prefs = document.forms.squeezebox_cleanup.cleanup_prefs.checked;
	var cache = document.forms.squeezebox_cleanup.cleanup_cache.checked;

	showProgressBar('wait');

	$.ajax({
		url: NasState.otherAddOnHash['SQUEEZEBOX'].DisplayAtom.set_url + '?OPERATION=cleanup&command=' + (prefs ? 'prefs|' : '') + (cache ? 'cache|' : ''),
		cache: false,
		complete: function(jqXHR, textStatus) {
			document.forms.squeezebox_cleanup.cleanup_prefs.checked = false;
			document.forms.squeezebox_cleanup.cleanup_cache.checked = false;
		
			showProgressBar('default');
		}
	});
}

function toggleCleanupOptions(enable)
{
	if (enable == undefined)
		enable = NasState.otherAddOnHash['SQUEEZEBOX'].Status != 'on';
		
	document.forms.squeezebox_cleanup.cleanup_prefs.disabled = !enable;
	document.forms.squeezebox_cleanup.cleanup_cache.disabled = !enable;
	document.forms.squeezebox_cleanup.cleanup_do.disabled    = !enable;
	
	if (enable)
		$('#LABEL_CLEANUP_PLEASE_STOP_SC').hide();
	else
		$('#LABEL_CLEANUP_PLEASE_STOP_SC').show();
}