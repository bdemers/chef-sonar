

action :create do
  Chef::Log::debug("Installing sonar plugin: #{new_resource.name} from: #{new_resource.remote_url}")

  new_resource.maven_repository_url(new_resource.maven_repository_url || node[:sonar][:maven_repository_url])

  maven_url = "#{new_resource.maven_repository_url}/#{new_resource.group.gsub('.', '/')}/#{new_resource.name}/#{new_resource.version}/#{new_resource.name}-#{new_resource.version}.jar"
  new_resource.remote_url( new_resource.remote_url || maven_url )

  remote_file "#{node[:sonar][:dir]}/plugins/#{new_resource.name}-#{new_resource.version}.jar" do
    source new_resource.remote_url
    mode 0440
    if node[:sonar][:create_user]
      owner node[:sonar][:service_user]
      group node[:sonar][:service_group]
    end
  end

end
