require 'rubygems'
require 'betabuilder'

BetaBuilder::Tasks.new do |config|
    config.build_dir      = :derived
    config.configuration  = "Release"
    config.workspace_path = "MrTickTock.xcworkspace"
    config.scheme         = "MrTickTock"
    config.app_name       = "MrTickTock"

    config.deploy_using(:testflight) do |tf|
        tf.api_token  = "164361b405de2c47171f857d22aa6124_MTUyNjMzMjAxMS0wOS0xMiAxMjowNToxNC45Njg5MDA"
        tf.team_token = "e9f2e39c8bff04f2885aa45c506b0e3c_MTM3NzgyMjAxMi0wOS0zMCAwODozNzozNS4zNTQ3ODk"
    end
end
