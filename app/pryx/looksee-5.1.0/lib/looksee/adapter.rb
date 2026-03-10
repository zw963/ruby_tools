module Looksee
  module Adapter
    autoload :Base, 'looksee/adapter/base'
    autoload :MRI, "looksee/mri.#{RbConfig::CONFIG['ruby_version']}.#{RbConfig::CONFIG["DLEXT"]}"
    autoload :JRuby, 'looksee/JRuby.jar'
  end
end
