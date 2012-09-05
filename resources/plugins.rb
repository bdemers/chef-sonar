# sonar_plugins resource
# Installs a list of sonar plugins from remote locations

actions :create

# List of plugins to install
attribute :plugins, :kind_of => Array, :default => []
# plugin directory
attribute :plugins_dir, :kind_of => String, :required => true

def initialize(*args)
  super
  @action = :create
end