require 'spec_helper'

describe ArtifactoryApi::Client::Artifacts do
  before do
    #setup mocks
    logger = Logger.new("test_log.log")
    @client = double("client")
    @client.stub(:logger) {logger}
    @artifacts = ArtifactoryApi::Client::Artifacts.new @client
  end

  it "should call the artifacts endpoint given a repo key and a path" do
    response = double("response")
    response.stub(:body) { "fred" }

    @client.should_receive(:api_get_request).with("/myrepo/my/path/to/file.jar",true).and_return(response)
    file = @artifacts.retrieve_artifact "myrepo", "/my/path/to/file.jar"
    expect(file).to eq("fred")
  end

  it "should deploy an artifact to the right place" do
    the_response = {
                "uri" => "http://localhost:8080/artifactory/libs-release-local/my/jar/1.0/jar-1.0.jar",
        "downloadUri" => "http://localhost:8080/artifactory/libs-release-local/my/jar/1.0/jar-1.0.jar",
               "repo" => "libs-release-local",
               "path" => "/my/jar/1.0/jar-1.0.jar"}
    
    the_file = "some file"
    @client.should_receive(:api_put_request).with("/libs-release-local/my/jar/1.0/jar-1.0.jar",the_file).and_return(the_response)

    response = @artifacts.deploy_artifact("libs-release-local","/my/jar/1.0/jar-1.0.jar",the_file)
    expect(response["repo"]).to eq("libs-release-local")
  end

  it "should return artifact information" do
    the_response = {
      "uri"  => "http://localhost:8080/artifactory/api/storage/libs-release-local/org/acme",
      "repo" => "libs-release-local",
      "path" => "/org/acme",
      "created" => "ISO8601 (yyyy-MM-dd'T'HH:mm:ss.SSSZ)",
      "createdBy" => "userY"
    }

    @client.should_receive(:api_get_request).with("/api/storage/myrepo/myfile").and_return(the_response)

    response = @artifacts.artifact_info "myrepo","/myfile"
    expect(response["uri"]).to eq("http://localhost:8080/artifactory/api/storage/libs-release-local/org/acme")
  end
end