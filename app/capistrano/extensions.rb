# require 'rake'

# rake_require "#{__dir__}/tasks/migrate"
# rake_require "#{__dir__}/tasks/assets"

# following method used in rake tasks.
def test_running(cap_pid_file_sym)
  pid_file = fetch(cap_pid_file_sym)
  test("[ -f #{pid_file} ] && kill -0 `cat #{pid_file}`")
end

def pid(cap_pid_file_sym)
  pid_file = fetch(cap_pid_file_sym)
  "`cat #{pid_file}`"
end

def config_update(system_config_dir:, service_name:, restart_service_command:, check_config_command: nil, check_running_status_command: nil, args:)
  # if test '[[ $(cat /etc/*-release) =~ Ubuntu ]]'
  #   system_config_dir = Pathname(ubuntu_config_path)
  # elsif test '[[ $(cat /etc/*-release) =~ CentOS ]]'
  #   system_config_dir = Pathname(centos_config_path)
  # else
  #   info "Current linux distribution not supported, skip `#{service_name}`!"
  #   exit
  # end
  system_config_dir = Pathname(system_config_dir) unless system_config_dir.is_a?(Pathname)

  if not args[:use_git].nil?
    invoke 'git:clone'
    invoke 'git:update'
    invoke 'git:create_release'
    invoke 'deploy:set_current_revision'
    invoke 'deploy:symlink:linked_dirs'
  end

  deploy_to = capture("cd #{deploy_to()}; pwd")
  project_config_dir = "#{deploy_to}/current/config/#{service_name}/#{fetch(:stage)}"
  # 这里使用 find, 是因为我们要获取服务上的文件列表，不是本地。
  project_config_files = capture("find #{project_config_dir} -name *.erb").split("\n").map {|e| Pathname(e) }

  should_reload_service = false

  project_config_files.each do |project_config_file|
    old_project_config_file = project_config_file
    project_config_file = old_project_config_file.sub_ext('') # remove .erb suffix
    ruby_script = <<-HEREDOC
require "erb"
require "yaml"
erb = ERB.new(File.read("#{old_project_config_file}"))
config = YAML.load_file("#{deploy_to}/current/Procfile.local").dig("#{service_name}", "#{fetch(:stage)}")
File.write("#{project_config_file}", erb.result_with_hash(config.merge("config_base_name"=>"#{project_config_file.basename(".conf")}")))
HEREDOC
    info "generating #{project_config_file}"
    execute "ruby -e '#{ruby_script}'"

    system_config_name = project_config_file.relative_path_from(project_config_dir)
    system_config_file = system_config_dir.join(system_config_name)
    system_sub_conf_dir = system_config_file.dirname

    # if system config exist, and two one no diff.
    next if test "[ -e #{system_config_file} ] && diff #{system_config_file} #{project_config_file} -q"

    execute "test -d #{system_sub_conf_dir} || sudo mkdir -pv #{system_sub_conf_dir}"

    should_reload_service = true

    # if system config exist, and new than project one, maybe someone changed it.
    if test "[[ -e #{system_config_file} && #{system_config_file} -nt #{project_config_file} ]]"
      # backup it before overwrite.
      execute :sudo, "mv #{system_config_file} #{system_config_file}-#{Time.now.strftime('%Y-%m-%d_%H:%M:%S')}"
    end

    execute :sudo, "cp -a #{project_config_file} #{system_config_file}"
  end

  return info "Skip reboot #{service_name} because no config is changed." if should_reload_service == false

  unless check_config_command.nil?
    info 'Checking configurations'
    execute :sudo, check_config_command
  end

  info 'Restarting service'
  execute :sudo, restart_service_command

  unless check_running_status_command.nil?
    info 'Checking running status'
    execute :sudo, check_running_status_command
  end

  info "#{service_name} is reloaded!"
end
