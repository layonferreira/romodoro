#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'colorize'
require 'open3'

class Romodoro
  WORK_TIME = 25 * 60 # time of a work sprint in seconds
  SHORT_BREAK = 5 * 60 # short break in seconds
  LONG_BREAK = 15 * 60 # long break in seconds
  SNOOZE_BREAK = 5 * 60 # snooze break in seconds

  REPETITIONS = 4 # repetitions before a long break
  ALERTER_PATH = './bin/alerter'
  SOUND_PATH = './bin/analog-watch-alarm_daniel-simion.mp3'
  SNOOZE_COMMAND = 'Snooze'
  START_COMMAND = 'Start'
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
    start_timer(seconds, message, color)
  end

  def notify(message)
    response = nil
    while response != START_COMMAND
      pid = start_alarm
      response = notification_command(message)
      kill_alarm(pid)
      start_timer(SNOOZE_BREAK, 'Snooze', :red) if response == SNOOZE_COMMAND
    end
  end

  private

  def start_alarm
    fork do
      exec "while :; do afplay #{SOUND_PATH}; done"
    end
  end

  def kill_alarm(pid)
    Process.kill('TERM', pid)
    IO.popen('killall afplay')
  end

  def start_timer(seconds, message, color)
    puts "#{message} #{seconds / 60} minutes.".colorize(color)
    puts ''
    seconds.times do |i|
      print "#{seconds - i} seconds left #{((i.to_f / seconds.to_f) * 100).to_i}% \r"
      sleep(1)
    end
  end

  def notification_command(message)
    command = "#{ALERTER_PATH} -title Romodoro -message \"#{message}\" " \
                "-closeLabel #{SNOOZE_COMMAND} -actions #{START_COMMAND}"
    response = nil
    ::Open3.popen3(command) do |_stdin, stdout, _stderr, _wait_thr|
      response = stdout.read
    end
    response
  end
end

Romodoro.new
