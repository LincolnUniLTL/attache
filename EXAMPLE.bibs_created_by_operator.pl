#! /usr/bin/perl
use strict;
use Data::Dumper;
use POSIX qw(strftime);

my ($sec, $min, $hour, $day, $month, $year, $wday, $yday, $isdst) = localtime;
my @lastMonth = ($sec, $min, $hour, $day, $month - 1, $year);
my $attachmentPeriod = strftime("%B %Y", @lastMonth);

my $operatorMatch = shift;

our %config = (
	'DEBUG'		=> '1',
	'hostname'	=> 'localhost',
	'db'		=> 'VGER',
	'user'		=> 'ro_USERNAME',
	'pass'		=> '*******',
	'SQL'		=> <<EOQ
	SELECT DISTINCT
		BIB_MASTER.BIB_ID,
		OPERATOR.LAST_NAME || ', ' || OPERATOR.FIRST_NAME || ' ' || OPERATOR.MIDDLE_INITIAL AS OpName,
		to_char(BIB_HISTORY.ACTION_DATE, 'MON-YYYY') AS CreateMonth,
		TITLE_BRIEF AS Title,
		BIB_TEXT.BIB_FORMAT,
		BIB_TEXT.NETWORK_NUMBER,
		BIB_TEXT.SERIES,
		BIB_TEXT.FIELD_008,
		ELINK_INDEX.LINK_TYPE
	FROM
		ELINK_INDEX, OPERATOR, BIB_MASTER, BIB_HISTORY, BIB_TEXT
	WHERE
		BIB_MASTER.BIB_ID = BIB_HISTORY.BIB_ID
		AND
		OPERATOR.OPERATOR_ID = BIB_HISTORY.OPERATOR_ID
		AND
		BIB_MASTER.BIB_ID = BIB_TEXT.BIB_ID
		AND
		ELINK_INDEX.RECORD_ID = BIB_MASTER.BIB_ID
		AND
		OPERATOR.LAST_NAME LIKE '%$operatorMatch%'
		AND
		BIB_HISTORY.ACTION_DATE >= TRUNC( ADD_MONTHS(SYSDATE,-1), 'MONTH')
		AND
		BIB_HISTORY.ACTION_DATE <= LAST_DAY( ADD_MONTHS(SYSDATE,-1) )
		AND
		BIB_HISTORY.ACTION_TYPE_ID = 1
EOQ
	,
	'csvName'	=> 'bibs-created-by-operator-' . strftime("%Y-%m", @lastMonth) . '.csv',
	'mail'		=> {
		'recipients'	=> [ 'Recipient Person <recipient@example.edu>' ],
		'bcc'			=> [ 'Over Lord <overlord@example.edu>' ],
		'sender'		=> 'Over Lord <overlord@example.edu>',
		'subject'		=> "Bibs created by operator report for $attachmentPeriod",
		'body'			=> <<MESG
Kia ora

The attached file $config{csvName} contains details of bib records created by operators matching "*$operatorMatch*" for $attachmentPeriod.

Cheers
Your favourite friendly automated Digital Access people
MESG
		,
		'maintainer'	=> 'Technical Person <techie@example.edu>',
	},
);

1;