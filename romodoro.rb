#!/usr/bin/env ruby
require 'bundler/setup'
require 'colorize'

class Romodoro
  WORK_TIME = 25 * 60 # time of a work sprint in seconds
  SHORT_BREAK = 5 * 60 # shor break in seconds
  LONG_BREAK = 15 * 60 # long break in seconds
  REPETITIONS = 4 # repetitions before a long break

  ALERTER_PATH = './bin/alerter'.freeze
  SOUND_PATH = './bin/analog-watch-alarm_daniel-simion.mp3'.freeze
  attr_reader :continue

  def initialize
    start_pomodoro
  end

  def start_pomodoro
    loop do
      REPETITIONS.times do |i|
        start_task(WORK_TIME, 'Work!', :yellow)
        if i == REPETITIONS - 1
          start_task(LONG_BREAK, 'Long Break', :blue)
        else
          start_task(SHORT_BREAK, 'Short Break', :green)
        end
      end
    end
  end

  def start_task(seconds, message, color)
    notify(message)
    puts "#{message} #{seconds / 60} minutes.".colorize(color)
    puts ''
    seconds.times do |i|
      print "#{seconds - i} seconds left #{((i.to_f / seconds.to_f) * 100).to_i}% \r"
      sleep(1)
    end
  end

  def notify(message)
    IO.popen("afplay #{SOUND_PATH}")
    system("#{ALERTER_PATH} -title Romodoro -message \"#{message}\" -closeLabel Start -actions Start")
    IO.popen('killall afplay')
  end
end

Romodoro.new
