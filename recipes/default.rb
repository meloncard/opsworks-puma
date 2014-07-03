require 'json'

ruby_block "ensure only our puma version is installed by deinstalling any other version" do
  block do
    ensure_only_gem_version('puma', node[:puma][:version])
  end
end

include_recipe "nginx"

Chef::Log.warn("Deploy JSON: #{node[:deploy].to_json}")

node[:deploy].each do |application, deploy|
  
  next unless deploy[:puma] # only run puma apps
  next unless deploy[:layers].nil? || ( deploy[:layers] & node[:opsworks][:instance][:layers] ).count > 0 # allow layer-by-layer restrictions (custom json can include a "layers" key indicting which layers should deploy this app)

  Chef::Log.warn("Application: #{application}, Deploy: #{deploy.to_json}")

  # Ensure we have user configured correctly
  opsworks_deploy_user do
    deploy_data deploy
  end

  # Configure puma
  puma_config application do
    directory deploy[:deploy_to]
    environment deploy[:rails_env]
    logrotate deploy[:puma][:logrotate] if deploy[:puma][:logrotate]
    thread_min deploy[:puma][:thread_min] if deploy[:puma][:thread_min]
    thread_max deploy[:puma][:thread_max] if deploy[:puma][:thread_max]
    workers deploy[:puma][:workers] if deploy[:puma][:workers]
    worker_timeout deploy[:puma][:worker_timeout] if deploy[:puma][:worker_timeout]
  end
end

