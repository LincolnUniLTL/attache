=======
attache
======
Send reports from SQL queries on a [Voyager](http://www.exlibrisgroup.com/category/Voyager)® server as CSV file attachments.

This is a Perl script you can place on your Voyager® server. It's useful for regular reports you might want to send to administrators in your library. Typically, you would invoke it as a cron job. If you set up report configuration files, you can pass them through as a parameter to this script, and have the results of an SQL query emailed to your recipient(s). You can also pass parameters to your SQL queries in case that is helpful.

Assumptions
------------
* **perl path.** For the sake of convention, this is set to _/usr/bin/perl_ though our server has it somewhere else. Set up a symlink to make your life easier.

Executing it
------------
It's an interpreted script, you just have to upload it somewhere, make sure it's executable or readable to perl, and run it.

**Requirements**

Ours runs on the Unix box that runs Voyager®. I don't even know if that product runs on other platforms.

* **Perl.** Funnily, Perl is needed to run Perl scripts. We run 5.12. I suspect it will run on any 5.x up.
* **Perl modules.** Possibly you can substitute some, but you're on your own. These are used and required:

 * [Data::Dumper](http://perldoc.perl.org/Data/Dumper.html)
 * [DBI](http://search.cpan.org/~timb/DBI-1.623/DBI.pm)
 * [DBD::Oracle](http://search.cpan.org/~pythian/DBD-Oracle-1.68/lib/DBD/Oracle.pm)
 * [MIME::Lite](http://search.cpan.org/~rjbs/MIME-Lite-3.030/lib/MIME/Lite.pm)
 * [File::Temp](http://perldoc.perl.org/File/Temp.html)

 Note that there are some modules we would ideally use but didn't (CSV, Config, Logger) but we don't have admin and didn't want to go through the process of requesting them installed. I would fully support a fork that did the sensible thing.

* **Oracle® database**. Again, not sure if anything else is ever deployed for Voyager®, but you'd need to hack the script a bit and make sure that its Perl DBI driver is available if you were using something else.

**Configuring**

Use one of the example report configuration files provided. Copy it, rename it, and modify it. The settings are reasonably explanatory.

The script will expect you to set at least these values in your report configurations to run successfully:

* _$config{DEBUG}_: 1 or 0
* database parameters: hostname, username, etc
* _$config{SQL}_: and if you want to pass parameters to your query, load them into a variable at the beginning of the config file using _shift_ or similar (see example [EXAMPLE.bibs_created_by_operator.pl](EXAMPLE.bibs_created_by_operator.pl#l10))
* _$config{csvName}_: how to name your CSV attachment
* _$config{mail}_: specifically its members _{recipients}_ (yes more than one possible), _{sender}_, _{subject}_, _{body}_
* _$config{maintainer}_ if you want to run it with _$config{DEBUG}_ on, which you probably do at first

**Running**

Invoke the script and add the name of the report configuration file (without the _.pl_ extension) as the first argument. For example:

    /path/to/script/attache.pl name_of_report

(I don't know if this would find a config file in a directory that is not the same as the script. Please let me know.)

If you want to pass **parameters** to your SQL query (or for anything in config I guess), go for:

    /path/to/script/attache.pl name_of_report param1 param2 paramN

Set _$config{DEBUG}_ to 0 and warn your intended recipients when you are ready to do a real test.

When you are happy and you know it, optionally add your command line into your **crontab** to run it at desired intervals. As an example, we have an entry like this:

    # Send monthly bibs created by Ms Cataloguer to Ms Cataloguer at 2.01pm on the 1st of the month
	01 14 1 * * /[...]/home/voyager/attache.pl bibs_created_by_op [cataloguer_surname]

Issues
----------
Please report or peruse any issues, or suggest enhancements at the Github repository master:

<http://github.com/LincolnUniLTL/attache/issues>

The project's home is at <http://github.com/LincolnUniLTL/attache> and some links in this README are relative to that.
