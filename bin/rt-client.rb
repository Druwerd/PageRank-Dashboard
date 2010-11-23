require 'rubygems'
require 'rest_client'
require 'json'

SERVER_URL = "http://pagerank.gorillanation.com"

puts "> Syncing with sites from Asset Tracker ..."

# get hosts from RT
hosts = `rt list -t asset "Type='Site' AND Status='production'" | awk -F ":" '{print $2}' | awk '{print $1}'`.split

# get sites from PageRankDashboard and hash them by name
site_hash = {}
response = RestClient.get "#{SERVER_URL}/sites.json", :content_type => 'application/json', :accept => :json
JSON.parse(response).map{|site_data| site_hash[site_data['name']] = site_data}
site_names = site_hash.keys

new_sites = hosts - site_names
decomissioned_sites = site_names - hosts

# add new sites from RT to page rank
new_sites.each do |site_name|
  next if site_name =~ /gorillanation\.com/ # skip sites with GN domains
  print "+ Importing #{site_name}..."
  json_string = { :site => { :name => site_name } }.to_json
  begin
    RestClient.post "#{SERVER_URL}/sites.json", json_string, :content_type => :json, :accept => :json
    puts "OK"
  rescue => e
    puts "ERROR"
  end
end

# remove decomissioned sites
decomissioned_sites.each do |site_name|
  print "- Removing #{site_name}..."
  site_id = site_hash[site_name]['id']
  begin
    RestClient.delete "#{SERVER_URL}/sites/#{site_id}.json", :content_type => :json, :accept => :json
    puts "OK"
  rescue => e
    puts "ERROR"
  end
end

puts "> Sync complete"