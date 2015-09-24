#!/usr/bin/perl -w
use JSON;
use Data::Dumper;

my $server = $ARGV[0];
my $curl = `curl http://$server:8181/adm/healthchecks 2>/dev/null`;
$json_stuff = decode_json($curl);

my $status = "Online";
foreach my $item (keys %$json_stuff){
        if ($json_stuff->{$item}->{'healthy'} eq "false") {
		if (index($json_stuff->{$item}->{'message'}, 'Database') != -1) {
			$status = "Offline";
			last;
		} else {
			$status = "Warning";
		}
	}
}

if ($status eq "Online") {
	print '<div class="panel panel-success">';
} else {
	if ($status eq "Offline") {
		print '<div class="panel panel-danger">';
	} else {
		print '<div class="panel panel-warning">';
	}
}

print '<div class="panel-heading" role="tab" id="headingOne">
<h4 class="panel-title">
<a class="collapsed" role="button" data-toggle="collapse" data-parent="#accordion" href="#collapse'.$server.'" aria-expanded="false" aria-controls="collapse'.$server.'">';
print $server . ": " . $status;
print '</a>
</h4>
</div>
<div id="collapse'.$server.'" class="panel-collapse collapse" role="tabpanel" aria-labelledby="headingOne">
<div class="panel-body">';

print"\n";
print"<table class=\"table\">
	<thead>
	     <tr>
		<th>Health Check</th>
		<th>Status</th>
		<th>Summary</th>
	    </tr>
	</thead>
	<tbody>";
foreach my $item (keys %$json_stuff){
	print "<tr>";
	print "<td>" . $item . "</td>";
	print "<td>" . $json_stuff->{$item}->{'healthy'} . "</td>";
	print "<td>" . $json_stuff->{$item}->{'message'} . "</td>";
	print "</tr>";
	print "\n";
}

print "</tbody></table>";

print "</div>";
print "</div>";
print "</div>";

print "\n\n\n";
