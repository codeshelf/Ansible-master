#!/usr/bin/perl -w
use JSON;

my $server = $ARGV[0];
my $port = "0";
my $curl = "";

# if we are called with two arguments, we're checking a site controller
if (@ARGV == 2) {
	my $port = $ARGV[1];
	$curl = `curl http://home1:$port/adm/healthchecks 2>/dev/null`;
} else {
	# otherwise we are checking an app server
	$curl = `curl http://$server:8181/adm/healthchecks 2>/dev/null`;
}

# make sure we got something useful back from the web server
if (length($curl) == 0) {
	print_error($server);
} else {
	# create the panel if we did
	print_status($server, $curl);
}

exit 0;

sub print_status {
	# get arguments
	my ($server, $curl) = @_;
	# decode the results from the webserver
	$json_stuff = decode_json($curl);

	# Figure out if the device is up, down, or unhealthy
	my $status = "Online";
	foreach my $item (keys %$json_stuff) {
                # Do not take into account the IsProduction "check"
                if ($item eq "IsProduction") {
                        next;
                }

                # Do not take into account the PicksActivity "check"
                if ($item eq "PicksActivity") {
                        next;
                }

		if ($json_stuff->{$item}->{'healthy'} eq "false") {
			# We only fail a server at this stage if the database is offline
			if (index($json_stuff->{$item}->{'message'}, 'Database') != -1) {
				$status = "Offline";
				last;
			} else {
				$status = "Warning";
			}
		}
	}

	# from our status, start the appropriate panel
	# sucess = green
	# danger = red
	# warning = yellow
	if ($status eq "Online") {
		print '<div class="panel panel-success">';
	} else {
		if ($status eq "Offline") {
			print '<div class="panel panel-danger">';
		} else {
			print '<div class="panel panel-warning">';
		}
	}

	print '
<div class="panel-heading" role="tab" id="headingOne">
	<h4 class="panel-title">
		<a class="collapsed" role="button" data-toggle="collapse" data-parent="#accordion" href="#collapse'.$server.'" aria-expanded="false" aria-controls="collapse'.$server.'">
	';

        my $title = "Default Title";
        if ($server eq "betelgeuse") {
                $title = $server . " (Accu-Logistics) : " . $status;
        } elsif ($server eq "capella") {
                $title =  $server . " (PFSweb) : " . $status;
        } elsif ($server eq "deneb") {
                $title =  $server . " (L\'Oreal) : " . $status;
        } else {
                $title = $server . ": " . $status;
        }
        print $title;

        print '</a></h4>';

        if ($json_stuff->{"PicksActivity"}) {
                print "<p>" . $json_stuff->{"PicksActivity"}->{"message"} . "</p>";
        }

        print '</div>
<div id="collapse'.$server.'" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingOne">
<div class="panel-body">
        ';

	print '
<table class="table">
	<thead>
	     <tr>
		<th>Health Check</th>
		<th>Status</th>
		<th>Summary</th>
	    </tr>
	</thead>
<tbody>
	';

	foreach my $item (keys %$json_stuff){
		print "<tr>";
		print "<td>" . $item . "</td>";
		# The app servers return booleans, turn them into something more pleasing
                if ($json_stuff->{$item}->{'healthy'} eq "true") {
                        print "<td style=\"color:green\">OK</td>";
                } else {
                        print "<td style=\"color:red\">Failed</td>";
                }
		print "<td>" . $json_stuff->{$item}->{'message'} . "</td>";
		print "</tr>";
		print "\n";
	}

	print "</tbody></table>";

	print "</div>";
	print "</div>";
	print "</div>";
}

sub print_error {
	# this function is called when an absolute error occurs
	# it just prints a red panel with nothing in it
	my ($server) = @_;

        if ($server eq "sc10022") {
		print '
	<div class="panel panel-danger">
	<div class="panel-heading" role="tab" id="headingOne">
		<h4 class="panel-title">
			<a class="collapsed" role="button" data-toggle="collapse" data-parent="#accordion" href="#collapse'.$server.'" aria-expanded="false" aria-controls="collapse'.$server.'">
		';
		print $server . ": Down";
		print '
			</a>
				</h4>
			</div>
		<div id="collapse'.$server.'" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingOne">
		<div class="panel-body">
		';

		print "<p>Tunnel might be stuck. Please run \"kick-tunnel sc10022\" in the Control Panel or contact Devops.</p>";

		print "</div>";
		print "</div>";
		print "</div>";
        } else {
		print '
	<div class="panel panel-danger">
	<div class="panel-heading" role="tab" id="headingOne">
		<h4 class="panel-title">
			<a class="collapsed" role="button" data-toggle="collapse" data-parent="#accordion" href="#collapse'.$server.'" aria-expanded="false" aria-controls="collapse'.$server.'">
		';
		print $server . ": Down";
		print '
			</a>
				</h4>
			</div>
		<div id="collapse'.$server.'" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingOne">
		<div class="panel-body">
		';

		print "<h2>Please contact Devops</h2>";

		print "</div>";
		print "</div>";
		print "</div>";
        }

}

