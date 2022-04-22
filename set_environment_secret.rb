require "rbnacl"
require "base64"
require "faraday"
require "faraday/net_http"

my_secret = ""
my_secret_name = ""
my_organization = "mlibrary"
my_repo = ""
my_environment = ""

Faraday.default_adapter = :net_http

conn = Faraday.new(
  url: "https://api.github.com",
  headers: {
    "Accept" => "application/vnd.github.v3+json",
    "Authorization" => "token #{ENV.fetch("GITHUB_PAT")}"
  }
) do |f|
  f.request :json
  f.response :json
end

repo_resp = conn.get("/repos/#{my_organization}/#{my_repo}")

response = conn.get("/repositories/#{repo_resp.body["id"]}/environments/#{my_environment}/secrets/public-key")

public_key_from_github = Base64.decode64(response.body["key"])
public_key = RbNaCl::PublicKey.new(public_key_from_github)

box = RbNaCl::Boxes::Sealed.from_public_key(public_key)
encrypted_secret = box.encrypt(my_secret)

secret_string = Base64.strict_encode64(encrypted_secret)

body = {
  encrypted_value: secret_string,
  key_id: response.body["key_id"]
}
new_response = conn.put("/repositories/#{repo_resp.body["id"]}/environments/#{my_environment}/secrets/#{my_secret_name}", body)
