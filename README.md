magerake
=======

A collection of simple tasks for Magento sites.

Installing
----------

1. Put the `magerake.rake` file in the root of your Magento site.
2. If you already have a `Rakefile`, add this line at the top of it:

        import 'magerake.rake'

  Otherwise, you can just rename `magerake.rake` to `Rakefile`.
3. `rake -T mage` for a list of available tasks.

Tasks
-----

These are some of the included tasks. More are coming.

### rake mage:cc

Clears the Magento cache. This task makes two assumptions: that you are using the filesystem for caching, and the cache is located in `MAGE_ROOT/var/cache`.

### rake mage:cs

Clears Magento sesssion data. Grabs the session data location from your `local.xml` configuration.

If you use the filesystem for sessions, this task assumes the data is located in `MAGE_ROOT/var/session`. If you are using the database, the table prefix and database credentials are fetched from `local.xml` and the table `PREFIX_core_session` is truncated.

### rake mage:watch:system

Alias for `tail -f MAGE_ROOT/var/log/system.log`.

### rake mage:watch:exception

Alias for `tail -f MAGE_ROOT/var/log/exception.log`.

### rake mage:watch

Alias for `tail -f MAGE_ROOT/var/log/system.log -f MAGE_ROOT/var/log/exception.log`.

### rake mage:backup:db

Makes a backup of your database, ignoring all the log tables including:

    log_customer
    log_quote
    log_summary
    log_summary_type
    log_url
    log_url_info
    log_visitor
    log_visitor_info
    log_visitor_online

Database credentials are fetched from `local.xml`. The file that is generated is gzip compressed and has the name `DATABASE_YYYYDDMM.sql.gz`, placed a directory above `MAGE_ROOT`.

### rake mage:backup:site

Creates a compressed archive the site without junk files. The following folders are excluded: 

    MAGE_ROOT/.git
    MAGE_ROOT/media
    MAGE_ROOT/var

The file that is generated is gzip compressed and has the name `MAGE_ROOT_BASENAME.YYYYMMDD.tgz`.

### rake mage:backup

Runs both backup commands.

### rake mage:modman:init

Alias for `modman init`.