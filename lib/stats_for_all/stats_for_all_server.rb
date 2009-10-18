class StatsForAllServer
  def initialize
    @@object_pool = {}
    @@processing = false
    @mutex = Mutex.new     
  end

  def increment(stat_id, hour=Time.now.hour)
    while @@processing; end
    @mutex.synchronize do
      @@object_pool[stat_id] = Array.new(24, 0) unless @@object_pool.include?(stat_id)
      @@object_pool[stat_id][hour] += 1
    end
  end

  def loop_process
    loop do 
      sleep StatsForAll::CONFIGURATION["dump_frequency_in_seconds"]
      save_all
    end
  end

  def save_all                 
    log_dump              
    @@object_pool.each do |key, value|
      begin
        @@object_pool.delete(key) if stat = Stat.find(key) 
        stat.data = Marshal.dump(value.add(stat.to_a))
        stat.save
        stat.update_all_stats
      rescue ActiveRecord::RecordNotFound
         p "The stat id => (key) can't be found"
      end
    end
  end
  
  def final_save_all
    @@processing = true    
    save_all
    @@processing = false
  end      
  
  def connected?
    true
  end

  private
  def log_dump
    puts "#{Time.now} - Dumping all data to the db (#{@@object_pool.size})."
    # puts @@object_pool.to_yaml
    # puts @@object_pool.empty?
  end
end
