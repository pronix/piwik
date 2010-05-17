require 'rubygems'
require 'cgi'
require 'activesupport'
require 'rest_client'
require 'xmlsimple'

module Piwik
  class ApiError < StandardError; end
  class MissingConfiguration < ArgumentError; end
  class UnknownSite < ArgumentError; end
  class UnknownUser < ArgumentError; end

  class Base
    @@template  = <<-EOF
# piwik.yml
#
# Please fill in fields like this:
#
#  piwik_url: http://your.piwik.site
#  auth_token: secret
#
development:
  piwik_url:
  auth_tokien:

production:
  piwik_url:
  auth_tokien:

test: &TEST
  piwik_url:
  auth_tokien:

cucumber:
  <<: *TEST

EOF

    private
    # Checks for the config, creates it if not found
    # Поменял файл загрузки конфига на RAILS_ROOT/config/piwik.yml
      def self.load_config_from_file
        config = {}
        if  File.exist?(File.join(RAILS_ROOT, 'config', 'piwik.yml'))
          temp_config = YAML.load(File.read(File.join(RAILS_ROOT, 'config', 'piwik.yml')))[Rails.env]
        else
          open(File.join(RAILS_ROOT, 'config', 'piwik.yml'),'w') { |f| f.puts @@template }
          temp_config = YAML::load(@@template)
        end
        temp_config.each { |k,v| config[k.to_sym] = v } if temp_config
        if config[:piwik_url] == nil || config[:auth_token] == nil
          raise MissingConfiguration, "Please edit config/piwik.yml to include your piwik url and auth_key"
        end
        config
      end
  end
end
