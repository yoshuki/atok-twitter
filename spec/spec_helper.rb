$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'spec'
require 'spec/autorun'

Spec::Runner.configure do |config|
  config.before(:all) do
    @extra_root  = File.join(File.dirname(__FILE__), '..', 'extra')
    @extra_files = [
      File.join('log', 'README'),
      'README',
      'speak_server.rb',
      'start_servers.bat',
      'tuple_server.rb',
    ]
    @plugin_root = File.join(File.dirname(__FILE__), '..', 'plugin')
    @plugin_files = [
      File.join('DATA', 'twitter.xml'),
      File.join('DATA', 'twitter_wo_login_info.rb'),
      'ATOK_PLUGIN_MESSAGE.DLL',
      'SETUP.EXE',
      'SETUPINFO.XML'
    ]
  end
end
