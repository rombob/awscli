module AwsCli
  module CLI
    module EC2
      require 'awscli/cli/ec2'
      class Instances < Thor

        # default_task :list

        desc "list", "ec2_describe_instances"
        long_desc <<-LONGDESC
         List and describe your instances
         The INSTANCE parameter is the instance ID(s) to describe.
         If unspecified all your instances will be returned.
        LONGDESC
        def list
          puts "Listing Instances"
          create_ec2_object
          puts parent_options #access awscli/cli/ec2.rb class options
          @ec2.list_instances
        end

        #not necessary
        desc "diatt", "ec2_describe_instance_attribute"
        long_desc <<-LONGDESC
          Describes the specified attribute of the specified instance. You can specify only one attribute at a time.
          \x5
          Available Attributes to Request:
          architecture ami_launch_index availability_zone block_device_mapping network_interfaces client_token
          dns_name ebs_optimized groups flavor_id iam_instance_profile image_id instance_initiated_shutdown_behavior
          kernel_id key_name created_at monitoring placement_group platform private_dns_name private_ip_address
          public_ip_address ramdisk_id root_device_name root_device_type security_group_ids state state_reason subnet_id
          tenancy tags user_data vpc_id volumes username
        LONGDESC
        method_option :id, :aliases => "-i", :banner => "INSTANCEID", :type => :string, :desc => "Id of an instance to modify attribute", :required => true
        method_option :attr, :aliases => "-a", :banner => "ATTR", :type => :string, :desc => "Attribute to modify", :required => true
        def diatt
          create_ec2_object
          @ec2.describe_instance_attribute(options[:id], options[:attr])
        end


        desc "miatt", "ec2_modify_instance_attribute"
        long_desc <<-LONGDESC
          Modifies an instance attribute. Only one attribute can be specified per call.
        LONGDESC
        method_option :id,                :aliases => "-i", :banner => "INSTANCEID",      :type => :string, :desc => "Id of an instance to modify attribute",                   :required => true
        method_option :isize,             :aliases => "-t", :banner => "VALUE",           :type => :string, :desc => "Changes the instance type to the specified value."
        method_option :kernel,            :aliases => "-k", :banner => "VALUE",           :type => :string, :desc => "Changes the instance's kernel to the specified value"
        method_option :ramdisk,           :aliases => "-r", :banner => "VALUE",           :type => :string, :desc => "Changes the instance's RAM disk to the specified value"
        method_option :userdata,          :aliases => "-u", :banner => "VALUE",           :type => :string, :desc => "Changes the instance's user data to the specified value"
        method_option :disable_api_term,  :aliases => "-d", :banner => "true|false" ,     :type => :string, :desc => "Changes the instance's DisableApiTermination flag to the specified value. Setting this flag means you can't terminate the instance using the API"
        method_option :inst_shutdown_beh, :aliases => "-s", :banner => "stop|terminate",  :type => :string, :desc => "Changes the instance's InstanceInitiatedShutdownBehavior flag to the specified value."
        method_option :source_dest_check, :aliases => "-c", :banner => "true|false" ,     :type => :string, :desc => "This attribute exists to enable a Network Address Translation (NAT) instance in a VPC to perform NAT. The attribute controls whether source/destination checking is enabled on the instance. A value of true means checking is enabled, and false means checking is disabled"
        method_option :group_id,          :aliases => "-g", :banner => "G1, G2, ..",      :type => :array,  :desc => "This attribute is applicable only to instances running in a VPC. Use this parameter when you want to change the security groups that an instance is in."
        def miatt
          create_ec2_object
          opts = Marshal.load(Marshal.dump(options))  #create a copy of options, as original options hash cannot be modified
          opts.reject!{ |k| k == 'id' } #remove id from opts
          abort "Please pass an attribute by setting respective option" unless opts
          abort "You can only pass one attribute at a time" if opts.size != 1
          opts.each do |k,v|
            puts "calling modify_instance_attribute with: #{options[:id]}, #{k}, #{opts[k]}"
            @ec2.modify_instance_attribute(options[:id], k, opts[k])
          end

        end

        desc "riatt", "ec2_reset_instance_attribute"
        long_desc <<-LONGDESC
          Resets an instance attribute to its initial value. Only one attribute can be specified per call.
        LONGDESC
        def riatt
          puts "Not yet Implemented"
        end

        desc "dins", "ec2_describe_instance_status"
        long_desc <<-LONGDESC
         Describe the status for one or more instances.
         Checks are performed on your instances to determine if they are
         in running order or not. Use this command to see the result of these
         instance checks so that you can take remedial action if possible.

         There are two types of checks performed: INSTANCE and SYSTEM.
         INSTANCE checks examine the health and reachability of the
         application environment. SYSTEM checks examine the health of
         the infrastructure surrounding your instance.
        LONGDESC
        def dins
        end

        desc "import", "ec2_import_instance"
        long_desc <<-LONGDESC
          Create an import instance task to import a virtual machine into EC2
          using meta_data from the given disk image. The volume size for the
          imported disk_image will be calculated automatically, unless specified.
        LONGDESC
        def import
        end

        desc "reboot", "ec2_reboot_instances"
        long_desc <<-LONGDESC
         Reboot selected running instances.
         The INSTANCE parameter is an instance ID to reboot.
        LONGDESC
        def reboot
        end

        desc "create", "ec2_run_instances"
        long_desc <<-LONGDESC
          Launch an instance of a specified AMI.\x5
          Usage Examples:\x5
          awscli ec2 instances create -i 'ami-xxxxxxx' -b '{:DeviceName => '/dev/sdg', :VirtualName => 'ephemeral0'}' -g 'default' -t 'm1.small' -k 'default' --tags=name:testserver
        LONGDESC
        method_option :image_id,             :aliases => "-i", :required => true, :banner => "AMIID", :type => :string, :desc => "Id of machine image to load on instances"
        method_option :availability_zone,    :banner => "ZONE", :type => :string, :desc => "Placement constraint for instances"
        method_option :placement_group,      :banner => "GROUP", :type => :string, :desc => "Name of existing placement group to launch instance into"
        method_option :tenancy,              :banner => "TENANCY", :type => :string, :desc => "Tenancy option in ['dedicated', 'default'], defaults to 'default'"
        method_option :block_device_mapping, :aliases => "-b", :type => :array , :desc => "hashes of device mappings, see help for how to pass values"
        method_option :client_token,         :type => :string, :desc => "unique case-sensitive token for ensuring idempotency"
        method_option :groups,               :aliases => "-g", :banner => "SG1 SG2 SG3",:type => :array, :default => ["default"], :desc => "Name of security group(s) for instances (not supported for VPC). Default: 'default'"
        method_option :flavor_id,            :aliases => "-t",:type => :string, :default => "m1.small", :desc => "Type of instance to boot."
        method_option :kernel_id,            :type => :string, :desc => "Id of kernel with which to launch"
        method_option :key_name,             :aliases => "-k", :required => true, :type => :string, :desc => "Name of a keypair to add to booting instances"
        method_option :monitoring,           :type => :boolean, :default => false, :desc => "Enables monitoring, defaults to false"
        method_option :ramdisk_id,           :type => :string, :desc => "Id of ramdisk with which to launch"
        method_option :subnet_id,            :type => :string, :desc => "VPC option to specify subnet to launch instance into"
        method_option :user_data,            :type => :string, :desc => "Additional data to provide to booting instances"
        method_option :ebs_optimized,        :type => :boolean, :default => false, :desc => "Whether the instance is optimized for EBS I/O"
        method_option :vpc_id,               :type => :string, :desc => "VPC to connect to"
        method_option :tags,                 :type => :hash, :default => {'Name' => "awscli-#{Time.now.to_i}"}, :desc => "Tags to identify server"
        method_option :private_ip_address,   :banner => "IP",:type => :string, :desc => "VPC option to specify ip address within subnet"
        method_option :wait_for,             :aliases => "-w", :type => :boolean, :default => false, :desc => "wait for the server to get created and return public_dns"
        # method_option :min_count, :banner => "MINCOUNT", :type => :numeric, :default => 1, :desc => "Minimum number of instances to launch, If this exceeds the count of available instances, no instances will be launched"
        # method_option :max_count, :banner => "MAXCOUNT", :type => :numeric, :default => 1, :desc => "max_count<~Integer> - Maximum number of instances to launch. If this exceeds the number of available instances, the largest possible number of instances above min_count will be launched instead. Must be between 1 and maximum allowed for you account"
        # method_option :disable_api_termination, :aliases => "-d", :type => :boolean, :default => "false", :desc => "pecifies whether or not to allow termination of the instance from the api, default: false"
        # method_option :instance_initiated_shutdown_behavior,  :banner => "", :type => :string, :desc => "specifies whether volumes are stopped or terminated when instance is shutdown, in [stop, terminate]"
        def create
          create_ec2_object
          @ec2.create_instance options
        end

        desc "start", "ec2_start_instances"
        long_desc <<-LONGDESC
          Start selected running instances.
        LONGDESC
        def start
        end

        desc "stop", "ec2_stop_instances"
        long_desc <<-LONGDESC
          Stop selected running instances.
        LONGDESC
        def stop
        end

        desc "kill", "ec2_terminate_instances"
        long_desc <<-LONGDESC
          Terminate selected running instances
        LONGDESC
        def kill
        end

        private

        def create_ec2_object
          puts "ec2 Establishing Connetion..."
          $ec2_conn = Awscli::Connection.new.request_ec2
          puts $ec2_conn
          puts "ec2 Establishing Connetion... OK"
          @ec2 = Awscli::EC2::EC2.new($ec2_conn)
        end

        AwsCli::CLI::Ec2.register AwsCli::CLI::EC2::Instances, :instances, 'instances [COMMAND]', 'EC2 Instance Management'

      end
    end
  end
end