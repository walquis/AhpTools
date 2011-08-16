require 'test/unit'
require File.expand_path(File.dirname(__FILE__) + '/../lib/cli/set_security')

class OptionTests < Test::Unit::TestCase

	def test_resource_type_option_single
		options = AhpTools::CLI::SetSecurity.new.parse_options( [ '--resource_type', 'agent' ] )
		assert_equal(true, options[:resource_type].is_a?(Array) )
		assert_equal('agent', options[:resource_type][0] )
	end

	def test_name_option_multi
		options = AhpTools::CLI::SetSecurity.new.parse_options( [ '--resource_name', 'machine1,machine2' ] )
		assert_equal(true, options[:resource_name].is_a?(Array) )
		assert_equal(2, options[:resource_name].count )
		assert_equal('machine2', options[:resource_name][1] )
	end

	def test_remove_option_default
		options = AhpTools::CLI::SetSecurity.new.parse_options( [ ] )
		assert_equal(false, options[:remove] )
	end

	def test_remove_option
		options = AhpTools::CLI::SetSecurity.new.parse_options( [ '--remove' ] )
		assert_equal(true, options[:remove] )
	end

	def test_role_option_multi
		options = AhpTools::CLI::SetSecurity.new.parse_options( [ '--role', 'SE,ProductionDeployer' ] )
		assert_equal(true, options[:role].is_a?(Array) )
		assert_equal(2, options[:role].count )
		assert_equal('ProductionDeployer', options[:role][1] )
	end

	def test_action_option_multi
		options = AhpTools::CLI::SetSecurity.new.parse_options( [ '--action', 'read,write,use' ] )
		assert_equal(true, options[:action].is_a?(Array) )
		assert_equal(3, options[:action].count )
		assert_equal('use', options[:action][2] )
	end

	# Showing that you can't set multi-arg options like this...
	def test_action_option_multi_occurrences_dont_work
		options = AhpTools::CLI::SetSecurity.new.parse_options( [ '--action', 'read', '--action', 'write' ] )
		assert_equal(true, options[:action].is_a?(Array) )
		assert_equal(1, options[:action].count )
		assert_equal(false, options[:action][1] == 'write')
	end

end
