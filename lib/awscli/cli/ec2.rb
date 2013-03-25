module AwsCli
  module CLI
    require 'awscli/cli'
    require 'awscli/connection'
    require 'awscli/ec2'
    class Ec2 < Thor

      class_option :region, :type => :string, :desc => "region to connect to", :default => 'us-west-1'

      private

      def create_ec2_object
        puts "ec2 Establishing Connetion..."
        $ec2_conn = Awscli::Connection.new.request_ec2
        puts $ec2_conn
        puts "ec2 Establishing Connetion... OK"
        @ec2 = Awscli::EC2::EC2.new($ec2_conn)
      end

      AwsCli::Cli.register AwsCli::CLI::Ec2, :ec2, 'ec2 [COMMAND]', 'Elastic Cloud Compute Interface'
    end
  end
end