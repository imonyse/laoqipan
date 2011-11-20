# run with: god -c config/god.rb
RAILS_ROOT = File.expand_path("../..", __FILE__)

God.watch do |w|
  w.name = "laoqipan-worker"
  w.interval = 30.seconds
  w.env = {"RAILS_ENV" => "production"}
  w.start = "#{RAILS_ROOT}/script/worker production"
  w.log = "#{RAILS_ROOT}/log/worker.log"
  
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.running = false
    end
  end
  
  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 50.megabytes
      c.times = [3, 5]
    end
    
    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
    end
  end
  
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end

God.watch do |w|
  w.name = 'unicorn-worker'
  w.interval = 30.seconds
  w.env = {"RAILS_ENV" => "production"}
  w.start = "bundle exec unicorn -c #{RAILS_ROOT}/config/unicorn.conf.rb -E production"
  w.log = "#{RAILS_ROOT}/log/unicorn-worker.log"
  
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.running = false
    end
  end
  
  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 100.megabytes
      c.times = [3, 5]
    end
    
    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
    end
  end
  
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end  
end

God.watch do |w|
  w.name = 'juggernaut-worker'
  w.interval = 30.seconds
  w.env = {"RAILS_ENV" => "production"}
  w.start = "juggernaut"
  w.log = "#{RAILS_ROOT}/log/juggernaut-worker.log"
  
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.running = false
    end
  end
  
  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 100.megabytes
      c.times = [3, 5]
    end
    
    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
    end
  end
  
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end  
end
