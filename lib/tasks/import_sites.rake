namespace :sites do
  desc "Imports sites from AssetTracker"
  task :import => :environment do
    puts "> Importing sites from Asset Tracker ..."

    hosts = `rt list -t asset "Type='Site' AND Status='production'" | awk -F ":" '{print $2}' | awk '{print $1}'`.split
    site_names = Site.all().collect{ |s| s.name }
    
    new_sites = hosts - site_names

    new_sites.each do |site_name|
      next if site_name =~ /gorillanation\.com/ # skip sites with GN domains
      puts "+ Importing #{site_name}"
      Site.new(:name => site_name).save
    end
    
    puts "> Import complete"

  end
end
