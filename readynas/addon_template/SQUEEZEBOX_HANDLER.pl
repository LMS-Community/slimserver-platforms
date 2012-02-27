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
my $enabled        = $in{"CHECKBOX_SQUEEZEBOX_ENABLED"};
my $data           = $in{"data"};

get_default_language_strings("SQUEEZEBOX");
 
my $xml_payload = "Content-type: text/xml; charset=utf-8\n\n"."<?xml version=\"1.0\" encoding=\"UTF-8\"?>";
 
if( $operation eq "get" )
{
  $xml_payload .= Show_SQUEEZEBOX_xml();
}
elsif( $operation eq "set" )
{
  if( $command eq "RemoveAddOn" )
  {
    # Remove_Service_xml() removes this add-on
    $xml_payload .= Remove_Service_xml("SQUEEZEBOX", $data);
  }
  elsif ($command eq "ToggleService")
  {
    # Toggle_Service_xml() toggles the enabled state of the add-on
    $xml_payload .= Toggle_Service_xml("SQUEEZEBOX", $enabled);
  }
  elsif ($command eq "ModifyAddOnService")
  {
    # Modify_SQUEEZEBOX_xml() processes the input form changes
    $xml_payload .= Modify_SQUEEZEBOX_xml();
  }
}

# handle Squeezebox cleanup requests
elsif ($operation eq 'cleanup') {
	run_cleanup($command);
}
elsif ($operation eq 'get_web_port') {
	$xml_payload .= get_web_port();
}

print $xml_payload;
  

sub Show_SQUEEZEBOX_xml
{
  my $xml_payload = "<payload><content>" ;

  $xml_payload .= "</content><warning>No Warnings</warning><error>No Errors</error></payload>";
  
  return $xml_payload;
}


sub Modify_SQUEEZEBOX_xml 
{
  my $xml_payload;
  
  if( $in{SWITCH} eq "YES" ) 
  {
    $xml_payload = Toggle_Service_xml("SQUEEZEBOX", $enabled);
  }
  else
  {
    $xml_payload = _build_xml_set_payload_sync();
  }
  return $xml_payload;
}

# custom handler to run Squeezebox cleanup tool
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
		my $SPOOL = "cd /usr/share/squeezeboxserver && ./cleanup.pl $params\n";
		spool_file("${ORDER_SERVICE}_SQUEEZEBOX", $SPOOL);
		empty_spool();
	}
}

sub get_web_port
{
	my $port = 9000;
	my $prefFile = '/c/.squeezeboxserver/prefs/server.prefs';
	
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
