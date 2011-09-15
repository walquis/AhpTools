$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

$: << File.dirname(__FILE__) + "/ahp_tools"

require 'java'
require 'yaml'
require 'erb'

include Java

Dir[File.join(File.dirname(__FILE__), "..", "..", "jars", "*.jar")].each do |jar|
  require jar
end

require "commands/base"
require "helpers/environment_helper"
require "helpers/job_helper"
require "helpers/script_helper"
require "helpers/repository_helper"
require "helpers/life_cycle_helper"
require "helpers/project_helper"
require "helpers/workflow_helper"
require "helpers/workflow_definition_helper"
require "helpers/build_profile_helper"
require "helpers/file_source_config_helper"
require "helpers/dependency_helper"
require "helpers/resource_helper"
require "helpers/security_helper"
require "helpers/property_helper"

module AhpTools
  VERSION = '0.0.1'
  AHPTOOLS_ENV = ENV["AHPTOOLS_ENV"] || "development"
  AHPTOOLS_CFG = ENV["AHPTOOLS_CFG"] || File.join(File.dirname(__FILE__), "..", "..", "conf", "config.yml")
  CONFIG = YAML.load(ERB.new(IO.read(AHPTOOLS_CFG)).result)[AHPTOOLS_ENV.to_sym]
end
