# sonar_plugin resource
# Installs sonar plugins from remote locations

actions :create

# Maven group of the plugin
attribute :group, :kind_of => String, :default => "org.codehaus.sonar-plugins"
#Maven artifact id of the plugin
attribute :name, :kind_of => String, :required => true
#Maven version of the plugin.
attribute :version, :kind_of => String, :required => true

# the repository  to download the files from
attribute :maven_repository_url, :kind_of => String

# the remote url of the sonar plugin.  If this is set gav coordinates will be ignored.
attribute :remote_url, :kind_of => String

def initialize(*args)
  super
  @action = :create
end