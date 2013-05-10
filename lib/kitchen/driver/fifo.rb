require 'project-fifo'

require 'kitchen'

module Kitchen

  module Driver

    class Fifo < Kitchen::Driver::SSHBase

      default_config :fifo_endpoint,      'http://192.168.1.100/api/0.1.0/'
      default_config :fifo_username,      'admin'
      default_config :fifo_password,      'admin'
      default_config :package,            'medium'
      default_config :dataset,            'ubuntu-12.04'
      default_config :iprange,            'default'
      default_config :username,           'root'
      default_config :port,               '22'

      def create(state)
        server = create_server
        state[:server_id] = server["uuid"]

        info("FIFO instance <#{state[:server_id]}> created.")
        wait_for_server(server)
        print "(server ready)"
        state[:hostname] = server['config']['networks'].first['ip']
        wait_for_sshd(state[:hostname])      ; print "(ssh ready)\n"
      rescue Fog::Errors::Error, Excon::Errors::Error => ex
        raise ActionFailed, ex.message
      end

      def destroy(state)
        return if state[:server_id].nil?
        
        server = connection.vms.get(state[:server_id])
        connection.vms.delete(state[:server_id]) unless server.nil?
        info("FIFO instance <#{state[:server_id]}> destroyed.")
        state.delete(:server_id)
        state.delete(:hostname)
      end

      private

      def connection
        fifo = ProjectFifo.new(config[:fifo_endpoint], config[:fifo_username], config[:fifo_password])
        fifo.connect
        fifo
      end

      def create_server
        # need to resolve names to uuid's
        connection.vms.create(
                              dataset: connection.datasets.get_by_name(config[:dataset]).first, 
                              package: connection.datasets.get_by_name(config[:package]).first, 
                              config: { 
                                alias: "kitchen-" + Time.now.to_i.to_s, 
                                resolvers: [ "8.8.8.8" ],
                                ssh_keys: connection.ssh_keys,
                                networks: { 
                                  net0: connection.ipranges.get_by_name(config[:iprange]).first
                                }
                              }
                              )
      end

      
      # add to fifo gem?
      def wait_for_server(server)
        id = server["uuid"]
        while true do
          s = connection.vms.get(id)
          break if s['state'] == "running"
          print "."
          sleep 10
        end
      end
      
    end
  end
end
