module SidekiqAlive
  class Worker
    include Sidekiq::Worker
    sidekiq_options retry: false

    def perform(alive_key)
      if(alive_key == SidekiqAlive.liveness_key)
        write_living_probe
        self.class.perform_in(SidekiqAlive.time_to_live / 2, SidekiqAlive.liveness_key)
      else
        self.class.perform_async(alive_key)
      end
    end

    def write_living_probe
      # Write liveness probe
      SidekiqAlive.store_alive_key
      # after callbacks
      SidekiqAlive.callback.call()
    end
  end
end
