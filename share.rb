require 'rubygems'
require 'sinatra'
require 'json'
require 'rio'
require 'net/http'
require 'digest/md5'


TOKEN = "fc096ab6f674d9bf61f2879e5c620c16e1c3441b"
SUPER_SECRET_HASH = Digest::MD5.hexdigest("do your damn job, erik")

get '/' do
  # redirect 'http://oit.nd.edu/'
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

  JSON.parse(fetcher.fetch(url, 120))
end


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