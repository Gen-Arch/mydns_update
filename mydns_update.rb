#!/usr/bin/env ruby

require 'net/https'
require 'fileutils'
require 'yaml'

class Mydns

  def update
    data = YAML.load_file(File.join(__dir__, "config.yml"))
    res = http_request(data)
    put_log(res)
  end

  private
  def http_request(data)
    uri = URI.parse("https://ipv4.mydns.jp/login.html")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Get.new(uri.path)
    req.basic_auth data["MID"], data["PWD"]
    http.request(req)
  end

  def put_log(response)
    log = File.join(__dir__, "log")
    FileUtils.mkdir_p(log) unless FileTest.exist?(log)

    File.open("#{log}/request.log", "a") do |f|
      f.puts "=" * 50
      f.puts "status: #{response}"
      f.puts "=" * 50
      f.puts
      f.puts response.body
    end
  end
end

Mydns.new.update if __FILE__ == $0
