default_parameters = {
  owner: 'deploy',
  group: 'nginx',
  directory: nil,
  puma_directory: nil,
  working_dir: nil,
  rackup: nil,
  environment: "production",
  daemonize: true,
  pidfile: nil,
  config_path: nil,
  state_path: nil,
  stdout_redirect: nil,
  stderr_redirect: nil,
  output_append: true,
  quiet: false,
  thread_min: 0,
  thread_max: 16,
  bind: nil,
  control_app_bind: nil,
  workers: 0,
  activate_control_app: true,
  logrotate: true,
  exec_prefix: nil,
  config_source: nil,
  config_cookbook: nil,
  worker_timeout: nil,
  preload_app: false,
  prune_bundler: true,
  on_worker_boot: nil }

define :puma_config, default_parameters do

  # Set defaults that require parameters
  params[:directory] ||= "/srv/www/#{params[:name]}"
  params[:working_dir] ||= "#{params[:directory]}/current"
  params[:puma_directory] ||= "#{params[:directory]}/shared/puma"
  params[:config_path] ||= "#{params[:puma_directory]}/#{params[:name]}.config"
  params[:state_path] ||= "#{params[:puma_directory]}/#{params[:name]}.state"
  params[:bind] ||= "unix://#{params[:puma_directory]}/#{params[:name]}.sock"
  params[:control_app_bind] ||= "unix://#{params[:puma_directory]}/#{params[:name]}_control.sock"
  params[:pidfile] ||= "#{params[:directory]}/shared/pids/#{params[:name]}.pid"
  params[:stdout_redirect] ||= "#{params[:working_dir]}/log/puma.log"
  params[:stderr_redirect] ||= "#{params[:working_dir]}/log/puma.error.log"
  params[:bin_path] ||= "/usr/local/bin/puma"
  params[:exec_prefix] ||= "bundle exec"
  params[:config_source] ||= "puma.rb.erb"
  params[:config_cookbook] ||= "opsworks-puma"
  params[:worker_timeout] ||= "60"

  # Create group
  group params[:group]

  # Create user
  user params[:owner] do
    action :create
    comment "deploy user"
    gid params[:group]
    not_if do
      existing_usernames = []
      Etc.passwd {|user| existing_usernames << user['name']}
      existing_usernames.include?(params[:owner])
    end
  end

  # Create app working directory with owner/group if specified
  directory params[:puma_directory] do
    recursive true
    owner params[:owner]
    group params[:group]
  end

  # puma.rb.erb -> {app}.config
  template params[:name] do
    source params[:config_source]
    path params[:config_path]
    cookbook params[:config_cookbook]
    mode "0644"
    owner params[:owner]
    group params[:group]
    variables params
  end

  # upstart script
  template params[:name] do
    source "puma.conf.erb"
    path "/etc/init/#{params[:name]}.conf"
    cookbook "opsworks-puma"
    mode "0755"
    owner params[:owner]
    group params[:group]
    variables params
  end

end
