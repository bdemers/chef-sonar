#
# Cookbook Name:: sonar
# Recipe:: default
#
# Copyright 2011, Christian Trabold
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "java"

package "unzip"

sonar_current_link = "#{node[:sonar][:dir]}/current"
sonar_version_path = "#{node[:sonar][:dir]}/sonar-#{node[:sonar][:version]}"
sonar_version_zip = "#{sonar_version_path}.zip"

plugins_link = "#{node[:sonar][:dir]}/current/extensions/plugins"
plugins_dir_path = "#{node[:sonar][:dir]}/plugins"


# Create a user to run the service
if node[:sonar][:create_user]
  group node[:sonar][:service_group] do
  end

# Create the Sonar User
  user node[:sonar][:service_user] do
    comment "Sonar User"
    gid node[:sonar][:service_group]
  end
end

directory node[:sonar][:dir] do
  mode 0755
  recursive true
  unless node[:os] == 'windows'
    owner node[:sonar][:service_user]
    group node[:sonar][:service_group]
  end
end

remote_file sonar_version_zip do
  source "#{node[:sonar][:mirror]}/sonar-#{node[:sonar][:version]}.zip"
  mode "0644"
  checksum "#{node['sonar']['checksum']}"
  not_if { ::File.exists?(sonar_version_zip) }
end

execute 'unzip sonar' do
  command "unzip #{sonar_version_zip} -d #{node[:sonar][:dir]}"
  not_if { ::File.directory?(sonar_version_path) }
  unless node[:os] == 'windows'
    user node[:sonar][:service_user]
    group node[:sonar][:service_group]
  end
end

link sonar_current_link do
  to sonar_version_path
end


directory plugins_link do
  action :delete
  recursive true
  only_if {::File.directory?( plugins_link )}
end

directory plugins_dir_path do
  action :create
  recursive true
  unless node[:os] == 'windows'
    owner node[:sonar][:service_user]
    group node[:sonar][:service_group]
  end
end

link plugins_link do
  to plugins_dir_path
end

#install plugins before starting up server
sonar_plugins 'plugins' do
  plugins node[:sonar][:plugins]
  plugins_dir plugins_dir_path
end

#ruby_block 'test-log' do
#  block do
#    Chef::Log.info( "WTF: #{foo.updated_by_last_action?}" )
#  end
#end

link "/etc/init.d/sonar" do
  to "#{sonar_current_link}/bin/#{node['sonar']['os_kernel']}/sonar.sh"
end

template "sonar.properties" do
  path "#{sonar_current_link}/conf/sonar.properties"
  source "sonar.properties.erb"
  owner "root"
  group "root"
  mode 0644
end

template "wrapper.conf" do
  path "#{sonar_current_link}/conf/wrapper.conf"
  source "wrapper.conf.erb"
  owner "root"
  group "root"
  mode 0644
end

template "sonar.sh" do
  path "#{sonar_current_link}/bin/#{node['sonar']['os_kernel']}/sonar.sh"
  source "sonar.sh.erb"
  owner "root"
  group "root"
  mode 0755
end

service 'sonar' do
  action [ :start,  :enable ]
  supports :status => true, :restart => true
  status_command '/etc/init.d/sonar status | grep "is running"'
  subscribes :stop, resources("execute[unzip sonar]",
                              "link[/etc/init.d/sonar]",
                              "template[sonar.properties]",
                              "template[wrapper.conf]",
                              "template[sonar.sh]",
                              "sonar_plugins[plugins]"
                              ), :immediately
end