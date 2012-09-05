
action :create do
  updated = false


  @new_resource.plugins.each do |plugin|

    if plugin[:remote_url].nil?

      plugin[:group] = plugin[:group] || "org.codehaus.sonar-plugins"

      maven_repository_url = (plugin[:maven_repository_url].nil? ? node[:sonar][:maven_repository_url] : plugin[:maven_repository_url])
      plugin[:remote_url] = "#{maven_repository_url}/#{plugin[:group].gsub('.', '/')}/#{plugin[:name]}/#{plugin[:version]}/#{plugin[:name]}-#{plugin[:version]}.jar"
    end


    remote_file = Chef::Resource::RemoteFile.new("#{@new_resource.plugins_dir}/#{plugin[:name]}-#{plugin[:version]}.jar", run_context)
    remote_file.source(plugin[:remote_url])
    remote_file.backup(false)
    remote_file.mode('0440')
    remote_file.run_action(:create_if_missing)

    updated = updated || remote_file.updated_by_last_action?

  end

  # clean up old plugins
  Dir.glob("#{new_resource.plugins_dir}/*.jar").each do |path|
    base = ::File.basename(path)
    if new_resource.plugins.select {|p| "#{p['name']}-#{p['version']}.jar" == base}.empty?
      Chef::Log::info("Deleting plugin: #{base} at: #{path}")
      ::File.delete( path )
      updated = true
    end
  end

  new_resource.updated_by_last_action(updated)
end