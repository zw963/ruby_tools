namespace :nginx do
  desc 'Link project nginx config into system nginx'
  task :update do
    on roles(:worker) do
      if test '[[ $(cat /etc/*-release) =~ Ubuntu|Mint ]]'
        nginx_config_dir = '/etc/nginx/sites-enabled'
      elsif test '[[ $(cat /etc/*-release) =~ CentOS ]]'
        nginx_config_dir = '/etc/nginx/conf.d'
      else
        info 'Skip `nginx:update`'
        exit
      end

      if test('sudo nginx -s reload')
        project_nginx_config = "~/current/config/containers/nginx/config/nginx_#{fetch(:stage)}.conf"
        nginx_config_name = "#{fetch(:application)}_#{fetch(:stage)}.conf"
        config = "#{nginx_config_dir}/#{nginx_config_name}"

        # # Broken symlink.
        # if test "[ -L #{config} -a ! -f #{config} ]"
        #   execute :sudo, "rm -f #{config}"
        # end

        if test "[ -f #{config} -a ! -L #{config} ]"
          # Backup not a symlink config
          execute :sudo, "mv #{config} /#{config_config_name}-$(date '+%Y-%m-%d_%H:%M')"
        end

        if test "[ -e #{project_nginx_config} ]"
          execute :sudo, "ln -sf #{project_nginx_config} #{config}"
          execute :sudo, 'nginx -t'
          execute :sudo, 'nginx -s reload'
          info 'nginx is reloaded!'
        else
          fail "#{project_nginx_config} is not exist."
        end
      else
        fail 'nginx start not correct.'
      end
    end
  end
end

# after 'deploy:finished', 'nginx:update'
