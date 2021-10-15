namespace :git do
  desc 'Generate last git hash to public folder'
  task :generate_git_hash_to_public_folder do
    on roles(:app) do
      within deploy_path do
        execute :cat, "revisions.log |tail -n1 > current/public/git_hash"
        info "Copied the last git hash to public/git_hash."
      end
    end
  end
end

after 'deploy:finished', 'git:generate_git_hash_to_public_folder'
