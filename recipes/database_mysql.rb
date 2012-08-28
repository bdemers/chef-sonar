include_recipe "mysql::server"

# Setup sonar user
grants_dir = "#{node[:sonar][:dir]}/mysql/"
grants_path = "#{grants_dir}/create_database.sql"

directory grants_dir do
  owner "root"
  group "root"
  mode "0777"
  recursive true
  action :create
end

template grants_path do
  source "create_mysql_database.sql.erb"
  owner "root"
  group "root"
  mode "0444"
  action :create
end

execute "mysql-install-application-privileges" do
  command "/usr/bin/mysql -u root #{node[:mysql][:server_root_password].empty? ? '' : '-p' }#{node[:mysql][:server_root_password]} < #{grants_path}"
end
