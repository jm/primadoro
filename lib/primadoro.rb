module Primadoro
  class <<self
    def run    
      # TODO: Make each of these configurable
      @views = [
        Views::Tunes.new,
        Views::Growl.new,
        Views::Sound.new
      ]
      
      @actions = {:break_time => 5, :pomodoro => 25}
      
      while(true)
        # TODO: Add action hooks later
        action(:pomodoro)
        action(:break_time)
      end
    end
  
    def action(action_taken)
      puts "#{action_taken} at #{Time.now.strftime('%D %T')}"
            
      @views.each {|v| v.send(action_taken)}
      sleep(@actions[action_taken] * 60)
    end
  end
  
  module Views
    class Base
      # TODO: Add intermittent update displays for timers etc.
      def display?(runner); false; end
    
      def display!
        raise "Implement the display! method on #{self.class.name} if you're going to make me display, fool!"
      end

      def pomodoro; end
      
      def break_time; end
    end
    
    class Growl < Base
      begin
        require 'ruby-growl'

        def initialize
          @growler = ::Growl.new "localhost", "Primadoro", ["pomodoro", "break time"]
        end  
      
        def pomodoro
          @growler.notify "pomodoro", "Pomodoro time!", "Get your work on..." rescue puts "! Growl not configured properly (make sure you allow network connections)"
        end
      
        def break_time
          @growler.notify "break time", "Break time!", "Get your break on..." rescue puts "! Growl not configured properly (make sure you allow network connections)"
        end
      rescue Exception
        require 'rubygems' and retry 
        
        puts "! Install ruby-growl for growl support (no Windows etc. support yet)"
      end
    end
    
    class Sound < Base
      def play(file)
        if RUBY_PLATFORM =~ /darwin/
          `afplay #{file}`
        elsif RUBY_PLATFORM =~ /mswin32/
          `sndrec32 /play /close "#{file}"`
        else
          `play #{file}`
        end
      end
      
      def pomodoro
        play(File.join(File.dirname(__FILE__), "..", "resources", "windup.wav"))
      end
      
      def break_time
        play(File.join(File.dirname(__FILE__), "..", "resources", "bell.mp3"))        
      end
    end
    
    class Tunes < Base
      begin
        require 'rbosa'
        
        def initialize
          @app = OSA.app('iTunes')
        end

        def pomodoro
          @app.play rescue puts '! iTunes not running'
        end

        def break_time
          @app.pause rescue puts '! iTunes not running'
        end
      rescue Exception
        require 'rubygems' and retry 
        
        puts "! To use the iTunes integration, you need rubyosa installed! (no Windows etc. support yet)"
      end
    end
  end
end