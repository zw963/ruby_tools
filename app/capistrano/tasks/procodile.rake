namespace :procodile do
  desc 'Start procodile processes'
  task :start do
    on roles(fetch(:procodile_roles, [:app])) do
      rvm_run "procodile start -r #{current_path}"
    end
  end

  desc 'Quiet the crawler process'
  task :quiet_crawler do
    on roles(fetch(:procodile_roles, [:app])) do
      crawler_processes = fetch(:crawler, []).join(',')

      if not crawler_processes.empty? and test('procodile status')
        puts '1'*100
        rvm_run "procodile stop -r #{current_path} -p #{crawler_processes}"
      end
    end
  end

  desc 'Stop procodile processes'
  task :stop do
    on roles(fetch(:procodile_roles, [:app])) do
      rvm_run "procodile stop -r #{current_path}"
    end
  end

  desc 'Restart procodile processes'
  task :restart do
    on roles(fetch(:procodile_roles, [:app])) do
      rvm_run "procodile restart -r #{current_path}"
    end
  end

  def rvm_run(command, gemset='all')
    # 这里的 all 就是 default gem set.
    # 事实上这里的代码，直接 execute command 也工作的。
    execute "rvm #{fetch(:rvm_ruby_version, gemset)} do #{command}"
  end
end

before 'deploy:started', 'procodile:quiet_crawler'
after 'deploy:finished', "procodile:restart"
