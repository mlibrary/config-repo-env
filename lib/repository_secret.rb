class RepositorySecret

  def initialize(repository)
    @repository = repository
    @conn = conn

    unless @github_pat = ENV.fetch("GITHUB_PAT")
      raise "You must add a PAT with repo access in the GITHUB_PAT environment variable"
    end
  end

  def add(secret_name, secret_value)
    body = {
      encrypted_value: encrypt_secret(secret_value),
      key_id: key_id
    }
    response = conn.put("/repos/#{repository}/actions/secrets/#{secret_name}", body)
    raise "Response for putting secret failed with #{response.status}" unless response.success?
    puts "Added #{secret_name} for #{repository}"
  end

  private

  attr_reader :repository, :github_pat

  def conn
    @conn ||= Faraday.default_adapter = :net_http
     Faraday.new(
      url: "https://api.github.com",
      headers: {
        "Accept" => "application/vnd.github.v3+json",
        "Authorization" => "token #{github_pat}"
      }
    ) do |f|
      f.request :json
      f.response :json
    end
  end

  def public_key
    @public_key || load_public_key && @public_key
  end

  def key_id
    @key_id || load_public_key && @key_id
  end

  def load_public_key
    response = conn.get("/repos/#{repository}/actions/secrets/public-key")
    raise "Response for public_key failed with #{response.status}" unless response.success?

    public_key_from_github = Base64.decode64(response.body["key"])
    @public_key = RbNaCl::PublicKey.new(public_key_from_github)
    @key_id = response.body["key_id"]
  end


  def encrypt_secret(value)
    box = RbNaCl::Boxes::Sealed.from_public_key(public_key)
    encrypted = box.encrypt(value)
    encoded = Base64.strict_encode64(encrypted)
  end
end


