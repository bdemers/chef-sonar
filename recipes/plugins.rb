
plugins_link = "#{node[:sonar][:dir]}/current/extensions/plugins"
plugins_dir = "#{node[:sonar][:dir]}/plugins"

directory plugins_link do
  action :delete
  recursive true
  only_if {::File.directory?( "#{node[:sonar][:dir]}/current/extensions/plugins" )}
end

directory plugins_dir do
  action :create
  recursive true
  if node[:sonar][:create_user]
    owner node[:sonar][:service_user]
    group node[:sonar][:service_group]
  end
end

 link plugins_link do
   to plugins_dir
 end

node[:sonar][:plugins].each do |plugin|
  sonar_plugin plugin[:name] do
   group plugin[:group]
   name plugin[:name]
   version plugin[:version]
   remote_url plugin[:remote_url]
  end
end