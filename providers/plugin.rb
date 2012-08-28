

action :create do
  Chef::Log::debug("Installing sonar plugin: #{new_resource.name} from: #{new_resource.remote_url}")

  new_resource.gav_resolution_service_base(new_resource.gav_resolution_service_base || node[:sonar][:plugin_resolution_service])
  new_resource.gav_resolution_service_repository(new_resource.gav_resolution_service_repository || node[:sonar][:plugin_repository])
  new_resource.remote_url( new_resource.remote_url || "#{new_resource.gav_resolution_service_base}r=#{new_resource.gav_resolution_service_repository}&g=#{new_resource.group}&a=#{new_resource.name}&v=#{new_resource.version}&e=jar" )


  remote_file "#{node[:sonar][:dir]}/plugins/#{new_resource.name}.jar" do
    source new_resource.remote_url
    mode 0440
    if node[:sonar][:create_user]
      owner node[:sonar][:service_user]
      group node[:sonar][:service_group]
    end
  end

end
