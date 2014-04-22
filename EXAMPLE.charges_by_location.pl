#! /usr/bin/perl
use strict;
use Data::Dumper;
use POSIX qw(strftime);

my ($sec, $min, $hour, $day, $month, $year, $wday, $yday, $isdst) = localtime;
my @lastMonth = ($sec, $min, $hour, $day, $month - 1, $year);
my $attachmentPeriod = strftime("%B %Y", @lastMonth);

our %config = (
	'DEBUG'		=> '1',
	'hostname'	=> 'localhost',
	'db'		=> 'VGER',
	'user'		=> 'ro_USERNAME',
	'pass'		=> '*******',
	'SQL'		=> <<EOQ
	SELECT BIB_MFHD.BIB_ID, BIB_TEXT.TITLE, MFHD_ITEM.CHRON, CIRC_TRANSACTIONS.PATRON_ID, PATRON.LAST_NAME, PATRON.FIRST_NAME, CIRC_TRANSACTIONS.CHARGE_DATE, CIRC_TRANSACTIONS.CURRENT_DUE_DATE AS Due_date, CIRC_TRANSACTIONS.DISCHARGE_DATE
	FROM
		CIRC_TRANSACTIONS, BIB_MFHD, MFHD_MASTER, MFHD_ITEM, ITEM, PATRON, BIB_TEXT
	WHERE
		CIRC_TRANSACTIONS.PATRON_ID = PATRON.PATRON_ID
		AND
		MFHD_MASTER.MFHD_ID = MFHD_ITEM.MFHD_ID
		AND
		MFHD_ITEM.ITEM_ID = ITEM.ITEM_ID
		AND
		CIRC_TRANSACTIONS.ITEM_ID = ITEM.ITEM_ID
		AND
		BIB_MFHD.BIB_ID = BIB_TEXT.BIB_ID
		AND
		BIB_MFHD.MFHD_ID = MFHD_MASTER.MFHD_ID
		AND
		CIRC_TRANSACTIONS.CHARGE_DATE >= TRUNC( ADD_MONTHS(SYSDATE,-1), 'MONTH')
		AND
		CIRC_TRANSACTIONS.CHARGE_DATE <= LAST_DAY( ADD_MONTHS(SYSDATE,-1) )
		AND
		ITEM.PERM_LOCATION = 4
EOQ
	,
	'csvName'	=> 'charges-by-location-' . strftime("%Y-%m", @lastMonth) . '.csv',
	'mail'		=> {
		'recipients'	=> [ 'Recipient Person <recipient@example.edu>' ],
		'bcc'			=> [ 'Over Lord <overlord@example.edu>' ],
		'sender'		=> 'Over Lord <overlord@example.edu>',
		'subject'		=> "Charges by location report for $attachmentPeriod",
		'body'			=> <<MESG
Kia ora

The attached file $config{csvName} contains details of charges by location for $attachmentPeriod.

Cheers
Your favourite friendly automated Digital Access people
MESG
		,
		'maintainer'	=> 'Technical Person <techie@example.edu>',
	},
);

1;