# == Schema Information
# Schema version: 20081021084157
#
# Table name: stats
#
#  id         :integer(4)      not null, primary key
#  model_id   :integer(4)
#  model_type :string(255)
#  stat_type  :integer(4)      not null
#  day        :integer(4)
#  month      :integer(4)
#  year       :integer(4)
#  data       :text
#  created_at :datetime
#  updated_at :datetime
#

class Stat < ActiveRecord::Base
  TYPE = StatsForAll::CONFIGURATION["types"]
  
  StatsForAll::CONFIGURATION["model"].each do | model |
    self.class_eval("belongs_to :#{model.downcase.singularize} , :polymorphic => true")
  end
    
  named_scope :is_like, lambda { |*args| {:conditions => { :stat_type => args.first.stat_type, 
                                                           :model_type => args.first.model_type,
                                                           :model_id => args.first.model_id } } }

  named_scope :stats_type, lambda { |*args| {:conditions => {:stat_type => args.first } } } 
    
  named_scope :today, :conditions => { :day => Time.now.day,
                                       :month => Time.now.month,
                                       :year => Time.now.year }
                                      
  named_scope :day, lambda { |*args| {:conditions => { :day => (args.first or 0) } } }
  named_scope :month, lambda { |*args| {:conditions => { :month => (args.first or 0)} } }
  named_scope :year, lambda { |*args| {:conditions => { :year => (args.first or Time.now.year ) } } }
  
  
  named_scope :month_only, lambda { |*args| {:conditions => { :month => (args.first or Time.now.month),
                                                              :day => 0,
                                                              :year => Time.now.year } } }
                                                                                                                        
  named_scope :year_only, lambda { |*args| {:conditions => { :year => (args.first or Time.now.year),
                                                             :day => 0,
                                                             :month => 0 } } }
  
  def to_a
    Marshal.load(data)
  end
  
  def model
    klass = self.model_type.capitalize.constantize
    klass.find(self.model_id)
  end

  def update_all_stats
    (update_day and update_month) ? true : false
  end
  
  def update_day
    stat = Stat.month_only.is_like(self).first 
    stat ||= Stat.create(:stat_type => self.stat_type, :model_type => self.model_type, :model_id => self.model_id,
                         :data => Marshal.dump(Array.new(Time.now.end_of_month.day,0)),
                         :day=>0 )
    stat_array = stat.to_a    
    stat_array[self.day-1] = self.to_a.sum 
    stat.data = Marshal.dump(stat_array)
    
    stat.save ? stat.to_a : false
  end

  def update_month
    stat = Stat.year_only.is_like(self).first 
    stat ||=  Stat.create(:stat_type => self.stat_type, :model_type => self.model_type, :model_id => self.model_id,
                          :data => Marshal.dump(Array.new(12,0)),
                          :day=>0 , :month => 0 )
    stat_array = stat.to_a    
    stat_array[self.month-1] = Stat.month_only.is_like(self).first.to_a.sum
    stat.data = Marshal.dump(stat_array)
    
    stat.save ? stat.to_a : false
  end

  after_create :initializer  
  protected      
  def initializer
    self.data=Marshal.dump(Array.new(24,0)) if self.data.nil?
    self.day=Time.now.day if self.day.nil?
    self.month=Time.now.month if self.month.nil?
    self.year=Time.now.year if self.year.nil?
    self.save!    
  end
end
