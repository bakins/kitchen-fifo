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
        server = connection.vms.get(state[:server_id])
        state[:hostname] = server['config']['networks'].first['ip']
        wait_for_sshd(state[:hostname])      ; print "(ssh ready)\n"
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
        @connection ||= begin
                          fifo = ProjectFifo.new(config[:fifo_endpoint], config[:fifo_username], config[:fifo_password])
                          fifo.connect
                          fifo
                        end
      end

      def create_server
        # need to resolve names to uuid's
        # need to add better helpers to fifo client??
        # TODO: we should sort the get_by_name by version???
        connection.vms.create(
                              dataset: connection.datasets.get_by_name(config[:dataset]).last['dataset'],
                              package: connection.packages.get_by_name(config[:package]).first['uuid'],
                              config: {
                                alias: "kitchen-" + Time.now.to_i.to_s,
                                resolvers: [ "8.8.8.8" ],
                                ssh_keys: connection.ssh_keys,
                                networks: {
                                  net0: connection.ipranges.get_by_name(config[:iprange]).first['uuid']
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
        sleep 10
      end

    end
  end
end
