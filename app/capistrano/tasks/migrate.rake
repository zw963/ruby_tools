namespace :deploy do
  desc 'Runs rake db:migrate'
  task :migrate do
    import '../../tasks/sequel.rake'
    on roles(fetch(:procodile_roles, [:app])) do
      within release_path do
        execute :rake, 'db:migrate'
      end
    end
  end
end

after 'deploy:updated', 'deploy:migrate'
