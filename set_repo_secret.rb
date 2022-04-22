require "rbnacl"
require "base64"
require "faraday"
require "faraday/net_http"

my_secret = ""
my_secret_name = ""
my_organization = "mlibrary"
my_repo = ""

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

response = conn.get("/repos/#{my_organization}/#{my_repo}/actions/secrets/public-key")

public_key_from_github = Base64.decode64(response.body["key"])
public_key = RbNaCl::PublicKey.new(public_key_from_github)

box = RbNaCl::Boxes::Sealed.from_public_key(public_key)
encrypted_secret = box.encrypt(my_secret)

secret_string = Base64.strict_encode64(encrypted_secret)

body = {
  encrypted_value: secret_string,
  key_id: response.body["key_id"]
}
new_response = conn.put("/repos/#{my_organization}/#{my_repo}/actions/secrets/#{my_secret_name}", body)
