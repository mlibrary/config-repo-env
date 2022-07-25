class RepositorySecret

  def initialize(repository, environment = nil)
    @repository = repository
    @environment = environment
    @conn = conn

    unless @github_pat = ENV.fetch("GITHUB_PAT")
      raise "You must add a PAT with repo access in the GITHUB_PAT environment variable"
    end
  end

  def add(secret_name, secret_value)
    create_env
    body = {
      encrypted_value: encrypt_secret(secret_value),
      key_id: key_id
    }
    response = conn.put("#{base_url}/secrets/#{secret_name}", body)
    raise "Response for putting secret failed with #{response.status}" unless response.success?
    puts "Added #{secret_name} for #{repository}" + (environment ? "env #{environment}" : "")
  end

  private

  attr_reader :repository, :repository_id, :github_pat, :base_url, :environment

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

  def repository_id
    return @repository_id if @repository_id
    response = conn.get("/repos/#{repository}")
    raise "Response for getting repository info failed with #{response.status}" unless response.success?
    @repository_id = response.body["id"]
  end

  def base_url
    @base_url ||= "/repos/#{repository}#{environment_path}"
  end

  def environment_path
    if(environment)
      "/environments/#{environment}"
    else
      ""
    end
  end

  def create_env
    return unless environment

    response = conn.put(base_url)
    raise "Response for create env failed with #{response.status}" unless response.success?
  end

  def load_public_key
    response = conn.get("#{base_url}/secrets/public-key")
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
