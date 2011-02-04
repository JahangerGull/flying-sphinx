class FlyingSphinx::Tunnel
  def self.connect(configuration, &block)
    tunnel = new configuration
    tunnel.open do |session|
      session.loop &block
    end
  end
  
  def initialize(configuration)
    @configuration = configuration
  end
  
  def open(&block)
    Net::SSH.start(@configuration.host, 'sphinx', ssh_options) do |session|
      session.forward.remote(
        db_port, db_host, @configuration.database_port, '0.0.0.0'
      )
      session.loop { !remote_exists?(session) }
      
      yield session
    end
  end
    
  private
  
  def db_host
    db_config['host']
  end
  
  def db_port
    db_config['port']
  end
  
  def db_config
    @db_config ||= YAML.load(File.open(Rails.root.join("heroku_env.yml")))['db']
  end
  
  def ssh_options
    {:keys => [
      File.expand_path('../../../keys/key', __FILE__)
    ]}
  end
  
  def remote_exists?(session)
    session.forward.active_remotes.include?(
      [@configuration.database_port, '0.0.0.0']
    )
  end
end
