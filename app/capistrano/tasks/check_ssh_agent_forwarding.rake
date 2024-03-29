desc 'Check if agent forwarding is working'
task :check_ssh_agent_forwarding do
  on roles(:all) do |h|
    if test('env | grep SSH_AUTH_SOCK')
      info "Agent forwarding is up to #{h}"
    else
      error "Agent forwarding is NOT up to #{h}"
    end
  end
end
