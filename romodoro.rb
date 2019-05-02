#!/usr/bin/env ruby
require 'bundler/setup'
require 'colorize'
require 'terminal-notifier-guard'

class Romodoro
  WORK_TIME = 25 * 60 # time of a work sprint in seconds
  SHORT_BREAK = 5 * 60 # shor break in seconds
  LONG_BREAK = 15 * 60 # long break in seconds
  REPETITIONS = 4 # repetitions before a long break

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
        resume_work?
      end
    end
  end

  def resume_work?
    notify('Resume work?')
    puts 'Press any key to resume your work, or  press Ctrl+C to exit'.colorize(:white)
    gets
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
    TerminalNotifier::Guard.notify(message, title: 'Romodoro', group: 'Romodoro')
  end
end

Romodoro.new
