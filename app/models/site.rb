class Site
  include MongoMapper::Document
  
  key :name, String, :unique => true, :required => true
  key :page_rank, Integer
  key :load_time, Float
  key :updated_at, Time
  key :reference, Boolean
  
  before_save :get_page_rank, :get_page_load_time, :update_timestamp, :set_reference, :strip_name
  
  def strip_name
    self.name = self.name.strip
  end
  
  def set_reference
    self.reference = false if self.reference.nil?
  end
  
  def update_timestamp
    self.updated_at = Time.now
  end
  
  def get_page_rank()
    self.page_rank = PageRankr.ranks(self.name)[:google]
  end
  
  def get_page_load_time(timeout=120)
    url = self.name
    url = "http://#{url}" if url !~ /^https?:\/\//
    start_time = Time.now
    `wget -E -H -p --delete-after -q -T #{timeout} #{url}`
    raise 'wget errror' unless $?.success?
    self.load_time = Time.now - start_time
  rescue 
    self.load_time = -1
  end
  
end