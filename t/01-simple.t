#!/usr/bin/env perl

use warnings;
use strict;
use Test::More tests => 8;
use Pye::MongoDB;

my $pye;

eval {
	$pye = Pye::MongoDB->new(
		log_db => 'test',
		log_coll => 'pye_test',
		be_safe => 1
	);
};

SKIP: {
	if ($@) {
		diag("Skipped: $@.");
		skip("MongoDB needs to be running for this test.", 7);
	}

	ok($pye, "Pye::MongoDB object created");

	ok($pye->log(1, "What's up?"), "Simple log message");

	ok($pye->log(1, "Some data", { hey => 'there' }), "Log message with data structure");

	sleep(0.5);

	ok($pye->log(2, "Yo yo ma"), "Log message for another session");

	my @latest_sessions = $pye->list_sessions;
	is(scalar(@latest_sessions), 2, "We only have one session");

	is($latest_sessions[0]->{_id}, '2', "We have the correct session ID");

	my @logs = $pye->session_log(1);

	is(scalar(@logs), 2, 'Session has two log messages');

	ok(exists $logs[1]->{data} && $logs[1]->{data}->{hey} eq 'there', 'Second log message has a data element');

	#$pye->_remove_session_logs(1);
}

done_testing();
