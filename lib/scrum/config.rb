require 'config-parser'

module Scrum
  ROOT = Pathname.new(File.dirname(__FILE__)).join('../..')
end

OPTS = Common::Options.new(Scrum::ROOT.join('config/options.yml').to_s, Scrum::ROOT.join('config/options-local.yml').to_s)
