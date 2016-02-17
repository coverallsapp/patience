require 'dotenv'
Dotenv.load
require 'sinatra'
require 'redis'
require 'json'

configure do
  uri = URI.parse(ENV['REDISCLOUD_URL'] || 'redis://localhost:6379')
  $redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
  $base_badge_url = "https://s3.amazonaws.com/assets.coveralls.io/badges"
end

post '/api/v1/jobs.?:format?' do
  content_type 'application/json'
  JSON.generate(
    message: "Coveralls is currently down for maintenance.",
    url: "https://coveralls.io",
  )
end

[
  '/repos/:service/:repo_user/:repo_name/badge.?:format?',
  '/repos/:repo_user/:repo_name/badge.?:format?',
].each do |path|
  get path do
    service = (params[:service] || 'github').downcase
    repo_user = params[:repo_user].downcase
    repo_name = params[:repo_name].downcase
    format = (params[:format] || 'svg').downcase

    base_redis_key = "coveralls:#{service}:#{repo_user}:#{repo_name}"

    begin
      repo_info = $redis.hgetall("#{base_redis_key}:info")
    rescue Redis::NoSuchKey
    end

    if repo_info.count > 1
      branch = (params[:branch] || repo_info['default_branch'] || '').downcase

      # If the repo is not public, ensure badge_token matches the param
      if repo_info['public'] == 't' || repo_info['badge_token'] == params[:t]
        begin
          coverage = $redis.get("#{base_redis_key}:coverage:#{branch}")
        rescue Redis::NoSuchKey
        end
      end
    end

    redirect "#{$base_badge_url}/coveralls_#{coverage || 'unknown'}.#{format}"
  end
end

get '/*' do
  send_file 'public/index.html'
end
