module SitesHelper
  
  def show_page_rank(page_rank)
    (page_rank.to_i >= 0)? page_rank : "N/A"
  end
  
  def show_load_time(load_time)
    if load_time < 0
      "error loading"
    else
      "%.2f seconds" % load_time
    end
  end
end
