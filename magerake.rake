current_path = File.dirname(__FILE__)
parent_path = File.dirname(current_path)
project = File.basename(current_path)

namespace :mage do
  desc 'Clear the Magento cache.'
  task :cc do
    sh %{cd #{current_path} && rm -rf var/cache/*}
  end

  desc 'Clear sessions data.'
  task :cs do
    doc = get_config
    sessions = doc.xpath('///session_save').text

    case sessions
    when "files"
      sh %{cd #{current_path} && rm -rf var/sessions/*}
    when "db"
      host, username, password, dbname = get_db_credentials
      table_prefix = doc.xpath('////db/table_prefix').text

      if !table_prefix.empty?
        table_prefix = table_prefix + '_'
      end

      sh %{mysql #{username} #{password} #{dbname} -e "TRUNCATE #{table_prefix}core_session"}
    end
  end

  namespace :watch do
    desc 'Watch the Magento system log.'
    task :system do
      sh %{cd #{current_path} && tail -f var/log/system.log}
    end

    desc 'Watch the Magento exception log.'
    task :exception do
      sh %{cd #{current_path} && tail -f var/log/exception.log}
    end
  end

  desc 'Watch both Magento logs simultaneously.'
  task :watch do
    sh %{cd #{current_path} && tail -f var/log/system.log -f var/log/exception.log}
  end

  namespace :backup do
    today = %x{date +"%Y%m%d"}.chomp

    desc 'Dump the database to file without log tables.'
    task :db do
      doc = get_config
      host, username, password, dbname = get_db_credentials
      ignore_tables = ''
      ["customer", "quote", "summary", "summary_type", "url", "url_info", "visitor", "visitor_info", "visitor_online"].each do |table|
        ignore_tables << " --ignore-table=#{dbname}.log_#{table}"
      end

      sh %{mysqldump #{username} #{password} #{dbname} #{ignore_tables} | gzip > #{parent_path}/#{dbname}.#{today}.sql.gz}
    end

    desc  'Create compressed archive of site without media or useless files.'
    task :files do
      sh %{cd #{current_path} && tar vczf #{parent_path}/#{project}.#{today}.tgz --exclude='./media/*' --exclude='./var/*' --exclude='./.git' .}
    end
  end

  desc 'Runs backup:db and backup:files to create full site backup.'
  task :backup => ["backup:db", "backup:files"]

  namespace :modman do
    desc 'Initialize modman.'
    task :init do
      if !File.exists?(%x{which modman}.chomp) then
        raise "Can't initialize modman, missing modman (silly)."
      end

      sh %{cd #{current_path} && modman init}
    end
  end
end

def get_config
  require 'nokogiri'
  Nokogiri::XML(File.open("#{current_path}/app/etc/local.xml"))
end

def get_db_credentials
  require 'nokogiri'
  Nokogiri::XML(File.open("#{current_path}/app/etc/local.xml"))

  host = doc.xpath('///default_setup/connection/host').first.text
  if !host.empty? then
    host = "-h#{host}"
  end

  username = doc.xpath('///default_setup/connection/username').first.text
  if !username.empty? then
    username = "-u#{username}"
  end

  password = doc.xpath('///default_setup/connection/password').first.text
  if !password.empty? then
    password = "-p#{password}"
  end

  dbname = doc.xpath('///default_setup/connection/dbname').first.text

  return host, username, password, dbname
end
