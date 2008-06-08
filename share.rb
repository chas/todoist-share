require 'rubygems'
require 'sinatra'
require 'json'
require 'net/http'
require 'digest/md5'

module ConstantsModule
  # TOKEN is your Todoist API token. Do not share this with anyone.
  TOKEN = "your token here"
  
  # SUPER_SECRET_HASH is used in the URL string just for a bit of the obfuscation
  SUPER_SECRET_HASH = Digest::MD5.hexdigest("do your damn job, erik")
end

include ConstantsModule

get '/' do
  redirect 'http://oit.nd.edu/'

  # just find and show all the scores
  @lists = grab_json("http://todoist.com/API/getProjects?token=#{TOKEN}")
  erb :index
end

get '/list/:id' do

  project_id = params[:id][0..5]
  params_hash = params[:id][6..45]

  unless (params_hash == SUPER_SECRET_HASH) && project_id
    redirect '/'
  end

  @list = grab_json("http://todoist.com/API/getProject?project_id=#{project_id}&token=#{TOKEN}")


  @items = grab_json("http://todoist.com/API/getUncompletedItems?project_id=#{project_id}&token=#{TOKEN}")
  
  erb :list
end

def grab_json(url)
  fetcher = MemFetcher.new
  # the 120 is the length in seconds that it should remain cached in memory
  JSON.parse(fetcher.fetch(url, 120))
end

# From Yahoo!
# TODO: Is this really doing anything? I think not.
class MemFetcher
   def initialize
      # we initialize an empty hash
      @cache = {}
   end
   def fetch(url, max_age=0)
      # if the API URL exists as a key in cache, we just return it
      # we also make sure the data is fresh
      if @cache.has_key? url
         return @cache[url][1] if Time.now-@cache[url][0]<max_age
      end
      # if the URL does not exist in cache or the data is not fresh,
      #  we fetch again and store in cache
      @cache[url] = [Time.now, Net::HTTP.get_response(URI.parse(url)).body]
      @cache[url][1]
   end
end