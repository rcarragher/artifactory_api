Gem::Specification.new do |s|
  s.name        = 'artifactory_api'
  s.version     = '0.0.7'
  s.date        = '2013-08-17'
  s.summary     = "artfifactory_api consumes the artifactory rest api to do useful stuff"
  s.description = "A client to the artifactory rest api"
  s.authors     = ["Rick Carragher"]
  s.email       = 'rcarragher@gmail.com'
  s.files       =  ["lib/artifactory_api/builds.rb", "lib/artifactory_api/client.rb", 
                    "lib/artifactory_api/exceptions.rb", "lib/artifactory_api/version.rb", 
                    "lib/artifactory_api.rb", "Gemfile", "Gemfile.lock", "Rakefile", "README.md",
                     "spec/builds_spec.rb", "spec/client_spec.rb", "spec/spec_helper.rb"] 
  s.homepage    =
    'http://rubygems.org/gems/artifactory_api'
end