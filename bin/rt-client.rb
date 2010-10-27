require 'rubygems'
require 'rest_client'
require 'json'

SERVER_URL = "http://pagerank.gorillanation.com"

puts "> Importing sites from Asset Tracker ..."

# get hosts from RT
hosts = `rt list -t asset "Type='Site' AND Status='production'" | awk -F ":" '{print $2}' | awk '{print $1}'`.split

# get sites from PageRankDashboard
response = RestClient.get "#{SERVER_URL}/sites.json", :content_type => 'application/json', :accept => :json
site_names = JSON.parse(response).collect{|site| site['name'] }

new_sites = hosts - site_names

new_sites.each do |site_name|
  next if site_name =~ /gorillanation\.com/ # skip sites with GN domains
  puts "+ Importing #{site_name}"
  json_string = { :site => { :name => site_name } }.to_json
  RestClient.post "#{SERVER_URL}/sites.json", json_string, :content_type => :json, :accept => :json
end

puts "> Import complete"