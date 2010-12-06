class FlyingSphinx::API
  include HTTParty
  
  APIServer = 'http://flying-sphinx.com/heroku'
  
  attr_reader :api_key
  
  def initialize(api_key)
    @api_key = api_key
  end
  
  def get(path, data = {})
    self.class.get "#{APIServer}#{path}", :query => data.merge(api_options)
  end
  
  private
  
  def api_options
    {:api_key => api_key}
  end
end