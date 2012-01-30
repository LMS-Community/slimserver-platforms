#!/usr/bin/perl
#-------------------------------------------------------------------------
#  Copyright 2007, NETGEAR
#  All rights reserved.
#-------------------------------------------------------------------------

do "/frontview/lib/cgi-lib.pl";
do "/frontview/lib/addon.pl";

# initialize the %in hash
%in = ();
ReadParse();

my $operation      = $in{OPERATION};
my $command        = $in{command};
my $enabled        = $in{"CHECKBOX_%ADDON%_ENABLED"};
my $data           = $in{"data"};

get_default_language_strings("%ADDON%");
 
my $xml_payload = "Content-type: text/xml; charset=utf-8\n\n"."<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
 
if( $operation eq "get" )
{
  $xml_payload .= Show_%ADDON%_xml();
}
elsif( $operation eq "set" )
{
  if( $command eq "RemoveAddOn" )
  {
    # Remove_Service_xml() removes this add-on
    $xml_payload .= Remove_Service_xml("%ADDON%", $data);
  }
  elsif ($command eq "ToggleService")
  {
    # Toggle_Service_xml() toggles the enabled state of the add-on
    $xml_payload .= Toggle_Service_xml("%ADDON%", $enabled);
  }
  elsif ($command eq "ModifyAddOnService")
  {
    # Modify_%ADDON%_xml() processes the input form changes
    $xml_payload .= Modify_%ADDON%_xml();
  }
}

print $xml_payload;
  

sub Show_%ADDON%_xml
{
  my $xml_payload = "<payload><content>" ;

  # check if service is running or not 
  my $enabled = GetServiceStatus("%ADDON%");

  # get %ADDON%_RUNTIME_SECS parameter from /etc/default_services
  my $run_time = GetValueFromServiceFile("%ADDON%_RUNTIME_SECS");

  if( $run_time eq "not_found" )
  {
    # set run_time to a default value
    $run_time = "60";
  }

  my $enabled_disabled = "disabled";
     $enabled_disabled = "enabled" if( $enabled );

  # return run_time value for HTML
  $xml_payload .= "<%ADDON%_RUNTIME_SECS><value>$run_time</value><enable>$enabled_disabled</enable></%ADDON%_RUNTIME_SECS>"; 

  $xml_payload .= "</content><warning>No Warnings</warning><error>No Errors</error></payload>";
  
  return $xml_payload;
}


sub Modify_%ADDON%_xml 
{
  my $run_time  = $in{"%ADDON%_RUNTIME_SECS"};
  my $SPOOL;
  my $xml_payload;
  
  $run_time = "60" if( $run_time eq "" );
  
  $SPOOL .= "
if grep -q %ADDON%_RUNTIME_SECS /etc/default/services; then
  sed -i 's/%ADDON%_RUNTIME_SECS=.*/%ADDON%_RUNTIME_SECS=${run_time}/' /etc/default/services
else
  echo '%ADDON%_RUNTIME_SECS=${run_time}' >> /etc/default/services
fi
";
 
  if( $in{SWITCH} eq "YES" ) 
  {
    $xml_payload = Toggle_Service_xml("%ADDON%", $enabled);
  }
  else
  {
    spool_file("${ORDER_SERVICE}_%ADDON%", $SPOOL);
    empty_spool();

    $xml_payload = _build_xml_set_payload_sync();
  }
  return $xml_payload;
}


1;
