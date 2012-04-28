require 'librarian/chef/cli'

module TestKitchen
  module Runner
    class Base

      attr_accessor :platform
      attr_accessor :configuration
      attr_accessor :env

      def initialize(env, options={})
        @env = env
        @platform = options[:platform]
        @configuration = options[:configuration]
      end

      def provision
        assemble_cookbooks!
      end

      def test
        raise NotImplementedError
      end

      def status
        raise NotImplementedError
      end

      def destroy
        raise NotImplementedError
      end

      def ssh
        raise NotImplementedError
      end

      def self.inherited(subclass)
        key = subclass.to_s.split('::').last.downcase
        Runner.targets[key] = subclass
      end

      protected

      def assemble_cookbooks!
        # dump out a meta Cheffile
        env.create_tmp_file('Cheffile',
            IO.read(TestKitchen.source_root.join('config', 'Cheffile')))

        env.ui.info("Assembling required cookbooks at [#{env.tmp_path.join('cookbooks')}].", :yellow)

        # The following is a programatic version of `librarian-chef install`
        Librarian::Action::Clean.new(librarian_env).run
        Librarian::Action::Resolve.new(librarian_env).run
        Librarian::Action::Install.new(librarian_env).run
      end

      def librarian_env
        @librarian_env ||= Librarian::Chef::Environment.new(:project_path => env.tmp_path)
      end
    end

    def self.targets
      @@targets ||= {}
    end
  end
end
