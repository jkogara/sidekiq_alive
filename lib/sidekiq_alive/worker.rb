module SidekiqAlive
  class Worker
    include Sidekiq::Worker
    sidekiq_options retry: 20
    sidekiq_retry_in { |count| 1 }

    def perform(alive_key)
      if(alive_key == SidekiqAlive.liveness_key)
        write_living_probe
        self.class.perform_in(SidekiqAlive.time_to_live / 2, SidekiqAlive.liveness_key)
      else
        raise StandardError, "Not the correct host, will retry"
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
