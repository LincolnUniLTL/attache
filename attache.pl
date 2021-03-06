﻿#! /usr/bin/perl
use strict;

if (!exists $ENV{'ORACLE_IS_SET'}) {
  $ENV{'ORACLE_IS_SET'} = 'Y';
  $ENV{'ORACLE_SID'} = 'VGER';
  $ENV{'ORACLE_HOME'} = '/oracle/app/oracle/product/11.2.0.3/db_1';
  $ENV{'LD_LIBRARY_PATH'} = '/oracle/app/oracle/product/11.2.0.3/db_1/lib32';
  exec $0, @ARGV;
}

use DBI;
require DBD::Oracle;
use Data::Dumper;
use MIME::Lite;
use POSIX qw(strftime);
use File::Temp qw(tempfile);

open (LOG, ">>./logs/attache.log") or die "Couldn't open attache.log: $!";
my ($sec, $min, $hr, $day, $mon, $year) = localtime;
print LOG "\n*** Script started on ", sprintf("%04d-%02d-%02d %02d:%02d:%02d", 1900 + $year, $mon + 1, $day, $hr, $min, $sec), " ***\n";

# >>>>>>>>> Configuration *************
our %config;
my $configLocation = shift;
require "$configLocation.pl"
	or die "Could not locate configuration file $configLocation.pl";

if ($config{DEBUG}) {
	$config{mail}{recipients} = [ $config{mail}{maintainer} ];
	delete $config{mail}{bcc};
}
# ********* Configuration <<<<<<<<<<<<<

# >>>>>>>>> Database *************
my $dbh = DBI->connect("dbi:Oracle:host=$config{hostname};sid=$config{db}", $config{user}, $config{pass})
	or die "Unable to connect: ( $DBI::errstr )";

my $sth = $dbh->prepare($config{SQL});

my $records = $dbh->selectall_arrayref($sth) or die $sth->errstr;
$dbh->disconnect() or warn $dbh->errstr;
# ********* Database <<<<<<<<<<<<<
# print Dumper($records); exit;

# >>>>>>>>> CSV file *************
my ($fh, $tempname) = tempfile(SUFFIX => '.csv');

print $fh join(',', @{$sth->{NAME}}), "\n";
foreach my $row (@$records) {
	print $fh '"', join('","', @$row), "\"\n";
}
# ********* CSV file <<<<<<<<<<<<<

# >>>>>>>>> Messaging *************
my %headers = (
	To		=> join(',', @{$config{mail}{recipients}}),
	From	=> $config{mail}{sender},
	Subject	=> $config{mail}{subject},
	);

$headers{Cc} = join(',', @{$config{mail}{copies}}) if (defined $config{mail}{copies}); #TODO: test the join of this!
$headers{Bcc} = join(',', @{$config{mail}{bcc}}) if (defined $config{mail}{bcc}); #TODO: test the join of this!

# print Dumper(\%headers); exit;

$headers{Type} = 'multipart/mixed';
my $msg = MIME::Lite->new(%headers);
$msg->attach(
	Type     => 'TEXT',
	Data     => $config{mail}{body},
);
$msg->attach(
        Type        => 'text/csv',
        Path        => $tempname,
        Filename    => $config{csvName},
        Disposition => 'attachment',
    );
$msg->send()
	or die "Couldn't send whole message: $!\n";
# ********* Messaging <<<<<<<<<<<<<

# *********** add to log file *************
print LOG "*** Script completed for $configLocation on ", sprintf("%04d-%02d-%02d %02d:%02d:%02d", 1900 + $year, $mon + 1, $day, $hr, $min, $sec), " ***\n";

1;