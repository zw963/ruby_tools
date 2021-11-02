namespace :deploy do
  desc 'Precompile assets'
  task :assets do
    on roles(fetch(:procodile_roles, [:app])) do
      within release_path do
        execute :rake, 'assets:precompile'
      end
    end
  end

  desc "deflate assets use brotli"
  task :deflate do
    on roles(fetch(:procodile_roles, [:app])) do
      within release_path do
        execute :rake, "assets:deflate"
      end
    end
  end

  # task :deflate do
  #     on roles(fetch(:procodile_roles, [:app])) do
  #       deploy_to = capture("cd #{deploy_to()}; pwd")
  #       assets_folder = "#{deploy_to}/shared/public/assets"
  #       within release_path do
  #         ruby_script = <<-HEREDOC
  # require "json"
  # require "brotli"
  # sprockets_manifest_json_file = Dir.glob("#{assets_folder}/.sprockets-manifest*.json").first
  # assets = JSON.load_file(sprockets_manifest_json_file).dig("assets").values
  # assets.each do |asset|
  #   asset_file = "#{assets_folder}/" + asset
  #   writer = Brotli::Writer.new File.open(asset_file +".br", "w")
  #   writer.write File.read(asset_file)
  #   writer.close
  # end
  # HEREDOC
  #         info "Creating brotli compressed assets"
  #         execute :bundle, "exec ruby -e '#{ruby_script}'"
  #       end
  #     end
  #   end
end

after 'deploy:assets', 'deploy:deflate'
