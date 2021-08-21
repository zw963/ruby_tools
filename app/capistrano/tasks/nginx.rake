desc 'Update nginx config'
task :update_nginx, :use_git do |_task_name, args|
  on roles(:app) do
    config_update(
      service_name: 'nginx',
      ubuntu_config_path: '/etc/nginx/sites-enabled',
      centos_config_path: '/etc/nginx/conf.d',
      check_config_command: 'nginx -t',
      restart_service_command: 'nginx -s reload',
      args: args
    )
  end
end

after 'deploy:finished', "update_nginx"
