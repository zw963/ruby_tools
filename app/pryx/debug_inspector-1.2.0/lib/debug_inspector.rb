require 'rbconfig'
dlext = RbConfig::CONFIG['DLEXT']
begin
  # If the installation task did its job, the extension is in lib/ next to this file.
  require "debug_inspector.#{RbConfig::CONFIG['ruby_version']}.#{dlext}"
  # We only want to define constants if the extension has loaded.
  require_relative "debug_inspector/version"
rescue LoadError
  begin
    # If not, maybe the extension is in ext/
    require_relative "../ext/debug_inspector/debug_inspector.#{dlext}"
    # We only want to define constants if the extension has loaded.
    require_relative "debug_inspector/version"
  rescue LoadError => e
    puts "debug_inspector extension was not loaded (#{e})"
  end
end

if defined?(RubyVM) && defined?(DebugInspector)
  RubyVM::DebugInspector = DebugInspector
  if RubyVM.respond_to?(:deprecate_constant)
    RubyVM.deprecate_constant :DebugInspector
  end
end
