node[:deploy].each do |application, deploy|

  next unless deploy[:puma] # only deploy puma apps
  next unless deploy[:layers].nil? || ( deploy[:layers] & node[:opsworks][:layers] ).count > 0 # allow layer-by-layer restrictions (custom json can include a "layers" key indicting which layers should deploy this app)

  Chef::Log.warn("Application: #{application}, Deploy: #{deploy.to_json}")

  # Create a deploy user
  opsworks_deploy_user do
    deploy_data deploy
  end

  # Create a deploy directory
  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end
  
  # Setup the web application
  puma_web_app do
    application application
    deploy deploy
  end
end
