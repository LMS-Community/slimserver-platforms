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
my $enabled        = $in{"CHECKBOX_UEML_ENABLED"};
my $data           = $in{"data"};

get_default_language_strings("UEML");
 
my $xml_payload = "Content-type: text/xml; charset=utf-8\n\n"."<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
 
if( $operation eq "get" )
{
  $xml_payload .= Show_UEML_xml();
}
elsif( $operation eq "set" )
{
  if( $command eq "RemoveAddOn" )
  {
    # Remove_Service_xml() removes this add-on
    $xml_payload .= Remove_Service_xml("UEML", $data);
  }
  elsif ($command eq "ToggleService")
  {
    # Toggle_Service_xml() toggles the enabled state of the add-on
    $xml_payload .= Toggle_Service_xml("UEML", $enabled);
  }
  elsif ($command eq "ModifyAddOnService")
  {
    # Modify_UEML_xml() processes the input form changes
    $xml_payload .= Modify_UEML_xml();
  }
}

# handle UEML cleanup requests
elsif ($operation eq 'cleanup') {
	run_cleanup($command);
}
elsif ($operation eq 'get_web_port') {
	$xml_payload .= get_web_port();
}

print $xml_payload;
  

sub Show_UEML_xml
{
  my $xml_payload = "<payload><content>" ;

  $xml_payload .= "</content><warning>No Warnings</warning><error>No Errors</error></payload>";
  
  return $xml_payload;
}


sub Modify_UEML_xml 
{
  my $xml_payload;
  
  if( $in{SWITCH} eq "YES" ) 
  {
    $xml_payload = Toggle_Service_xml("UEML", $enabled);
  }
  else
  {
    $xml_payload = _build_xml_set_payload_sync();
  }
  return $xml_payload;
}

# custom handler to run UEML cleanup tool
sub run_cleanup 
{
	my $command = shift;
	
	my $params = '';
	
	if ($command =~ /prefs/) {
		$params .= ' --prefs';
	}

	if ($command =~ /cache/) {
		$params .= ' --cache';
	}
	
	if ($params) {
		my $SPOOL = "cd /usr/share/uemusiclibrary && ./cleanup.pl $params\n";
		spool_file("${ORDER_SERVICE}_UEML", $SPOOL);
		empty_spool();
	}
}

sub get_web_port
{
	my $port = 3546;
	my $prefFile = '/c/.uemusiclibrary/prefs/server.prefs';
	
	if (-r $prefFile) {
		if (open(PREF, $prefFile)) {
			local $_;
			while (<PREF>) {
				if (/^httpport(:| \=)? (\d+)$/) {
					$port = $2;
					last;
				}
			}

			close(PREF);
		}
	}
	
	return "<payload><content>$port</content><warning>No Warnings</warning><error>No Errors</error></payload>";
}

1;
