require 'minitest/spec'

describe_recipe 'sonar::default' do

  # It's often convenient to load these includes in a separate
  # helper along with
  # your own helper methods, but here we just include them directly:
  include MiniTest::Chef::Assertions
  include MiniTest::Chef::Context
  include MiniTest::Chef::Resources

  describe "installs" do
    it "installs the files to the correct folder" do
      directory(node['sonar']['dir']).must_exist
    end

#    TODO ct 2012-06-27 How to check sonar process?
#    it "starts the server" do
#      service "sonar".must_be_running
#    end
  end

  describe "plugins" do
    it "plugins have correct permissions" do
        node['sonar']['plugins'].each do |plugin|

        plugin_file = "#{node['sonar']['dir']}/plugins/#{plugin[:name]}-#{plugin[:version]}.jar"
        file(plugin_file).must_exist
        # FIXME, regression in chef 0.10.10+10.12.0 http://tickets.opscode.com/browse/CHEF-3235
        #unless node[:os] == 'windows'
        #  file(plugin_file).must_have(:owner, node['sonar']['service_user'])
        #end
      end
    end
  end

  describe "run_state" do
    it "succeed" do
      run_status.success?.must_equal true
    end

    it "service running" do
      service('sonar').must_be_running
      service('sonar').must_be_enabled
    end
  end

end
